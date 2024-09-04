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