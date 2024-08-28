# Database Design and Basic SQL in PostgreSQL
## Module 1
### Introduction to SQL
1. History
    1. Before Relational Databases: Sequential Master Update using Magnetic tape(1970s)
    2. HDD become more common, but databases software isn't sophisticated enough to meet all the needs. Companies at this time often bundle software with their hardware.
    3. NIST came out a standardize database model: Structured Query Language (SQL)

2. SQL
    1. It's a non-procedural language
    2. We only need to express what we want in SQL, and the system will organize efficient procedures to fulfill them.
    3. Different companies can have different system implementations, but they all command using SQL.
    4. The critical notion is CRUD
        1. Create/Insert
        2. Read/Select
        3. Update
        4. Delete
    5. user uses client(like pgAdmin or psql)

3. Terminology
    1. Database: contains one or more tables
    2. Relation (table): contain tup孬and attributes
    3. Tuple (row): a set of field which generally represent an "object" like a person or a product
    4. Attributes (column or field): one of possibly many elements of data corresponding to the object represented by row

4. From an abstract perspective, SQL database is a spreadsheet.

5. Using SQL
    1. User use client (like pgAdmin or psql) to command
    2. client forwards SQL to Database Server (like PostgreSQL)
```bash
psql -U postgres # start psql as a super user "postgres"

\l # list database
CREATE USER account_name WITH PASSWORD 'password';
CREATE DATABASE people WITH OWNER 'account_name';
\q # quit psql
```
```bash
psql -U account_name # start psql as a user "account_name"

# create a table
CREATE TABLE users(
    name VARCHAR(128),
    email VARCHAR(128)
);

\dt # display tables in the database
\d+ users # display "users" table with the schema
\i file.sql # run commands from file.sql
```

6. Assessment: Inserting Some Data into a Table
```sql
CREATE TABLE ages ( 
  name VARCHAR(128), 
  age INTEGER
);
```
```sql
DELETE FROM ages;
INSERT INTO ages (name, age) VALUES ('Ayaan', 29);
INSERT INTO ages (name, age) VALUES ('Conan', 39);
INSERT INTO ages (name, age) VALUES ('Nima', 31);
INSERT INTO ages (name, age) VALUES ('Patrikas', 14);
INSERT INTO ages (name, age) VALUES ('Rochelle', 16);
```

## Module 2
