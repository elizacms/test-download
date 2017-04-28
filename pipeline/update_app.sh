#!/bin/bash -ex
if [ "${BRANCH}" = 'staging' ]; then
  cd ~/devops_dev/jenkins/eliza-cms-stg
  ansible-playbook -i aws_hosts.ini eliza-cms-update.yml --extra-vars="{'BRANCH_NAME':'${BRANCH}'}"
else
  echo "no server to update for branch name: ${BRANCH}"
fi
