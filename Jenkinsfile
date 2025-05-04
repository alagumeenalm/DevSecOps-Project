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
      script {
        def qualityGate = waitForQualityGate()
        echo "SonarQube Quality Gate status: ${qualityGate.status}"
        if (qualityGate.status != 'OK') {
          error "Build failed due to SonarQube Quality Gate: ${qualityGate.status}"
        }
      }
    }
  }
}

stage('Build & Push Docker Image') {
  steps {
    script {
      def appImage = docker.build("chiomanwanedo/devsecops-app:${BUILD_NUMBER}")
      docker.withRegistry('', 'dockerhub') {
        appImage.push()
      }
    }
  }
}

stage('Scan Image with Trivy') {
  steps {
    sh "trivy image chiomanwanedo/devsecops-app:${BUILD_NUMBER} > trivy-results.txt || true"
  }
}

stage('Archive Reports') {
  steps {
    archiveArtifacts artifacts: 'trivy-results.txt, target/site/**/*', allowEmptyArchive: true
    writeFile file: 'image-tag.txt', text: "${BUILD_NUMBER}"
    archiveArtifacts artifacts: 'image-tag.txt', fingerprint: true
  }
}

stage('Trigger CD Pipeline') {
  steps {
    build job: 'DevSecOps-Project-CD', parameters: [
      string(name: 'IMAGE_TAG', value: "${BUILD_NUMBER}")
    ]
  }
}
