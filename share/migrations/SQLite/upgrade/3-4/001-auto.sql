-- Convert schema '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/3/001-auto.yml' to '/mnt/Private/Projects/Metal/Metal/share/migrations/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE user ADD COLUMN ignored integer;

;

COMMIT;

