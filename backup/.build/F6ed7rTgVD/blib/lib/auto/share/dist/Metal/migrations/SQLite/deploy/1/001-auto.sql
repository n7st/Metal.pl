-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Sep  7 19:50:53 2017
-- 

;
BEGIN TRANSACTION;
--
-- Table: user
--
CREATE TABLE user (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  hostmask varchar(100) NOT NULL,
  name varchar(45) NOT NULL,
  lastfm varchar(20)
);
COMMIT;
