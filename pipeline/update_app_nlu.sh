#!/bin/bash -ex
if [ "${BRANCH}" = 'staging' ]; then
  cd ~/devops_dev/live/nlu-cms/prod
  ansible-playbook nlu-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}'}"
else
  echo "no server to update for branch name: ${BRANCH}"
fi
