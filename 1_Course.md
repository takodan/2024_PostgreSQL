# Database Design and Basic SQL in PostgreSQL
## Module 1 Introduction to SQL
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
    2. Relation (table): contain tuple and attributes
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
`psql -d [database] -U [user] -p [port] -h [host]`
```bash
psql -U account_name # start psql database "account_name" as a user "account_name"

# create a table
CREATE TABLE users(
    name VARCHAR(128),
    email VARCHAR(128)
);

\dt # display tables in the database
\d+ users # display "users" table with the schema
\i file.sql # run commands from file.sql
```

### ASSESSMENT: Inserting Some Data into a Table
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

## Module 2 Single Table SQL
### PostgreSQL commands
1. Insert
```sql
INSERT INTO table_name (column_1, column_2) VALUE ('value_1', 'value_2');
```
2. Delete
    1. From an abstract perspective, database seems loop through a table.
    2. In fact, DBMS will complete it in a more efficient way.
```sql
DELETE FROM table_name WHERE column_1='some_value';
```
3. Update
```sql
UPDATE table_name SET column_1 ='new_value' WHERE column_2='value_2';
```
4. Retrieving (Select)
```sql
SELECT * FROM table_name WHERE column_1='value_1';
SELECT column_1, column_2 FROM table_name WHERE column_1='value_1';
```
5. Sorting (Order By)
```sql
SELECT * FROM table_name ORDER BY column_1;
SELECT * FROM table_name ORDER BY column_1 DESC;
```
6. LIKE
```sql
SELECT * FROM table_name WHERE column_1 Like '%e%'
```
7. LIMIT/OFFSET
    1. request 'n' rows, or 'n' rows after skipping some rows. It's like paging.
    1. `OFFSET` starts from row 0
```sql
SELECT * FROM table_name ORDER BY column_1 LIMIT 2; 
SELECT * FROM table_name ORDER BY column_1 OFFSET 1 LIMIT 3; 
```
8. Counting Rows
```sql
SELECT COUNT(*) FROMtable_name WHERE column_1='value_1';
```


### PostgreSQL Data Types
1. String Field: 
    1. have character set and are indexable for searching
    2. `CHAR(n)`: fix space, but usually faster for small string.
    3. `VARCHAR(n)`: set the maximum, only use as much space as the value itself.
2. Test Field
    1. have character set, usually for paragraphs or HTML pages
    2. Generally not used with indexing or sorting 
    3. `TEXT`: varying length.
3. Binary Type
    1. rarely used because they don't have character set
    2. `BYTEA(n)`: up to 255 bytes.
4. Integer Numbers
    1. `SMALLINT`: -32768, +32768
    2. `INTEGER`: 2 Billion
    3. `BIGINT`: 10**18 ish
5. Floating Point Numbers
    1. `REAL`: 32bit, 10**38 with 7 digits of accuracy
    2. `DOUBLE PRECISION`: 64bit, 10**308 with 14 digits of accuracy
    3. `NUMERIC(accuracy, decimal)`: specified digits of accuracy and digits after the decimal point (deal with money use NUMERIC)
6. Dates
    1. `TIMESTAMP`: 64 bit, 'YYYY-MM-DD HH:MM:SS' (4713BC, 294276 AD)
    2. `DATE`: 'YYYY-MM-DD'
    3. `TIME`: 'HH:MM:SS'


### PostgreSQL Keys and Indexes
1. SERIAL, UNIQUE, PRIMARY KEY
    1. `SERIAL`: automatically increment integer row numbers
    2. `UNIQUE`: a logical key. Use a index to avoid duplicates.
    3. `PRIMARY KEY`: set a primary key for a row that make DBMS can find it fast
```sql
CREATE TABLE users(
    id SERIAL
    name VARCHAR(128),
    email VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);
```
2. PostgreSQL Function
    1. PostgreSQL also have a lots of built-in functions. (like `NOW()`)
    2. Go check the document for yourself

3. Indexes
    1. a short cut to find a data
    2. Hashes or Trees are the most common index

4. B-Tree
    1. Basically, it's about partitioning space into various ranges.
    2. pros
        1. good for exact match lookup
        2. help for sorting
        3. help for range lookup
        4. good fo prefix lookup

5. Hashes
    1. Hash_function(Keys) = Hashes
    2. super fast, but only good for exact match (like PRIMARY KEY or GUID)

### ASSESSMENT
```sql
CREATE TABLE automagic(
    id SERIAL,
    name VARCHAR(32) NOT NULL,
    height REAL NOT NULL
);
```
```sql
CREATE TABLE track_raw(
    title TEXT, artist TEXT, album TEXT,
    count INTEGER, rating INTEGER, len INTEGER
);

\copy track_raw(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;

SELECT title, album FROM track_raw ORDER BY title LIMIT 3;
```

