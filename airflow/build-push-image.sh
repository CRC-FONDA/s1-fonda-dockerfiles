#!/bin/bash

REPOSITORY=fondahub
IMAGE_NAME=airflow
TAG=latest

docker build . -t $REPOSITORY/$IMAGE_NAME:$TAG
docker push $REPOSITORY/$IMAGE_NAME:$TAG
