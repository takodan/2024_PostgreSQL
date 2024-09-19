# JSON and Natural Language Processing in PostgreSQL
## Module 1 Natural Language
1. PostgreSQL arrange the file into blocks (default 8K) and pack the rows into blocks.
2. Block leaves some free space to make inserts, updates, or deletes possible without needing to rewrite a large file.
3. PostgreSQL read an entire block into memory (i.e. not just one row).

4. Forward indexes: You give the index a logical key and it tells you where to find the row that contains the key. (eg., B-Tree, BRIN, Hash)
5. Inverse indexes: most typical use is for text search. you give the index a string (query) and the index gives you a list of all the rows that match the query. (e.g., GIN, GiST)

6. Inverted Indexes without using the built-in feature of PostgreSQL
    1. `string_to_array('Hello word', ' ');`
    2. `unnest(string_to_array('Hello word', ' '));`: turn array in to separate rows.
    3. Use these two function to turn documents in to something like this:
    ```
    keyword | doc_id
    ----------+--------
    Python   |      1
    SQL      |      1
    This     |      1
    stuff    |      1
    teaching |      1
    More     |      2
    SQL      |      2
    UMSI     |      2
    from     |      2
    learn    |      2
    people   |      2
    should   |      2
    Python   |      3
    SQL      |      3
    UMSI     |      3
    also     |      3
    and      |      3
    teaches  |      3
    ```
    4. Using stemming and stop words to reduce the size of the index.
        1. Stop words: function words that contribute little to the meaning of a sentence
        2. Stemming: a technique used to reduce words to their root form.
    5. Example in `3_Demonstration_1.sql`



## Module 2 Inverted Indexes with PostgreSQL
1. Generalized Inverse Index (GIN)
    1. Advantages: exact matches, efficient on lookup/search. 
    2. Disadvantages: can be costly when inserting or updating
2. Generalized Search Tree (GiST) indexes: Hashing is used to reduce the size of and cost to update the GiST
    1. GiST is faster to build, but slower to lookups compare with GIN
    2. GiST index size is smaller compare with GIN
3. `ts_vector()`
    1. processing an array and returns a list of words that represent the document
    2. preserving only the semantically meaningful components, akin to and stemming
    3. this process call "conflation"
4. `ts_query()`
    1. returns a list of words with operators to representations various logical combinations
    2. use it when doing a query
5. `@@` operator
    ```sql
    -- is to_tsquery(...) in to_tsvector(...)? return 't' or 'f'
    SELECT to_tsquery('english', 'teaching') @@ to_tsvector('english', 'UMSI also teaches Python and also SQL');
    ```
6. `<->` operator
    ```sql
    -- follow by
    SELECT count(column1) FROM table_name WHERE to_tsquery('english', 'tiny <-> tim') @@ to_tsvector('english', column1);
    ```
7. Example in `3_Demonstration_2.sql`
8. More `ts` operators in `3_Demonstration_3.sql`



## Module 3 Python and PostgreSQL
1. psycopg2
```py
conn = psycopg2.connect(host=secrets['host'],
        port=secrets['port'],
        database=secrets['database'], 
        user=secrets['user'], 
        password=secrets['pass'], 
        connect_timeout=3)
cur = conn.cursor()

sql = 'DROP TABLE IF EXISTS pythonfun CASCADE;'
print(sql)
cur.execute(sql)

conn.commit()
```
2. Demonstration: Loading The Text of a Book
    1. `loadbook.py`
    2. file_name as the table_name
    3. every paragraph as a row
    4. `commit()` every 50 rows
    5. print "loaded..." every 100 rows


3. Demonstration: Loading Email Data
    1. `gmane.py`, `datecompat.py`
    2. catch ctrl c so the program can commit SQL before it stop
    ```py
    try:
        pass
    except KeyboardInterrupt:
        print('')
        print('Program interrupted by user...')
        break
    ```
    3. most of the code is used to clean text data (using Regex)before it is stored in SQL
    4. sql substring
    ```sql
    -- substring
    SELECT substring('hello@example.com' FROM '([^@]+)') AS username;
    ```
    5. `ts_rank`
        - https://www.postgresql.org/docs/current/textsearch-controls.html#TEXTSEARCH-RANKING



## Module 4 JSON and PostgreSQL
1. timeline: HTML -> XML -> AJAX -> JSON
2. JSON is suitable for data with a key-value structure.
3. JSON in Python
```py
import json

data = {}

# Serialize dictionary to JSON
print(json.dumps(data, indent=4))

# Deserialize JSON to dictionary
info = json.loads(data)
```
4. key/value data in PostgreSql
    1. hstore: like a Python dictionary without support for nested data structures
    2. JSON: JSON-like TEXT columns
    3. JSONB: completely new column type that stores the parsed JSON
```sql
CREATE TABLE table_name (id SERIAL, body JSONB);

-- to copy a file into data base as json, using CSV with an irrelevant non-printing character as QUOTE and DELIMITER
-- E'\x01' is ASCII number 1, E'\x02' is ASCII number 2  
\copy table_name (body) FROM 'json_file.jstxt' WITH CSV QUOTE E'\x01' DELIMITER E'\x02';

-- `->>` covert JSONB to TEXT
SELECT body->>'name' FROM table_name LIMIT 5;

```

