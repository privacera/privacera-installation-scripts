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
PRIVACERA_MANIFEST_URL=""

# Function to compare version strings
clean_version() {
  echo "$1" | sed -E 's/^rel_//; s/-SNAPSHOT$//'
}

# Extract version number from PRIV_MGR_IMAGE_TAG
if [ -z "$PRIVACERA_VERSION" ]; then
  PRIVACERA_VERSION=$(clean_version "$PRIV_MGR_IMAGE_TAG")
fi

# Function to compare version strings (e.g., "9.0.4.1-1")
version_le() {
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" = "$1" ]
}

echo "PRIVACERA_VERSION: $PRIVACERA_VERSION"
VERSION_COMPARE=$(echo $PRIVACERA_VERSION | tr "-" " " | awk '{print $1}')
echo "VERSION_COMPARE: $VERSION_COMPARE"

if ! version_le "$VERSION_COMPARE" "9.0.4.1"; then
  echo "going with new deployment process....."
  PRIV_MGR_BASE_URL=$(echo $PRIV_MGR_PACKAGE | awk -F/ '{print $1 "//" $3}')
  PRIVACERA_MANIFEST_URL="${PRIV_MGR_BASE_URL}/manifests/${PRIVACERA_VERSION}/release-manifest.yaml"
  echo "Manifest URL: $PRIVACERA_MANIFEST_URL"
else
  PRIV_MGR_BASE_URL=${PRIV_MGR_PACKAGE%/privacera-manager.tar.gz}
fi

echo "PRIV_MGR_BASE_URL: $PRIV_MGR_BASE_URL"

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
if ! version_le "$VERSION_COMPARE" "9.0.4.1"; then
  echo "Downloading latest manifest file...."
  wget ${PRIVACERA_MANIFEST_URL} -O ~/privacera/privacera-manager/ansible/privacera-docker/privacera-manifest/release-manifest.yaml
fi

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