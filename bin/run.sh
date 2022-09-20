#!/bin/bash

docker run --rm -it --name jenkins -p 8080:8080 -p 50000:50000 -u $(id -u):$(id -g) -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/jenkins.yaml:/var/jenkins_home/jenkins.yaml ready2use-jenkins