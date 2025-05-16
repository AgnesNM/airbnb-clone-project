# Airbnb Clone Database

This repository contains sample SQL data for an Airbnb-like property rental platform database. The database includes tables for users, properties, bookings, payments, reviews, and messages, providing a complete structure for a rental marketplace application.

## Database Structure

The database consists of the following tables:

### User

Stores information about platform users, including guests, hosts, and administrators.

- `user_id` (UUID): Primary key
- `first_name`: User's first name
- `last_name`: User's last name
- `email`: User's email address
- `password_hash`: Hashed password for security
- `phone_number`: Contact phone number
- `role`: User role (guest, host, or admin)
- `created_at`: Timestamp when the user account was created

### Property

Contains details about rental properties listed on the platform.

- `property_id` (UUID): Primary key
- `host_id` (UUID): Foreign key reference to User table
- `name`: Property name/title
- `description`: Detailed property description
- `location`: Property location (city, state)
- `price_per_night`: Nightly rental rate
- `created_at`: Timestamp when the property was listed
- `updated_at`: Timestamp when the property details were last updated

### Booking

Records of property reservations made by guests.

- `booking_id` (UUID): Primary key
- `property_id` (UUID): Foreign key reference to Property table
- `user_id` (UUID): Foreign key reference to User table (the guest)
- `start_date`: Reservation start date
- `end_date`: Reservation end date
- `total_price`: Total cost for the entire stay
- `status`: Booking status (confirmed, pending, canceled)
- `created_at`: Timestamp when the booking was created

### Payment

Tracks payment transactions for bookings.

- `payment_id` (UUID): Primary key
- `booking_id` (UUID): Foreign key reference to Booking table
- `amount`: Payment amount
- `payment_date`: Date and time of payment
- `payment_method`: Method used for payment (credit_card, paypal, stripe)

### Review

Guest reviews for properties they've stayed at.

- `review_id` (UUID): Primary key
- `property_id` (UUID): Foreign key reference to Property table
- `user_id` (UUID): Foreign key reference to User table (the reviewer)
- `rating`: Numerical rating (1-5)
- `comment`: Text review
- `created_at`: Timestamp when the review was submitted

### Message

Communication between users on the platform.

- `message_id` (UUID): Primary key
- `sender_id` (UUID): Foreign key reference to User table
- `recipient_id` (UUID): Foreign key reference to User table
- `message_body`: Text content of the message
- `sent_at`: Timestamp when the message was sent

## Sample Data

The SQL script includes sample data for all tables:

- 5 users (2 hosts, 2 guests, 1 admin)
- 4 properties (2 per host)
- 5 bookings (with different statuses)
- 3 payments
- 5 reviews
- 10 messages between users

## Entity Relationships

- A User can be a guest and/or a host
- Hosts can list multiple Properties
- Guests can make multiple Bookings
- Each Booking is for one Property by one guest
- Each Payment is associated with one Booking
- Guests can leave Reviews for Properties they've booked
- Users can exchange Messages with each other

## Common Queries

### Retrieving Bookings with User Information (INNER JOIN)

This query uses an INNER JOIN to retrieve all bookings along with details about the users who made those bookings:

```sql
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
```

The INNER JOIN ensures that only records with matches in both tables are returned. In this context, it means we only get bookings that have a corresponding user in the User table. With properly maintained data integrity, all bookings should have a valid user_id, so all bookings should be returned.

### Retrieving Properties with Reviews (LEFT JOIN)

This query uses a LEFT JOIN to retrieve all properties and their reviews, including properties that have no reviews:

```sql
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
```

The LEFT JOIN is crucial here because:
- It returns ALL records from the left table (Property) regardless of whether there are matches in the right table (Review)
- For properties with no reviews, the review fields (review_id, rating, comment, etc.) will be NULL
- It allows property owners and administrators to identify properties that may need attention to generate reviews
- A second LEFT JOIN retrieves reviewer information when available

### Retrieving Users and Bookings (FULL OUTER JOIN)

This query uses a FULL OUTER JOIN to retrieve all users and all bookings, even if a user has no bookings or a booking is not linked to a user:

```sql
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
```

The FULL OUTER JOIN provides these benefits:
- Returns ALL users, including those who have never made a booking (booking fields will be NULL)
- Returns ALL bookings, even if they somehow don't have a valid user association (user fields will be NULL)
- Useful for data integrity checks to find orphaned bookings or inactive users
- Helps identify anomalies that might need administrative attention
- Can reveal users who register but never book (potential marketing opportunities)

### Finding Highly-Rated Properties (Subquery)

This query uses a subquery to find all properties where the average rating is greater than 4.0:

