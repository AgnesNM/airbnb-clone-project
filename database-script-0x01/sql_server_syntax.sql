-- User Table
CREATE TABLE [User] (
  user_id UNIQUEIDENTIFIER PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone_number VARCHAR(255) NULL,
  role VARCHAR(10) NOT NULL CHECK (role IN ('guest', 'host', 'admin')),
  created_at DATETIME DEFAULT GETDATE()
);
CREATE INDEX index_user_email ON [User](email);

-- Property Table
CREATE TABLE Property (
  property_id UNIQUEIDENTIFIER PRIMARY KEY,
  host_id UNIQUEIDENTIFIER NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  location VARCHAR(255) NOT NULL,
  price_per_night DECIMAL(10,2) NOT NULL,
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (host_id) REFERENCES [User](user_id)
);
CREATE INDEX index_property_id ON Property(property_id);

-- Booking Table
CREATE TABLE Booking (
  booking_id UNIQUEIDENTIFIER PRIMARY KEY,
  property_id UNIQUEIDENTIFIER NOT NULL,
  user_id UNIQUEIDENTIFIER NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  status VARCHAR(10) NOT NULL CHECK (status IN ('pending', 'confirmed', 'canceled')),
  created_at DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (property_id) REFERENCES Property(property_id),
  FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
CREATE INDEX index_booking_id ON Booking(booking_id);
CREATE INDEX index_booking_property ON Booking(property_id);

-- Payment Table
CREATE TABLE Payment (
  payment_id UNIQUEIDENTIFIER PRIMARY KEY,
  booking_id UNIQUEIDENTIFIER NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_date DATETIME DEFAULT GETDATE(),
  payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('credit_card', 'paypal', 'stripe')),
  FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);
CREATE INDEX index_payment_booking ON Payment(booking_id);

-- Review Table
CREATE TABLE Review (
  review_id UNIQUEIDENTIFIER PRIMARY KEY,
  property_id UNIQUEIDENTIFIER NOT NULL,
  user_id UNIQUEIDENTIFIER NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT NOT NULL,
  created_at DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (property_id) REFERENCES Property(property_id),
  FOREIGN KEY (user_id) REFERENCES [User](user_id)                                              
);

-- Message Table
CREATE TABLE Message (
  message_id UNIQUEIDENTIFIER PRIMARY KEY,
  sender_id UNIQUEIDENTIFIER NOT NULL,
  recipient_id UNIQUEIDENTIFIER NOT NULL,
  message_body TEXT NOT NULL,
  sent_at DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (sender_id) REFERENCES [User](user_id),
  FOREIGN KEY (recipient_id) REFERENCES [User](user_id)                                             
);
