
CREATE TABLE make (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE model (
  id SERIAL,
  name VARCHAR(128),
  make_id INTEGER REFERENCES make(id) ON DELETE CASCADE,
  PRIMARY KEY(id)
);


INSERT INTO make (name) VALUES ('Chevrolet');
INSERT INTO make (name) VALUES ('Mercedes-Benz');

INSERT INTO model (name, make_id) VALUES ('Tahoe K1500 4WD', 1);
INSERT INTO model (name, make_id) VALUES ('Tracker 2WD Convertible', 1);
INSERT INTO model (name, make_id) VALUES ('Tracker 2WD Hardtop', 1);
INSERT INTO model (name, make_id) VALUES ('E320 (Wagon)', 2);
INSERT INTO model (name, make_id) VALUES ('E320 4Matic', 2);
