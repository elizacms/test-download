#!/bin/bash -ex
if [ "${BRANCH}" = 'staging' ]; then
  cd ~/devops_dev/live/eliza/stg
  ansible-playbook eliza-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}'}"
elif [ "${BRANCH}" = 'master' ]; then
  cd ~/devops_dev/live/eliza/prod
  ansible-playbook eliza-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}'}"
elif [ "${BRANCH}" = 'eliza-voice' ]; then
  cd ~/devops_dev/live/eliza/voice
  ansible-playbook eliza-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}'}"

else
  echo "no server to update for branch name: ${BRANCH}"
fi
