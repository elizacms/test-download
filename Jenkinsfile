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
      when {
        expression { env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'staging'}
      }
      steps {
          sh 'bash ./pipeline/run-unit-tests.sh'
          step([$class: 'JUnitResultArchiver', testResults: 'junit.xml'])
      }
    }

    stage('Update App -- Eliza') {
      steps {
        sh "BRANCH=${env.BRANCH_NAME} COMMIT_ID=" + getCommitId() + " bash ./pipeline/update_app_eliza.sh"
      }
    }
    stage('Update App -- Eliza Voice') {
      steps {
        sh "BRANCH=${env.BRANCH_NAME} COMMIT_ID=" + getCommitId() + " bash ./pipeline/update_app_eliza_voice.sh"
      }
    }
    stage('Update App -- Aneeda') {
      steps {
        sh "BRANCH=${env.BRANCH_NAME} COMMIT_ID=" + getCommitId() + " bash ./pipeline/update_app_aneeda.sh"
      }
    }
  }
  post {
    always {
      junit allowEmptyResults: true, testResults: 'junit.xml'
    }
    failure {
      slackSend (channel: '#nlu-cms_dev', color: '#FF0000', message: "FAILED: Job (${env.BUILD_URL}) \n" + getCommitAuthor() + " " + getCommitId() + "\n" + getCommitMessage())
    }
    success {
      slackSend (channel: '#nlu-cms_dev', color: '#00FF00', message: "SUCCESSFUL: Job (${env.BUILD_URL}) \n" + getCommitAuthor() + " " + getCommitId() + "\n" + getCommitMessage())
    }
  }
}

def getCommitAuthor() {
  def props = readFile "commit_author_email.properties"
  return props
}

def getCommitId() {
  def props = readFile "commit_id.properties"
  return props.replace("\n", "").replace("\r", "")
}

def getCommitMessage() {
  def props = readFile "commit_message.properties"
  return props
}
