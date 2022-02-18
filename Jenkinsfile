pipeline {
    agent any // we specify the pods per stages

    stages {
        stage('Dockerfile linting') {
            parallel {
                // Jenkins Dockerfile
                stage('Jenkins') {
                    agent {
                        kubernetes {
                            yamlFile 'jenkins-pod-hadolint.yaml'
                        }
                    }
                    steps {
                        // use hadolint container
                        container('hadolint') {
                            sh 'hadolint jenkins/Dockerfile | tee -a hadolint_jenkins.txt'
                        }
                    }
                    // store hadolint linting results
                    post {
                        always {
                            archiveArtifacts 'hadolint_jenkins.txt'
                        }
                    }
                }
                // Spark
                stage('Spark') {
                    agent {
                        kubernetes {
                            yamlFile 'jenkins-pod-hadolint.yaml'
                        }
                    }
                    steps {
                        // use hadolint container
                        container('hadolint') {
                            sh 'hadolint spark/python-s3/Dockerfile | tee -a hadolint_spark.txt'
                        }
                    }
                    // store hadolint linting results
                    post {
                        always {
                            archiveArtifacts 'hadolint_spark.txt'
                        }
                    }
                }
            }
        }

        stage('Build images') {
            agent {
                kubernetes {
                    yamlFile 'jenkins-pod-docker.yaml'
                }
            }
            steps {
                sh "docker info && docker build jenkins/ -f Dockerfile -t fondahub/jenkins:build-$BUILD_NUMBER"
            }
        }
    }
}