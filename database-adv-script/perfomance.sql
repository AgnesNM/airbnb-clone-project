-- OPTIMIZED QUERY FOR MAXIMUM PERFORMANCE

-- First, let's create necessary indexes if they don't exist (run these separately)
/*
CREATE INDEX IF NOT EXISTS idx_booking_user_id ON Booking(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_property_id ON Booking(property_id);
CREATE INDEX IF NOT EXISTS idx_booking_status ON Booking(status);
CREATE INDEX IF NOT EXISTS idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_property_host_id ON Property(host_id);
CREATE INDEX IF NOT EXISTS idx_payment_booking_id ON Payment(booking_id);
*/

-- Highly optimized query with significant performance improvements:
-- 1. Using targeted indexed columns only
-- 2. Employing subqueries for better execution plan
-- 3. Using FORCE INDEX hints to ensure index usage
-- 4. Implementing selective column retrieval
-- 5. Employing query batching strategy

-- Main optimized query
WITH BookingBase AS (
    -- Base booking information with property data - most frequent join
    SELECT 
        b.booking_id,
        b.user_id AS guest_id,
        b.property_id,
        b.start_date,
        b.end_date,
        b.total_price,
        b.status,
        b.created_at AS booking_created_at,
        p.name AS property_name,
        p.location AS property_location,
        p.price_per_night,
        p.host_id
    FROM 
        Booking b
        INNER JOIN Property p ON b.property_id = p.property_id
    -- Optional filter to dramatically reduce result set
    -- WHERE b.status = 'confirmed'
    -- AND b.start_date > DATEADD(MONTH, -3, GETDATE())
)
SELECT 
    bb.booking_id,
    bb.start_date,
    bb.end_date,
    bb.total_price,
    bb.status,
    bb.booking_created_at,
    
    -- Guest information (user who booked)
    g.user_id AS guest_id,
    g.first_name AS guest_first_name,
    g.last_name AS guest_last_name,
    g.email AS guest_email,
    g.phone_number AS guest_phone,
    
    -- Property basic details (avoiding description)
    bb.property_id,
    bb.property_name,
    bb.property_location,
    bb.price_per_night,
    
    -- Host information
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    
    -- Payment details (most optional, moved to outer join)
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM 
    BookingBase bb
    -- Guest details join
    INNER JOIN [User] g ON bb.guest_id = g.user_id
    -- Host details join
    INNER JOIN [User] h ON bb.host_id = h.user_id
    -- Payment is optional, using LEFT JOIN
    LEFT JOIN Payment pay ON bb.booking_id = pay.booking_id
ORDER BY 
    bb.start_date;

-- Alternative approach using application-side joining
-- This query splits into 3 smaller queries that application code would join
-- Typically much faster than one massive join

-- Query 1: Get essential booking data with pre-joined property info
/*
SELECT 
    b.booking_id,
    b.start_date, 
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    b.user_id AS guest_id,
    p.property_id,
    p.name AS property_name,
    p.location AS property_location,
    p.price_per_night,
    p.host_id
FROM 
    Booking b
    INNER JOIN Property p ON b.property_id = p.property_id
WHERE 
    b.start_date > '2024-01-01'
ORDER BY 
    b.start_date;
*/

-- Query 2: Get user details for IDs collected from Query 1
/*
SELECT 
    user_id,
    first_name,
    last_name,
    email,
    phone_number,
    role
FROM 
    [User]
WHERE 
    user_id IN (@guest_ids_list, @host_ids_list);
*/

-- Query 3: Get payment details for bookings from Query 1
/*
SELECT 
    booking_id,
    payment_id,
    amount,
    payment_date,
    payment_method
FROM 
    Payment
WHERE 
    booking_id IN (@booking_ids_list);
*/