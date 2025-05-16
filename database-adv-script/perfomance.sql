-- INITIAL QUERY

-- Query to retrieve all bookings with user details, property details, and payment details
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    
    -- User (Guest) details
    u.user_id AS guest_id,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    u.email AS guest_email,
    u.phone_number AS guest_phone,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location AS property_location,
    p.price_per_night,
    
    -- Host details
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM 
    Booking b
    INNER JOIN [User] u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN [User] h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY 
    b.start_date;

-- Performance Analysis with EXPLAIN
-- The original query may have performance issues:
-- 1. Missing indexes on join columns and filtering columns
-- 2. Retrieving unnecessary columns (like full property descriptions)
-- 3. No limit on results which could affect performance with large datasets

-- First, let's examine the query's execution plan
EXPLAIN
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    
    -- User (Guest) details
    u.user_id AS guest_id,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    u.email AS guest_email,
    u.phone_number AS guest_phone,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location AS property_location,
    p.price_per_night,
    
    -- Host details
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM 
    Booking b
    INNER JOIN [User] u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN [User] h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY 
    b.start_date;

-- Optimized query with recommended index creation statements

-- Create missing indexes to improve join performance
-- Note: Execute these index creations statements separately if they don't exist
-- CREATE INDEX idx_booking_user_id ON Booking(user_id);
-- CREATE INDEX idx_booking_property_id ON Booking(property_id);
-- CREATE INDEX idx_booking_start_date ON Booking(start_date);
-- CREATE INDEX idx_property_host_id ON Property(host_id);
-- CREATE INDEX idx_payment_booking_id ON Payment(booking_id);

-- Optimized query for better performance
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    
    -- User (Guest) details - selected only necessary columns
    u.user_id AS guest_id,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    u.email AS guest_email,
    u.phone_number AS guest_phone,
    
    -- Property details - avoiding long text field when possible
    p.property_id,
    p.name AS property_name,
    p.location AS property_location,
    p.price_per_night,
    
    -- Host details - only essential information
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM 
    Booking b
    -- Using table hints for join order optimization (SQL Server specific)
    INNER JOIN [User] u WITH (INDEX(PK_User)) ON b.user_id = u.user_id
    INNER JOIN Property p WITH (INDEX(PK_Property)) ON b.property_id = p.property_id
    INNER JOIN [User] h WITH (INDEX(PK_User)) ON p.host_id = h.user_id
    LEFT JOIN Payment pay WITH (INDEX(PK_Payment)) ON b.booking_id = pay.booking_id
WHERE
    -- Optional: Add date range filter to limit result set
    -- b.start_date >= '2024-01-01' AND b.start_date <= '2024-12-31'
    1=1 -- Placeholder for WHERE clause that can be uncommented when needed
ORDER BY 
    b.start_date
-- OPTION (OPTIMIZE FOR UNKNOWN) -- SQL Server specific hint to optimize for parameter sniffing issues
