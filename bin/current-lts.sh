#!/bin/bash

set -ex

docker run -d --name jenkins-plugins jenkins/jenkins:lts
trap 'docker rm -fv jenkins-plugins' EXIT

JENKINS_VERSION=$(docker exec -it jenkins-plugins /bin/sh -c 'echo -n "${JENKINS_VERSION}"')

sed -i "s|^FROM jenkins/jenkins:.*$|FROM jenkins/jenkins:${JENKINS_VERSION}|" Dockerfile

suggested_plugins_url="https://raw.githubusercontent.com/jenkinsci/jenkins/jenkins-${JENKINS_VERSION}/core/src/main/resources/jenkins/install/platform-plugins.json"

suggested_plugins=$(curl -fsSL "${suggested_plugins_url}" | jq --raw-output '.[].plugins[] | select(.suggested) | .name' | xargs)

useful_plugins=$(cat useful-plugins.txt | xargs)

docker exec -it jenkins-plugins /bin/sh -c "jenkins-plugin-cli --plugins ${suggested_plugins} ${useful_plugins}"

docker exec -it jenkins-plugins /bin/sh -c "jenkins-plugin-cli --list --output YAML > /tmp/plugins.yml"

docker exec -it jenkins-plugins /bin/sh -c "cat /tmp/plugins.yml" > plugins.yml
