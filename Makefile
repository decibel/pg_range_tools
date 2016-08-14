include pgxntool/base.mk

PLAIN_SQL = $(patsubst sql/%.sql,sql/%.plain,$(wildcard sql/*.sql))
EXTRA_CLEAN += $(PLAIN_SQL)

testdeps: $(PLAIN_SQL)

sql/%.plain: sql/%.sql
	sed -e 's/@extschema@\.//g' $< > $@
