#!/usr/bin/env bash
set -ue

rake db:create
rake db:migrate
rake db:seed

bundle exec rackup --port 1234 --host 0.0.0.0
