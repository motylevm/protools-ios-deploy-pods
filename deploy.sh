#!/bin/sh

#this flag terminates the script if any of the commands fail
set -e

echo 'Finding podscpec file ...'
finding_specs_file="$(find . -type f -depth 1 -name "*.podspec.json")"
echo "${finding_specs_file}"
string_to_strip="./"
finding_specs_file=${finding_specs_file/$string_to_strip/}
if [ ${#finding_specs_file} == 0 ]
then 
	echo 'Podspec file is not found!'
	exit 1
fi


echo 'Checking podscpec file version and tag ...'
#get current version and the tag
export PYTHONIOENCODING=utf8

version_and_tag=$((python -c "
import json
import sys

args = sys.argv
with open(args[1]) as data_file:    
    data = json.load(data_file)
    print(data['version'] + '34601EE6E2B5' + data['source']['tag'])
sys.exit(0)
" $finding_specs_file) 2>&1)

arrIN=(${version_and_tag//34601EE6E2B5/ })

version=${arrIN[0]}
tag=${arrIN[1]}

#check if the tag is the same is version
if [ $version != $tag ]
then
	echo 'Specified version' $version 'is not equal to tag, specified in source[tag]' $tag 'aborting ... '
	exit 1
fi

#lint current podscpec
echo 'Linting current podscpec file ...'
pod lib lint

#create the tag and push it
git tag $version
git push origin --tags

#add protools-ios-specs repo if it is not there
POD_REPO_OUTPUT="$(pod repo)"
echo "${POD_REPO_OUTPUT}"

case "$POD_REPO_OUTPUT" in
  *avito-scm-ma-protools-ios-specs*) echo 'avito-scm-ma-protools-ios-specs already exists' ;;
  *) pod repo add avito-scm-ma-protools-ios-specs http://stash.se.avito.ru/scm/ma/protools-ios-specs.git ;;
esac

pod repo push avito-scm-ma-protools-ios-specs $finding_specs_file