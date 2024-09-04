-- create tables
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
    len INTEGER, rating INTEGER, count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS track_raw;
CREATE TABLE track_raw (
    title TEXT, artist TEXT, album TEXT, album_id INTEGER,
    count INTEGER, rating INTEGER, len INTEGER
);

-- load CSV data file into the track_raw table
\copy track_raw(title, artist, album, count, rating, len) FROM 'D:\3_Work\2_repos\2024_PostgreSQL\library.csv' WITH DELIMITER ',' CSV HEADER;

-- insert all of the distinct albums into the album table
INSERT INTO album (title) 
SELECT album FROM track_raw
ON CONFLICT DO NOTHING;

-- set the album_id in the track_raw table using album table
UPDATE track_raw SET album_id = (
    SELECT album.id FROM album WHERE album.title = track_raw.album
);

--  copy the corresponding data from the track_raw table to the track table
INSERT INTO track (title, len, rating, count, album_id) 
SELECT title, len, rating, count, album_id FROM track_raw;

-- check answer
SELECT track.title, album.title
FROM track
JOIN album ON track.album_id = album.id
ORDER BY track.title LIMIT 3;