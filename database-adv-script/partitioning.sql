-- partitioning.sql
-- Implementing partitioning on the Booking table based on start_date
-- Assumes we're using a SQL database that supports table partitioning (e.g., PostgreSQL)

-- First, create a new partitioned table structure
CREATE TABLE booking_partitioned (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL
) PARTITION BY RANGE (start_date);

-- Create quarterly partitions for the current year (2024)
-- You can adjust the partitioning strategy based on your needs
CREATE TABLE booking_q1_2024 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE booking_q2_2024 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

CREATE TABLE booking_q3_2024 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');

CREATE TABLE booking_q4_2024 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

-- Create quarterly partitions for the next year (2025)
CREATE TABLE booking_q1_2025 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

CREATE TABLE booking_q2_2025 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

CREATE TABLE booking_q3_2025 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');

CREATE TABLE booking_q4_2025 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

-- Create a default partition for any other dates outside our defined ranges
CREATE TABLE booking_default PARTITION OF booking_partitioned DEFAULT;

-- Create indexes on each partition for improved query performance
-- Index on start_date for range queries
CREATE INDEX idx_booking_q1_2024_start_date ON booking_q1_2024 (start_date);
CREATE INDEX idx_booking_q2_2024_start_date ON booking_q2_2024 (start_date);
CREATE INDEX idx_booking_q3_2024_start_date ON booking_q3_2024 (start_date);
CREATE INDEX idx_booking_q4_2024_start_date ON booking_q4_2024 (start_date);
CREATE INDEX idx_booking_q1_2025_start_date ON booking_q1_2025 (start_date);
CREATE INDEX idx_booking_q2_2025_start_date ON booking_q2_2025 (start_date);
CREATE INDEX idx_booking_q3_2025_start_date ON booking_q3_2025 (start_date);
CREATE INDEX idx_booking_q4_2025_start_date ON booking_q4_2025 (start_date);
CREATE INDEX idx_booking_default_start_date ON booking_default (start_date);

-- Index on property_id for property-specific booking queries
CREATE INDEX idx_booking_q1_2024_property_id ON booking_q1_2024 (property_id);
CREATE INDEX idx_booking_q2_2024_property_id ON booking_q2_2024 (property_id);
CREATE INDEX idx_booking_q3_2024_property_id ON booking_q3_2024 (property_id);
CREATE INDEX idx_booking_q4_2024_property_id ON booking_q4_2024 (property_id);
CREATE INDEX idx_booking_q1_2025_property_id ON booking_q1_2025 (property_id);
CREATE INDEX idx_booking_q2_2025_property_id ON booking_q2_2025 (property_id);
CREATE INDEX idx_booking_q3_2025_property_id ON booking_q3_2025 (property_id);
CREATE INDEX idx_booking_q4_2025_property_id ON booking_q4_2025 (property_id);
CREATE INDEX idx_booking_default_property_id ON booking_default (property_id);

-- Index on user_id for user-specific booking queries
CREATE INDEX idx_booking_q1_2024_user_id ON booking_q1_2024 (user_id);
CREATE INDEX idx_booking_q2_2024_user_id ON booking_q2_2024 (user_id);
CREATE INDEX idx_booking_q3_2024_user_id ON booking_q3_2024 (user_id);
CREATE INDEX idx_booking_q4_2024_user_id ON booking_q4_2024 (user_id);
CREATE INDEX idx_booking_q1_2025_user_id ON booking_q1_2025 (user_id);
CREATE INDEX idx_booking_q2_2025_user_id ON booking_q2_2025 (user_id);
CREATE INDEX idx_booking_q3_2025_user_id ON booking_q3_2025 (user_id);
CREATE INDEX idx_booking_q4_2025_user_id ON booking_q4_2025 (user_id);
CREATE INDEX idx_booking_default_user_id ON booking_default (user_id);

-- Migrate data from the original table to the partitioned table
INSERT INTO booking_partitioned SELECT * FROM Booking;

-- Add Foreign Key constraints to the new partitioned table
ALTER TABLE booking_partitioned ADD CONSTRAINT fk_booking_partitioned_property
    FOREIGN KEY (property_id) REFERENCES Property(property_id);

ALTER TABLE booking_partitioned ADD CONSTRAINT fk_booking_partitioned_user
    FOREIGN KEY (user_id) REFERENCES User(user_id);

-- After verifying data migration was successful:
-- Option 1: Rename tables to replace the original
-- ALTER TABLE Booking RENAME TO Booking_old;
-- ALTER TABLE booking_partitioned RENAME TO Booking;

-- Option 2: Drop the old table and rename the new one
-- DROP TABLE Booking;
-- ALTER TABLE booking_partitioned RENAME TO Booking;

-- Update any dependent tables (like Payment table) to reference the new table
-- ALTER TABLE Payment ADD CONSTRAINT fk_payment_booking
--    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id);

-- Create a maintenance function to automatically add new partition tables
-- for future years/quarters as needed
CREATE OR REPLACE FUNCTION create_booking_partition()
RETURNS VOID AS $$
DECLARE
    next_year INTEGER;
    next_quarter INTEGER;
    start_date DATE;
    end_date DATE;
    partition_name TEXT;
BEGIN
    -- Find the latest year and quarter for which a partition exists
    SELECT EXTRACT(YEAR FROM MAX(start_date)) INTO next_year
    FROM booking_partitioned;
    
    next_year := COALESCE(next_year, EXTRACT(YEAR FROM CURRENT_DATE)) + 1;
    
    -- Create partitions for each quarter of the next year
    FOR next_quarter IN 1..4 LOOP
        start_date := make_date(next_year, (next_quarter - 1) * 3 + 1, 1);
        
        IF next_quarter < 4 THEN
            end_date := make_date(next_year, next_quarter * 3 + 1, 1);
        ELSE
            end_date := make_date(next_year + 1, 1, 1);
        END IF;
        
        partition_name := 'booking_q' || next_quarter || '_' || next_year;
        
        -- Create the partition
        EXECUTE 'CREATE TABLE ' || partition_name || 
                ' PARTITION OF booking_partitioned FOR VALUES FROM (''' || 
                start_date || ''') TO (''' || end_date || ''')';
                
        -- Create indexes on the new partition
        EXECUTE 'CREATE INDEX idx_' || partition_name || '_start_date ON ' || 
                partition_name || ' (start_date)';
        EXECUTE 'CREATE INDEX idx_' || partition_name || '_property_id ON ' || 
                partition_name || ' (property_id)';
        EXECUTE 'CREATE INDEX idx_' || partition_name || '_user_id ON ' || 
                partition_name || ' (user_id)';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Set up a scheduled task to execute this function once per year
-- This can be done with pg_cron extension or an external scheduler
-- COMMENT: Run this once a year to create next year's partitions
-- SELECT create_booking_partition();
