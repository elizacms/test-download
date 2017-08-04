#!/bin/bash -ex
if [ "${BRANCH}" = 'master' ]; then
  cd ~/devops_dev/applications/eliza-nlu-cms/iamplus-voice
  ansible-playbook eliza-cms-update.yml --extra-vars="{'branch_name':'${COMMIT_ID}'}"
else
  echo "no server to update for branch name: ${BRANCH}"
fi
