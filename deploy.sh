#!/bin/sh

curl -H "Cache-Control: no-cache" -O https://raw.githubusercontent.com/motylevm/protools-ios-deploy-pods/master/_deploy.sh
sh _deploy.sh $*
rm -f _deploy.sh
