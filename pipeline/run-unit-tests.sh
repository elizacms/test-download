#!/bin/bash -ex
source ~/.bashrc > /dev/null 2>&1
rvm use 2.3.1
bundle install
bundle exec rspec --colour --tty -r rspec_junit_formatter --format documentation --format RspecJunitFormatter -o junit.xml
if [ $? = 1 ]; then
  exit 1
fi
CODECLIMATE_REPO_TOKEN=e116f16512c30ab9b8f645292d954f5c93bb3d4ba87e47623dec70e8922e3f92 bundle exec codeclimate-test-reporter
