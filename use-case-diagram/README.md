# Airbnb Clone Use Case Diagram

## Overview
This repository contains a UML Use Case Diagram for an Airbnb Clone Backend application. The diagram visually represents the interactions between different actors and the system, illustrating the core functionalities and relationships between use cases in the application.

## Purpose
The Use Case Diagram serves to:
- Document the functional requirements of the Airbnb Clone Backend
- Identify all key actors and their interactions with the system
- Illustrate the relationships between different use cases
- Provide a high-level overview of the system's behavior
- Serve as a communication tool for stakeholders, developers, and analysts

## Actors
The diagram identifies the following actors:

### Human Actors
1. **Guest** - Users who search for and book properties
2. **Host** - Users who create and manage property listings
3. **Admin** - System administrators who oversee and manage the platform

### System Actors
4. **Payment Gateway** - External payment processing system (e.g., Stripe, PayPal)
5. **Email Service** - External email notification service (e.g., SendGrid, Mailgun)
6. **Cloud Storage** - External file storage system (e.g., AWS S3, Cloudinary)
7. **OAuth Providers** - External authentication providers (e.g., Google, Facebook)

## Use Cases
The diagram includes the following main use case categories:

### User Management
- Register
- Log in via email or password
- Log in via OAuth
- Update profile information
- Upload profile photo
- Admin login
- Manage Admin Account
- Monitor user accounts

### Property Management
- Create Property Listing (Host)
- Update Own Listing (Host)
- Set Availability (Host)
- Define Pricing (Host)
- Upload Images (Host)
- Manage Property Listings (Admin)

### Booking Process
- Search Properties
- Book Property
- Process Payment
- Confirm Booking
- Cancel Booking
- Track booking activities

### Financial Operations
- Process Guest Payment
- Issue Refund
- Transfer Funds to Host
- Oversee payment transactions

### Review System
- Leave Review
- Respond to Review

### Administrative Functions
- Generate System Reports
- Handle user disputes/issues

## Relationships
The diagram uses two types of relationships between use cases:

### Include Relationships (<<include>>)
Indicates that one use case necessarily incorporates the functionality of another use case.
- "Book Property" includes "Process Payment"
- "Register" includes "Verify Email"
- "Create Property Listing" includes "Upload Images"
- "Admin Login" includes "Two-Factor Authentication"

### Extend Relationships (<<extend>>)
Indicates that one use case may be augmented by another use case under specific conditions.
- "Cancel Booking" extends "Book Property"
- "Apply Discount" extends "Process Payment"
- "Dispute Resolution" extends "Complete Stay"

## System Boundary
The rectangle in the diagram represents the Airbnb Clone system boundary, clearly delineating what is inside the system (use cases) and what is outside (actors).

## How to Read the Diagram
- Actors (stick figures) represent external entities that interact with the system
- Ovals represent use cases (system functionalities)
- Lines between actors and use cases represent associations (interactions)
- Dashed arrows with <<include>> or <<extend>> stereotypes show relationships between use cases
- All use cases inside the rectangle are part of the Airbnb Clone system

## Technologies and Tools
This Use Case Diagram was created using Draw.io and follows standard UML 2.x notation.

## Next Steps
This Use Case Diagram serves as the foundation for more detailed system design, including:
- Sequence diagrams for important use cases
- Class diagrams for database structure
- Activity diagrams for complex workflows
- API endpoint design and documentation

