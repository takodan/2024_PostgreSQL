# Intermediate PostgreSQL
## Module 1 SQL Techniques
1. Altering Table
```sql
ALTER TABLE table_name DROP COLUMN column_name;
ALTER TABLE table_name ALTER　COLUMN column_name TYPE TEXT;
ALTER TABLE table_name ADD COLUMN column_name INTEGER;
```

2. Reading from a File
```bash
\i file_name.sql
```

3. DATE
    1. `DATE`: 'YYY-MM-DD'
    2. `TIME`: 'HH:MM:SS'
    3. `TIMESTAMP`: 'YYY-MM-DD HH:MM:SS'
    4. `TIMESTAMPTZ`: TIMESTAMP with time zone
    5. `NOW()`: return a `TIMESTAMPTZ` with current time
```sql
-- set default values with NOW()
CREATE TABLE table_name(
    what_time TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- different time zone
SELECT NOW(), NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'HST';

-- shows available time zone in PostgreSQL.
-- There are 591 rows, so you may want to use WHERE...LIKE...
SELECT * from pg_timezone_names;

-- CASTing
SELECT NOW()::DATE;
-- same as
SELECT CAST(NOW() AS DATE);

SELECT CAST(NOW() AS TIME);

-- Intervals arithmetic 間隔計算
-- two days ago
SELECT NOW() - INTERVAL '2 days';

(SELECT NOW() - INTERVAL '2 days')::DATE;


-- truncating 截短
-- can be use with WHERE to select a period of time
SELECT * FROM table_name
    WHERE what_date >= DATE_TRUNC('day', NOW())
    AND what_date < DATE_TRUNC('day', NOW())

-- using DATE_TRUNC is faster then CAST in this upcoming situation
SELECT * FROM table_name
    WHERE what_date::DATE = NOW()::DATE;
```

4. DISTINCT / GROUP BY
    1. to remove vertical replications as the result of a SELECT statement
    2. `DISTINCT`: only return unique row
    3. `DISTINCT ON`: `DISTINCT` to a set of columns
    4. `GROUP BY`: can combined with aggregate function like `COUNT()`, `MAX()`, `SUM()`, etc.
```sql
-- DISTINCT
SELECT DISTINCT column1 FROM table_name;

SELECT DISTINCT ON (column1) column2, column1 FROM table_name;

SELECT DISTINCT ON (column1) column2, column1 FROM table_name ORDER BY column2 DESC;

-- GROUP BY
-- to count the number of same rows in column1
SELECT COUNT(column1), column1 FROM table_name GROUP BY column1; 

-- to count the number of rows WHERE column2 = value2 and only shows those > 10
-- 計算column2中等於value2的rows, 只顯示次數大於10的結果
SELECT COUNT(column1) AS ct, column1 FROM table_name
    WHERE column2=value2 GROUP BY column1 HAVING COUNT(column1) > 10;
```

5. Sub-query
    1. do a sub-query then feed the result into another query
    2. it's less abstraction, so it might be harder for DBMS to optimize.
```sql
SELECT COUNT(column1) AS ct, column1 FROM table_name
    WHERE column2=value2 GROUP BY column1 HAVING COUNT(column1) > 10;

-- same as
SELECT ct column1 FROM (
    -- sub-query
    SELECT COUNT(column1) AS ct, column1 FROM table_name
    WHERE column2=value2 GROUP BY column1
) AS zap
WHERE ct > 10;
```

6. Concurrency, Transactions and Atomicity
    1. SQL DBMS will "locks' areas before it starts a command
    2. `RETURNING`: return the row after a command
    3. `ON CONFLICT...DO...`: do... if try... fail
    4. `BEGIN`: initiates a transaction block
    5. `ROLLBACK`: end the current transaction block and abort it
    6. `COMMIT`: end the current transaction and commit it
    5. `FOR UPDATE`: causes the rows retrieved by the SELECT statement to be locked as though for update
    5. Concurrency is a vast topic with much to explore.

```sql
INSERT INTO table_name (column1, column2)
    VALUE (1, 1)
    ON CONFLICT (column1)
    DO UPDATE SET column2 = table_name.column2 + 1
RETURNING *;

-- transaction
BEGIN;
SELECT column1 FROM table_name WHERE column2 = value2 FOR UPDATE OF table_name;
UPDATE table_name SET column1 = 1 WHERE column2 = value2;
ROLLBACK;

BEGIN;
SELECT column1 FROM table_name WHERE column2 = value2 FOR UPDATE OF table_name;
UPDATE table_name SET column1 = 1 WHERE column2 = value2;
COMMIT;
```


7. Stored Procedures
    1. reuseable code that runs inside of the database
    2. goal is to have fewer SQL statements
    3. generally non-portable, can't transfer to another DBMS
```sql
-- create FUNCTION
CREATE OR REPLACE FUNCTION trigger_function_name()
RETURNS TRIGGER AS $$
BEGIN
    NEW.column1 = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- create TRIGGER
CREATE TRIGGER set_column1
BEFORE UPDATE ON table_name
FOR EACH ROW
EXECUTE PROCEDURE trigger_function_name()
```


## Module 2 Using SQL Techniques
1. `2_Assignment_1.sql`
2. `2_Assignment_2.sql`
3. `2_Assignment_3.sql`

## Module 3 Text in PostgreSQL
1. There are some functions in PostgreSQL that Generate data to text the performance of the database
    1. repeat()
    2. generate_series()
    3. random()
