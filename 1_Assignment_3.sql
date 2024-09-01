CREATE TABLE student (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE course CASCADE;
CREATE TABLE course (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE roster CASCADE;
CREATE TABLE roster (
    id SERIAL,
    student_id INTEGER REFERENCES student(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
    role INTEGER,
    UNIQUE(student_id, course_id),
    PRIMARY KEY (id)
);

INSERT INTO student (name) VALUES ('Wasif');
INSERT INTO student (name) VALUES ('Brook');
INSERT INTO student (name) VALUES ('Kallan');
INSERT INTO student (name) VALUES ('Mysha');
INSERT INTO student (name) VALUES ('Zakaria');
INSERT INTO student (name) VALUES ('Kandel');
INSERT INTO student (name) VALUES ('Madinah');
INSERT INTO student (name) VALUES ('Siergiej');
INSERT INTO student (name) VALUES ('Soul');
INSERT INTO student (name) VALUES ('Woyenbrakemi');
INSERT INTO student (name) VALUES ('Walid');
INSERT INTO student (name) VALUES ('Amaylyuh');
INSERT INTO student (name) VALUES ('Kiarra');
INSERT INTO student (name) VALUES ('Shergo');
INSERT INTO student (name) VALUES ('Tyrone');

INSERT INTO course (title) VALUES ('si106');
INSERT INTO course (title) VALUES ('si110');
INSERT INTO course (title) VALUES ('si206');

INSERT INTO roster (student_id, course_id, role) VALUES (1, 1, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (2, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (3, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (4, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (5, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (6, 2, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (7, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (8, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (9, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (10, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (11, 3, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (12, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (13, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (14, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (15, 3, 0);