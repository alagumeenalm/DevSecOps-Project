pipeline {
  agent any

  environment {
    IMAGE_NAME = 'chiomanwanedo/devsecops-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
    DOCKER_CREDENTIAL_ID = 'docker'
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/chiomanwanedo/DevSecOps-Project.git', branch: 'main'
      }
    }

    stage('Build App') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        script {
          def appImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
          docker.withRegistry('', DOCKER_CREDENTIAL_ID) {
            appImage.push()
          }
        }
      }
    }

    stage('Save Image Tag') {
      steps {
        script {
          writeFile file: 'image-tag.txt', text: "${IMAGE_TAG}"
          archiveArtifacts artifacts: 'image-tag.txt'
        }
      }
    }
  }
}
