FROM jenkins/jenkins:2.361.1

COPY plugins.yml /usr/share/jenkins/ref/plugins.yml

RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.yml \
 && echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
