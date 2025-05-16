-- Implementing partitioning on the Booking table based on start_date
-- This script assumes we're using SQL Server which supports range partitioning

-- Step 1: Create a partition function that defines how to divide the data
-- We'll partition by quarters (3-month periods) which works well for booking data
CREATE PARTITION FUNCTION BookingDateRangePF (DATE)
AS RANGE RIGHT FOR VALUES (
    '2024-01-01', -- Q1 2024
    '2024-04-01', -- Q2 2024
    '2024-07-01', -- Q3 2024
    '2024-10-01', -- Q4 2024
    '2025-01-01', -- Q1 2025
    '2025-04-01', -- Q2 2025
    '2025-07-01', -- Q3 2025
    '2025-10-01'  -- Q4 2025
);

-- Step 2: Create a partition scheme that maps partitions to filegroups
-- This assumes you've created filegroups already (PRIMARY is the default filegroup)
CREATE PARTITION SCHEME BookingDateRangePS
AS PARTITION BookingDateRangePF
TO (
    [PRIMARY], -- Bookings before 2024-01-01
    [PRIMARY], -- Q1 2024
    [PRIMARY], -- Q2 2024
    [PRIMARY], -- Q3 2024
    [PRIMARY], -- Q4 2024
    [PRIMARY], -- Q1 2025
    [PRIMARY], -- Q2 2025
    [PRIMARY], -- Q3 2025
    [PRIMARY]  -- Q4 2025 and beyond
);
-- Note: In production, you would typically use separate filegroups for each partition
-- Example: TO ([FG_Archive], [FG_2024_Q1], [FG_2024_Q2], etc.)

-- Step 3: Create a new partitioned Booking table
-- First, we'll create the new table structure
CREATE TABLE [Booking_Partitioned] (
    [booking_id] UNIQUEIDENTIFIER PRIMARY KEY,
    [property_id] UNIQUEIDENTIFIER NOT NULL,
    [user_id] UNIQUEIDENTIFIER NOT NULL,
    [start_date] DATE NOT NULL,
    [end_date] DATE NOT NULL,
    [total_price] DECIMAL(10, 2) NOT NULL,
    [status] VARCHAR(20) NOT NULL,
    [created_at] DATETIME NOT NULL
) ON BookingDateRangePS(start_date);

-- Step 4: Create additional indexes on the partitioned table
-- Secondary indexes should also be aligned with the partition scheme
CREATE INDEX IX_Booking_Partitioned_UserID ON [Booking_Partitioned]([user_id])
ON BookingDateRangePS(start_date);

CREATE INDEX IX_Booking_Partitioned_PropertyID ON [Booking_Partitioned]([property_id])
ON BookingDateRangePS(start_date);

CREATE INDEX IX_Booking_Partitioned_Status ON [Booking_Partitioned]([status])
ON BookingDateRangePS(start_date);

-- Step 5: Migrate data from the old table to the new partitioned table
INSERT INTO [Booking_Partitioned] (
    [booking_id],
    [property_id],
    [user_id],
    [start_date],
    [end_date],
    [total_price],
    [status],
    [created_at]
)
SELECT 
    [booking_id],
    [property_id],
    [user_id],
    [start_date],
    [end_date],
    [total_price],
    [status],
    [created_at]
FROM [Booking];

-- Step 6: Rename tables to complete the transition
-- First, rename the old table as a backup
EXEC sp_rename 'Booking', 'Booking_Old';

-- Then, rename the new partitioned table to the original name
EXEC sp_rename 'Booking_Partitioned', 'Booking';

-- Step 7: Set up foreign key constraints on the new table
-- Assuming we have foreign keys to Property and User tables
ALTER TABLE [Booking] 
ADD CONSTRAINT FK_Booking_Property 
FOREIGN KEY ([property_id]) REFERENCES [Property]([property_id]);

ALTER TABLE [Booking] 
ADD CONSTRAINT FK_Booking_User 
FOREIGN KEY ([user_id]) REFERENCES [User]([user_id]);

-- Step 8: Add a comment to document the partitioning scheme
EXEC sp_addextendedproperty
    @name = N'Partitioning_Info',
    @value = N'Table is partitioned by start_date on a quarterly basis',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'Booking';

-- Step 9: Optional - Set up partition maintenance job
-- In a real system, you would set up a job to:
-- 1. Create new partitions for future dates
-- 2. Archive or remove old partitions
-- 3. Rebuild indexes on active partitions

-- Example query to show data distribution across partitions
-- This helps verify the partitioning worked correctly
SELECT 
    p.partition_number,
    p.rows,
    CONVERT(DATE, prv.value) AS boundary_value,
    fg.name AS filegroup_name
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_range_values prv ON ps.function_id = prv.function_id 
    AND p.partition_number = prv.boundary_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
