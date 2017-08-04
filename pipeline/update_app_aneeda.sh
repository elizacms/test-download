#!/bin/bash -ex
if [ "${BRANCH}" = 'master' ]; then
  cd ~/devops_dev/application/eliza-nlu-cms/eliza-prod
  ansible-playbook nlu-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}'}"
else
  echo "no server to update for branch name: ${BRANCH}"
fi
