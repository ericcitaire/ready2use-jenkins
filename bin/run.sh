#!/bin/bash

docker run --rm -it --name jenkins -p 8080:8080 -v $(pwd)/jenkins.yaml:/var/jenkins_home/jenkins.yaml ready2use-jenkins