JOIN sys.filegroups fg ON p.partition_number = fg.data_space_id
WHERE i.object_id = OBJECT_ID('Booking') AND i.index_id = 1;

-- Implementing partitioning on the Booking table based on start_date
-- This script assumes we're using SQL Server which supports range partitioning

-- Step 1: Create a partition function that defines how to divide the data
-- We'll partition by quarters (3-month periods) which works well for booking data
CREATE PARTITION FUNCTION BookingDateRangePF (DATE)
AS RANGE RIGHT FOR VALUES (
    '2024-01-01', -- Q1 2024
    '2024-04-01', -- Q2 2024
    '2024-07-01', -- Q3 2024
    '2024-10-01', -- Q4 2024
    '2025-01-01', -- Q1 2025
    '2025-04-01', -- Q2 2025
    '2025-07-01', -- Q3 2025
    '2025-10-01'  -- Q4 2025
);

-- Step 2: Create a partition scheme that maps partitions to filegroups
-- This assumes you've created filegroups already (PRIMARY is the default filegroup)
CREATE PARTITION SCHEME BookingDateRangePS
AS PARTITION BookingDateRangePF
TO (
    [PRIMARY], -- Bookings before 2024-01-01
    [PRIMARY], -- Q1 2024
    [PRIMARY], -- Q2 2024
    [PRIMARY], -- Q3 2024
    [PRIMARY], -- Q4 2024
    [PRIMARY], -- Q1 2025
    [PRIMARY], -- Q2 2025
    [PRIMARY], -- Q3 2025
    [PRIMARY]  -- Q4 2025 and beyond
);
-- Note: In production, you would typically use separate filegroups for each partition
-- Example: TO ([FG_Archive], [FG_2024_Q1], [FG_2024_Q2], etc.)

-- Step 3: Create a new partitioned Booking table
-- First, we'll create the new table structure
CREATE TABLE [Booking_Partitioned] (
    [booking_id] UNIQUEIDENTIFIER PRIMARY KEY,
    [property_id] UNIQUEIDENTIFIER NOT NULL,
    [user_id] UNIQUEIDENTIFIER NOT NULL,
    [start_date] DATE NOT NULL,
    [end_date] DATE NOT NULL,
    [total_price] DECIMAL(10, 2) NOT NULL,
    [status] VARCHAR(20) NOT NULL,
    [created_at] DATETIME NOT NULL
) ON BookingDateRangePS(start_date);

-- Step 4: Create additional indexes on the partitioned table
-- Secondary indexes should also be aligned with the partition scheme
CREATE INDEX IX_Booking_Partitioned_UserID ON [Booking_Partitioned]([user_id])
ON BookingDateRangePS(start_date);

CREATE INDEX IX_Booking_Partitioned_PropertyID ON [Booking_Partitioned]([property_id])
ON BookingDateRangePS(start_date);

CREATE INDEX IX_Booking_Partitioned_Status ON [Booking_Partitioned]([status])
ON BookingDateRangePS(start_date);

-- Step 5: Migrate data from the old table to the new partitioned table
INSERT INTO [Booking_Partitioned] (
    [booking_id],
    [property_id],
    [user_id],
    [start_date],
    [end_date],
    [total_price],
    [status],
    [created_at]
)
SELECT 
    [booking_id],
    [property_id],
    [user_id],
    [start_date],
    [end_date],
    [total_price],
    [status],
    [created_at]
FROM [Booking];

-- Step 6: Rename tables to complete the transition
-- First, rename the old table as a backup
EXEC sp_rename 'Booking', 'Booking_Old';

-- Then, rename the new partitioned table to the original name
EXEC sp_rename 'Booking_Partitioned', 'Booking';

-- Step 7: Set up foreign key constraints on the new table
-- Assuming we have foreign keys to Property and User tables
ALTER TABLE [Booking] 
ADD CONSTRAINT FK_Booking_Property 
FOREIGN KEY ([property_id]) REFERENCES [Property]([property_id]);

ALTER TABLE [Booking] 
ADD CONSTRAINT FK_Booking_User 
FOREIGN KEY ([user_id]) REFERENCES [User]([user_id]);

-- Step 8: Add a comment to document the partitioning scheme
EXEC sp_addextendedproperty
    @name = N'Partitioning_Info',
    @value = N'Table is partitioned by start_date on a quarterly basis',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'Booking';

-- Step 9: Optional - Set up partition maintenance job
-- In a real system, you would set up a job to:
-- 1. Create new partitions for future dates
-- 2. Archive or remove old partitions
-- 3. Rebuild indexes on active partitions

