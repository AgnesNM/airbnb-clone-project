# Airbnb Clone Backend Project

## Project Overview
This project implements a backend system for an Airbnb-like rental marketplace platform. The system provides APIs and services to support property listings, user management, bookings, payments, and administrative functions.

## System Actors
The system interacts with the following actors:
- **Guests**: Users who search for and book properties
- **Hosts**: Users who list and manage properties
- **Admins**: System administrators who oversee platform operations
- **Payment Gateways**: External systems that process financial transactions

## UML Use Case Diagram
The repository includes a UML Use Case Diagram that visually represents all system functionalities and actor interactions. The diagram follows standard UML notation and provides a high-level overview of the system's behavior.

## User Stories

### Host User Stories

#### Property Management
1. **As a Host**, I want to create property listings with detailed information so that I can advertise my properties to potential guests.
2. **As a Host**, I want to update my property listings so that I can keep information current and accurate.
3. **As a Host**, I want to set availability for my properties so that I can control when my properties can be booked.
4. **As a Host**, I want to define pricing for my listings so that I can optimize my revenue based on seasons and demand.
5. **As a Host**, I want to upload multiple photos of my property so that guests can see what they're booking.

#### Financial Management
6. **As a Host**, I want to receive funds transferred to my account after successful bookings so that I can get paid for hosting guests.
7. **As a Host**, I want to view my booking history and earnings so that I can track my revenue.

#### Guest Interaction
8. **As a Host**, I want to respond to reviews left by guests so that I can address feedback and maintain my reputation.
9. **As a Host**, I want to communicate with guests before their arrival so that I can provide check-in instructions.

### Guest User Stories

#### Account Management
10. **As a Guest**, I want to register an account so that I can book properties and track my reservations.
11. **As a Guest**, I want to log in via email or password so that I can access my account securely.
12. **As a Guest**, I want to log in via OAuth (Google, Facebook) so that I can access my account without remembering another password.
13. **As a Guest**, I want to update my profile information so that hosts have accurate information about me.
14. **As a Guest**, I want to upload a profile photo so that hosts can identify me.

#### Property Search and Booking
15. **As a Guest**, I want to search for properties based on location, price, and amenities so that I can find accommodations that meet my needs.
16. **As a Guest**, I want to book a property for specific dates so that I can secure my accommodation for travel.
17. **As a Guest**, I want to make secure payments for my bookings so that I can safely complete transactions.
18. **As a Guest**, I want to leave reviews after my stay so that I can share my experience with other potential guests.
19. **As a Guest**, I want to receive booking confirmations so that I have proof of my reservation.

#### Financial Management
20. **As a Guest**, I want to receive refunds for canceled bookings so that I don't lose money when plans change.

### Admin User Stories

#### System Management
21. **As an Admin**, I want to log in through a secure admin portal so that I can access the system's administrative functions.
22. **As an Admin**, I want to monitor user accounts so that I can ensure platform integrity and address suspicious activities.
23. **As an Admin**, I want to manage property listings so that I can moderate content and ensure compliance with platform policies.
24. **As an Admin**, I want to track booking activities so that I can understand platform usage patterns.

#### Financial Oversight
25. **As an Admin**, I want to oversee payment transactions so that I can resolve financial disputes and ensure proper fund flows.
26. **As an Admin**, I want to generate daily reports so that I can track daily operational metrics.
27. **As an Admin**, I want to generate weekly reports so that I can analyze broader usage trends.

#### Customer Support
28. **As an Admin**, I want to handle user disputes and issues so that I can maintain customer satisfaction and platform reputation.
29. **As an Admin**, I want to manage my admin account so that I can maintain secure access to administrative functions.

### Payment Gateway Integration Stories

#### Transaction Processing
30. **As a Payment Gateway**, I want to process guest payments securely so that financial transactions are completed safely.
31. **As a Payment Gateway**, I want to issue refunds when bookings are canceled so that guests receive their money back according to platform policies.
32. **As a Payment Gateway**, I want to transfer funds to hosts after successful stays so that hosts receive their earnings in a timely manner.

## Technical Requirements

- **Database**: PostgreSQL or MySQL
- **API Design**: RESTful architecture with proper HTTP methods
- **Authentication**: JWT-based with role-based access control
- **File Storage**: AWS S3 or equivalent for property images
- **Payment Processing**: Integration with payment gateway APIs
- **Email Notifications**: SendGrid or equivalent
- **Testing**: Comprehensive unit and integration tests


