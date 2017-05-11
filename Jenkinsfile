#!/usr/bin/env groovy

pipeline {
  agent any

  stages {
    stage('Checkout nlu-cms') {
      steps {
        println env.BRANCH_NAME
        sh "git branch -D ${env.BRANCH_NAME} > /dev/null 2>&1 || true"
        sh "git checkout -b ${env.BRANCH_NAME}"
        sh 'bash ./pipeline/write_commit_info.sh'
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

    stage('Deploy to heroku nlu-cms') {
      steps {
        sh "BRANCH=${env.BRANCH_NAME} bash ./pipeline/deploy_to_heroku.sh"
      }
    }
  }
  post {
    always {
      junit 'junit.xml'
    }
    failure {
      slackSend (channel: '#nlu-cms_dev', color: '#FF0000', message: "FAILED: Job (${env.BUILD_URL}) " + getCommitInfo())
    }
    success {
      slackSend (channel: '#nlu-cms_dev', color: '#00FF00', message: "SUCCESSFUL: Job (${env.BUILD_URL}) " + getCommitInfo())
    }
  }
}

def getCommitInfo() {
  def props = readFile "commit_info.properties"
  println props
  return props
}
