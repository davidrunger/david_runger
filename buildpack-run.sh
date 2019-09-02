#!/usr/bin/env bash

gem_dir="vendor/foreman/"

mkdir -p $gem_dir

gem install foreman --install-dir "$gem_dir" --no-document
