-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Apr  6 19:59:45 2017
-- 

;
BEGIN TRANSACTION;
--
-- Table: server
--
CREATE TABLE server (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  hostname varchar(50) NOT NULL,
  port varchar(6) NOT NULL,
  connect integer(1) NOT NULL,
  join_chan integer(1) NOT NULL,
  debug integer(1) NOT NULL,
  ssl integer(1) NOT NULL,
  nickname varchar(9),
  ident varchar(11) NOT NULL
);
--
-- Table: channel
--
CREATE TABLE channel (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(30) NOT NULL,
  server_id integer NOT NULL,
  FOREIGN KEY (server_id) REFERENCES server(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX channel_idx_server_id ON channel (server_id);
COMMIT;
