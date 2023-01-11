FROM jenkins/jenkins:2.375.2

USER root

RUN curl -fsSL https://get.docker.com -o get-docker.sh \
 && sh get-docker.sh \
 && rm -f get-docker.sh \
 && rm -rf /var/lib/apt/lists/*

USER jenkins

COPY plugins.yml /usr/share/jenkins/ref/plugins.yml

RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.yml \
 && echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
