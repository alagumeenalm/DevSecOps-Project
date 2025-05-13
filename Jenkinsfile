pipeline {
  agent any

  environment {
    IMAGE_NAME = 'chiomanwanedo/devsecops-app'
    GITHUB_CREDENTIAL_ID = 'github'
  }

  stages {
    stage('Checkout GitOps Repo') {
      steps {
        git url: 'https://github.com/chiomanwanedo/DevSecOps-Project-CD.git', branch: 'main', credentialsId: GITHUB_CREDENTIAL_ID
      }
    }

    stage('Download Image Tag from CI') {
      steps {
        copyArtifacts(
          projectName: 'DevSecOps-Project',
          selector: lastSuccessful(),
          filter: 'image-tag.txt',
          target: '.'
        )
        sh 'cat image-tag.txt' // Optional debug line
      }
    }

    stage('Update Kubernetes Manifest') {
      steps {
        script {
          def tag = readFile('image-tag.txt').trim()
          sh """
            sed -i 's|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${tag}|' kubernetes/deployment.yml
          """
        }
      }
    }

    stage('Commit & Push Changes') {
      steps {
        withCredentials([usernamePassword(credentialsId: GITHUB_CREDENTIAL_ID, usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
          sh '''
            git config user.name "chiomanwanedo"
            git config user.email "chiomavanessa8@gmail.com"
            git add image-tag.txt kubernetes/deployment.yml
            git commit -m "Update image tag for deployment"
            git push https://$GIT_USER:$GIT_PASS@github.com/chiomanwanedo/DevSecOps-Project-CD.git main
          '''
        }
      }
    }

    // Optional: Sync with ArgoCD if GitOps is used
    // stage('Sync ArgoCD') {
    //   steps {
    //     sh 'argocd app sync your-app-name --insecure --grpc-web'
    //   }
    // }
  }
}
