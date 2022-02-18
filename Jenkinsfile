pipeline {
    agent {
        // use kubernetes cluster
        kubernetes {
            yamlFile 'jenkins-pod.yaml'
        }
    }

    stages {
        stage('Dockerfile linting') {
            parallel {
                // Jenkins Dockerfile
                stage('Jenkins') {
                    steps {
                        // use hadolint container
                        container('hadolint') {
                            sh 'hadolint jenkins/Dockerfile | tee -a hadolint_lint.txt'
                        }
                    }
                    // store hadolint linting results
                    post {
                        always {
                            archiveArtifacts 'hadolint_lint.txt'
                        }
                    }
                }
                // Spark
                stage('Spark') {
                    steps {
                        // use hadolint container
                        container('hadolint') {
                            sh 'hadolint spark/python-s3/Dockerfile | tee -a hadolint_lint.txt'
                        }
                    }
                    // store hadolint linting results
                    post {
                        always {
                            archiveArtifacts 'hadolint_lint.txt'
                        }
                    }
                }
            }
        }

        stage('Build images') {
            steps {
                echo "TODO"
            }
        }
    }
}