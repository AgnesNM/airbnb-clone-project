-- performance.sql
-- Comprehensive query analysis and optimization for Airbnb Clone database

-- =================================================================
-- SECTION 1: INITIAL QUERY (UNOPTIMIZED)
-- =================================================================

-- Initial query that retrieves all bookings with user, property, and payment details
-- This is likely to be an expensive operation without proper indexing
EXPLAIN
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.price_per_night,
    
    host.user_id AS host_id,
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    host.email AS host_email,
    
    pay.payment_id,
    pay.amount,
    pay.payment_date,
    pay.payment_method
FROM 
    Booking b
INNER JOIN 
    [User] u ON b.user_id = u.user_id
INNER JOIN 
    Property p ON b.property_id = p.property_id
INNER JOIN 
    [User] host ON p.host_id = host.user_id
LEFT JOIN 
    Payment pay ON b.booking_id = pay.booking_id
ORDER BY 
    b.start_date DESC;

/*
PERFORMANCE ANALYSIS:

The EXPLAIN output would likely show multiple issues:

1. Multiple table scans or clustered index scans
2. Several nested loops joins
3. High I/O costs due to large data retrieval
4. Sorting operation (for the ORDER BY) performed on a large result set
5. No parallelism in the execution plan

Key inefficiencies:
- Joining 5 tables without leveraging proper indexes
- Selecting all columns from multiple tables
- Sorting a large result set
- No filtering to reduce the result set size
*/

-- =================================================================
-- SECTION 2: OPTIMIZED QUERY
-- =================================================================

-- Create necessary indexes if they don't exist
-- (These would normally be in a separate migration script, but included here for reference)

-- Index for the Booking table to improve JOIN and filtering
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_booking_user_property' AND object_id = OBJECT_ID('Booking'))
BEGIN
    CREATE INDEX idx_booking_user_property ON Booking (user_id, property_id, start_date DESC);
    PRINT 'Created index idx_booking_user_property';
END

-- Index for the Payment table to improve JOIN
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_payment_booking' AND object_id = OBJECT_ID('Payment'))
BEGIN
    CREATE INDEX idx_payment_booking ON Payment (booking_id);
    PRINT 'Created index idx_payment_booking';
END

-- Index for the Property table to improve JOIN and cover common columns
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_property_host_cover' AND object_id = OBJECT_ID('Property'))
BEGIN
    CREATE INDEX idx_property_host_cover ON Property (property_id, host_id) INCLUDE (name, location, price_per_night);
    PRINT 'Created index idx_property_host_cover';
END

-- Now the optimized query with the following improvements:
-- 1. Uses the new indexes
-- 2. Adds a WHERE clause to limit to recent/upcoming bookings (last 3 months, next 6 months)
-- 3. Limits the number of rows returned
-- 4. Uses column list instead of selecting everything
EXPLAIN
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    u.email AS guest_email,
    
    p.property_id,
    p.name AS property_name,
    p.location,
    p.price_per_night,
    
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    
    pay.payment_id,
    pay.amount,
    pay.payment_method
FROM 
    Booking b
INNER JOIN 
    [User] u ON b.user_id = u.user_id
INNER JOIN 
    Property p ON b.property_id = p.property_id
INNER JOIN 
    [User] host ON p.host_id = host.user_id
LEFT JOIN 
    Payment pay ON b.booking_id = pay.booking_id
WHERE 
    b.start_date BETWEEN DATEADD(MONTH, -3, GETDATE()) AND DATEADD(MONTH, 6, GETDATE())
ORDER BY 
    b.start_date DESC
OFFSET 0 ROWS FETCH NEXT 100 ROWS ONLY;

/*
PERFORMANCE IMPROVEMENTS:

The optimized query should show significant improvements:

1. Uses covering indexes to reduce I/O
2. Filters data to only relevant bookings (past 3 months and upcoming 6 months)
3. Limits the result set to 100 rows
4. Reduces column selection to only necessary fields
5. Improves JOIN performance with proper indexes

Expected outcome in EXPLAIN:
- Index seeks instead of table scans
- Reduced I/O operations
- Lower memory requirements
- Faster execution time (potentially 5-10x improvement)
*/

-- =================================================================
-- SECTION 3: FURTHER OPTIMIZATIONS
-- =================================================================

-- If we need to support different query patterns, we can create additional optimized queries:

-- Example 1: Recent bookings for a specific user
EXPLAIN
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    p.name AS property_name,
    p.location,
    
    pay.payment_id,
    pay.payment_method
FROM 
    Booking b
INNER JOIN 
    Property p ON b.property_id = p.property_id
LEFT JOIN 
    Payment pay ON b.booking_id = pay.booking_id
WHERE 
    b.user_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2' -- Specific user
    AND b.start_date > DATEADD(MONTH, -6, GETDATE())
ORDER BY 
    b.start_date DESC;

-- Example 2: Materialized view approach for frequently accessed data
-- This would be useful in a real production system but requires maintenance
/*
CREATE VIEW vw_BookingSummary
WITH SCHEMABINDING
AS
SELECT 
    b.booking_id,
    b.user_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    p.name AS property_name,
    p.location,
    host.user_id AS host_id,
    host.first_name AS host_first_name,
    host.last_name AS host_last_name
FROM 
    dbo.Booking b
INNER JOIN 
    dbo.[User] u ON b.user_id = u.user_id
INNER JOIN 
    dbo.Property p ON b.property_id = p.property_id
INNER JOIN 
    dbo.[User] host ON p.host_id = host.user_id;

CREATE UNIQUE CLUSTERED INDEX idx_vw_BookingSummary 
ON vw_BookingSummary(booking_id);
*/

-- =================================================================
-- SECTION 4: MONITORING AND MEASURING IMPROVEMENTS
-- =================================================================

-- SQL Server specific performance measurement
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Run the original query with statistics
-- [Original query would go here]

-- Run the optimized query with statistics
-- [Optimized query would go here]

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- Expected improvement metrics:
-- 1. Logical reads: Reduced by 60-90%
-- 2. CPU time: Reduced by 50-80%
-- 3. Elapsed time: Reduced by 50-80%
-- 4. Memory grants: Reduced by 30-60%

/*
CONCLUSION:

The optimized approach provides several benefits:

1. Better performance through proper indexing
2. Reduced resource utilization through:
   - Filtering (WHERE clause)
   - Pagination (OFFSET-FETCH)
   - Column selection
3. More maintainable queries through focused result sets
4. Improved scalability as the database grows

Additional best practices implemented:
1. Created covering indexes to minimize lookups
2. Used specific column lists instead of SELECT *
3. Added pagination to handle large result sets
4. Used specific data types and avoided implicit conversions
5. Considered materialized views for frequently accessed data
*/