```sql
-- repeat 'word' 5 times
SELECT repeat('word', 5);

-- generate 5 rows with series number 1 to 5
SELECT generate_series(1, 5)

-- generate random number
SELECT trunc(random()*100);

-- generate 5 rows of random data
SELECT generate_series(1, 5) || 'string' || trunc(random()*100);
-- e.g., 1string7, 2string81,  3string42, 4string64, 5string67
```
2. String Functions
    - https://www.postgresql.org/docs/current/functions-string.html

```sql
CREATE TABLE text_table(
    content TEXT
);

-- create a b-tree index
CREATE INDEX text_table_b ON text_table(content);

-- to see data size and indexes size
CREATE pg_relation_size('text_table'), pg_indexes_size('text_table');

-- generate radom data tin to the table
INSERT INTO text_table (content)
SELECT(CASE WHEN (random() < 0.5)
    THEN 'if random() < 0.5 add this string'
    ELSE 'else add this string'
    END) || generate_series(100000, 200000);

-- LIKE, ILIKE
SELECT content FROM text_table WHERE content LIKE '%150000%';
-- "if random() < 0.5 add this string150000"

SELECT content FROM text_table WHERE content LIKE '%1_0000%';
-- " else add this string100000"
-- "if random() < 0.5 add this string110000"
-- "else add this string120000"
-- ...

-- upper(), lower(), right(), left()
SELECT upper(content) FROM text_table WHERE content LIKE '%150000%';
-- "IF RANDOM() < 0.5 ADD THIS STRING150000"

SELECT right(content, 5) FROM text_table WHERE content LIKE '%150000%';
-- "50000"

-- strpos()
SELECT strpos(content, 'ran') FROM text_table WHERE content LIKE '%150000%';
-- 4

-- substr(), splitpart() translate()
```

3. Performance
    1. `explain analyze` to see the details of the operation, e.g., 'Scan Type', 'Execution Time'
    2. add `LIMIT` with `LIKE` so scan can stop earlier when it find the first few results
```sql
explain analyze SELECT content FROM text_table WHERE content LIKE '%150000%';

-- Index Only Scan: faster
-- Seq Scan: slower

```

4. Character Sets
    1. ASCII: the earliest widely used character set.
    2. There are many different character sets used for various languages before Unicode.
    3. Unicode: the most widely used character set today.
    4. UTF-8 is a character encoding standard that encodes Unicode.
    5. `SHOW SERVER_ENCODING`: show the database server's encoding.
    6. in Python, sometime you my have to decode data manually

5. Hash
    1. any function that can be
    2. use
        1. Checksum
        2. Cryptography/Signature
        3. For fast lookup
    3. hash function
        1. Deterministic: the same out put for the same input
        2. Uniform Distribution: should have an equal chance of generating any value with the range of its outputs
        3. Sensitive: any change of input should change output
        4. One-way: not able to derive the input from the output
    4. Bruce Schneier: Building Cryptographic Systems https://youtu.be/opT6pIfyGUs

6. Index Techniques
```sql
-- using md5 as indexes
CREATE UNIQUE INDEX table_name_md5 ON table_name (md5(column1));

-- find the row using md5 in a md5 index
SELECT * FROM table_name WHERE md5(column1) = md5('value1');

-- you can also create a md5 column when create a table
CREATE TABLE table_name (
    id SERIAL,
    column1 TEXT,
    column1_md5 UUID UNIQUE, -- UUID is a 128 bits data type can store md5 hash value
    column2 TEXT, 
)

-- UPDATE md5 for the existing data in UUID
UPDATE table_name set column1_md5 = md5(column1)::UUID;


-- hash index, help only on exact lookup
CREATE UNIQUE INDEX table_name_md5 ON table_name USING HASH column1;

SELECT * FROM table_name WHERE column1 = 'value1';
```


## Module 4 
1. think Regular Expressions as an another programming language.
2. RegEx cheat sheet
    1. `^`        Matches the beginning of a line
    2. `$`        Matches the end of the line
    3. `.`        Matches any character
    4. `\s`       Matches whitespace
    5. `\S`       Matches any non-whitespace character
    6. `*`        Repeats a character zero or more times
    7. `*?`       Repeats a character zero or more times (non-greedy)
    8. `+`        Repeats a character one or more times
    9. `+?`       Repeats a character one or more times (non-greedy)
    10. `[aeiou]` Matches a single character in the listed set
    11. `[^XYZ]`  Matches a single character not in the listed set
    12. `[a-z0-9]`The set of characters can include a range
    13. `(`       Indicates where string extraction is to start
    14. `)`       Indicates where string extraction is to end
3. RegEx in PostgreSQL
    1. `~`  match
    2. `~`  match (case insensitive)
    3. `!~` Does not match
    4. `!~*`Does not match (case insensitive)
```sql
SELECT column1 FROM table_name WHERE column1 ~ 'string';

SELECT substring( email FROM '.+@(.*)$') FROM table_name;
-- 'string@gmail.com' will return 'gmail.com'

SELECT substring(email FROM '.+@(.*)$'),
    count(substring(email FROM '.+@(.*)$'))
    FROM table_name GROUP BY (email FROM '.+@(.*)$');

-- multiple matches
SELECT column1, regexp_matches(column2, '#([A-Za-z0-9_]+)', 'g') FROM table_name;
-- 'g': all the way cross

```