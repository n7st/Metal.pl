-- Convert schema '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/2/001-auto.yml' to '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE stat (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL
);

;
CREATE TABLE user_stat (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  user_id integer NOT NULL,
  stat_id integer NOT NULL,
  FOREIGN KEY (stat_id) REFERENCES stat(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX user_stat_idx_stat_id ON user_stat (stat_id);

;
CREATE INDEX user_stat_idx_user_id ON user_stat (user_id);

;

COMMIT;

