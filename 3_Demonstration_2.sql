-- PostgreSQL built-in Inverse Index method (GIN)

DROP TABLE docs cascade;
CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));

-- The GIN (General Inverted Index) thinks about columns that contain arrays
-- A GIN needs to know what kind of data will be in the arrays
-- array_ops means that it is expecting text[] (arrays of strings)
-- and WHERE clauses will use array operators (i.e. like <@ )

DROP INDEX gin1;

CREATE INDEX gin1 ON docs USING gin(string_to_array(doc, ' ')  array_ops);

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');

-- Insert enough lines to get PostgreSQL attention
-- PostgreSQL might still use Seq Scan if there are not enough lines.
INSERT INTO docs (doc) SELECT 'Neon ' || generate_series(10000,20000);

-- You might need to wait a minute until the index catches up to the inserts
-- After you insert some lines, PostgreSQL needs time to update the index

-- The <@ if "is contained within" or "intersection" from set theory
SELECT id, doc FROM docs WHERE '{learn}' <@ string_to_array(doc, ' ');
EXPLAIN SELECT id, doc FROM docs WHERE '{learn}' <@ string_to_array(doc, ' ');


-- Using PostgreSQL built-in features (much easier and more efficient)
-- https://www.pg4e.com/lectures/05-FullText.sql

-- ts_vector is an special "array" of stemmed words, passed through a stop-word
-- filter + positions within the document
SELECT to_tsvector('english', 'This is SQL and Python and other fun teaching stuff');

-- ts_query is an "array" of lower case, stemmed words with
-- stop words removed plus logical operators & = and, ! = not, | = or
SELECT to_tsquery('english', 'teaching');
SELECT to_tsquery('english', 'Teach | teaches | teaching | and | the | if');

-- Plaintext just pulls out the keywords
SELECT plainto_tsquery('english', 'SQL Python');
SELECT plainto_tsquery('english', 'Teach teaches teaching and the if');

-- A phrase is words that come in order
SELECT phraseto_tsquery('english', 'SQL Python');

-- Websearch is in PostgreSQL >= 11 and a bit like
-- https://www.google.com/advanced_search
SELECT websearch_to_tsquery('english', 'SQL -not Python');

SELECT to_tsquery('english', 'teaching') @@
  to_tsvector('english', 'UMSI also teaches Python and also SQL');


-- Lets do an english language inverted index using a tsvector index.
-- https://www.pg4e.com/lectures/05-FullText.sql

DROP TABLE docs cascade;
DROP INDEX gin1;

CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));
CREATE INDEX gin1 ON docs USING gin(to_tsvector('english', doc));

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');

-- Filler rows
INSERT INTO docs (doc) SELECT 'Neon ' || generate_series(10000,20000);

SELECT id, doc FROM docs WHERE
    to_tsquery('english', 'learn') @@ to_tsvector('english', doc);
EXPLAIN SELECT id, doc FROM docs WHERE
    to_tsquery('english', 'learn') @@ to_tsvector('english', doc);


-- Check the operation types for the various indexes

-- SELECT version();   -- PostgreSQL 9.6.7
-- https://habr.com/en/company/postgrespro/blog/448746/

SELECT version();

SELECT am.amname AS index_method, opc.opcname AS opclass_name
    FROM pg_am am, pg_opclass opc
    WHERE opc.opcmethod = am.oid
    ORDER BY index_method, opclass_name;

