\i test/pgxntool/setup.sql

CREATE TEMP TABLE test(
  description text NOT NULL
  , input :subtype[] NOT NULL
  , expected :range_type NOT NULL
);


