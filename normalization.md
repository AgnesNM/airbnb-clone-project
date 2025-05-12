# Third Normal Form (3NF)

A relation is in 3NF if it satisfies 2NF and additionally, there are no transitive dependencies. In simpler terms, non-prime attributes should not depend on other non-prime attributes. 

Our database is comprised of different relations as shown in the [ER diagram](https://github.com/AgnesNM/airbnb-clone-project/blob/main/ERD/Database%20Specification%20-%20AirBnB.drawio.png)

For a table to be in 3NF, it must:

    - Be in 2NF (which requires it to be in 1NF and have no partial dependencies)
    - Have no transitive dependencies (where non-key attributes depend on other non-key attributes)

## The User Table   

    - The primary key is user_id (a UUID)
    - All attributes directly depend on the primary key
    - There are no transitive dependencies where one non-key column determines another non-key column
    
This table meets 3NF requirements.

## The Property Table 

    - There are no transitive dependencies. All non-key attributes depend directly on the primary key and not on other non-key attributes.
    - Proper use of foreign keys: Instead of duplicating host information within the Property table (which would violate 3NF), the design uses host_id as a foreign key to reference the complete host information stored in         the User table.
    - Separation of concerns: The design properly separates property data from user data, with each entity having its own dedicated table and attributes that directly describe that entity's characteristics.
    
This table meets 3NF requirements.

## The Booking Table 

    - There are no transitive dependencies where non-key attributes depend on other non-key attributes. Each attribute directly depends on the primary key.
    - Proper separation of concerns. While total_price is related to the property's price_per_night and the booking duration, it's correctly stored in the Booking table.
    - Proper referential integrity. Foreign keys to Property and User tables maintain data consistency without introducing redundancy.

This table meets 3NF requirements.

## The Payment Table

    - Each attribute directly depends on the payment_id (the primary key), and there are no transitive dependencies between the non-key attributes. The booking_id serves as a foreign key to maintain referential integrity       with the Booking table.
    
This table meets 3NF requirements.
