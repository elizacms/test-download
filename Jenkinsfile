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
    stage('Checkout devops'){
      steps {
        sh "git clone git@github.com:iAmPlus/devops.git"
      }
    }
  //   stage('UnitTest') {
  //     steps {
  //       sh 'bash ./pipeline/run-unit-tests.sh'
  //       step([$class: 'JUnitResultArchiver', testResults: 'junit.xml'])
  //     }
  //   }
  //   stage('DeployHeroku') {
  //     steps {
  //       sh "BRANCH=${env.BRANCH_NAME} bash ./pipeline/deploy-to-heroku.sh"
  //     }
  //   }
  //   stage('IntegrationTest') {
  //     steps {
  //       sh "BRANCH=${env.BRANCH_NAME} bash ./pipeline/run-integration-tests.sh"
  //       step([$class: 'JUnitResultArchiver', testResults: '**/newman/*.xml'])
  //     }
  //   }
  // }
  // post {
  //   always {
  //     junit '**/newman/*.xml'
  //     junit 'junit.xml'
  //   }
  //   failure {
  //     slackSend (channel: '#skills-music', color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
  //   }
  //   success {
  //     slackSend (channel: '#skills-music', color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
  //   }
  }
}

@NonCPS
def testFunction() {
  println 'got to test function'
  try {
    println 'try block'
    def build = manager.build
    println "Build Number: ${build.number}"
  } catch (Exception exc) {
    println 'catch exception'
    println(exc.toString());
    println(exc.getMessage());
    println(exc.getStackTrace());
    throw exc
  }
}


@NonCPS
def reportOnTestsForBuild() {
  def build = manager.build
  println("Build Number: ${build.number}")
  if (build.getAction(hudson.tasks.junit.TestResultAction.class) == null) {
    println("No tests")
    return ("No Tests")
  }

  // The string that will contain our report.
  String emailReport;

  emailReport = "URL: ${env.BUILD_URL}\n"

  def testResults =    build.getAction(hudson.tasks.junit.TestResultAction.class).getFailCount();
  def failed = build.getAction(hudson.tasks.junit.TestResultAction.class).getFailedTests()
  println("Failed Count: ${testResults}")
  println("Failed Tests: ${failed}")
  def failures = [:]

  def result = build.getAction(hudson.tasks.junit.TestResultAction.class).result

  if (result == null) {
    emailReport = emailReport + "No test results"
  } else if (result.failCount < 1) {
    emailReport = emailReport + "No failures"
  } else {
    emailReport = emailReport + "overall fail count: ${result.failCount}\n\n"
  failedTests = result.getFailedTests();

  failedTests.each { test ->
    failures.put(test.fullDisplayName, test)
    emailReport = emailReport + "\n-------------------------------------------------\n"
    emailReport = emailReport + "Failed test: ${test.fullDisplayName}\n" +
    "name: ${test.name}\n" +
    "age: ${test.age}\n" +
    "failCount: ${test.failCount}\n" +
    "failedSince: ${test.failedSince}\n" +
    "errorDetails: ${test.errorDetails}\n"
    }
  }
  return (emailReport)
}
