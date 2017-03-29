#!/bin/sh

mkdir ../temp_C24A86D7-D049-454B-A894-A191FFD41EFD
curl -o ../temp_C24A86D7-D049-454B-A894-A191FFD41EFD/_deploy.sh -H "Cache-Control: no-cache" -O https://raw.githubusercontent.com/motylevm/protools-ios-deploy-pods/master/_deploy.sh
sh ../temp_C24A86D7-D049-454B-A894-A191FFD41EFD/_deploy.sh $*
rm -rf ../temp_C24A86D7-D049-454B-A894-A191FFD41EFD
