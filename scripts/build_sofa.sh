#!/bin/bash

# The location of the https://github.com/MIT-LCP/mimic-code directory
mimic_code="../mimic-code"

# Params for the psql commands
dbname="mimic"
user="username"
search_path="mimiciii"

cd $mimic_code/concepts 2> /dev/null || {
  echo "ERROR: Failed to find mimic-code directory. Is '$mimic_code' the correct path?"
  exit 1
}

echo "***This may take several hours/days if the db views already exist.***"
echo "Are you sure you wish to continue?"
# From https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script
select yn in "Continue" "Cancel"; do
    case "$yn" in
        "Continue" ) break;;
        "Cancel" ) exit 0;;
    esac
done

echo "Checking db integrity..."
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f ../buildmimic/postgres/postgres_checks.sql

echo "Building constituent views... This may take a while if the views already exist."

echo "(1 of 8) echodata"
# Exit early if the params don't work. Currently prints messy output if $search_path is bad.
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f echo-data.sql || exit 1

echo "(2 of 8) ventdurations"
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f durations/ventilation-durations.sql

echo "(3 of 8) vitalsfirstday"
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f firstday/vitals-first-day.sql

echo "(4 of 8) uofirstday"
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f firstday/urine-output-first-day.sql

echo "(5 of 8) gcsfirstday"
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f firstday/gcs-first-day.sql

echo "(6 of 8) labsfirstday"
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f firstday/labs-first-day.sql

echo "(7 of 8) bloodgasfirstday"
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f firstday/blood-gas-first-day.sql

echo "(8 of 8) bloodgasfirstdayarterial"
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f firstday/blood-gas-first-day-arterial.sql

echo "Building SOFA view..."
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f severityscores/sofa.sql

echo "Done."
