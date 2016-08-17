CREATE OR REPLACE VIEW range_type AS
  SELECT
      rngtypid::regtype AS range_type, rtn.nspname AS range_type_schema, rt.typname AS range_type_name
      , rngsubtype::regtype AS range_subtype, stn.nspname AS range_subtype_schema, st.typname AS range_subtype_name
      , rngcollation AS range_type_collation_oid, cn.nspname AS range_type_collation_schema, c.collname AS range_type_collation_name
      , rngsubopc AS range_type_operator_class_oid, oc.opcname AS range_type_operator_class_name, ocn.nspname AS range_type_operator_class_schema
      , rngcanonical AS range_type_canonical_function
      , rngsubdiff::regprocedure AS range_type_subdiff_function
    FROM pg_range r
      LEFT JOIN pg_type rt ON rt.oid = rngtypid
      LEFT JOIN pg_namespace rtn ON rtn.oid = rt.typnamespace
      LEFT JOIN pg_type st ON st.oid = rngsubtype
      LEFT JOIN pg_namespace stn ON stn.oid = st.typnamespace
      LEFT JOIN pg_collation c ON c.oid = rngcollation
      LEFT JOIN pg_namespace cn ON cn.oid = c.collnamespace
      LEFT JOIN pg_opclass oc ON oc.oid = rngsubopc
      LEFT JOIN pg_namespace ocn ON ocn.oid = oc.opcnamespace
;

CREATE OR REPLACE FUNCTION range__create(
  rangetype anyrange
  , lower anyelement
  , upper anyelement
  , bounds text DEFAULT '[]'
) RETURNS anyrange LANGUAGE plpgsql IMMUTABLE AS $body$
DECLARE
  sql CONSTANT text := format(
    $$SELECT %s( $1, $2, $3 ) AS range$$
    , pg_catalog.pg_typeof(rangetype)::text
  );

  r record;
BEGIN
  RAISE DEBUG 'sql = %', sql;

  EXECUTE sql INTO STRICT r USING lower, upper, bounds;

  RETURN r.range;
END;
$body$;
COMMENT ON FUNCTION range__create(
  rangetype anyrange
  , lower anyelement
  , upper anyelement
  , bounds text 
) IS $$Creates a range of "rangetype" type, from lower, upper and bounds. This is the same as calling the rangetype's constructor directly, but this way you don't have to use different function names. "rangetype" can be set to anything (including NULL); it just needs to be the correct type.$$;

CREATE OR REPLACE FUNCTION _range_from_array__create(
  range_type regtype
) RETURNS regprocedure LANGUAGE plpgsql
-- Do NOT set search_path here! Function needs to run with the calling search_path
AS $_range_from_array__create$
DECLARE
  subtype regtype;
  creation_function regproc;

  c_template CONSTANT text := $template$
-- This is a template!
CREATE OR REPLACE FUNCTION range_from_array(
    a %2$s[] -- 2:range_subtype
) RETURNS %1$s -- 1:range_type
LANGUAGE sql IMMUTABLE STRICT
SET search_path FROM CURRENT -- Make sure search path is same as when creation function was called
AS $range_from_array$
SELECT %3$s( -- 3:creation_function
      min(u)
      , max(u)
      , '[]'
    )
  FROM unnest(a) u
$range_from_array$;
$template$;
  
  sql text;
BEGIN
  SELECT INTO subtype, creation_function
      range_subtype
      , format(
        $$%1$s(%2$s, %2$s, text)$$
        , t.range_type -- Blindly assume function has same name as the range type
        , range_subtype
      )::regprocedure -- Note that this gets cast back to regproc
    FROM @extschema@.range_type t
    WHERE t.range_type = _range_from_array__create.range_type
  ;
  IF NOT FOUND THEN
    /*
     * Since range_type is of type regtype it must be a valid type, but it
     * might not be a range type. If we get here either it's not a range type
     * or our view is broken. :)
     */
    RAISE 'type "%" is not a range type', range_type
      USING ERRCODE = 'undefined_object'
    ;
  END IF;

  sql := format(
    c_template
    , range_type
    , subtype
    , creation_function
  );
  RAISE DEBUG 'executing sql: %', sql;
  EXECUTE sql;

  RETURN format( 'range_from_array(%s[])', subtype )::regprocedure;
END
$_range_from_array__create$;

SELECT _range_from_array__create(range_type)
  FROM range_type
  WHERE range_type_schema = 'pg_catalog'
;

-- vi: expandtab ts=2 sw=2
