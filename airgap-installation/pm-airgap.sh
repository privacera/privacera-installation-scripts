#!/bin/bash
action=$1
CURRENT_DIR=$(pwd)
source ${CURRENT_DIR}/airgap-env.sh

PRIVACERA_HUB_URL=$(echo $PRIV_MGR_IMAGE | awk -F'/' '{print $1}')
PRIVACERA_VERSION=$(echo $PRIV_MGR_IMAGE | awk -F':' '{print $2}')
PRIVACERA_BASE_DOWNLOAD_URL=$(echo $PRIV_MGR_PACKAGE | awk -F/ '{print $1 "//" $3}')
AIRGAP_SCRIPT_DOWNLOAD_URL=$PRIVACERA_BASE_DOWNLOAD_URL/privacera-manager/$PRIVACERA_VERSION/pm-airgap-installation-v2.sh

echo "Downloading/Updating the Airgap Script..."
wget -c $AIRGAP_SCRIPT_DOWNLOAD_URL -O pm-airgap-installation-v2.sh
chmod +x pm-airgap-installation-v2.sh

echo "===================================================="
echo "Running Airgap Script.."
if [ "$action" = "" ]; then
  . $CURRENT_DIR/pm-airgap-installation-v2.sh
elif [ "$action" = "push" ]; then
  . $CURRENT_DIR/pm-airgap-installation-v2.sh $action
else
  echo "ERROR: Action '$action' not supported"
fi