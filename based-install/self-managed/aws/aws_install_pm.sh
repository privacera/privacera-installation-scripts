#!/bin/bash

# Check if a file path is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/your/envfile"
  exit 1
fi

# Source the environment variables from the provided file
source "$1"

# Ensure the necessary variables are set
if [ -z "$DEPLOYMENT_ENV_NAME" ] || [ -z "$PRIV_MGR_IMAGE" ] || [ -z "$PRIV_MGR_PACKAGE" ] || [ -z "$PRIVACERA_HUB_USER" ] || [ -z "$PRIVACERA_HUB_PASSWORD" ]; then
  echo "One or more required environment variables are missing in the file."
  exit 1
fi

# Derive other environment variables
PRIVACERA_HUB_HOSTNAME=$(echo $PRIV_MGR_IMAGE | awk -F'/' '{print $1}')
PRIV_MGR_IMAGE_TAG=$(echo $PRIV_MGR_IMAGE | awk -F':' '{print $2}')
PRIV_MGR_BASE_URL=${PRIV_MGR_PACKAGE%/privacera-manager.tar.gz}

# Log in to Docker Hub
docker login $PRIVACERA_HUB_HOSTNAME -u $PRIVACERA_HUB_USER -p $PRIVACERA_HUB_PASSWORD

# Pull the Docker image
docker pull $PRIV_MGR_IMAGE

# Create directories
mkdir -p ~/privacera/downloads

# Download the package
cd ~/privacera/downloads
wget $PRIV_MGR_PACKAGE -O privacera-manager.tar.gz

# Extract the tarball
cd ~/privacera
tar -zxf ~/privacera/downloads/privacera-manager.tar.gz

# Create a shell script for internal use
cd ~/privacera/privacera-manager/config
echo '#!/bin/bash' > pm-env.sh
echo "export PRIV_MGR_PACKAGE=${PRIV_MGR_PACKAGE}" >> pm-env.sh 
echo "export PRIV_MGR_IMAGE=${PRIV_MGR_IMAGE}" >> pm-env.sh
echo "export privacera_hub_url=${PRIVACERA_HUB_HOSTNAME}" >> pm-env.sh

# Copy and update configuration file
cd ~/privacera/privacera-manager
cp -n config/sample.vars.privacera.yml config/vars.privacera.yml

# Update vars.privacera.yml with the derived values

sed -i \
"s|DEPLOYMENT_ENV_NAME: \"<PLEASE_CHANGE>\"|DEPLOYMENT_ENV_NAME: \"${DEPLOYMENT_ENV_NAME}\"|g" \
config/vars.privacera.yml

sed -i \
"s|^PRIVACERA_IMAGE_TAG: .*|PRIVACERA_IMAGE_TAG: \"${PRIV_MGR_IMAGE_TAG}\"|g" \
config/vars.privacera.yml

sed -i \
"s|^PRIVACERA_BASE_DOWNLOAD_URL: .*|PRIVACERA_BASE_DOWNLOAD_URL: \"${PRIV_MGR_BASE_URL}\"|g" \
config/vars.privacera.yml

sed -i \
"s|^privacera_hub_user: .*|privacera_hub_user: \"${PRIVACERA_HUB_USER}\"|g" \
config/vars.privacera.yml

sed -i \
"s|^privacera_hub_password: .*|privacera_hub_password: \"${PRIVACERA_HUB_PASSWORD}\"|g" \
config/vars.privacera.yml


# Insert the line to the configuration file
echo "privacera_hub_url: \"$PRIVACERA_HUB_HOSTNAME\"" >> config/vars.privacera.yml

