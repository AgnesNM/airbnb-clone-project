# Database Performance Monitoring Report

## Overview
This document outlines performance monitoring for frequently used queries in our Airbnb-like application database. We've used SQL commands like `EXPLAIN ANALYZE` and `SHOW PROFILE` to identify potential bottlenecks and recommend optimizations. After thorough analysis, we've identified several critical performance issues requiring immediate attention.

## Critical Bottlenecks Identified

1. **UUID Performance Issues**
   - Using UUID/GUID as primary keys (particularly in join operations) causes poor index performance
   - All tables use UUID format which impacts index size and query efficiency
   - Join operations between tables are consistently slow due to UUID comparison overhead

2. **Missing Foreign Key Indexes**
   - No indexes on foreign key columns in most tables
   - Every join operation requires full table scans
   - Particularly problematic in Booking, Review, and Message tables

3. **Inefficient Date Range Queries**
   - Date range queries in Booking table perform poorly
   - No efficient indexing strategy for overlapping date ranges
   - Availability searches becoming increasingly slow as bookings grow

4. **Suboptimal Message Storage**
   - Messages table becoming unwieldy with all conversations mixed together
   - Current query pattern for conversations extremely inefficient
   - No partitioning strategy for historical messages

5. **Review Aggregation Overhead**
   - Calculating average ratings on demand is computationally expensive
   - No pre-computed metrics for property ratings
   - Full table scans occurring for popular property listings

### 1. Finding Available Properties for Specific Dates

```sql
EXPLAIN ANALYZE
SELECT p.property_id, p.name, p.location, p.price_per_night 
FROM Property p
WHERE p.property_id NOT IN (
    SELECT b.property_id 
    FROM Booking b 
    WHERE b.status != 'canceled' 
    AND (
        ('2024-08-01' BETWEEN b.start_date AND b.end_date) OR 
        ('2024-08-05' BETWEEN b.start_date AND b.end_date) OR 
        (b.start_date BETWEEN '2024-08-01' AND '2024-08-05') OR 
        (b.end_date BETWEEN '2024-08-01' AND '2024-08-05')
    )
);
```

**Findings:**
- The subquery creates a performance bottleneck
- Missing indexes on date columns causing full table scans
- Query complexity affects response time for availability searches

**Recommendations:**
- Create an index on `start_date` and `end_date` in the Booking table
- Consider reformulating as a LEFT JOIN with NULL check instead of NOT IN
- Implement caching for popular date ranges

### 2. User's Booking History with Property Details

```sql
SHOW PROFILE FOR QUERY
SELECT b.booking_id, p.name, p.location, b.start_date, b.end_date, b.total_price, b.status
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.user_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2'
ORDER BY b.start_date DESC;
```

**Findings:**
- Join operation with Property table adds significant overhead
- Missing index on user_id slows retrieval of user-specific bookings
- Sorting by date requires additional processing time

**Recommendations:**
- Add index on `user_id` in Booking table
- Consider adding covering index that includes frequently queried fields
- For frequent users, implement result caching

### 3. Message Conversation Between Users

```sql
EXPLAIN ANALYZE
SELECT message_id, message_body, sent_at
FROM Message
WHERE (sender_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2' AND recipient_id = '28F72E56-75D9-4A27-A502-5A324A47FF14')
   OR (sender_id = '28F72E56-75D9-4A27-A502-5A324A47FF14' AND recipient_id = 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2')
ORDER BY sent_at ASC;
```

**Findings:**
- OR condition prevents efficient use of single-column indexes
- Table scan likely occurring on larger Message tables
- Ordering by sent_at adds additional processing time

**Recommendations:**
- Create a composite index on `(sender_id, recipient_id, sent_at)`
- Consider creating a conversation_id field to simplify queries
- For large message tables, implement time-based partitioning

### 4. Average Property Ratings with Details

```sql
EXPLAIN
SELECT p.property_id, p.name, p.location, 
       AVG(r.rating) as average_rating, 
       COUNT(r.review_id) as review_count
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.location
ORDER BY average_rating DESC;
```

**Findings:**
- Full table scan on Review table without proper indexing
- Aggregation operations (AVG, COUNT) adding computational overhead
- Sorting by calculated field requires additional processing

