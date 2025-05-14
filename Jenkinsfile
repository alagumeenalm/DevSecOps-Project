pipeline {
  agent any

  environment {
    IMAGE_NAME = 'chiomanwanedo/devsecops-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
    DOCKER_CREDENTIAL_ID = 'docker'
    GITHUB_CREDENTIAL_ID = 'github'
    SONARQUBE_SERVER = 'sonarqube'
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/chiomanwanedo/DevSecOps-Project.git',
            branch: 'main',
            credentialsId: "${GITHUB_CREDENTIAL_ID}"
      }
    }

    stage('Build App') {
      steps {
        sh 'mvn clean verify'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv("${SONARQUBE_SERVER}") {
          withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_TOKEN')]) {
            sh '''
              mvn sonar:sonar \
                -Dsonar.projectKey=devsecops-project \
                -Dsonar.login=$SONAR_TOKEN \
                -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
            '''
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        script {
          def appImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
          docker.withRegistry('', "${DOCKER_CREDENTIAL_ID}") {
            appImage.push()
          }
        }
      }
    }

    stage('Save Image Tag') {
      steps {
        writeFile file: 'image-tag.txt', text: "${IMAGE_TAG}"
        archiveArtifacts artifacts: 'image-tag.txt'
      }
    }

    stage('Trigger CD Pipeline') {
      steps {
        build job: 'DevSecOps-Project-CD' // Make sure this matches your actual CD job name
      }
    }
  }

  post {
    success {
      echo '✅ CI pipeline completed successfully and CD triggered.'
    }
    failure {
      echo '❌ CI pipeline failed.'
    }
  }
}
