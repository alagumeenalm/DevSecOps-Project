pipeline {
  agent any

  environment {
    IMAGE_NAME = 'chiomavee/devsecops-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
    DOCKER_CREDENTIAL_ID = 'docker'
    SONARQUBE_SERVER = 'sonarqube'
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/chiomanwanedo/DevSecOps-Project.git', branch: 'main', credentialsId: 'github'
      }
    }

    stage('Build App') {
      steps {
        sh 'mvn clean package'
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
        script {
          writeFile file: 'image-tag.txt', text: "${IMAGE_TAG}"
          archiveArtifacts artifacts: 'image-tag.txt'
        }
      }
    }

    stage('Trigger CD') {
      steps {
        build job: 'DevSecOps-Project-CD'
      }
    }
  }

  post {
    failure {
      echo '❌ CI pipeline failed.'
    }
    success {
      echo '✅ CI pipeline completed successfully.'
    }
  }
}
