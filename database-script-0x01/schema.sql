```sql
CREATE TABLE User (
  user_id UUID PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone_number VARCHAR(255) NULL,
  role ENUM('guest', 'host', 'admin') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
);

CREATE INDEX index_user_email ON User(email);

CREATE TABLE Property (
  property_id UUID PRIMARY KEY,
  host_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  location VARCHAR(255) NOT NULL,
  price_per_night DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (host_id) REFERENCES User(user_id)
);

CREATE INDEX index_property_id ON Property(property_id);

CREATE TABLE Booking (
  booking_id UUID PRIMARY KEY,
  property_id UUID NOT NULL,
  user_id UUID NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (property_id) REFERENCES Property(property_id),
  FOREIGN KEY (user_id) REFERENCES User(user_id)
);

CREATE INDEX index_booking_id ON Booking(booking_id);
CREATE INDEX index_booking_property ON Booking(property_id);
```

