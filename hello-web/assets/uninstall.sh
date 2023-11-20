#!/bin/bash

systemctl stop hello-web.service
systemctl disable hello-web.service
rm /usr/bin/hello-web
rm /etc/systemd/system/hello-web.service
