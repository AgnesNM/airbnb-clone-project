# Airbnb Clone Backend - Requirement Specifications

## 1. User Authentication System

### Functional Requirements

#### 1.1 User Registration
Users must be able to create new accounts with unique email addresses, specifying whether they are registering as a guest or host.

**API Endpoint:**
```
POST /api/v1/auth/register
```

**Request Payload:**
```json
{
  "email": "string",
  "password": "string",
  "firstName": "string",
  "lastName": "string",
  "userType": "guest|host",
  "phoneNumber": "string (optional)"
}
```

**Response Payload:**
```json
{
  "id": "string (UUID)",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "userType": "guest|host",
  "createdAt": "datetime",
  "token": "string (JWT)"
}
```

**Validation Rules:**
- Email must be valid format and unique in the system
- Password must be minimum 8 characters, containing at least one uppercase letter, one lowercase letter, one number, and one special character
- First name and last name are required and must be 2-50 characters
- User type must be either "guest" or "host"
- Phone number, if provided, must be in valid international format

#### 1.2 User Login
Users must be able to authenticate using their email and password credentials.

**API Endpoint:**
```
POST /api/v1/auth/login
```

**Request Payload:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response Payload:**
```json
{
  "id": "string (UUID)",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "userType": "guest|host",
  "token": "string (JWT)",
  "expiresAt": "datetime"
}
```

**Validation Rules:**
- Email must exist in the system
- Password must match stored (hashed) password
- Account must not be suspended or deactivated

#### 1.3 OAuth Authentication
Users must be able to authenticate using OAuth providers (Google, Facebook).

**API Endpoint:**
```
POST /api/v1/auth/oauth/{provider}
```

**Request Payload:**
```json
{
  "accessToken": "string",
  "userType": "guest|host (optional)"
}
```

**Response Payload:**
```json
{
  "id": "string (UUID)",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "userType": "guest|host",
  "token": "string (JWT)",
  "expiresAt": "datetime",
  "isNewUser": "boolean"
}
```

**Validation Rules:**
- Access token must be valid with the specified OAuth provider
- If new user, user type must be specified

#### 1.4 Token Refresh
Users must be able to refresh their authentication token without re-entering credentials.

**API Endpoint:**
```
POST /api/v1/auth/refresh
```

**Request Payload:**
```json
{
  "refreshToken": "string"
}
```

**Response Payload:**
```json
{
  "token": "string (JWT)",
  "refreshToken": "string",
  "expiresAt": "datetime"
}
```

**Validation Rules:**
- Refresh token must be valid and not expired
- Refresh token must not be blacklisted

#### 1.5 Logout
Users must be able to invalidate their current session.

**API Endpoint:**
```
POST /api/v1/auth/logout
```

**Request Payload:**
None (uses Authorization header)

**Response Payload:**
```json
{
  "success": true
}
```

### Technical Requirements

#### 1.6 Authentication Mechanism
- JWT (JSON Web Tokens) must be used for authentication
- Tokens must have a configurable expiration time (default: 24 hours)
- Refresh tokens must have a longer expiration (default: 30 days)
- All passwords must be hashed using bcrypt with a minimum work factor of 10

#### 1.7 Security
- All authentication endpoints must use HTTPS
- Rate limiting must be implemented (max 5 failed attempts per minute per IP)
- Failed login attempts must be logged with timestamps and IP addresses
- Suspicious activity (multiple failed attempts) must trigger account protection measures

#### 1.8 Performance Criteria
- Registration process must complete within 2 seconds
- Login process must complete within 1 second
- Token validation must occur in under 100ms
- System must support 100 concurrent authentication requests

#### 1.9 Error Handling
- Detailed error messages for validation failures
- Generic error messages for security-sensitive operations (e.g., "Invalid credentials" instead of specifying which field is incorrect)
- All authentication errors must be logged (without sensitive data)

## 2. Property Management System

### Functional Requirements

#### 2.1 Create Property Listing
Hosts must be able to create new property listings with detailed information.

**API Endpoint:**
```
POST /api/v1/properties
```

