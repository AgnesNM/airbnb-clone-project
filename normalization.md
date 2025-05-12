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
