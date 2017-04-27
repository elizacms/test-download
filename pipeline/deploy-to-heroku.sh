#!/bin/bash -ex

if [ "${BRANCH}" = 'develop' ]; then
  git push -f https://git.heroku.com/iamplus-skills-music-dev.git develop:master 2>&1| tail -1 >gitpushstatus.log

  deployStatus=`cat gitpushstatus.log`
  echo $deployStatus
  if [ "$deployStatus" != 'Everything up-to-date' ]; then
    echo "sleeping 20 seconds for app to restart"
    sleep 20
  fi

  curl http://nlu-dev.aneeda.ai:8080/
elif [[ "${BRANCH}" == *release* ]]; then
  git push -f https://git.heroku.com/iamplus-skills-music-stg.git ${BRANCH}:master 2>&1| tail -1 >gitpushstatus.log

  deployStatus=`cat gitpushstatus.log`
  echo $deployStatus
  if [ "$deployStatus" != 'Everything up-to-date' ]; then
    echo "sleeping 20 seconds for app to restart"
    sleep 20
  fi

  curl http://nlu-staging.aneeda.ai:8080/
else
  echo "no deploy. branch name: ${BRANCH}"
fi
