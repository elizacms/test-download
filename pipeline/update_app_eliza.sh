#!/bin/bash -ex
if [ "${BRANCH}" = 'staging' ]; then
  cd ~/devops_dev/applications/eliza_nlu_cms/eliza-stg
  ansible-playbook eliza-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}'}"
elif [ "${BRANCH}" = 'master' ]; then
  cd ~/devops_dev/applications/eliza_nlu_cms/eliza-prod
  ansible-playbook eliza-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}'}"
else
  echo "no server to update for branch name: ${BRANCH}"
fi
