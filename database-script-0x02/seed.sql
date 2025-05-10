```sql
-- Insert Users (mix of guests, hosts, and admins)
INSERT INTO "User" (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at)
VALUES 
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'John', 'Doe', 'john.doe@example.com', 'hashed_password_1', '+1-555-123-4567', 'host', '2024-01-01 10:00:00'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'Jane', 'Smith', 'jane.smith@example.com', 'hashed_password_2', '+1-555-987-6543', 'guest', '2024-01-15 11:30:00'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'Michael', 'Johnson', 'michael.j@example.com', 'hashed_password_3', '+1-555-234-5678', 'guest', '2024-02-01 09:45:00'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'Emily', 'Brown', 'emily.b@example.com', 'hashed_password_4', '+1-555-345-6789', 'host', '2024-02-10 14:20:00'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'Admin', 'User', 'admin@airbnb-clone.com', 'admin_password_hash', '+1-555-999-0000', 'admin', '2024-01-01 00:00:00');

-- Insert Properties
INSERT INTO "Property" (property_id, host_id, name, description, location, price_per_night, created_at, updated_at)
VALUES 
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Beachfront Villa', 'Luxurious villa with direct beach access and panoramic ocean views.', 'Malibu, CA', 350.00, '2024-01-05 12:00:00', '2024-01-05 12:00:00'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b12', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Downtown Loft', 'Modern loft in the heart of downtown with city views.', 'New York, NY', 200.00, '2024-01-10 15:30:00', '2024-01-20 10:15:00'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b13', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'Mountain Cabin', 'Cozy cabin with fireplace and mountain views.', 'Aspen, CO', 175.00, '2024-02-15 09:00:00', '2024-02-15 09:00:00'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b14', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'Lakeside Cottage', 'Peaceful cottage with private dock and lake access.', 'Lake Tahoe, CA', 225.00, '2024-03-01 11:45:00', '2024-03-05 16:30:00');

-- Insert Bookings
INSERT INTO "Booking" (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at)
VALUES 
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', '2024-06-10', '2024-06-15', 1750.00, 'confirmed', '2024-03-15 14:00:00'),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c12', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b12', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', '2024-07-01', '2024-07-05', 800.00, 'confirmed', '2024-03-20 10:30:00'),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c13', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b13', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', '2024-08-15', '2024-08-20', 875.00, 'pending', '2024-04-01 16:45:00'),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c14', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', '2024-09-05', '2024-09-10', 1750.00, 'canceled', '2024-04-10 09:15:00'),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c15', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b14', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', '2024-07-20', '2024-07-25', 1125.00, 'confirmed', '2024-04-15 11:30:00');

-- Insert Payments
INSERT INTO "Payment" (payment_id, booking_id, amount, payment_date, payment_method)
VALUES 
  ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c11', 1750.00, '2024-03-15 14:05:00', 'credit_card'),
  ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380d12', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c12', 800.00, '2024-03-20 10:35:00', 'paypal'),
  ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380d13', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c15', 1125.00, '2024-04-15 11:35:00', 'stripe');

-- Insert Reviews
INSERT INTO "Review" (review_id, property_id, user_id, rating, comment, created_at)
VALUES 
  ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380e11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 5, 'Absolutely stunning property with amazing views! The host was very accommodating and responsive.', '2024-06-16 10:00:00'),
  ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380e12', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b12', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 4, 'Great location and modern amenities. Could use a bit more kitchen supplies.', '2024-07-06 14:30:00'),
  ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380e13', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b14', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 5, 'Perfect lakeside retreat! We loved the private dock and the peaceful surroundings.', '2024-07-26 09:45:00');

-- Insert Messages
INSERT INTO "Message" (message_id, sender_id, recipient_id, message_body, sent_at)
VALUES 
  ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Hi, I''m interested in your Beachfront Villa. Is it available for the dates I selected?', '2024-03-10 16:30:00'),
  ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380f12', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'Yes, those dates are available. Would you like to proceed with the booking?', '2024-03-10 17:15:00'),
  ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380f13', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Great, I''ve just completed the booking. Is there a check-in code or key pickup process?', '2024-03-15 14:10:00'),
  ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380f14', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'Hello, does the Mountain Cabin have WiFi? I need to work remotely during my stay.', '2024-03-25 11:00:00'),
  ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380f15', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'Yes, we have high-speed WiFi throughout the cabin. The password will be in the welcome book.', '2024-03-25 13:45:00');
```
