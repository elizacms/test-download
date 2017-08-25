#!/bin/bash -ex
if [ "${BRANCH}" = 'master' ]; then
  cd ~/devops_dev/applications/eliza_nlu_cms/eliza-voice
  ansible-playbook eliza-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}','eliza_repo':'iAmPlus/eliza_voice'}"
else
  echo "no server to update for branch name: ${BRANCH}"
fi
