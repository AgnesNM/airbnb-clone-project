---INNER JOIN

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number
FROM 
    Booking b
INNER JOIN 
    [User] u ON b.user_id = u.user_id
ORDER BY 
    b.start_date;
---

---LEFT JOIN

SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.price_per_night,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date,
    u.first_name AS reviewer_first_name,
    u.last_name AS reviewer_last_name
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
LEFT JOIN 
    [User] u ON r.user_id = u.user_id
ORDER BY 
    p.name, r.created_at DESC;

---

--- FULL OUTER JOIN

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM 
    [User] u
FULL OUTER JOIN 
    Booking b ON u.user_id = b.user_id
ORDER BY 
    u.last_name, u.first_name, b.start_date;
---