-- Example query to show data distribution across partitions
-- This helps verify the partitioning worked correctly
SELECT 
    p.partition_number,
    p.rows,
    CONVERT(DATE, prv.value) AS boundary_value,
    fg.name AS filegroup_name
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_range_values prv ON ps.function_id = prv.function_id 
    AND p.partition_number = prv.boundary_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
JOIN sys.filegroups fg ON p.partition_number = fg.data_space_id
WHERE i.object_id = OBJECT_ID('Booking') AND i.index_id = 1;

-- ============================================================================
-- PERFORMANCE TESTING SECTION
-- ============================================================================

-- Step 10: Performance testing to compare the original table vs. partitioned table
-- Note: Run these tests on a representative dataset for meaningful results

-- First, let's create a stored procedure to help with testing
CREATE PROCEDURE TestQueryPerformance
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartTime DATETIME;
    DECLARE @EndTime DATETIME;
    DECLARE @Duration INT;
    
    -- TEST 1: Range query on original table (non-partitioned)
    -- This simulates finding summer 2024 bookings (Q3)
    PRINT '=== TEST 1: Summer 2024 bookings on non-partitioned table ===';
    SET @StartTime = GETDATE();
    
    SELECT 
        COUNT(*) AS TotalBookings,
        SUM(total_price) AS TotalRevenue,
        AVG(DATEDIFF(DAY, start_date, end_date)) AS AvgStayDuration
    FROM Booking_Old
    WHERE start_date >= '2024-07-01' AND start_date < '2024-10-01'
    OPTION (RECOMPILE, MAXDOP 1); -- Forcing single thread for consistent testing
    
    SET @EndTime = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT 'Non-partitioned query completed in ' + CAST(@Duration AS VARCHAR) + ' ms';
    
    -- TEST 2: Same query on partitioned table
    PRINT '=== TEST 2: Summer 2024 bookings on partitioned table ===';
    SET @StartTime = GETDATE();
    
    SELECT 
        COUNT(*) AS TotalBookings,
        SUM(total_price) AS TotalRevenue,
        AVG(DATEDIFF(DAY, start_date, end_date)) AS AvgStayDuration
    FROM Booking
    WHERE start_date >= '2024-07-01' AND start_date < '2024-10-01'
    OPTION (RECOMPILE, MAXDOP 1); -- Forcing single thread for consistent testing
    
    SET @EndTime = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT 'Partitioned query completed in ' + CAST(@Duration AS VARCHAR) + ' ms';
    
    -- TEST 3: Complex query using multiple conditions on non-partitioned table
    PRINT '=== TEST 3: Complex query on non-partitioned table ===';
    SET @StartTime = GETDATE();
    
    SELECT 
        b.booking_id,
        b.start_date,
        b.end_date,
        b.total_price,
        p.name AS property_name,
        u.first_name + ' ' + u.last_name AS guest_name
    FROM Booking_Old b
    JOIN Property p ON b.property_id = p.property_id
    JOIN [User] u ON b.user_id = u.user_id
    WHERE b.start_date BETWEEN '2024-06-01' AND '2024-08-31'
    AND b.status = 'confirmed'
    AND b.total_price > 1000
    ORDER BY b.start_date
    OPTION (RECOMPILE, MAXDOP 1); -- Forcing single thread for consistent testing
    
    SET @EndTime = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT 'Non-partitioned complex query completed in ' + CAST(@Duration AS VARCHAR) + ' ms';
    
    -- TEST 4: Same complex query on partitioned table
    PRINT '=== TEST 4: Complex query on partitioned table ===';
    SET @StartTime = GETDATE();
    
    SELECT 
        b.booking_id,
        b.start_date,
        b.end_date,
        b.total_price,
        p.name AS property_name,
        u.first_name + ' ' + u.last_name AS guest_name
    FROM Booking b
    JOIN Property p ON b.property_id = p.property_id
    JOIN [User] u ON b.user_id = u.user_id
    WHERE b.start_date BETWEEN '2024-06-01' AND '2024-08-31'
    AND b.status = 'confirmed'
    AND b.total_price > 1000
    ORDER BY b.start_date
    OPTION (RECOMPILE, MAXDOP 1); -- Forcing single thread for consistent testing
    
    SET @EndTime = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT 'Partitioned complex query completed in ' + CAST(@Duration AS VARCHAR) + ' ms';
    
    -- TEST 5: Year-to-date query on non-partitioned table (spans multiple partitions)
    PRINT '=== TEST 5: Year-to-date query on non-partitioned table ===';
    SET @StartTime = GETDATE();
    
    SELECT 
        DATEPART(MONTH, start_date) AS Month,
        COUNT(*) AS TotalBookings,
        SUM(total_price) AS MonthlyRevenue
    FROM Booking_Old
    WHERE start_date >= '2024-01-01' AND start_date < DATEADD(YEAR, 1, '2024-01-01')
    GROUP BY DATEPART(MONTH, start_date)
    ORDER BY Month
    OPTION (RECOMPILE, MAXDOP 1); -- Forcing single thread for consistent testing
    
    SET @EndTime = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT 'Non-partitioned year query completed in ' + CAST(@Duration AS VARCHAR) + ' ms';
    
    -- TEST 6: Year-to-date query on partitioned table
    PRINT '=== TEST 6: Year-to-date query on partitioned table ===';
    SET @StartTime = GETDATE();
    
    SELECT 
        DATEPART(MONTH, start_date) AS Month,
        COUNT(*) AS TotalBookings,
        SUM(total_price) AS MonthlyRevenue
    FROM Booking
    WHERE start_date >= '2024-01-01' AND start_date < DATEADD(YEAR, 1, '2024-01-01')
    GROUP BY DATEPART(MONTH, start_date)
    ORDER BY Month
    OPTION (RECOMPILE, MAXDOP 1); -- Forcing single thread for consistent testing
    
    SET @EndTime = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT 'Partitioned year query completed in ' + CAST(@Duration AS VARCHAR) + ' ms';
    
    -- TEST 7: Check query plan differences
    PRINT '=== TEST 7: Execution plan comparison ===';
    PRINT 'Run the following queries separately with "Include Actual Execution Plan" enabled:';
    PRINT '
    -- Non-partitioned query:
    SELECT * FROM Booking_Old WHERE start_date BETWEEN ''2024-07-01'' AND ''2024-09-30'';
    
    -- Partitioned query:
    SELECT * FROM Booking WHERE start_date BETWEEN ''2024-07-01'' AND ''2024-09-30'';
    ';
    
    -- Expected results in a real large-scale database:
    PRINT '
    EXPECTED RESULTS ON LARGE DATASETS:
    ---------------------------------------------
    Non-partitioned table:
    - Full table scan likely required
    - Higher I/O operations
    - Higher CPU usage
    - Longer execution time
    
    Partitioned table:
    - Partition elimination (only scanning Q3 2024 partition)
    - Reduced I/O operations
    - Lower CPU usage  
    - Significantly faster execution time
    - Estimated 40-90% performance improvement for date-range queries
    ';
