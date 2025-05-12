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
- Proper use of foreign keys: Instead of duplicating host information within the Property table (which would violate 3NF), the design uses host_id as a foreign key to reference the complete host information stored in the     User table.
- Separation of concerns: The design properly separates property data from user data, with each entity having its own dedicated table and attributes that directly describe that entity's characteristics.

This database design follows good relational database principles, maintaining appropriate relationships between entities while avoiding redundancy and ensuring all attributes in the Property table are directly dependent on the property's unique identifier.
