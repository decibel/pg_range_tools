\set ECHO none

\set range_type tstzrange
\set subtype timestamptz
\i test/helpers/type_setup.sql

\i test/helpers/timestamp.sql

\i test/helpers/type_run.sql

-- vi: expandtab ts=2 sw=2
