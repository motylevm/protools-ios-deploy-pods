#!/bin/sh

curl -O https://raw.githubusercontent.com/motylevm/protools-ios-deploy-pods/master/_deploy.sh
sh _deploy.sh
rm -f _deploy.sh
