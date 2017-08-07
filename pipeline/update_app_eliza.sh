#!/bin/bash -ex
if [ "${BRANCH}" = 'staging' ]; then
  cd ~/devops_dev/applications/eliza_nlu_cms/eliza-stg
  ansible-playbook eliza-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}','eliza_repo':'iAmPlus/eliza-cms-stg'}"
elif [ "${BRANCH}" = 'master' ]; then
  cd ~/devops_dev/applications/eliza_nlu_cms/eliza-prod
  ansible-playbook eliza-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}','eliza_repo':'iAmPlus/eliza-lp'}"
else
  echo "no server to update for branch name: ${BRANCH}"
fi
