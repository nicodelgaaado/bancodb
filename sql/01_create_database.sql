\set ON_ERROR_STOP on

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'bancodb'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS bancodb WITH (FORCE);

CREATE DATABASE bancodb
  WITH
  ENCODING = 'UTF8'
  CONNECTION LIMIT = -1;
