-- create tables
CREATE TABLE unesco_raw (
    name TEXT, description TEXT, justification TEXT, year INTEGER,
    longitude FLOAT, latitude FLOAT, area_hectares FLOAT,
    category TEXT, category_id INTEGER, state TEXT, state_id INTEGER,
    region TEXT, region_id INTEGER, iso TEXT, iso_id INTEGER
);

CREATE TABLE category (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE state (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE region (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE iso (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

-- load CSV data file into the unesco_raw table
\copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso) FROM 'D:\3_Work\2_repos\2024_PostgreSQL\whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER;

-- normalize the data
INSERT INTO category (name) 
SELECT DISTINCT category FROM unesco_raw;

INSERT INTO state (name) 
SELECT DISTINCT state FROM unesco_raw;

INSERT INTO region (name) 
SELECT DISTINCT region FROM unesco_raw;

INSERT INTO iso (name) 
SELECT DISTINCT iso FROM unesco_raw;

-- adding the foreign key columns to the unesco_raw
ALTER TABLE unesco_raw
ADD FOREIGN KEY (category_id) REFERENCES category(id);

ALTER TABLE unesco_raw
ADD FOREIGN KEY (state_id) REFERENCES state(id);

ALTER TABLE unesco_raw
ADD FOREIGN KEY (region_id) REFERENCES region(id);

ALTER TABLE unesco_raw
ADD FOREIGN KEY (iso_id) REFERENCES iso(id);

UPDATE unesco_raw SET category_id = (
    SELECT category.id FROM category WHERE category.name = unesco_raw.category
);

UPDATE unesco_raw SET state_id = (
    SELECT state.id FROM state WHERE state.name = unesco_raw.state
);

UPDATE unesco_raw SET region_id = (
    SELECT region.id FROM region WHERE region.name = unesco_raw.region
);

UPDATE unesco_raw SET iso_id = (
    SELECT iso.id FROM iso WHERE iso.name = unesco_raw.iso
);

--  make a new table called unesco that removes all of the un-normalized redundant text columns
CREATE TABLE unesco (
    name TEXT, description TEXT, justification TEXT, year INTEGER,
    longitude FLOAT, latitude FLOAT, area_hectares FLOAT,
    category_id INTEGER, state_id INTEGER,
    region_id INTEGER, iso_id INTEGER
);

INSERT INTO unesco (name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id)
SELECT name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id FROM unesco_raw;

-- check answer
SELECT unesco.name, unesco.year, category.name, state.name, region.name, iso.name
    FROM unesco
    JOIN category ON unesco.category_id = category.id
    JOIN iso ON unesco.iso_id = iso.id
    JOIN state ON unesco.state_id = state.id
    JOIN region ON unesco.region_id = region.id
    ORDER BY iso.name, unesco.name
    LIMIT 3;