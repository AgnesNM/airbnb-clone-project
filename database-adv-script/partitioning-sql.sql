-- partitioning.sql
-- Implementation of table partitioning for the Booking table in Airbnb Clone database

-- =================================================================
-- SECTION 1: SETUP PARTITION FUNCTION AND SCHEME
-- =================================================================

-- Create a partition function that divides the data by quarter
-- We'll create 12 partitions - one for each quarter from 2023 to 2025
-- This accommodates historical bookings and future bookings
CREATE PARTITION FUNCTION [BookingDateRangePF](DATE)
AS RANGE RIGHT FOR VALUES (
    '2023-01-01', -- Partition 1: before 2023
    '2023-04-01', -- Partition 2: Q1 2023
    '2023-07-01', -- Partition 3: Q2 2023
    '2023-10-01', -- Partition 4: Q3 2023
    '2024-01-01', -- Partition 5: Q4 2023
    '2024-04-01', -- Partition 6: Q1 2024
    '2024-07-01', -- Partition 7: Q2 2024
    '2024-10-01', -- Partition 8: Q3 2024
    '2025-01-01', -- Partition 9: Q4 2024
    '2025-04-01', -- Partition 10: Q1 2025
    '2025-07-01', -- Partition 11: Q2 2025
    '2025-10-01'  -- Partition 12: Q3 2025
                   -- Partition 13: Q4 2025 and beyond
);

-- Create filegroups for each partition (if using separate filegroups)
-- Note: In a production environment, you would typically create separate filegroups
-- for each partition and place them on different storage devices.
-- For simplicity in this example, we'll use the PRIMARY filegroup.

CREATE PARTITION SCHEME [BookingDateRangePS]
AS PARTITION [BookingDateRangePF]
ALL TO ([PRIMARY]);
-- In a real production environment, we might do:
-- TO (fg_booking_archive, fg_booking_2023_q1, fg_booking_2023_q2, ...)

-- =================================================================
-- SECTION 2: CREATE PARTITIONED TABLE
-- =================================================================

-- First, we need to create a new partitioned table, then migrate data
-- We'll create it with a slightly different name, then rename after migration

-- Create the partitioned booking table
CREATE TABLE [Booking_Partitioned] (
    [booking_id] UNIQUEIDENTIFIER NOT NULL,
    [property_id] UNIQUEIDENTIFIER NOT NULL,
    [user_id] UNIQUEIDENTIFIER NOT NULL,
    [start_date] DATE NOT NULL,  -- This is our partitioning column
    [end_date] DATE NOT NULL,
    [total_price] DECIMAL(10, 2) NOT NULL,
    [status] VARCHAR(20) NOT NULL,
    [created_at] DATETIME NOT NULL,
    CONSTRAINT [PK_Booking_Partitioned] PRIMARY KEY CLUSTERED ([booking_id], [start_date])
        ON [BookingDateRangePS]([start_date]), -- Specify the partition scheme
    CONSTRAINT [FK_Booking_Partitioned_Property] FOREIGN KEY ([property_id]) 
        REFERENCES [Property]([property_id]),
    CONSTRAINT [FK_Booking_Partitioned_User] FOREIGN KEY ([user_id]) 
        REFERENCES [User]([user_id])
) ON [BookingDateRangePS]([start_date]); -- The table is partitioned by start_date

-- Create necessary nonclustered indexes on the partitioned table
-- Note: These are aligned with the partitioning scheme
CREATE NONCLUSTERED INDEX [IX_Booking_Partitioned_UserID] 
ON [Booking_Partitioned]([user_id], [start_date])
ON [BookingDateRangePS]([start_date]);

CREATE NONCLUSTERED INDEX [IX_Booking_Partitioned_PropertyID] 
ON [Booking_Partitioned]([property_id], [start_date])
ON [BookingDateRangePS]([start_date]);

CREATE NONCLUSTERED INDEX [IX_Booking_Partitioned_Status] 
ON [Booking_Partitioned]([status], [start_date])
ON [BookingDateRangePS]([start_date]);

-- =================================================================
-- SECTION 3: DATA MIGRATION
-- =================================================================

-- Insert data from the original table to the partitioned table
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

-- =================================================================
-- SECTION 4: SWITCH TABLES
-- =================================================================

-- This would be done in a transaction in a real environment
-- Step 1: Rename the original table
EXEC sp_rename 'Booking', 'Booking_Old';

-- Step 2: Rename the new partitioned table to the original name
EXEC sp_rename 'Booking_Partitioned', 'Booking';

