# Database Indexing Strategy for Airbnb Clone

This document outlines the indexing strategy for the Airbnb Clone database to optimize query performance. It identifies high-usage columns, provides CREATE INDEX commands, and explains how to measure performance improvements.

## High-Usage Columns Analysis

Based on query patterns observed in the application, we've identified the following high-usage columns:

### User Table
- `user_id` (primary key, used in JOIN conditions, WHERE filters)
- `role` (filtered in WHERE clauses)
- `last_name`, `first_name` (used in ORDER BY operations)
- `email` (used for user lookups)

### Booking Table
- `booking_id` (primary key, used in JOIN conditions)
- `user_id` (foreign key, used in JOIN conditions)
- `property_id` (foreign key, used in JOIN conditions)
- `start_date`, `end_date` (used in date range filters and ORDER BY)
- `status` (filtered in WHERE clauses)

### Property Table
- `property_id` (primary key, used in JOIN conditions)
- `host_id` (foreign key, used in JOIN conditions)
- `location` (filtered in WHERE, used in ORDER BY)
- `price_per_night` (used in range filters, ORDER BY)

## Index Creation Commands

Below are the SQL commands to create appropriate indexes for optimizing query performance:

### User Table Indexes

```sql
-- Index for user role (for filtering users by role, e.g., finding all hosts)
CREATE INDEX idx_user_role ON [User] (role);

-- Composite index for name search and sorting
CREATE INDEX idx_user_name ON [User] (last_name, first_name);

-- Email is likely to be used for login lookup and is unique
CREATE UNIQUE INDEX idx_user_email ON [User] (email);
```

### Booking Table Indexes

```sql
-- Foreign key indexes for JOIN operations
CREATE INDEX idx_booking_user_id ON Booking (user_id);
CREATE INDEX idx_booking_property_id ON Booking (property_id);

-- Indexes for date ranges and sorting
CREATE INDEX idx_booking_dates ON Booking (start_date, end_date);

-- Index for booking status (for filtering by confirmed, pending, canceled)
CREATE INDEX idx_booking_status ON Booking (status);

-- Composite index for common query patterns
CREATE INDEX idx_booking_user_dates ON Booking (user_id, start_date, end_date);
```

### Property Table Indexes

```sql
-- Index for host_id (for joining and finding properties by host)
CREATE INDEX idx_property_host_id ON Property (host_id);

-- Index for location (for geographical searches)
CREATE INDEX idx_property_location ON Property (location);

-- Index for price (for price range searches and sorting)
CREATE INDEX idx_property_price ON Property (price_per_night);
```

### Review Table Indexes

```sql
-- Foreign key indexes for JOIN operations
CREATE INDEX idx_review_property_id ON Review (property_id);
CREATE INDEX idx_review_user_id ON Review (user_id);

-- Index for rating (for filtering properties by rating)
CREATE INDEX idx_review_rating ON Review (rating);
```

### Payment Table Indexes

```sql
-- Foreign key index for JOIN operations
CREATE INDEX idx_payment_booking_id ON Payment (booking_id);

-- Index for payment method (for filtering and reporting)
CREATE INDEX idx_payment_method ON Payment (payment_method);
```

### Message Table Indexes

```sql
-- Indexes for sender and recipient (for finding messages by user)
CREATE INDEX idx_message_sender_id ON Message (sender_id);
CREATE INDEX idx_message_recipient_id ON Message (recipient_id);

-- Index for conversation lookup (common pattern to find all messages between two users)
CREATE INDEX idx_message_conversation ON Message (sender_id, recipient_id);
```

## Performance Measurement

### Before and After Performance Comparison

To measure the impact of indexes on query performance, use the EXPLAIN or ANALYZE features of your database system:

#### Example Query for Performance Testing

```sql
-- Query to test performance improvements
SELECT * FROM Booking 
WHERE user_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2' 
  AND start_date > '2024-06-01';
```

### EXPLAIN/ANALYZE Syntax by Database System

Different database systems have different syntax for execution plans:

| Database   | Command Syntax                       |
|------------|--------------------------------------|
| SQL Server | `SET STATISTICS IO ON; SELECT...;`   |
| MySQL      | `EXPLAIN SELECT...`                  |
| PostgreSQL | `EXPLAIN ANALYZE SELECT...`          |
| SQLite     | `EXPLAIN QUERY PLAN SELECT...`       |

### Expected Performance Improvements

| Scenario        | Before Indexing              | After Indexing                         |
|-----------------|-----------------------------|---------------------------------------|
| User lookup     | Full table scan             | Index seek on idx_user_email          |
| Booking search  | Full table scan             | Index seek on idx_booking_user_dates  |
| Property filter | Full table scan             | Index seek on idx_property_price      |
| Join operation  | Nested loops with table scan| Nested loops with index seek          |

### Measuring Specific Improvements in SQL Server

```sql
-- Before adding indexes:
SET STATISTICS IO ON;
SELECT * FROM Booking WHERE user_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2' AND start_date > '2024-06-01';
-- Check logical reads in the messages tab

-- After adding indexes:
SET STATISTICS IO ON;
SELECT * FROM Booking WHERE user_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2' AND start_date > '2024-06-01';
-- Check logical reads in the messages tab, expect significant reduction
```

## Indexing Best Practices

1. **Don't over-index**: Each index adds overhead to inserts, updates, and deletes
2. **Monitor usage**: Periodically review index usage to identify unused indexes
3. **Consider covering indexes**: Include all columns needed by a query to avoid lookups
4. **Order matters in composite indexes**: Put most selective columns first
5. **Update statistics**: Ensure query optimizer has current data distribution information

## Regular Maintenance

```sql
-- Rebuild or reorganize fragmented indexes
ALTER INDEX idx_booking_dates ON Booking REBUILD;

-- Update statistics
UPDATE STATISTICS Booking WITH FULLSCAN;
```

By implementing these indexes, we expect to see significant query performance improvements, particularly for complex JOIN operations and filtered searches.
