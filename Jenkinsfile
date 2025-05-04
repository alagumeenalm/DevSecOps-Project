node {
  stage('Build') {
    sh 'mvn clean package'
  }

  stage('SonarQube Analysis') {
    withSonarQubeEnv('sonarqube') {
      sh '''
        mvn sonar:sonar \
          -Dsonar.projectKey=devsecops-project \
          -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
      '''
    }
  }

  stage('Quality Gate') {
    timeout(time: 1, unit: 'MINUTES') {
      def qualityGate = waitForQualityGate()
      echo "SonarQube Quality Gate status: ${qualityGate.status}"
      if (qualityGate.status != 'OK') {
        error "Build failed due to SonarQube Quality Gate: ${qualityGate.status}"
      }
    }
  }

  stage('Build & Push Docker Image') {
    def appImage = docker.build("chiomanwanedo/devsecops-app:${BUILD_NUMBER}")
    docker.withRegistry('', 'dockerhub') {
      appImage.push()
    }
  }

  stage('Scan Image with Trivy') {
    sh "trivy image chiomanwanedo/devsecops-app:${BUILD_NUMBER} > trivy-results.txt || true"
  }

  stage('Archive Reports') {
    archiveArtifacts artifacts: 'trivy-results.txt, target/site/**/*', allowEmptyArchive: true
    writeFile file: 'image-tag.txt', text: "${BUILD_NUMBER}"
    archiveArtifacts artifacts: 'image-tag.txt', fingerprint: true
  }

  stage('Trigger CD Pipeline') {
    build job: 'DevSecOps-Project-CD', parameters: [
      string(name: 'IMAGE_TAG', value: "${BUILD_NUMBER}")
    ]
  }
}