```sql
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.price_per_night,
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) AS average_rating
FROM 
    Property p
WHERE 
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) > 4.0
ORDER BY 
    average_rating DESC;
```

Key aspects of this subquery:
- The subquery appears twice: once in the SELECT clause to display the average rating and once in the WHERE clause for filtering
- For each row in the Property table, the subquery calculates the average rating for that specific property
- Only properties with an average rating higher than 4.0 are included in the results
- Results are sorted by average rating in descending order, showing the highest-rated properties first

### Finding Frequent Bookers (Correlated Subquery)

This query uses a correlated subquery to find users who have made more than 3 bookings:

```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) AS booking_count
FROM 
    [User] u
WHERE 
    (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) > 3
ORDER BY 
    booking_count DESC;
```

How this correlated subquery works:
- For each user in the User table, the subquery counts how many bookings are associated with that user
- The correlation happens through the WHERE clause in the subquery (b.user_id = u.user_id)
- Only users with more than 3 bookings are included in the results
- The subquery appears both in the SELECT clause (to display the count) and the WHERE clause (for filtering)
- Results are ordered by booking count, showing the most active users first
- This identifies valuable repeat customers for potential loyalty programs or targeted marketing

### Counting User Bookings (Aggregation with GROUP BY)

This query finds the total number of bookings made by each user using the COUNT function and GROUP BY clause:

```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings
FROM 
    [User] u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
ORDER BY 
    total_bookings DESC;
```

Key features of this aggregation query:
- Uses LEFT JOIN to include all users, even those with no bookings
- The COUNT function tallies the number of bookings for each user
- GROUP BY combines all rows for the same user into a single summary row
- All non-aggregated columns in the SELECT must appear in the GROUP BY clause
- Results are ordered by booking count to identify the most active users first
- Returns 0 for users who have never made a booking (unlike INNER JOIN which would exclude them)

### Ranking Properties by Popularity (Window Functions)

This query uses window functions to rank properties based on their booking counts:

```sql
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.price_per_night,
    COUNT(b.booking_id) AS booking_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank_with_ties
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.price_per_night
ORDER BY 
    booking_count DESC;
```

Window functions add powerful analytical capabilities:
- ROW_NUMBER() assigns a unique sequential integer to each row (1, 2, 3, ...)
- RANK() allows for ties, so multiple properties with the same booking count get the same rank
- OVER clause defines how to partition and order the data for the window function
- Unlike regular aggregations, window functions don't collapse rows
- Combination of GROUP BY (for counting) and window functions (for ranking) provides rich analysis
- Shows both the absolute number of bookings and the relative popularity ranking
- Helps identify the most popular properties for featured listings or premium positioning

### Finding Highly-Rated Properties (Subquery)

This query uses a subquery to find all properties where the average rating is greater than 4.0:

```sql
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.price_per_night,
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) AS average_rating
FROM 
    Property p
WHERE 
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) > 4.0
ORDER BY 
    average_rating DESC;
```

Key aspects of this subquery:
- The subquery appears twice: once in the SELECT clause to display the average rating and once in the WHERE clause for filtering
- For each row in the Property table, the subquery calculates the average rating for that specific property
- Only properties with an average rating higher than 4.0 are included in the results
- Results are sorted by average rating in descending order, showing the highest-rated properties first

### Finding Frequent Bookers (Correlated Subquery)

This query uses a correlated subquery to find users who have made more than 3 bookings:

```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) AS booking_count
FROM 
    [User] u
WHERE 
    (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) > 3
ORDER BY 
    booking_count DESC;
```

How this correlated subquery works:
- For each user in the User table, the subquery counts how many bookings are associated with that user
- The correlation happens through the WHERE clause in the subquery (b.user_id = u.user_id)
- Only users with more than 3 bookings are included in the results
- The subquery appears both in the SELECT clause (to display the count) and the WHERE clause (for filtering)
- Results are ordered by booking count, showing the most active users first
- This identifies valuable repeat customers for potential loyalty programs or targeted marketing

## Usage

This database can be used for:

- Development and testing of rental platform applications
- Database design and query practice
- Demonstrating relationships between entities in a marketplace platform
- Practice with SQL transactions and data manipulation

To use this data:

1. Create a database in your SQL server
2. Run the SQL script to create and populate the tables
3. Start querying or developing against the database

## Notes

- All IDs are stored as UUIDs/GUIDs for better security and distribution
- Passwords are represented as hashed values (not actual passwords)
- Dates in the sample data range from January 2024 to September 2024
- Timestamps use the format 'YYYY-MM-DD HH:MM:SS'

## Extending the Database

Consider adding these tables for a more complete application:

- PropertyAmenities
- PropertyPhotos
- UserProfiles (with additional user details)
- WishLists
- PaymentRefunds
- Notifications
