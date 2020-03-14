#!/bin/sh

DOCKER_IMAGE_NAME=netlykos/ipsec-vpn-server
docker rmi ${DOCKER_IMAGE_NAME}
# docker build --no-cache=true -t ${DOCKER_IMAGE_NAME} .
docker-compose build
