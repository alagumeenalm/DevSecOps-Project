pipeline {
  agent any

  environment {
    IMAGE_NAME = 'chiomanwanedo/devsecops-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
    DOCKER_CREDENTIAL_ID = 'docker'
    SONARQUBE_SERVER = 'sonarqube'
  }

  stages {
    stage('Clean Workspace') {
      steps {
        deleteDir() // This will clean the workspace before pulling new code
      }
    }

    stage('Checkout') {
      steps {
        git url: 'https://github.com/chiomanwanedo/DevSecOps-Project.git', branch: 'main'
      }
    }

    stage('Build') {
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

    stage('Scan Image with Trivy') {
      steps {
        sh "trivy image ${IMAGE_NAME}:${IMAGE_TAG} > trivy-results.txt || true"
      }
    }

    stage('Archive Reports') {
      steps {
        archiveArtifacts artifacts: 'trivy-results.txt, target/site/**/*', allowEmptyArchive: true
        writeFile file: 'image-tag.txt', text: "${IMAGE_TAG}"
        archiveArtifacts artifacts: 'image-tag.txt', fingerprint: true
      }
    }

    stage('Trigger CD Pipeline') {
      steps {
        build job: 'DevSecOps-Project-CD', parameters: [
          string(name: 'IMAGE_TAG', value: "${IMAGE_TAG}")
        ]
      }
    }
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
          echo "Could not get Quality Gate result or it failed: ${err.getMessage()}"
        }
      }
    }
  }
}
