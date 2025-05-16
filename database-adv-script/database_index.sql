-- database_index.sql
-- Indexes for the Airbnb Clone Database

-- Note: Primary keys typically have indexes automatically created,
-- so we don't need to create indexes for primary key columns like user_id in User table.

-- ========== User Table Indexes ==========
-- Index for user role (for filtering users by role, e.g., finding all hosts)
CREATE INDEX idx_user_role ON [User] (role);

-- Composite index for name search and sorting (last_name, first_name is common for user display)
CREATE INDEX idx_user_name ON [User] (last_name, first_name);

-- Email is likely to be used for login lookup and is unique
CREATE UNIQUE INDEX idx_user_email ON [User] (email);

-- ========== Booking Table Indexes ==========
-- Foreign key indexes for JOIN operations
CREATE INDEX idx_booking_user_id ON Booking (user_id);
CREATE INDEX idx_booking_property_id ON Booking (property_id);

-- Indexes for date ranges and sorting
CREATE INDEX idx_booking_dates ON Booking (start_date, end_date);

-- Index for booking status (for filtering by confirmed, pending, canceled)
CREATE INDEX idx_booking_status ON Booking (status);

-- Composite index for common query patterns
CREATE INDEX idx_booking_user_dates ON Booking (user_id, start_date, end_date);

-- ========== Property Table Indexes ==========
-- Index for host_id (for joining and finding properties by host)
CREATE INDEX idx_property_host_id ON Property (host_id);

-- Index for location (for geographical searches)
CREATE INDEX idx_property_location ON Property (location);

-- Index for price (for price range searches and sorting)
CREATE INDEX idx_property_price ON Property (price_per_night);

-- ========== Review Table Indexes ==========
-- Foreign key indexes for JOIN operations
CREATE INDEX idx_review_property_id ON Review (property_id);
CREATE INDEX idx_review_user_id ON Review (user_id);

-- Index for rating (for filtering properties by rating)
CREATE INDEX idx_review_rating ON Review (rating);

-- ========== Payment Table Indexes ==========
-- Foreign key index for JOIN operations
CREATE INDEX idx_payment_booking_id ON Payment (booking_id);

-- Index for payment method (for filtering and reporting)
CREATE INDEX idx_payment_method ON Payment (payment_method);

-- ========== Message Table Indexes ==========
-- Indexes for sender and recipient (for finding messages by user)
CREATE INDEX idx_message_sender_id ON Message (sender_id);
CREATE INDEX idx_message_recipient_id ON Message (recipient_id);

-- Index for conversation lookup (common pattern to find all messages between two users)
CREATE INDEX idx_message_conversation ON Message (sender_id, recipient_id);

-- ========== EXPLAIN Examples ==========

-- Before adding indexes, a query like this might be slow:
-- EXPLAIN SELECT * FROM Booking WHERE user_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2' AND start_date > '2024-06-01';

-- After adding the composite index idx_booking_user_dates, this query should use the index:
-- EXPLAIN SELECT * FROM Booking WHERE user_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2' AND start_date > '2024-06-01';

-- Performance improvements from indexes:
-- 1. Without indexes: Full table scan on Booking table
-- 2. With indexes: Index seek on idx_booking_user_dates
-- Expected improvement: Reduced logical reads from potentially thousands to just a few dozen

-- Note on EXPLAIN/ANALYZE:
-- Different database systems have different syntax for execution plans:
-- - SQL Server: Use EXEC sp_executesql N'SET STATISTICS IO ON; SELECT...'; or SET SHOWPLAN_ALL ON;
-- - MySQL: Use EXPLAIN SELECT...
-- - PostgreSQL: Use EXPLAIN ANALYZE SELECT...
-- - SQLite: Use EXPLAIN QUERY PLAN SELECT...

-- Example for measuring performance improvement in SQL Server:
/*
-- Before adding indexes:
SET STATISTICS IO ON;
SELECT * FROM Booking WHERE user_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2' AND start_date > '2024-06-01';
-- Check logical reads in the messages tab

-- After adding indexes:
SET STATISTICS IO ON;
SELECT * FROM Booking WHERE user_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2' AND start_date > '2024-06-01';
-- Check logical reads in the messages tab, should be significantly lower
*/
