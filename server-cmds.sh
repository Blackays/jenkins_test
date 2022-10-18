#!/usr/bin/env bash

export IMAGE=$1
export DOCKER_PASS=$2
export DOCKER_USER=$3
echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
docker-compose -f /home/user/docker-compose.yaml up --detach
echo "success"