FONDA Dockerfile
============

This repository contains Dockerfiles used for different infrastructure components in FONDA.

All images are automatically build on new changes and pushed with the :latest tag.

In addition, the images are furthermore tagged with the current Git hash to enable rollbacks.

Dockerfiles
-----------
#### Apache Airflow
[Apache Airflow](https://airflow.apache.org/) in version 2.0.0. Available at [fondahub/airflow:2.0.0](https://hub.docker.com/repository/docker/fondahub/airflow).

#### Jenkins
[Jenkins](https://www.jenkins.io/) CI Server, available at [fondahub/jenkins:latest](https://hub.docker.com/repository/docker/fondahub/jenkins).

#### Spark
Contains base images which can be used to deploy Spark jobs with different versions, dependencies or programming languages.