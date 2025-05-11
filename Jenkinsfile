pipeline {
  agent any

  environment {
    IMAGE_NAME = 'chiomanwanedo/devsecops-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
    DOCKER_CREDENTIAL_ID = 'docker'       // DockerHub creds in Jenkins
    SONARQUBE_SERVER = 'sonarqube'        // Jenkins SonarQube config name
  }

  stages {
    stage('Checkout') {
      steps {
        deleteDir()
        git url: 'https://github.com/chiomanwanedo/DevSecOps-Project.git', branch: 'main'
      }
    }

    stage('Build with Maven') {
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

    stage('Docker Build & Push') {
      agent {
        docker {
          image 'docker:24.0.6-dind'   // DinD agent with Docker daemon
          args '--privileged'          // Needed to run Docker daemon inside
        }
      }
      steps {
        sh 'dockerd-entrypoint.sh & sleep 10'
        sh 'docker version'

        withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIAL_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh """
            docker build -t $IMAGE_NAME:$IMAGE_TAG .
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push $IMAGE_NAME:$IMAGE_TAG
          """
        }
      }
    }

    stage('Scan with Trivy') {
      steps {
        sh "trivy image $IMAGE_NAME:$IMAGE_TAG > trivy-results.txt || true"
        sh "cat trivy-results.txt"
      }
    }

    stage('Archive Reports') {
      steps {
        archiveArtifacts artifacts: 'trivy-results.txt, target/site/**/*', allowEmptyArchive: true
        writeFile file: 'image-tag.txt', text: IMAGE_TAG
        archiveArtifacts artifacts: 'image-tag.txt', fingerprint: true
      }
    }

    stage('Trigger CD Pipeline') {
      steps {
        build job: 'DevSecOps-Project-CD', parameters: [
          string(name: 'IMAGE_TAG', value: IMAGE_TAG)
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
          echo "Quality Gate skipped or failed: ${err.getMessage()}"
        }
      }
    }
  }
}