-- Step 3: Update any foreign key constraints that reference the booking table
-- This would involve dropping and recreating those foreign keys
-- Example (not executed here):
-- ALTER TABLE [Payment] DROP CONSTRAINT [FK_Payment_Booking];
-- ALTER TABLE [Payment] ADD CONSTRAINT [FK_Payment_Booking] 
--     FOREIGN KEY ([booking_id]) REFERENCES [Booking]([booking_id]);

-- =================================================================
-- SECTION 5: PERFORMANCE TESTING
-- =================================================================

-- Clear cache to ensure accurate testing
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

-- Test 1: Query for a specific quarter (partition-aligned)
-- This should use partition elimination
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Before: Query on old table (for reference)
SELECT * 
FROM [Booking_Old]
WHERE [start_date] >= '2024-04-01' AND [start_date] < '2024-07-01';

-- After: Query on partitioned table
SELECT * 
FROM [Booking]
WHERE [start_date] >= '2024-04-01' AND [start_date] < '2024-07-01';

-- Test 2: Query for a range that spans multiple partitions
-- Before: Query on old table (for reference)
SELECT * 
FROM [Booking_Old]
WHERE [start_date] >= '2024-01-01' AND [start_date] < '2024-10-01';

-- After: Query on partitioned table
SELECT * 
FROM [Booking]
WHERE [start_date] >= '2024-01-01' AND [start_date] < '2024-10-01';

-- Test 3: Query with additional filters
-- Before: Query on old table (for reference)
SELECT * 
FROM [Booking_Old]
WHERE [start_date] >= '2024-04-01' 
  AND [start_date] < '2024-07-01'
  AND [status] = 'confirmed';

-- After: Query on partitioned table
SELECT * 
FROM [Booking]
WHERE [start_date] >= '2024-04-01' 
  AND [start_date] < '2024-07-01'
  AND [status] = 'confirmed';

-- Test 4: INSERT performance
-- Test inserting into a specific partition
BEGIN TRANSACTION;

DECLARE @StartTime DATETIME = GETDATE();

-- Insert a batch of test records
INSERT INTO [Booking] (
    [booking_id],
    [property_id],
    [user_id],
    [start_date],
    [end_date],
    [total_price],
    [status],
    [created_at]
)
VALUES 
    (NEWID(), 'E3D19B4D-6C10-4F56-9E34-3C825DF3CED4', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', 
     '2024-05-01', '2024-05-10', 1500.00, 'pending', GETDATE());

PRINT 'Insert time: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, GETDATE()) AS VARCHAR) + ' ms';

ROLLBACK TRANSACTION;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- =================================================================
-- SECTION 6: PARTITION MAINTENANCE
-- =================================================================

-- Query to view partition information
SELECT 
    p.partition_number,
    p.rows,
    prv.value AS boundary_value,
    fg.name AS filegroup_name
FROM sys.partitions p
JOIN sys.indexes i 
    ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.data_spaces ds 
    ON i.data_space_id = ds.data_space_id
JOIN sys.partition_schemes ps 
    ON ds.data_space_id = ps.data_space_id
JOIN sys.partition_range_values prv 
    ON ps.function_id = prv.function_id 
    AND p.partition_number = prv.boundary_id
JOIN sys.destination_data_spaces dds 
    ON ps.function_id = dds.partition_scheme_id 
    AND p.partition_number = dds.destination_id
JOIN sys.filegroups fg 
    ON dds.data_space_id = fg.data_space_id
WHERE 
    i.type_desc = 'CLUSTERED' 
    AND p.object_id = OBJECT_ID('Booking')
ORDER BY 
    p.partition_number;

-- Add future partitions (example)
-- In a real environment, you would periodically add new partitions for future dates
/*
ALTER PARTITION SCHEME [BookingDateRangePS]
NEXT USED [PRIMARY]; -- Or a specific filegroup

ALTER PARTITION FUNCTION [BookingDateRangePF]()
SPLIT RANGE ('2026-01-01');
*/

-- Implement partition sliding window (example for archiving old data)
/*
-- Step 1: Create archive table with identical structure
CREATE TABLE [BookingArchive] (
    -- Same structure as Booking table
);

-- Step 2: Switch out oldest partition to archive table
ALTER TABLE [Booking] SWITCH PARTITION 1 TO [BookingArchive];

-- Step 3: Merge the now-empty partition
ALTER PARTITION FUNCTION [BookingDateRangePF]()
MERGE RANGE ('2023-01-01');
*/

-- =================================================================
-- SECTION 7: CLEANUP (commented out - only for testing)
-- =================================================================
/*
-- If needed, revert changes during testing
DROP TABLE [Booking];
EXEC sp_rename 'Booking_Old', 'Booking';

-- Clean up partition objects
DROP PARTITION SCHEME [BookingDateRangePS];
DROP PARTITION FUNCTION [BookingDateRangePF];
*/
