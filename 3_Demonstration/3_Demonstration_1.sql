
-- https://www.pg4e.com/lectures/05-FullText.sql

-- Strings, arrays, and rows

SELECT string_to_array('Hello world', ' ');
SELECT unnest(string_to_array('Hello world', ' '));

-- Inverted string index with SQL

CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));
INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');
SELECT * FROM docs;

--- https://stackoverflow.com/questions/29419993/split-column-into-multiple-rows-in-postgres


-- Create a inverted string index table
CREATE TABLE docs_gin (
  keyword TEXT,
  doc_id INTEGER REFERENCES docs(id) ON DELETE CASCADE
);

-- Insert the keyword / primary key rows into a table
INSERT INTO docs_gin (doc_id, keyword)
-- Break the document column into one row per word + primary key, and discard duplicate rows
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(D.doc, ' ')) s(keyword)
ORDER BY id;

SELECT * FROM docs_gin ORDER BY doc_id;


-- Find all the distinct documents that match a keyword
SELECT DISTINCT id, doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = 'UMSI';

-- We can have more than one keyword
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword IN ('fun', 'people');

-- We can also handle a phrase
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = ANY(string_to_array('I want to learn', ' '));




-- Inverted string index with stop words using SQL

-- If we know the documents contain natural language, we can optimize indexes

-- (1) Ignore the case of words in the index and in the query
-- (2) Don't index low-meaning "stop words" that we will ignore
-- if they are in a search query

DROP TABLE docs CASCADE;
CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));
INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');
SELECT * FROM docs;

--- https://stackoverflow.com/questions/29419993/split-column-into-multiple-rows-in-postgres

-- Create a inverted string index table
DROP TABLE docs_gin CASCADE;
CREATE TABLE docs_gin (
  keyword TEXT,
  doc_id INTEGER REFERENCES docs(id) ON DELETE CASCADE
);

DROP TABLE stop_words;
CREATE TABLE stop_words (word TEXT unique);
INSERT INTO stop_words (word) VALUES ('is'), ('this'), ('and');

-- Throw out the words in the stop word list and lower the case
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY id;

-- Put the stop-word free list into the GIN
INSERT INTO docs_gin (doc_id, keyword)
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY id;

SELECT * FROM docs_gin;

-- A one word query
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = lower('UMSI');

-- A multi-word query
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword =
  ANY(string_to_array(lower('Meet fun people'), ' '));

-- A stop word query - as if it were never there
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = lower('and');

-- Add stemming
-- https://www.pg4e.com/lectures/05-FullText.sql

-- We can make the index even smaller
-- (3) Only store the "stems" of words

-- Our simple approach is to make a "dictionary" of word -> stem

CREATE TABLE docs_stem (word TEXT, stem TEXT);
INSERT INTO docs_stem (word, stem) VALUES
('teaching', 'teach'), ('teaches', 'teach');


-- Add the stems as third column (may or may not exist)
SELECT id, keyword, stem FROM (
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

-- If the stem is there, replace keyword with it
SELECT id,
CASE WHEN stem IS NOT NULL THEN stem ELSE keyword END AS k_replaced,
keyword, stem
FROM (
SELECT DISTINCT id, lower(s.keyword) AS keyword
FROM docs AS D, unnest(string_to_array(D.doc, ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

-- Null Coalescing - return the first non-null in a list
SELECT COALESCE(NULL, NULL, 'umsi');
SELECT COALESCE('umsi', NULL, 'SQL');


-- Insert only the stems with COALESCE()
DELETE FROM docs_gin;

INSERT INTO docs_gin (doc_id, keyword)
SELECT id, COALESCE(stem, keyword)
FROM (
  SELECT DISTINCT id, s.keyword AS keyword
  FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

SELECT * FROM docs_gin;

-- stop words and stems together
DELETE FROM docs_gin;

INSERT INTO docs_gin (doc_id, keyword)
SELECT id, COALESCE(stem, keyword)
FROM (
  SELECT DISTINCT id, s.keyword AS keyword
  FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
  WHERE s.keyword NOT IN (SELECT word FROM stop_words)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

SELECT * FROM docs_gin;


-- Handling the stems in queries.
-- if lower('SQL') in stem, use it. else use lower('SQL')
SELECT COALESCE((SELECT stem FROM docs_stem WHERE word=lower('teaching')), lower('teaching'));

SELECT DISTINCT id, doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = COALESCE((SELECT stem FROM docs_stem WHERE word=lower('teaching')), lower('teaching'));

-- The technical term for converting search terms to their stems is called "conflation"
-- from https://en.wikipedia.org/wiki/Stemming