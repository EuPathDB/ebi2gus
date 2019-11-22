node ('centos8') {
    def tag
    stage('checkout') {
        checkout scm
        }
       
    stage('build') {
        // build the container
        sh 'podman build --format=docker -t ebi2gus $WORKSPACE'
        }

    stage('push') {
      withCredentials([usernameColonPassword(credentialsId: '0f11d4d1-6557-423c-b5ae-693cc87f7b4b', variable: 'HUB_LOGIN')]) {

        // set master to latest (may be better ways to do this)
        if (env.BRANCH_NAME == 'master') {
           tag = "latest"
         } else {
           tag = "${env.BRANCH_NAME}"
         }

        // push to dockerhub (for now)
        sh "podman push --creds \"$HUB_LOGIN\" ebi2gus docker://docker.io/veupathdb/ebi2gus:${tag}"
        }
      }

    }

