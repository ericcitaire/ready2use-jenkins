#!/bin/bash

# CHANGE IT !!
fqdn=jenkins.example.com

docker network create jenkins-network

mkdir -p /var/jenkins_home /etc/jenkins

cat << EOF > /etc/jenkins/jenkins.yaml
jenkins:
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
  securityRealm:
    local:
      allowsSignup: false
      users:
       - id: admin
         password: training
EOF

cat << EOF > /lib/systemd/system/jenkins.service
[Unit]
Description=Jenkins
BindsTo=docker.service
After=docker.service

[Service]
Type=exec
ExecStart=/usr/bin/docker run --rm -i --cgroupns host --name jenkins --network jenkins-network \
  --hostname $fqdn \
  -u root -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/jenkins/jenkins.yaml:/var/jenkins_home/jenkins.yaml \
  ghcr.io/ericcitaire/ready2use-jenkins:main
Restart=on-failure

[Install]
WantedBy=default.target
EOF
systemctl enable --now jenkins

mkdir -p /etc/nginx/conf.d

cat << 'EOF' > /etc/nginx/conf.d/jenkins.conf
proxy_buffer_size 16k;
proxy_buffers 4 32k;
proxy_busy_buffers_size 32k;

# https://wiki.jenkins.io/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy

upstream jenkins {
  server jenkins:8080;
}

server {
  listen 80;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl;

  ssl_certificate /etc/letsencrypt/live/labs.strigo.io/cert.pem;
  ssl_certificate_key /etc/letsencrypt/live/labs.strigo.io/privkey.pem;

  location / {
    proxy_set_header        Host $host:$server_port;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_redirect          http:// https://;
    proxy_pass              http://jenkins;
    # Pour que la CLI ne tombe pas en erreur au bout de 60 secondes d'inactivité
    # (60 secondes étant la valeur par défaut de proxy_read_timeout).
    # java.io.IOException: Premature EOF
    proxy_read_timeout      1h;
    # Required for new HTTP-based CLI
    proxy_http_version 1.1;
    proxy_request_buffering off;
    proxy_buffering off; # Required for HTTP-based CLI to work over SSL
  }
}
EOF

cat << EOF > /lib/systemd/system/nginx.service
[Unit]
Description=NGinx
BindsTo=docker.service
After=docker.service

[Service]
Type=exec
ExecStart=/usr/bin/docker run --rm -i --name nginx --network jenkins-network \
  --hostname $fqdn \
  -p 80:80 -p 443:443 \
  -e 'TZ=Europe/Paris' \
  -v /etc/nginx/conf.d/jenkins.conf:/etc/nginx/conf.d/jenkins.conf:ro \
  -v /etc/letsencrypt:/etc/letsencrypt \
  nginx:stable
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl enable --now nginx
