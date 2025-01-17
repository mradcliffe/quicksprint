#!/bin/bash

# This script creates a new drupal instance in the current directory.

set -o errexit
set -o pipefail
set -o nounset

SPRINT_BRANCH=11.x

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
TIMESTAMP=$(date +"%Y%m%d-%H%M")
SPRINTNAME="sprint-${TIMESTAMP}"
echo ${SPRINTNAME} > .test_sprint_name.txt

# Extract a new ddev D9 core instance to $CWD/sprint-$TIMESTAMP
mkdir -p ${SPRINTNAME}
echo "Untarring sprint.tar.xz" >&2
tar -xpf sprint.tar.xz -C ${SPRINTNAME}

# Check Docker is running
if docker run --rm -t busybox:latest ls >/dev/null
then
    printf "docker is running, continuing."
else
    printf "${RED}Docker is not running and is required for this script, exiting.\n${RESET}"
    exit 1
fi

echo "Using ddev version $(ddev version| awk '/^cli/ { print $2}') from $(which ddev)"

printf "${YELLOW}Configuring your fresh Drupal instance. This takes a few minutes.${RESET}\n"

cd "${SPRINTNAME}/drupalpod"
ddev config --project-name="${SPRINTNAME}"

# DrupalPod hacks.
sed 's#time composer#time ddev composer#g' .gitpod/drupal/drupalpod-setup/drupal_setup_core.sh > .gitpod/drupal/drupalpod-setup/drupal_setup_core.sh.new
mv .gitpod/drupal/drupalpod-setup/drupal_setup_core.sh.new .gitpod/drupal/drupalpod-setup/drupal_setup_core.sh
chmod +x .gitpod/drupal/drupalpod-setup/drupal_setup_core.sh

sed 's#\$(composer#\$(ddev composer#g' .gitpod/drupal/install-essential-packages.sh > .gitpod/drupal/install-essential-packages.sh.new
mv .gitpod/drupal/install-essential-packages.sh.new .gitpod/drupal/install-essential-packages.sh
chmod +x .gitpod/drupal/install-essential-packages.sh

sed 's#vendor/bin/phpcs#ddev exec vendor/bin/phpcs#g' .gitpod/drupal/drupalpod-setup/drupalpod-setup.sh > .gitpod/drupal/drupalpod-setup/drupalpod-setup.sh.new
mv .gitpod/drupal/drupalpod-setup/drupalpod-setup.sh.new .gitpod/drupal/drupalpod-setup/drupalpod-setup.sh
chmod +x .gitpod/drupal/drupalpod-setup/drupalpod-setup.sh

GITPOD_REPO_ROOT="$(pwd)" DP_PROJECT_NAME= DP_CORE_VERSION=$SPRINT_BRANCH DP_PROJECT_TYPE=project_core .gitpod/drupal/drupalpod-setup/drupalpod-setup.sh

ddev describe

printf "
${GREEN}
####
# Use the following URL's to access your site:
#
# Website:    ${YELLOW}http://sprint-${TIMESTAMP}.ddev.site:8080/${GREEN}
#             ${YELLOW}https://sprint-${TIMESTAMP}.ddev.site:8443/${GREEN}
#             ${YELLOW}(U:admin  P:admin)${GREEN}
#
# ${GREEN}Mailhog:    ${YELLOW}http://sprint-${TIMESTAMP}.ddev.site:8025/${GREEN}
#
# phpMyAdmin: ${YELLOW}http://sprint-${TIMESTAMP}.ddev.site:8036/${GREEN}
#
# Chat:       ${YELLOW}https://drupal.org/chat to join Drupal Slack or https://drupalchat.me${GREEN}
#
# See ${YELLOW}Readme.txt${GREEN} for more information.
####
${RESET}
"
