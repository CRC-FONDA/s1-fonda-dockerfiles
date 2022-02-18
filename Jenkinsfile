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