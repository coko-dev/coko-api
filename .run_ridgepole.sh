#!/bin/bash

if [ "$1" = "dev" ]; then
  docker compose run api ridgepole --apply -c config/database.yml -f db/Schemafile.rb
elif [ "$1" = "stg" ]; then
  heroku run -r staging ridgepole --apply -c config/database.yml -f db/Schemafile.rb -E production
elif [ "$1" = "prd" ]; then
  heroku run -r heroku ridgepole --apply -c config/database.yml -f db/Schemafile.rb -E production
else
  echo 'Pass the environment name ("dev" or "stg" or "prd")'
fi
