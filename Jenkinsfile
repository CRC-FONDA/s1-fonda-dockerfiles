pipeline {
    agent {
        // use kubernetes cluster
        kubernetes {
            yamlFile 'jenkins-pod.yaml'
        }
    }

    stages {
        stage('Dockerfile linting') {
            steps {
                // use hadolint container
                container('hadolint') {
                    sh 'hadolint jenkins/* | tee -a hadolint_lint.txt'
                }
            }
            // store hadolint linting results
            post {
                always {
                    archiveArtifacts 'hadolint_lint.txt'
                }
            }

        stage('Build images')
            steps {
                echo "TODO"
            }
        }
    }
}