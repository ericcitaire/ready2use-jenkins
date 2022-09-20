#!/bin/bash

# https://issues.jenkins.io/browse/JENKINS-67659?jql=resolution%20is%20EMPTY%20and%20component%3D20625
# The solution is to use --cgroupns host into the container creation command.

mkdir -p .jenkins_home
docker run --rm -it --cgroupns host --name jenkins -u $(id -u):$(id -g) -p 8080:8080 -p 50000:50000 -v $(pwd)/.jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/jenkins.yaml:/var/jenkins_home/jenkins.yaml ready2use-jenkins
