SELECT plan(
  0
  + 1 * (SELECT count(*)::int FROM test)
);

SELECT is(
    :install_schema.range_from_array(input)
    , expected
    , description
  )
  FROM test
;

\i test/pgxntool/finish.sql
