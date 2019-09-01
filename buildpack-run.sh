#!/usr/bin/env bash

gem_parent_dir="vendor/heroku/ruby/2.6.0"

mkdir -p $gem_parent_dir
mkdir -p vendor/heroku/bin

gem install foreman --install-dir "$gem_parent_dir" --bindir vendor/heroku/bin
