#!/bin/bash -ex
source ~/.bashrc > /dev/null 2>&1
rvm use 2.3.1
bundle install
bundle exec rspec spec/models spec/requests --colour --tty -r rspec_junit_formatter --format documentation --format RspecJunitFormatter -o junit.xml
if [ $? = 1 ]; then
  exit 1
fi
#CODECLIMATE_REPO_TOKEN= bundle exec codeclimate-test-reporter
