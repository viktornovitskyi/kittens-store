#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker
sudo yum install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
docker run -it -d -e RACK_ENV=development -e DATABASE_URL=${database_connection_url} vnovitskyi/assignment-kittens-store rake db:create db:migrate db:seed
docker run -it -d -p 80:80 -e RACK_ENV=development -e DATABASE_URL=${database_connection_url} vnovitskyi/assignment-kittens-store bundle exec rackup --port 80 --host 0.0.0.0