#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Base checkout should be of the 8.7.x branch
SPRINT_BRANCH=8.7.x

# Maximise compression
export XZ_OPT=-9e

# This script creates a package of artifacts that can then be used at a code sprint working on Drupal 8.

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
USER=$(whoami)

cd ${STAGING_DIR}

printf "${GREEN}####\n# Preparing Drupal codebase...\n#### \n${RESET}"

# clone or refresh d8 clone
mkdir -p sprint
git clone --config core.autocrlf=false --config core.eol=lf --quiet https://git.drupal.org/project/drupal.git ${STAGING_DIR}/sprint/drupal8 -b ${SPRINT_BRANCH}
pushd ${STAGING_DIR}/sprint/drupal8 >/dev/null
cp ${REPO_DIR}/example.gitignore ${STAGING_DIR}/sprint/drupal8/.gitignore

echo "Running composer install --quiet"
composer install --quiet
popd >/dev/null

cd ${STAGING_DIR}

# @todo Optionally build package with Cloud 9 IDE.

# Copies framework-specific files to the staging directory.
cp ${REPO_DIR}/framework/drupal/start_sprint.sh ${STAGING_DIR}
cp ${REPO_DIR}/framework/drupal/SPRINTUSER_README.md ${STAGING_DIR}
cp ${REPO_DIR}/framework/drupal/sprint_readme.txt ${STAGING_DIR}/sprint/Readme.txt

exit 0

