#!groovy

def CONTAINER_IMAGE="${REGISTRY}/library/postgres:${POSTGRES_VERSION}-${BUILD_NUMBER}"

def REPOSITORY_PATH = 'container-images/postgres'

GITLAB_REPOSITORY = 'git@gitlab.emea.irdeto.com:Titan/devops.git'
GITLAB_CREDENTIALS = 'gitlabCredentials'

def checkoutSCM() {
  checkout(
    changelog: true,
    poll: true,
    scm: [
      $class                           : 'GitSCM',
      branches                         : [[name: '*/master']],
      doGenerateSubmoduleConfigurations: false,
      extensions                       : [],
      submoduleCfg                     : [],
      userRemoteConfigs                : [[
        url: GITLAB_REPOSITORY,
        credentialsId: GITLAB_CREDENTIALS]]
    ]
  )
}

node('bare-linux') {

  stage('Build and Publish the Container Image') {
    timeout(time: 30, unit: 'MINUTES') {
      currentBuild.description = CONTAINER_IMAGE
      checkoutSCM()
      sh('envsubst \'${POSTGRES_VERSION}\' < ' + REPOSITORY_PATH + '/Dockerfile.template  > ' + REPOSITORY_PATH + '/Dockerfile')
      withDockerRegistry([credentialsId: 'ArtifactoryLogin', url: 'http://' + REGISTRY]) {
        docker.build("${CONTAINER_IMAGE}", "--pull ${REPOSITORY_PATH}").push()
      }
    }
  }

}
