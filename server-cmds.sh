#!/usr/bin/env bash

export IMAGE=$1
docker-compose -f /home/user/docker-compose.yaml up --detach
echo "success"