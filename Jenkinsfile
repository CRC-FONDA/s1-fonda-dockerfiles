// List containing all folders with Dockerfiles
// Add folders here
def dockerfiles = ['jenkins', 'airflow']

def parallelLintingStagesMap = dockerfiles.collectEntries {
    ["${it}": generateLintingStage(it)]
}

def generateLintingStage(service) {
    return {
        stage("lint-${service}") {
            try {
                container('hadolint') {
                    sh "hadolint --format json ${service}/Dockerfile | tee -a hadolint_${service}.json"
                }
            } finally {
                archiveArtifacts "hadolint_${service}.json"
                recordIssues(tools: [
                    hadoLint(
                        pattern: "hadolint_${service}.json")])
            }
        }
    }
}

pipeline {
    agent none // we specify the pods per stage

    stages {
        stage('Dockerfile linting') {
            agent {
                kubernetes {
                    yamlFile 'jenkins-pod-hadolint.yaml'
                }
            }
            steps {
                script {
                    parallel parallelLintingStagesMap
                }
            }
        }

        stage('Build and push images') {
            // only build/push images of main branch
            //when {
            //    branch 'main'
            //}
            agent {
                kubernetes {
                    yamlFile 'jenkins-pod-docker.yaml'
                }
            }
            steps {
                container('docker') {
                    withCredentials([[
                        $class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'fondahub-dockerhub', usernameVariable: 'DOCKERUSER', passwordVariable: 'DOCKERPASS'
                    ]]) {
                        sh """
                        echo "$DOCKERPASS" | docker login -u "$DOCKERUSER" --password-stdin
                        docker build jenkins/ -t fondahub/jenkins:build-$BUILD_NUMBER
                        docker tag fondahub/jenkins:build-$BUILD_NUMBER fondahub/jenkins:latest
                        docker push fondahub/jenkins:build-$BUILD_NUMBER
                        docker push fondahub/jenkins:latest
                        """
                    }
                }
            }
        }
    }
}