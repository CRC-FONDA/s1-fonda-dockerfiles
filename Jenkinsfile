// List containing all folders with Dockerfiles
// Add folders here
def dockerfiles = ['jenkins', 'airflow']

def parallelLintingStagesMap = dockerfiles.collectEntries {
    ["${it}": generateLintingStage(it)]
}

def parallelBuildingStagesMap = dockerfiles.collectEntries {
    ["${it}": generateBuildingStage(it)]
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

def generateBuildingStage(service) {
    return {
        stage("build-${service}") {
            container('docker') {
                withCredentials([[
                    $class: 'UsernamePasswordMultiBinding',
                    credentialsId: 'fondahub-dockerhub', usernameVariable: 'DOCKERUSER', passwordVariable: 'DOCKERPASS'
                ]]) {
                    sh """
                    echo "$DOCKERPASS" | docker login -u "$DOCKERUSER" --password-stdin
                     docker build ${service}/ -t fondahub/${service}:$GIT_COMMIT_SHORT
                        docker tag fondahub/${service}:$GIT_COMMIT_SHORT fondahub/${service}:latest
                        docker push fondahub/${service}:$GIT_COMMIT_SHORT
                        docker push fondahub/${service}:latest
                        """
                    }
            }
        }
    }
}

pipeline {
    agent none // we specify the pods per stage

    environment {
        // git short commit hash for container tag
        GIT_COMMIT_SHORT = sh(
                script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
                returnStdout: true
        )

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
                script {
                    parallel parallelBuildingStagesMap
                }
            }
        }
    }
}