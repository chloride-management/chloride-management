#!/bin/bash

# The location of the https://github.com/MIT-LCP/mimic-code directory
mimic_code="../mimic-code"

# The location of the mimic CSVs
path_to_data="../mimic-data"

# Params for the psql command
dbname="mimic"
user="username"
search_path="mimiciii"

cd $mimic_code/buildmimic/postgres 2> /dev/null || {
  echo "ERROR: Failed to find mimic-code directory. Is '$mimic_code' the correct path?"
  exit 1
}

echo "***This may take several hours if the db tables already exist.***"
echo "Are you sure you wish to continue?"
# From https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script
select yn in "Continue" "Cancel"; do
    case "$yn" in
        "Continue" ) break;;
        "Cancel" ) exit 0;;
    esac
done

echo "Creating tables..."
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f postgres_create_tables.sql

echo "Loading data into the mimic database..."
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f postgres_load_data.sql -v mimic_data_dir=$path_to_data

echo "Creating indexes..."
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f postgres_add_indexes.sql

echo "Running checks..."
psql "dbname=$dbname user=$user options=--search_path=$search_path" -f postgres_checks.sql

echo "Done."
