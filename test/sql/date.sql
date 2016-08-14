\set ECHO none

\set range_type tsrange
\set subtype timestamp
\i test/helpers/type_setup.sql

INSERT INTO test VALUES
    ( 'current_date +/- 1'
      , array[
          current_date
          , current_date + 1
          , current_date + 1
          , current_date + 1
          , current_date - 1
          , current_date - 1
          , current_date - 1
        ]
      , :range_type(
          current_date - 1
          , current_date + 1
          , '[]'
      )
    )
;


\i test/helpers/type_run.sql

-- vi: expandtab ts=2 sw=2
