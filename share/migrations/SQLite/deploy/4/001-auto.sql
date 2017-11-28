-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Tue Nov 28 18:20:00 2017
-- 

;
BEGIN TRANSACTION;
--
-- Table: role
--
CREATE TABLE role (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL
);
--
-- Table: stat
--
CREATE TABLE stat (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL
);
--
-- Table: user
--
CREATE TABLE user (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  hostmask varchar(100) NOT NULL,
  name varchar(45) NOT NULL,
  lastfm varchar(20),
  ignored integer
);
--
-- Table: user_role
--
CREATE TABLE user_role (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  user_id integer NOT NULL,
  role_id integer NOT NULL,
  FOREIGN KEY (role_id) REFERENCES role(id),
  FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX user_role_idx_role_id ON user_role (role_id);
CREATE INDEX user_role_idx_user_id ON user_role (user_id);
--
-- Table: user_stat
--
CREATE TABLE user_stat (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  user_id integer NOT NULL,
  stat_id integer NOT NULL,
  FOREIGN KEY (stat_id) REFERENCES stat(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX user_stat_idx_stat_id ON user_stat (stat_id);
CREATE INDEX user_stat_idx_user_id ON user_stat (user_id);
COMMIT;
