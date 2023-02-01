#!/bin/bash

for f in $(ls tests/dbs | sed '/_createSchema.sql/d')
do
    DB="tests/dbs/$(basename --suffix .sql $f).db"
    SQL="tests/dbs/$f"
    echo "creating test db: $DB with: tests/dbs/$f"
    sqlite3 $DB < tests/dbs/_createSchema.sql
    sqlite3 $DB < $SQL
done
