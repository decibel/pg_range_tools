SELECT plan(
  0
  + 2 * (SELECT count(*)::int FROM test)
);

SELECT is(
    :install_schema.range__create(
        expected
        , lower(expected)
        , upper(expected)
    )
    , expected
    , 'range__create from ' || description
  )
  FROM test
;

SELECT is(
    :install_schema.range_from_array(input)
    , expected
    , description
  )
  FROM test
;

\i test/pgxntool/finish.sql
