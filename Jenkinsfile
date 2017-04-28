#!/usr/bin/env groovy

pipeline {
  agent any

  stages {
    stage('Checkout nlu-cms') {
      steps {
        println env.BRANCH_NAME
        sh "git branch -D ${env.BRANCH_NAME} > /dev/null 2>&1 || true"
        sh "git checkout -b ${env.BRANCH_NAME}"
      }
    }

    stage('UnitTest') {
      steps {
        sh 'bash ./pipeline/run-unit-tests.sh'
        step([$class: 'JUnitResultArchiver', testResults: 'junit.xml'])
      }
    }

    stage('Update App') {
      steps {
        sh "BRANCH=${env.BRANCH_NAME} bash ./pipeline/update_app.sh"
      }
    }
  }
  post {
    always {
      junit 'junit.xml'
    }
    failure {
      slackSend (channel: '#nlu-cms_dev', color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    }
    success {
      slackSend (channel: '#nlu-cms_dev', color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    }
  }
}
