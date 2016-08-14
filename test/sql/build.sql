\set ECHO none

\i test/pgxntool/psql.sql

BEGIN;
-- NOTE! This is NOT the .sql file!
\i sql/range_tools.plain

\echo # TRANSACTION INTENTIONALLY LEFT OPEN!

-- vi: expandtab sw=2 ts=2
