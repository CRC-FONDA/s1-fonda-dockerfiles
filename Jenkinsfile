// List containing all folders with Dockerfiles
// Add folders here
def dockerfiles = ['jenkins', 'airflow']

def generateLintingStagesMap = dockerfiles.collectEntries {
    ["${dfile}": generateLintingStage(dfile)]
}

def generateLintingStage(dfile) {
    return
        stage("lint-${dfile}") {
            steps {
                // use hadolint container
                container('hadolint') {
                    sh "hadolint ${dfile}/Dockerfile | tee -a hadolint_${dfile}.txt"
                }
            }
            // store hadolint linting results
            post {
                always {
                    archiveArtifacts 'hadolint_${dfile}.txt'
                }
            }
        }
}


pipeline {
    agent any // we specify the pods per stage

    stages {
        stage('Dockerfile linting') {

            parallel {
                agent {
                    kubernetes {
                        yamlFile 'jenkins-pod-hadolint.yaml'
                    }
                }
                steps {
                    generateLintingStagesMap
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