END;

-- Execute the performance test
EXEC TestQueryPerformance;

-- Additional performance monitoring queries
-- These help you understand how SQL Server is using the partitions

-- 1. Check partition usage statistics
SELECT
    OBJECT_NAME(p.object_id) AS TableName,
    p.partition_number,
    p.rows,
    stat.used_page_count * 8 AS used_space_KB,
    stat.reserved_page_count * 8 AS reserved_space_KB,
    CASE pf.boundary_value_on_right
        WHEN 1 THEN 'Less than'
        ELSE 'Less than or equal to'
    END AS Comparison,
    CONVERT(VARCHAR(10), CONVERT(DATE, rv.value)) AS BoundaryValue
FROM sys.partitions p
JOIN sys.dm_db_partition_stats stat ON p.partition_id = stat.partition_id
JOIN sys.indexes i ON stat.object_id = i.object_id AND stat.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
LEFT JOIN sys.partition_range_values rv ON pf.function_id = rv.function_id 
    AND p.partition_number = rv.boundary_id
WHERE OBJECT_NAME(p.object_id) = 'Booking'
    AND i.index_id <= 1  -- Clustered index or heap
ORDER BY p.partition_number;

-- 2. Look at I/O statistics for the partitioned vs non-partitioned tables
SELECT
    DB_NAME(database_id) AS DatabaseName,
    OBJECT_NAME(object_id) AS TableName,
    index_id,
    partition_number,
    row_count,
    leaf_insert_count,
    leaf_update_count,
    leaf_delete_count,
    range_scan_count,
    singleton_lookup_count
FROM sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('Booking'), NULL, NULL)
ORDER BY partition_number;

SELECT
    DB_NAME(database_id) AS DatabaseName,
    OBJECT_NAME(object_id) AS TableName,
    index_id,
    partition_number,
    row_count,
    leaf_insert_count,
    leaf_update_count,
    leaf_delete_count,
    range_scan_count,
    singleton_lookup_count
FROM sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('Booking_Old'), NULL, NULL);

-- 3. Memory used by queries against each table
-- Run a workload first, then execute these queries
SELECT 
    t.text, 
    s.last_execution_time,
    s.execution_count,
    s.total_logical_reads / s.execution_count AS avg_logical_reads,
    s.total_elapsed_time / s.execution_count AS avg_elapsed_time_ms
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) t
WHERE t.text LIKE '%Booking%' AND t.text NOT LIKE '%dm_%'
ORDER BY s.last_execution_time DESC;

