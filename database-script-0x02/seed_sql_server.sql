```sql
-- Insert Users (a mix of guests, hosts, and admins)
INSERT INTO [User] (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at)
VALUES 
  ('28F72E56-75D9-4A27-A502-5A324A47FF14', 'John', 'Doe', 'john.doe@example.com', 'hashed_password_1', '+1-555-123-4567', 'host', '2024-01-01 10:00:00'),
  ('A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', 'Jane', 'Smith', 'jane.smith@example.com', 'hashed_password_2', '+1-555-987-6543', 'guest', '2024-01-15 11:30:00'),
  ('B7F52C7A-2F13-47D9-A3B2-9D632DF0AFB1', 'Michael', 'Johnson', 'michael.j@example.com', 'hashed_password_3', '+1-555-234-5678', 'guest', '2024-02-01 09:45:00'),
  ('C9D57B2E-8A12-4D78-B6C3-1A823DF1AED2', 'Emily', 'Brown', 'emily.b@example.com', 'hashed_password_4', '+1-555-345-6789', 'host', '2024-02-10 14:20:00'),
  ('D1F29A3C-7B11-4E67-8D45-2B914DF2BFC3', 'Admin', 'User', 'admin@airbnb-clone.com', 'admin_password_hash', '+1-555-999-0000', 'admin', '2024-01-01 00:00:00');

-- Insert Properties
INSERT INTO Property (property_id, host_id, name, description, location, price_per_night, created_at, updated_at)
VALUES 
  ('E3D19B4D-6C10-4F56-9E34-3C825DF3CED4', '28F72E56-75D9-4A27-A502-5A324A47FF14', 'Beachfront Villa', 'Luxurious villa with direct beach access and panoramic ocean views. Fully equipped kitchen, infinity pool, and outdoor entertainment area.', 'Malibu, CA', 350.00, '2024-01-05 12:00:00', '2024-01-05 12:00:00'),
  ('F5B18C5E-5D12-4C45-AE23-4D736DF4DFE5', '28F72E56-75D9-4A27-A502-5A324A47FF14', 'Downtown Loft', 'Modern loft in the heart of downtown with city views. Walking distance to restaurants, shopping, and entertainment.', 'New York, NY', 200.00, '2024-01-10 15:30:00', '2024-01-20 10:15:00'),
  ('A7A17D6F-4E11-4D34-BD12-5E647DF5EFF6', 'C9D57B2E-8A12-4D78-B6C3-1A823DF1AED2', 'Mountain Cabin', 'Cozy cabin with fireplace and mountain views. Perfect for a weekend getaway or ski trip.', 'Aspen, CO', 175.00, '2024-02-15 09:00:00', '2024-02-15 09:00:00'),
  ('B9C16E7F-3F10-4B23-CE01-6F558DF6FFF7', 'C9D57B2E-8A12-4D78-B6C3-1A823DF1AED2', 'Lakeside Cottage', 'Peaceful cottage with private dock and lake access. Enjoy fishing, swimming, and beautiful sunsets.', 'Lake Tahoe, CA', 225.00, '2024-03-01 11:45:00', '2024-03-05 16:30:00');

-- Insert Bookings
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'E3D19B4D-6C10-4F56-9E34-3C825DF3CED4', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', '2024-06-10', '2024-06-15', 1750.00, 'confirmed', '2024-03-15 14:00:00'),
  ('22222222-2222-2222-2222-222222222222', 'F5B18C5E-5D12-4C45-AE23-4D736DF4DFE5', 'B7F52C7A-2F13-47D9-A3B2-9D632DF0AFB1', '2024-07-01', '2024-07-05', 800.00, 'confirmed', '2024-03-20 10:30:00'),
  ('33333333-3333-3333-3333-333333333333', 'A7A17D6F-4E11-4D34-BD12-5E647DF5EFF6', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', '2024-08-15', '2024-08-20', 875.00, 'pending', '2024-04-01 16:45:00'),
  ('44444444-4444-4444-4444-444444444444', 'E3D19B4D-6C10-4F56-9E34-3C825DF3CED4', 'B7F52C7A-2F13-47D9-A3B2-9D632DF0AFB1', '2024-09-05', '2024-09-10', 1750.00, 'canceled', '2024-04-10 09:15:00'),
  ('55555555-5555-5555-5555-555555555555', 'B9C16E7F-3F10-4B23-CE01-6F558DF6FFF7', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', '2024-07-20', '2024-07-25', 1125.00, 'confirmed', '2024-04-15 11:30:00');

-- Insert Payments 
INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method)
VALUES 
  ('11111111-6183-4512-9031-210143F21111', '11111111-1111-1111-1111-111111111111', 1750.00, '2024-03-15 14:05:00', 'credit_card'),
  ('22222222-5174-4412-9041-312923F32222', '22222222-2222-2222-2222-222222222222', 800.00, '2024-03-20 10:35:00', 'paypal'),
  ('33333333-4165-4322-9051-413832F43333', '55555555-5555-5555-5555-555555555555', 1125.00, '2024-04-15 11:35:00', 'stripe');

-- Insert Reviews
INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at)
VALUES 
  ('AABBCC11-1234-5678-90AB-CDEF12345678', 'E3D19B4D-6C10-4F56-9E34-3C825DF3CED4', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', 5, 'Amazing beachfront property! The views were breathtaking and the amenities were top-notch. We especially loved the infinity pool. Will definitely book again.', '2024-06-16 10:30:00'),
  
  ('BBCCDD22-2345-6789-ABCD-EF1234567890', 'F5B18C5E-5D12-4C45-AE23-4D736DF4DFE5', 'B7F52C7A-2F13-47D9-A3B2-9D632DF0AFB1', 4, 'Great location in downtown. The loft was stylish and comfortable. Only giving 4 stars because the street noise was a bit loud at night, but otherwise perfect.', '2024-07-06 14:15:00'),
  
  ('CCDDEE33-3456-789A-BCDE-F12345678901', 'A7A17D6F-4E11-4D34-BD12-5E647DF5EFF6', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', 5, 'Cozy mountain cabin with incredible views! The fireplace made our evenings so special. Everything was clean and well-maintained.', '2024-08-21 16:20:00'),
  
  ('DDEEFF44-4567-89AB-CDEF-123456789012', 'B9C16E7F-3F10-4B23-CE01-6F558DF6FFF7', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', 4, 'Peaceful lakeside retreat. Enjoyed fishing off the private dock and watching sunsets. Kitchen could use some updating, but overall a wonderful stay.', '2024-07-26 09:45:00'),
  
  ('EEFF5555-5678-9ABC-DEF1-2345678901233', 'E3D19B4D-6C10-4F56-9E34-3C825DF3CED4', 'B7F52C7A-2F13-47D9-A3B2-9D632DF0AFB1', 3, 'The villa has great potential but needs some maintenance. Beach access was as advertised but we had issues with the air conditioning during our stay.', '2024-04-15 11:20:00');

-- Insert Messages
INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at)
VALUES 
  ('T3312Q9S-9R29-4962-OP91-8R478DF8RST9', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', '28F72E56-75D9-4A27-A502-5A324A47FF14', 'Hi, I''m interested in your Beachfront Villa. Is it available for the dates I selected? Also, is the beach private or public access?', '2024-03-10 16:30:00'),
  ('U5211R0T-8S10-3872-PQ01-9S387DF9STU0', '28F72E56-75D9-4A27-A502-5A324A47FF14', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', 'Yes, those dates are available. The beach is a public beach but very secluded and rarely crowded. Would you like to proceed with the booking?', '2024-03-10 17:15:00'),
  ('V7110S1U-7T01-2782-QR11-0T296DF0TUV1', 'A5E55CA5-5C18-4EE1-A1B4-9C518DF231B2', '28F72E56-75D9-4A27-A502-5A324A47FF14', 'Great, I''ve just completed the booking. Is there a check-in code or key pickup process? Also, is parking available on the property?', '2024-03-15 14:10:00'),
  ('W9012T2V-6U92-1692-RS21-1U105DF1UVW2', 'B7F52C7A-2F13-47D9-A3B2-9D632DF0AFB1', 'C9D57B2E-8A12-4D78-B6C3-1A823DF1AED2', 'Hello, does the Mountain Cabin have WiFi? I need to work remotely during my stay. And is the fireplace wood-burning or gas?', '2024-03-25 11:00:00'),
  ('X1911U3W-5V83-0502-ST31-2V014DF2VWX3', 'C9D57B2E-8A12-4D78-B6C3-1A823DF1AED2', 'B7F52C7A-2F13-47D9-A3B2-9D632DF0AFB1', 'Yes, we have high-speed WiFi throughout the cabin. The password will be in the welcome book. The fireplace is gas with a remote control for easy operation. Let me know if you have any other questions!', '2024-03-25 13:45:00');
```
