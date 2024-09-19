-- create tables
DROP TABLE album CASCADE;
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE track CASCADE;
CREATE TABLE track (
    id SERIAL,
    title TEXT, 
    artist TEXT, 
    album TEXT, 
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    count INTEGER, 
    rating INTEGER, 
    len INTEGER,
    PRIMARY KEY(id)
);

DROP TABLE artist CASCADE;
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE tracktoartist CASCADE;
CREATE TABLE tracktoartist (
    id SERIAL,
    track VARCHAR(128),
    track_id INTEGER REFERENCES track(id) ON DELETE CASCADE,
    artist VARCHAR(128),
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);

-- load CSV data file into the track table
\copy track(title, artist, album, count, rating, len) FROM 'D:\3_Work\2_repos\2024_PostgreSQL\library.csv' WITH DELIMITER ',' CSV;

-- insert of the distinct data into the corresponding table
INSERT INTO album (title) SELECT DISTINCT album FROM track;
UPDATE track SET album_id = (SELECT album.id FROM album WHERE album.title = track.album);

INSERT INTO tracktoartist (track, artist) SELECT DISTINCT title, artist FROM track;

INSERT INTO artist (name) SELECT DISTINCT artist FROM track;

-- UPDATE the track_id and artist_id in the tracktoartist table
UPDATE tracktoartist SET track_id = (
    SELECT track.id FROM track WHERE tracktoartist.track = track.title
);

UPDATE tracktoartist SET artist_id = (
    SELECT artist.id FROM artist WHERE tracktoartist.artist = artist.name
);


--  removes all of the un-normalized text columns
ALTER TABLE track DROP COLUMN album;
ALTER TABLE track DROP COLUMN artist;
ALTER TABLE tracktoartist DROP COLUMN track;
ALTER TABLE tracktoartist DROP COLUMN artist;

-- check answer
SELECT track.title, album.title, artist.name
FROM track
JOIN album ON track.album_id = album.id
JOIN tracktoartist ON track.id = tracktoartist.track_id
JOIN artist ON tracktoartist.artist_id = artist.id
ORDER BY track.title
LIMIT 3;