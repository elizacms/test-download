#!/bin/bash -ex

if [ "${BRANCH}" = 'develop' ]; then
  newman run ${postman_music_tests_url} -e ${postman_dev_env_url} -r junit,cli --reporter-junit-export
elif [[ "${BRANCH}" == *release* ]]; then
  newman run ${postman_music_tests_url} -e ${postman_staging_env_url} -r junit,cli --reporter-junit-export
else
  echo "no tests run. branch name: ${BRANCH}"
fi