**Request Payload:**
```json
{
  "title": "string",
  "description": "string",
  "propertyType": "apartment|house|room|other",
  "address": {
    "street": "string",
    "city": "string",
    "state": "string",
    "zipCode": "string",
    "country": "string",
    "latitude": "number (optional)",
    "longitude": "number (optional)"
  },
  "amenities": ["string", "string"],
  "bedrooms": "integer",
  "beds": "integer",
  "bathrooms": "number",
  "maxGuests": "integer",
  "pricePerNight": "number",
  "cleaningFee": "number (optional)",
  "serviceFee": "number (optional)",
  "cancellationPolicy": "flexible|moderate|strict",
  "houseRules": ["string (optional)"]
}
```

**Response Payload:**
```json
{
  "id": "string (UUID)",
  "title": "string",
  "description": "string",
  "propertyType": "apartment|house|room|other",
  "address": {
    "street": "string",
    "city": "string",
    "state": "string",
    "zipCode": "string",
    "country": "string",
    "latitude": "number",
    "longitude": "number"
  },
  "amenities": ["string", "string"],
  "bedrooms": "integer",
  "beds": "integer",
  "bathrooms": "number",
  "maxGuests": "integer",
  "pricePerNight": "number",
  "cleaningFee": "number",
  "serviceFee": "number",
  "cancellationPolicy": "flexible|moderate|strict",
  "houseRules": ["string"],
  "hostId": "string (UUID)",
  "status": "draft|published",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

**Validation Rules:**
- Title must be 10-100 characters
- Description must be 50-2000 characters
- Property type must be one of the allowed values
- Address fields are required (except latitude/longitude)
- Bedrooms, beds, and maxGuests must be positive integers
- Bathrooms must be a positive number (supporting half bathrooms)
- PricePerNight must be a positive number
- User must be authenticated with "host" role

#### 2.2 Upload Property Images
Hosts must be able to upload multiple images for their property listings.

**API Endpoint:**
```
POST /api/v1/properties/{propertyId}/images
```

**Request Payload:**
Form data with:
- images[] (multiple file uploads)
- primaryImage (boolean, optional, for each image)

**Response Payload:**
```json
{
  "images": [
    {
      "id": "string (UUID)",
      "url": "string",
      "isPrimary": "boolean",
      "order": "integer",
      "createdAt": "datetime"
    }
  ],
  "totalCount": "integer"
}
```

**Validation Rules:**
- Maximum 20 images per property
- Each image must be JPG, PNG, or WebP format
- Maximum file size: 10MB per image
- At least one image must be marked as primary

#### 2.3 Update Property Listing
Hosts must be able to update their property listing details.

**API Endpoint:**
```
PUT /api/v1/properties/{propertyId}
```

**Request Payload:**
Same as Create Property, with all fields optional

**Response Payload:**
Same as Create Property Response

**Validation Rules:**
- Same field validations as Create Property
- User must be the owner of the property
- Property must exist

#### 2.4 Set Property Availability
Hosts must be able to define when their property is available for booking.

**API Endpoint:**
```
POST /api/v1/properties/{propertyId}/availability
```

**Request Payload:**
```json
{
  "availabilityWindows": [
    {
      "startDate": "date",
      "endDate": "date"
    }
  ],
  "blockedDates": ["date", "date"],
  "minimumStay": "integer (optional)",
  "maximumStay": "integer (optional)"
}
```

**Response Payload:**
```json
{
  "propertyId": "string (UUID)",
  "availabilityWindows": [
    {
      "id": "string (UUID)",
      "startDate": "date",
      "endDate": "date"
    }
  ],
  "blockedDates": ["date", "date"],
  "minimumStay": "integer",
  "maximumStay": "integer",
  "updatedAt": "datetime"
}
```

**Validation Rules:**
- Start date must be before end date
- Dates must not be in the past
- Availability windows must not overlap with existing bookings
- Minimum stay must be at least 1 night
- Maximum stay must be greater than or equal to minimum stay

#### 2.5 Get Property Details
Users must be able to view detailed information about a property.

**API Endpoint:**
```
GET /api/v1/properties/{propertyId}
```

**Response Payload:**
Same as Create Property Response plus:
```json
{
  "images": [
    {
      "id": "string (UUID)",
      "url": "string",
      "isPrimary": "boolean",
      "order": "integer"
    }
  ],
  "host": {
    "id": "string (UUID)",
    "firstName": "string",
    "lastName": "string",
    "profileImage": "string (URL)",
    "joinedDate": "datetime",
    "responseRate": "number (percentage)"
  },
  "ratings": {
    "average": "number",
    "total": "integer",
    "cleanliness": "number",
    "communication": "number",
    "checkIn": "number",
    "accuracy": "number",
    "location": "number",
    "value": "number"
  },
  "availability": {
    "availabilityWindows": [...],
    "blockedDates": [...],
    "minimumStay": "integer",
    "maximumStay": "integer"
  }
}
```

### Technical Requirements

#### 2.6 Database Design
- Properties must be stored in a dedicated table/collection
- Property images must be stored in a separate table/collection with foreign key relationship
- Availability data must be stored efficiently to support fast querying of available dates
- Geographic coordinates must be stored to support proximity searches

#### 2.7 File Storage
- Property images must be stored in cloud storage (AWS S3 or equivalent)
- Images must be processed to create multiple resolutions:
  - Thumbnail (200x200px)
  - Medium (800x600px)
  - Full (1600x1200px)
- Images must be optimized for web delivery (compression, proper format)

#### 2.8 Performance Criteria
- Property creation must complete within 3 seconds
- Image upload (batch of 5 images) must complete within 8 seconds
- Property listing retrieval must complete within 500ms
- Search results must be returned within 2 seconds
- System must support 50 concurrent property creation/update operations

#### 2.9 Error Handling
- Validation errors must provide clear field-specific messages
- Image upload failures must be clearly reported with reason
- All property management errors must be logged with property IDs and user IDs

## 3. Booking System

### Functional Requirements

#### 3.1 Create Booking
Guests must be able to book a property for specified dates.

**API Endpoint:**
```
POST /api/v1/bookings
```

**Request Payload:**
```json
{
  "propertyId": "string (UUID)",
  "checkInDate": "date",
  "checkOutDate": "date",
  "guestCount": "integer",
  "specialRequests": "string (optional)",
  "paymentMethodId": "string"
}
```

**Response Payload:**
```json
{
  "id": "string (UUID)",
  "propertyId": "string (UUID)",
  "property": {
    "title": "string",
    "address": {
      "city": "string",
      "state": "string",
      "country": "string"
    },
    "primaryImage": "string (URL)"
  },
  "guestId": "string (UUID)",
  "hostId": "string (UUID)",
  "checkInDate": "date",
  "checkOutDate": "date",
  "guestCount": "integer",
  "specialRequests": "string",
  "status": "pending|confirmed|cancelled|completed",
  "paymentStatus": "pending|completed|failed|refunded",
  "totalAmount": "number",
  "breakdown": {
    "nightsCount": "integer",
    "nightlyRate": "number",
    "subtotal": "number",
    "cleaningFee": "number",
    "serviceFee": "number",
    "taxes": "number"
  },
  "createdAt": "datetime"
}
```

**Validation Rules:**
- Property must exist and be available for the requested dates
- Check-in date must be in the future
- Check-out date must be after check-in date
- Booking duration must meet property's minimum and maximum stay requirements
- Guest count must not exceed property's maximum guests
- User must be authenticated with "guest" role
- Dates must not conflict with existing bookings or blocked dates
- Payment method must be valid

#### 3.2 Get Booking Details
Users must be able to view their booking details.

**API Endpoint:**
```
GET /api/v1/bookings/{bookingId}
```

**Response Payload:**
Same as Create Booking Response plus:
```json
{
  "host": {
    "id": "string (UUID)",
    "firstName": "string",
    "lastName": "string",
    "profileImage": "string (URL)",
    "phoneNumber": "string (only shown after booking confirmation)"
  },
  "cancellationPolicy": {
    "type": "flexible|moderate|strict",
    "description": "string",
    "refundable": "boolean",
    "refundableUntilDate": "datetime (if applicable)"
  },
  "checkInInstructions": "string (only shown after payment)",
  "timeline": [
    {
      "status": "booked|confirmed|canceled|completed",
      "timestamp": "datetime"
    }
  ]
}
```

#### 3.3 Cancel Booking
Users must be able to cancel their bookings according to cancellation policies.

**API Endpoint:**
```
POST /api/v1/bookings/{bookingId}/cancel
```

**Request Payload:**
```json
{
  "reason": "string (optional)"
}
```

**Response Payload:**
```json
{
  "id": "string (UUID)",
  "status": "cancelled",
  "cancellationDate": "datetime",
  "refundAmount": "number",
  "refundStatus": "processing|completed|none",
  "cancellationReason": "string"
}
```

**Validation Rules:**
- Booking must exist
- User must be the guest who made the booking or the host of the property
- Booking must be in "pending" or "confirmed" status
- Cancellation must comply with property's cancellation policy

#### 3.4 List User Bookings
Users must be able to view their booking history.

**API Endpoint:**
```
GET /api/v1/bookings
```

**Query Parameters:**
- status: "upcoming|past|cancelled" (optional)
- page: integer (optional, default: 1)
- limit: integer (optional, default: 10)
- sortBy: "checkInDate|createdAt" (optional, default: "checkInDate")
- sortDirection: "asc|desc" (optional, default: "asc")

**Response Payload:**
```json
{
  "bookings": [
    {
      "id": "string (UUID)",
      "propertyId": "string (UUID)",
      "property": {
        "title": "string",
        "primaryImage": "string (URL)",
        "address": {
          "city": "string",
          "state": "string",
          "country": "string"
        }
      },
      "checkInDate": "date",
      "checkOutDate": "date",
      "status": "pending|confirmed|cancelled|completed",
      "totalAmount": "number"
    }
  ],
  "pagination": {
    "total": "integer",
    "page": "integer",
    "limit": "integer",
    "pages": "integer"
  }
}
```

#### 3.5 Process Payment for Booking
System must process payment for a booking.

**API Endpoint:**
```
POST /api/v1/bookings/{bookingId}/payment
```

**Request Payload:**
```json
{
  "paymentMethodId": "string",
  "savePaymentMethod": "boolean (optional)"
}
```

**Response Payload:**
```json
{
  "bookingId": "string (UUID)",
  "transactionId": "string",
  "paymentStatus": "pending|completed|failed",
  "amount": "number",
  "paymentMethod": "string (masked, e.g., **** 4242)",
  "timestamp": "datetime"
}
```

**Validation Rules:**
- Booking must exist
- Booking must be in "pending" status
- User must be the guest who made the booking
- Payment method must be valid

### Technical Requirements

#### 3.6 Database Design
- Bookings must be stored in a dedicated table/collection
- Booking status changes must be stored in a history table
- Payment information must be stored securely in a separate table
- Efficient indexing for date-based queries

#### 3.7 Payment Processing
- Integration with payment gateway (Stripe/PayPal)
- Support for multiple payment methods (credit card, PayPal)
- Secure handling of payment information (PCI compliance)
- Support for currency conversion based on user's locale

#### 3.8 Concurrency Handling
- Implement optimistic locking to prevent double bookings
- Use database transactions for booking + payment operations
- Implement a booking hold mechanism (temporary reservation)

#### 3.9 Performance Criteria
- Booking creation must complete within 5 seconds (including payment processing)
- Booking retrieval must complete within 300ms
- Cancellation must complete within 2 seconds
- System must support 20 concurrent booking operations
- Availability checks must complete within 200ms

#### 3.10 Error Handling
- Payment failures must be clearly reported with appropriate error messages
- Double booking attempts must be detected and prevented
- All booking operations must be logged with transaction IDs
- Failed bookings must trigger cleanup operations

#### 3.11 Notification System
- Email notifications for booking confirmation, cancellation, and reminders
- Support for SMS notifications (optional)
- Notifications to both guest and host for status changes
