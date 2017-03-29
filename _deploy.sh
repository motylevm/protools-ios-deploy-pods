#!/bin/sh

#this flag terminates the script if any of the commands fail
set -e

#-----------------------------------------------------------------
echo "Checking that there is no more than one avito-scm-ma-protools-ios-specs repo in pod repo (there can be 0)"
POD_REPO_OUT="$(pod repo)"
echo "${POD_REPO_OUT}"

needle="protools-ios-specs.git"
declare -i number_of_occurrences=$(grep -o "$needle" <<< "$POD_REPO_OUT" | wc -l)

if [ "$number_of_occurrences" -gt 1 ]; then
echo "ERROR: There are more than 1 protools-ios-specs.git repo! Aborting ..."
exit 1
fi

#-----------------------------------------------------------------
echo 'Checking that working directory is clean and switching to master...'

GIT_STATUS_OUTPUT="$(git status)"
echo "${GIT_STATUS_OUTPUT}"

case "$GIT_STATUS_OUTPUT" in
*"working tree clean"*) git checkout master ;;
*) echo 'Working directory tree not clean, abotrting'; exit 1 ;;
esac

#-----------------------------------------------------------------
echo 'Pulling from origin/master ...'
git pull origin master

#-----------------------------------------------------------------
echo 'Finding podscpec file ...'
finding_specs_file="$(find . -type f -depth 1 -name "*.podspec.json")"
echo "${finding_specs_file}"
string_to_strip="./"
finding_specs_file=${finding_specs_file/$string_to_strip/}
if [ ${#finding_specs_file} == 0 ]
then 
	echo 'ERROR: Podspec file not found!'
	exit 1
fi

#-----------------------------------------------------------------
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
	echo 'ERROR: Specified version' $version 'is not equal to tag, specified in source[tag]' $tag 'aborting ... '
	exit 1
fi

#-----------------------------------------------------------------
echo 'Linting current podscpec file ...'
pod lib lint $* --sources='http://stash.se.avito.ru/scm/ma/protools-ios-specs.git,https://github.com/CocoaPods/Specs'

#-----------------------------------------------------------------
#create the tag and push it
git tag -f $version
git push -f origin $version

#-----------------------------------------------------------------
#add protools-ios-specs repo if it is not there
POD_REPO_OUTPUT="$(pod repo)"
echo "${POD_REPO_OUTPUT}"

case "$POD_REPO_OUTPUT" in
  *avito-scm-ma-protools-ios-specs*) echo 'avito-scm-ma-protools-ios-specs already exists' ;;
  *) pod repo add avito-scm-ma-protools-ios-specs http://stash.se.avito.ru/scm/ma/protools-ios-specs.git ;;
esac

#-----------------------------------------------------------------
#in pod repo push confitional raciton to result is needed
echo "Pushing spec to avito-scm-ma-protools-ios-specs..."
set +e

if pod repo push avito-scm-ma-protools-ios-specs $finding_specs_file $* ; then
    echo "Successfully deployed pod!"
else
    echo "pod repo push failed! Dropping avito-scm-ma-protools-ios-specs with corrupted commit. On next deploy try this repo will be added automatically!"
    pod repo remove avito-scm-ma-protools-ios-specs
fi
