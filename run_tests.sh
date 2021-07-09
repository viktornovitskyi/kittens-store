#!/usr/bin/env bash
set -ue

rake db:create
rake db:migrate

bundle exec rspec
