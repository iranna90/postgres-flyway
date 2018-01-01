#!/usr/bin/env sh
set -e

sed -i 's/max_connections = 100/max_connections = 250/g' ${PGDATA}/postgresql.conf

if [ -z "$DB_CONFIG" ]; then
  echo "Error: no database config found"
  exit 1
fi

for dbc in $DB_CONFIG; do
  db=$(echo $dbc|cut -d ':' -f 1)
  user=$(echo $dbc|cut -d ':' -f 2)
  pass=$(echo $dbc|cut -d ':' -f 3)

  if [ ! -z "$db" ] && [ ! -z "$user" ] && [ ! -z "$pass" ]; then

    # this allows us use the same user for more than one database
    psql -e -v ON_ERROR_STOP=0 --username postgres <<-EOSQL
      CREATE USER "$user" SUPERUSER UNENCRYPTED PASSWORD '$pass';
		EOSQL

    psql -e -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
      CREATE DATABASE "$db" WITH TEMPLATE = template0 ENCODING = 'UTF8';
		EOSQL

    psql -e -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
      ALTER DATABASE "$db" OWNER TO "$user";
		EOSQL

    # TODO: don't hardcode the absolute path
    if [ -d "/docker-entrypoint-initdb.d/sql/${db}" ]; then
      echo "Running Flyway..."
      /docker-entrypoint-initdb.d/flyway/flyway -user="$user" -password="$pass" -url="jdbc:postgresql://localhost:5432/${db}" -locations="filesystem:/docker-entrypoint-initdb.d/sql/${db}" migrate
    else
      echo "Not running Flyway, no database scripts directory found for database $db"
    fi

  else
    echo "The data should be in the database:username:password format, separated by whitespace"
    exit 1
  fi

done
