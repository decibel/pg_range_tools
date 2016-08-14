INSERT INTO test VALUES
    ( 'now() +/- 1us'
      , array[
          now()
          , now() + interval '1 us'
          , now() - interval '1 us'
        ]
      , :range_type(
          now():::subtype - interval '1 us'
          , now():::subtype + interval '1 us'
          , '[]'
      )
    )

  , ( 'timezone test'
      , array[
          '2000-1-1'::timestamptz AT TIME ZONE 'CST6CDT'
          , '2000-1-1'::timestamptz AT TIME ZONE 'MST7MDT'
          , '2000-1-1'::timestamptz AT TIME ZONE 'EST5EDT'
        ]
      , :range_type(
        '2000-1-1'::timestamptz AT TIME ZONE 'MST7MDT'
        , '2000-1-1'::timestamptz AT TIME ZONE 'EST5EDT'
        , '[]'
      )
    )
;

-- vi: expandtab ts=2 sw=2
