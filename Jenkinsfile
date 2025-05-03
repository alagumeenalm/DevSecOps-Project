pipeline {
  agent any

  environment {
    IMAGE_NAME = 'chiomanwanedo/devsecops-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
    DOCKER_CREDENTIAL_ID = 'dockerhub'
    GITHUB_CREDENTIAL_ID = 'github'
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/chiomanwanedo/DevSecOps-Project.git', branch: 'main', credentialsId: "${GITHUB_CREDENTIAL_ID}"
      }
    }

    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarqube') {
          sh '''
            mvn sonar:sonar \
              -Dsonar.projectKey=devsecops-project \
              -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 1, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
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

    stage('Scan Image with Trivy') {
      steps {
        sh "trivy image ${IMAGE_NAME}:${IMAGE_TAG} > trivy-results.txt || true"
      }
    }

    stage('Archive Image Info') {
      steps {
        writeFile file: 'image-tag.txt', text: IMAGE_TAG
        archiveArtifacts artifacts: 'image-tag.txt', fingerprint: true
      }
    }

    stage('Trigger CD Pipeline') {
      steps {
        build job: 'DevSecOps-Project-CD'
      }
    }
  }
}
