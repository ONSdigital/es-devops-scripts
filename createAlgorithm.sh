#!/usr/bin/env bash

# exit when any command fails
set -e

onsGitHubOrg="ONSdigital"
owner="ons"
# default to no internet access for the algorithm
network="isolated"
algoRepo="git.algpoc.com/git" #ons
#algoRepo="git.algorithmia.com/git" #public
algoUrl="https://api.algpoc.com" #ons
#algoUrl="https://api.algorithmia.com" #public

while getopts "a:k:g:l:n:r:u:" option; do
    case "${option}" in
    a) algorithm=${OPTARG};;
    k) authKey=${OPTARG};;
    g) gitHubRepo=${OPTARG};;
    l) language=${OPTARG};;
    n) network=${OPTARG};;
    o) owner=${OPTARG};;
    r) algoRepo=${OPTARG};;
    u) algoUrl=${OPTARG};;
    *) echo "script usage: $(basename "$0") [-a algorithm name] [-k auth key] [-g GitHub repository] [-l language (java, python3-1, scala)] [-n network access (isolated, full)] [-r algoRepo]" >&2
       exit 1;;
    esac
done

conciseAlgorithmName=${algorithm//[^[:alnum:]]/}
conciseAlgorithmName=$(tr "[:lower:]" "[:upper:]" <<< "${conciseAlgorithmName:0:1}")${conciseAlgorithmName:1}
echo "Concise algorithm name is ${conciseAlgorithmName}"
echo

source "${BASH_SOURCE%/*}"/algorithmia/create.sh -a "${algorithm}" -c ${conciseAlgorithmName} -l "${language}" -n "${network}"

echo
echo "Cloning algorithm '${algorithm}' with name '${conciseAlgorithmName}' from ${algoRepo}"
git clone -o algo https://"${algoRepo}"/"${owner}"/"${conciseAlgorithmName}".git "${gitHubRepo}"

cd "${gitHubRepo}"

echo
echo "Adding remote to GitHub repository "${onsGitHubOrg}"/"${gitHubRepo}""
git remote add github https://github.com/"${onsGitHubOrg}"/"${gitHubRepo}"

echo
echo "Pushing changes to GitHub master branch"
git push github master

echo
echo "Checking out feature/devops branch"
git -c core.ignorecase=false checkout -b feature/devops
cd ..

echo "Copying ONS MIT license to feature/devops branch"
rm "${gitHubRepo}"/LICENSE.txt
cp -v "${BASH_SOURCE%/*}"/LICENSE "${gitHubRepo}"

echo
echo "Copying '${language}' language source files to feature/devops branch"
case ${language} in
     java)
          # Copy over all language files
          cp -vr "${BASH_SOURCE%/*}"/language/"${language}/" "${gitHubRepo}"
          # Update the pom.xml
          src_pom=$(<"${BASH_SOURCE%/*}"/language/java/pom.xml)
          pom="${src_pom/algorithm-name/${algorithm}}"
          echo "${pom//concise-alg-name/${conciseAlgorithmName}}" > "${gitHubRepo}"/pom.xml
          # Remove helloworld dir
          rm -rf "${gitHubRepo}"/src/test/java/algorithmia/helloworld
          # Create unit test
          unitTest=$(<"${BASH_SOURCE%/*}"/language/java/src/test/java/algorithmia/helloworld/HelloWorldTest.java)
          unitTest="${unitTest//HelloWorld/${conciseAlgorithmName}}"
          echo "${unitTest//helloworld/${packageName}}" > "${gitHubRepo}"/src/test/java/algorithmia/"${conciseAlgorithmName}"/"${conciseAlgorithmName}Test".java
          # Create integration test
          sysTest=$(<"${BASH_SOURCE%/*}"/language/java/src/test/java/algorithmia/helloworld/HelloWorldSystemIT.java)
          sysTest="${sysTest//HelloWorld/${conciseAlgorithmName}}"
          echo "${sysTest//helloworld/${packageName}}" > "${gitHubRepo}"/src/test/java/algorithmia/"${conciseAlgorithmName}"/"${conciseAlgorithmName}SystemIT".java
          ;;
     python3-1)
          language="python"
          sonar=$(<"${BASH_SOURCE%/*}"/language/python/sonar-project.properties)
          sonar="${sonar//github-repo/${gitHubRepo}}"
          echo "${sonar//algorithm-name/${algorithm}}" > "${gitHubRepo}"/sonar-project.properties
          ;;
     scala)
          cp -vr "${BASH_SOURCE%/*}"/language/"${language}/" "${gitHubRepo}"
          build_sbt=$(<"${BASH_SOURCE%/*}"/language/scala/build.sbt)
          echo "${build_sbt//concise-alg-name/${conciseAlgorithmName}}" > "${gitHubRepo}"/build.sbt
          ;;
     *)
          echo "${language} is not supported"
          ;;
esac

echo
echo "Copying Algorithmia algorithm management scripts to feature/devops branch"
mkdir "${gitHubRepo}"/scripts
cp -v "${BASH_SOURCE%/*}"/algorithmia/*.sh "${gitHubRepo}"/scripts

echo
echo "Copying .travis.yml for '${language}' to feature/devops branch"
yml=$(<"${BASH_SOURCE%/*}"/travis/${language}/.travis.yml)
yml="${yml/algo-url/${algoUrl}}"
yml="${yml/alg-owner/${owner}}"
echo "${yml//concise-alg-name/${conciseAlgorithmName}}" > "${gitHubRepo}"/.travis.yml

echo
echo "Creating Jenkinsfile for '${language}' and copying to feature/devops branch"
file_contents=$(<"${BASH_SOURCE%/*}"/jenkins/Jenkinsfile)
capitalizedLanguage=$(tr a-z A-Z <<< "${language:0:1}")${language:1}
language_file="${file_contents//Language/${capitalizedLanguage}}"
echo "${language_file//name/${conciseAlgorithmName}}" > "${gitHubRepo}"/Jenkinsfile

echo
echo "Pushing changes to GitHub feature/devops branch"
cd "${gitHubRepo}"
git add -A
git commit -a -m "DevOps configuration"
git push github feature/devops




