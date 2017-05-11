#!/bin/bash -ex
if [ "${BRANCH}" = 'staging' ]; then
  git push https://git.heroku.com/iamplus-nlu-cms.git staging:master
else
  echo "no deploy.  Onnly deploy staging branch to heroku. current branch: ${BRANCH}"
fi
