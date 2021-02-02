#!/bin/bash

REPOSITORY=fondahub
IMAGE_NAME=airflow
TAG=2.0.0

docker build . -t $REPOSITORY/$IMAGE_NAME:$TAG
docker push $REPOSITORY/$IMAGE_NAME:$TAG