**Recommendations:**
- Add index on `property_id` in Review table
- Consider materialized view for frequently accessed rating data
- Implement caching for popular property listings

### 5. Popular Properties with Booking Counts

```sql
SHOW PROFILE FOR QUERY
SELECT p.property_id, p.name, p.location, COUNT(b.booking_id) as booking_count
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
WHERE b.status = 'confirmed'
GROUP BY p.property_id, p.name, p.location
HAVING COUNT(b.booking_id) > 0
ORDER BY booking_count DESC;
```

**Findings:**
- Filtering on booking status with no index causes inefficient execution
- Grouping operations on non-indexed columns is expensive
- Ordering by derived field (booking_count) adds overhead

**Recommendations:**
- Create an index on `status` column in Booking table
- Add composite index on `(property_id, status)` for this specific query
- Consider pre-computing popular property metrics periodically

## Optimized Query Examples

### 1. Improved Availability Search

```sql
-- Using the new PropertyAvailability table
SELECT p.property_int_id, p.name, p.location, p.price_per_night
FROM Property p
WHERE EXISTS (
    SELECT 1
    FROM PropertyAvailability pa
    WHERE pa.property_id = p.property_int_id
    AND pa.date_value BETWEEN '2024-08-01' AND '2024-08-05'
    AND pa.is_available = TRUE
    GROUP BY pa.property_id
    HAVING COUNT(*) = DATEDIFF('2024-08-05', '2024-08-01') + 1
);
```

### 2. Efficient User Booking History

```sql
-- Using integer IDs and covering index
SELECT b.booking_int_id, p.name, p.location, b.start_date, b.end_date, b.total_price, b.status
FROM Booking b
JOIN Property p ON b.property_int_id = p.property_int_id
WHERE b.user_int_id = 2 -- Jane Smith's integer ID
ORDER BY b.start_date DESC;
```

### 3. Conversation Messages with New Schema

```sql
-- Using the conversation table and partitioned messages
SELECT m.message_int_id, m.message_body, m.sent_at
FROM Message m
WHERE m.conversation_id = (
    SELECT c.conversation_id
    FROM Conversation c
    WHERE (c.participant1_id = 1 AND c.participant2_id = 2)
       OR (c.participant1_id = 2 AND c.participant2_id = 1)
)
ORDER BY m.sent_at ASC;
```

### 4. Pre-computed Property Ratings

```sql
-- Using materialized metrics in Property table
SELECT p.property_int_id, p.name, p.location, p.avg_rating, p.review_count
FROM Property p
WHERE p.avg_rating > 0
ORDER BY p.avg_rating DESC;
```

### 5. Booking Counts with Materialized Data

```sql
-- Using pre-computed booking counts
SELECT p.property_int_id, p.name, p.location, p.booking_count
FROM Property p
WHERE p.booking_count > 0
ORDER BY p.booking_count DESC;
```

## Implementation Plan

### Phase 1: Immediate Index Optimizations (Before Schema Changes)
```sql
-- Create indexes on existing schema to improve immediate performance
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_property ON Booking(property_id);
CREATE INDEX idx_booking_user ON Booking(user_id);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_message_users ON Message(sender_id, recipient_id, sent_at);
CREATE INDEX idx_review_property ON Review(property_id);
```

### Phase 2: Schema Migration (1-2 Weeks)
1. Add integer ID columns to all tables
2. Create new conversation and availability tables
3. Migrate data to new structure
4. Update application code to use new schema

### Phase 3: Optimization Verification (After Migration)
1. Re-run performance tests to measure improvements
2. Implement monitoring for slow queries
3. Fine-tune indexes based on actual production loads

### Phase 4: Advanced Optimizations (Future)
1. Implement caching layer for frequently accessed data
2. Consider read replicas for reporting queries
3. Evaluate database sharding strategy for horizontal scaling

---

*Note: The exact syntax for EXPLAIN ANALYZE and SHOW PROFILE varies between database systems (MySQL, PostgreSQL, SQL Server, etc.). The examples above are PostgreSQL-oriented, but the concepts apply across systems.*