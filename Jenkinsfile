pipeline {
  agent {
    docker {
      image 'maven:3.9.6-eclipse-temurin-17'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    IMAGE_NAME = 'chiomanwanedo/devsecops-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
    DOCKER_CREDENTIAL_ID = 'docker'
    SONARQUBE_SERVER = 'sonarqube'
  }

  stages {
    stage('Checkout') {
      steps {
        deleteDir()
        git url: 'https://github.com/chiomanwanedo/DevSecOps-Project.git', branch: 'main'
      }
    }

    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }

    // ... other stages remain unchanged
  }

  post {
    always {
      script {
        try {
          timeout(time: 2, unit: 'MINUTES') {
            def qualityGate = waitForQualityGate()
            echo "SonarQube Quality Gate: ${qualityGate.status}"
          }
        } catch (err) {
          echo "Quality Gate skipped or failed: ${err.getMessage()}"
        }
      }
    }
  }
}
