#!/bin/bash -x

#INSTALL awscli
sudo apt-get update
sudo apt-get install -yf python3 python3-pip

#INSTALL Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo usermod -aG docker ubuntu

#INSTALL Docker Compose
sudo pip3 install docker-compose
mkdir /home/ubuntu/app/

sudo dd of=/etc/systemd/system/simple-web-app.service <<EOF
[Unit]
Description=Docker Compose Simple_Web_Application Service
Requires=docker.service
After=docker.service

[Service]
WorkingDirectory=/home/ubuntu/app/
ExecStart=/usr/local/bin/docker-compose up
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0
Restart=on-failure
StartLimitIntervalSec=60
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable simple-web-app
