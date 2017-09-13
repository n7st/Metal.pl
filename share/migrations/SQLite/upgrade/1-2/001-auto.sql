-- Convert schema '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/1/001-auto.yml' to '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE role (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL
);

;
CREATE TABLE user_role (
  date_created datetime NOT NULL,
  date_modified datetime NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  user_id integer NOT NULL,
  role_id integer NOT NULL,
  FOREIGN KEY (role_id) REFERENCES role(id),
  FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX user_role_idx_role_id ON user_role (role_id);

;
CREATE INDEX user_role_idx_user_id ON user_role (user_id);

;

COMMIT;

