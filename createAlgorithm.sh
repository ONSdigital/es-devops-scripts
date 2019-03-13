#!/usr/bin/env bash

# exit when any command fails
set -e

onsGitHubOrg="ONSdigital"
owner="ons"
# default to no internet access for the algorithm
network="isolated"
algoRepo="git.algpoc.com/git" #ons
#algoRepo="git.algorithmia.com/git" #public

while getopts "a:u:p:k:g:l:n:r:" option; do
    case "${option}" in
    a) algorithm=${OPTARG};;
    u) username=${OPTARG};;
    p) password=${OPTARG};;
    k) authKey=${OPTARG};;
    g) gitHubRepo=${OPTARG};;
    l) language=${OPTARG};;
    n) network=${OPTARG};;
    r) algoRepo=${OPTARG};;
    *) echo "script usage: $(basename "$0") [-a algorithm name] [-u username] [-p password] [-k auth key] [-g GitHub repository] [-l language (java, python3-1, scala)] [-n network access (isolated, full)] [-r algoRepo]" >&2
       exit 1;;
    esac
done

source "${BASH_SOURCE%/*}"/algorithmia/create.sh -a "${algorithm}" -u "${username}" -p "${password}" -l "${language}" -n "${network}"

conciseAlgorithmName=${algorithm//[^[:alnum:]]/}

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
git checkout -b feature/devops

cd ..

echo "Copying ONS MIT license to feature/devops branch"
rm "${gitHubRepo}"/LICENSE.txt
cp -v "${BASH_SOURCE%/*}"/LICENSE "${gitHubRepo}"

echo
echo "Copying '${language}' language source files to feature/devops branch"
case ${language} in
     java)
          src_pom=$(<"${BASH_SOURCE%/*}"/language/java/pom.xml)
          pom="${src_pom/algorithm-name/${algorithm}}"
          echo "${pom//concise-alg-name/${conciseAlgorithmName}}" > "${gitHubRepo}"/pom.xml
          ;;
     scala)
          cp -vr "${BASH_SOURCE%/*}"/language/"${language}/" "${gitHubRepo}"
          ;;
     *)
          echo "${language} is not supported"
          exit 1
          ;;
esac

echo
echo "Copying Algorithmis algorithm management scripts to feature/devops branch"
mkdir "${gitHubRepo}"/scripts
cp -v "${BASH_SOURCE%/*}"/algorithmia/*.sh "${gitHubRepo}"/scripts

echo
echo "Copying .travis.yml for '${language}' to feature/devops branch"
cp -v "${BASH_SOURCE%/*}"/travis/"${language}"/.travis.yml "${gitHubRepo}"

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
