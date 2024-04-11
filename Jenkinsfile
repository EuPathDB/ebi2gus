node ('centos8') {
  def tag

  if (env.BRANCH_NAME == 'master') {
    tag = "latest"
  } else {
    tag = "${env.BRANCH_NAME}"
  }

  stage('checkout') {
    checkout scm
  }

  stage('build') {
    // build the container
    sh "podman build --format=docker -t ebi2gus:${tag} $WORKSPACE"
  }

  stage('push') {
    withCredentials([usernameColonPassword(credentialsId: '0f11d4d1-6557-423c-b5ae-693cc87f7b4b', variable: 'HUB_LOGIN')]) {
      sh "podman push --creds \"$HUB_LOGIN\" ebi2gus:${tag} docker://docker.io/veupathdb/ebi2gus:${tag}"
    }
  }
}
