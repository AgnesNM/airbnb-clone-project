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
