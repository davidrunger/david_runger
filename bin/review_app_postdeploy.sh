#!/usr/bin/env bash

echo "Loading schema and seeding database"
bin/rails db:schema:load db:seed

bin/rails runner bin/review_app_setup.rb
