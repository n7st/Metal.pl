-- Convert schema '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/4/001-auto.yml' to '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE user_temp_alter (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  hostmask varchar(100) NOT NULL,
  name varchar(45) NOT NULL,
  lastfm varchar(20)
);

;
INSERT INTO user_temp_alter( date_created, date_modified, id, hostmask, name, lastfm) SELECT date_created, date_modified, id, hostmask, name, lastfm FROM user;

;
DROP TABLE user;

;
CREATE TABLE user (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  hostmask varchar(100) NOT NULL,
  name varchar(45) NOT NULL,
  lastfm varchar(20)
);

;
INSERT INTO user SELECT date_created, date_modified, id, hostmask, name, lastfm FROM user_temp_alter;

;
DROP TABLE user_temp_alter;

;

COMMIT;

