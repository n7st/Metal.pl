-- Convert schema '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/1/001-auto.yml' to '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE channel (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(30) NOT NULL,
  server_id integer NOT NULL,
  FOREIGN KEY (server_id) REFERENCES server(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX channel_idx_server_id ON channel (server_id);

;

COMMIT;

