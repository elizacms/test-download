#!/bin/bash -ex
cd jenkins/eliza-cms-stg
ansible-playbook -i aws_hosts.ini eliza-cms.yml --tags jenkins_test
