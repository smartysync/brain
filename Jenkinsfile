pipeline {
  agent {
    label "docker"
  }
  stages {
    stage("Retrieve build information") {
      steps {
        script {
          GIT_BRANCH = sh(returnStdout: true, script: "git rev-parse --abbrev-ref HEAD").trim()
          GIT_COMMIT = sh(returnStdout: true, script: "git rev-parse HEAD").trim()
        }
      }
    }
    stage("Build image") {
      steps {
        script {
          docker.build("smartbox/brain:${GIT_COMMIT}")
        }
      }
    }
    stage("Analyze image") {
      parallel {
        stage("Run coding style analysis") {
          steps {
            sh("docker run --rm -i smartbox/brain:${GIT_COMMIT} bundle exec rubocop -D")
          }
        }
        stage("Run security analysis") {
          steps {
            sh("docker run --rm -i smartbox/brain:${GIT_COMMIT} bundle exec brakeman -zA")
          }
        }
        stage("Run specs") {
          steps {
            sh("docker run --rm -i smartbox/brain:${GIT_COMMIT} bundle exec rspec")
          }
        }
      }
    }
    stage("Publish image") {
      steps {
        script {
          docker.withRegistry("https://registry.hub.docker.com", "docker-hub-credentials") {
            docker.image("smartbox/brain:${GIT_COMMIT}").push("${GIT_COMMIT}")
            docker.image("smartbox/brain:${GIT_COMMIT}").push("latest")
          }
        }
      }
    }
  }
  post {
    always {
      sh "docker rmi -f smartbox/brain:${GIT_COMMIT}"
      sh "docker rmi -f registry.hub.docker.com/smartbox/brain"
      sh "docker rmi -f registry.hub.docker.com/smartbox/brain:${GIT_COMMIT}"
    }
  }
}
