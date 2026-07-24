#!/bin/bash
action=$1
CURRENT_DIR=$(pwd)
source ${CURRENT_DIR}/airgap-env.sh

PRIVACERA_HUB_URL=$(echo $PRIV_MGR_IMAGE | awk -F'/' '{print $1}')
PRIVACERA_VERSION=$(echo $PRIV_MGR_IMAGE | awk -F':' '{print $2}')
PRIVACERA_BASE_DOWNLOAD_URL=$(echo $PRIV_MGR_PACKAGE | awk -F/ '{print $1 "//" $3}')
AIRGAP_SCRIPT_DOWNLOAD_URL=$PRIVACERA_BASE_DOWNLOAD_URL/privacera-manager/$PRIVACERA_VERSION/pm-airgap-installation-v2.sh

########################################################
########################################################
docker_login() {
  local hub_url="$1"
  local username="$2"
  local password="$3"

  if [[ -z "$hub_url" || -z "$username" || -z "$password" ]]; then
    echo "Error: Missing required arguments in docker login."
    exit 1
  fi

  echo "Logging into Docker Hub at $hub_url as $username user."
  echo "$password" | docker login "$hub_url" -u "$username" --password-stdin

  if [[ $? -eq 0 ]]; then
    echo "Docker Login successful."
  else
    echo "Docker Login failed. Please verify the details and retry."
    exit 1
  fi
  echo "==========================================================="
}
PRIVACERA_HUB_URL=$(echo $PRIV_MGR_IMAGE | awk -F'/' '{print $1}')
docker_login $PRIVACERA_HUB_URL $PRIVACERA_HUB_USER $PRIVACERA_HUB_PASSWORD

# Destination hub login/tag/push are only needed for default and push flows.
# Pull-only mode keeps images locally and does not require destination hub vars.
if [ "$action" != "pull" ]; then
  docker_login $DESTINATION_HUB_URL $DESTINATION_HUB_USER $DESTINATION_HUB_PASSWORD
fi

echo "Pulling the Privacera Manager Image from Privacera Hub..."
docker pull $PRIV_MGR_IMAGE

if [ "$action" != "pull" ]; then
  docker tag $PRIV_MGR_IMAGE $DESTINATION_HUB_URL/privacera-manager:$PRIVACERA_VERSION
  echo "==========================================================="
  echo "Pushing the Privacera Manager Image to Destination Hub..."
  docker push $DESTINATION_HUB_URL/privacera-manager:$PRIVACERA_VERSION
  echo "==========================================================="
else
  echo "Pull-only mode: keeping Privacera Manager image locally (no tag/push)."
  echo "==========================================================="
fi

########################################################
########################################################

echo "Downloading/Updating the Airgap Script..."
wget -c $AIRGAP_SCRIPT_DOWNLOAD_URL -O pm-airgap-installation-v2.sh
chmod +x pm-airgap-installation-v2.sh

echo "===================================================="
echo "Running Airgap Script.."
if [ "$action" = "" ] || [ "$action" = "pull" ]; then
  . $CURRENT_DIR/pm-airgap-installation-v2.sh $action
elif [ "$action" = "push" ]; then
  . $CURRENT_DIR/pm-airgap-installation-v2.sh $action
else
  echo "ERROR: Action '$action' not supported"
fi
