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
