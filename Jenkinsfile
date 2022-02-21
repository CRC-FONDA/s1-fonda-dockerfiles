// List containing all folders with Dockerfiles
// Add folders here
def dockerfiles = ['jenkins', 'airflow']

def parallelLintingStagesMap = dockerfiles.collectEntries {
    ["${it}": generateLintingStage(it)]
}

def parallelBuildingStagesMap = dockerfiles.collectEntries {
    ["${it}": generateBuildingStage(it)]
}

/**
* Generates a stage for each folder listed in 'dockerfiles' which lints the corresponding
* Dockerfiles.
*
* The analysis results are stored on Jenkins.
*/
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

/**
* Generates a stage for each folder listed in 'dockerfiles' to build and push the 
* respective container image to the 'fondahub' DockerHub organization (https://hub.docker.com/orgs/fondahub).
*
* Container images are named 'fondahub/<service>' and tagged with the 'latest' tag as well as the current git commit hash (shorted).
* We are using the node(POD_LABEL) directive to start an isolated pod for each building process  
*
* Note: The images are only built and pushed for changes on the 'main' branch.
*/
def generateBuildingStage(service) {
    return {
        node(POD_LABEL) {
            stage("build-${service}") {
                    container('docker') {
                        checkout scm
                        withCredentials([[
                            $class: 'UsernamePasswordMultiBinding',
                            credentialsId: 'fondahub-dockerhub', usernameVariable: 'DOCKERUSER', passwordVariable: 'DOCKERPASS'
                        ]])
                        {
                        sh """
                            echo "$DOCKERPASS" | docker login -u "$DOCKERUSER" --password-stdin
                            docker build ${service}/ -t fondahub/${service}:${GIT_COMMIT[0..7]}
                            docker tag fondahub/${service}:${GIT_COMMIT[0..7]} fondahub/${service}:latest
                            docker push fondahub/${service}:${GIT_COMMIT[0..7]}
                            docker push fondahub/${service}:latest
                        """          
                        }
                    }
            }
        }
    }
}

/**
* The actual declerative pipeline description.

* The helper methods are enclosed in 'script' directives in order to 
* support the scripted pipeline syntax.
*/
pipeline {
    agent {
        kubernetes {
            yamlFile 'jenkins-pod-docker.yaml'
        }
    }

    stages {
        stage('Dockerfile linting') {
            steps {
                script {
                    parallel parallelLintingStagesMap
                }
            }
        }

        stage('Build and push images') {
            // only build/push images of main branch
            when {
                branch 'main'
            }
            steps {
                script {
                    parallel parallelBuildingStagesMap
                }
            }
        }
    }
}