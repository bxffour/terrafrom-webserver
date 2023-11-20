#!/bin/bash

mkdir -p /tmp/hello-web
curl -sL https://github.com/bxffour/terrafrom-webserver/releases/download/v0.1.0/hello-web.tar.xz | tar xJ -C /tmp/hello-web
sudo cp /tmp/hello-web/hello-web /usr/bin/hello-web
sudo cp /tmp/hello-web/hello-web.service /etc/systemd/system/hello-web.service
sudo systemctl daemon-reload
sudo systemctl start hello-web.service
sudo systemctl enable hello-web.service

