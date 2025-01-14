#!/bin/bash

# Function to run sed commands with pattern replacement
replace_in_file() {
  local file_path=$1
  local search_pattern=$2
  local replacement=$3

  sed -i "s|$search_pattern|$replacement|" "$file_path"
}

# Check if a file path is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/your/envfile"
  exit 1
fi

# Source the environment variables from the provided file
source "$1"

# Ensure the necessary variables are set
if [ -z "$PRIVACERA_HUB_PASSWORD" ] || [ -z "$ANSIBLE_VAULT_PASSWORD" ]; then
  echo "One or more required environment variables are missing in the file."
  exit 1
fi

# Set the Ansible Vault password file path
VAULT_PASS_FILE=~/privacera/privacera-manager/credentials/ansible/vault_secret.txt

# Create the base directory if it does not exist
mkdir -p ~/privacera/privacera-manager/credentials/ansible

# Write the Ansible Vault password to the file
echo -n "$ANSIBLE_VAULT_PASSWORD" > $VAULT_PASS_FILE

# Set the temporary file for the secrets
TEMP_FILE=~/privacera/privacera-manager/vault-file.txt

# Empty the TEMP_FILE before adding any content
> $TEMP_FILE

# Add the secrets to the temporary file
echo "privacera_hub_password: \"${PRIVACERA_HUB_PASSWORD}\"" > $TEMP_FILE

# Conditionally add GLOBAL_DEFAULT_SECRETS_KEYSTORE_PASSWORD if it is set
if [ -n "$GLOBAL_DEFAULT_SECRETS_KEYSTORE_PASSWORD" ]; then
  echo "GLOBAL_DEFAULT_SECRETS_KEYSTORE_PASSWORD: \"${GLOBAL_DEFAULT_SECRETS_KEYSTORE_PASSWORD}\"" >> $TEMP_FILE

  # Additional steps: Copy and modify the vars.encrypt.secrets.yml file                                                  
  cd ~/privacera/privacera-manager/config
  cp sample-vars/vars.encrypt.secrets.yml custom-vars/

  # Comment out the GLOBAL_DEFAULT_SECRETS_KEYSTORE_PASSWORD line in the vars.encrypt.secrets.yml file
  replace_in_file "custom-vars/vars.encrypt.secrets.yml" "GLOBAL_DEFAULT_SECRETS_KEYSTORE_PASSWORD: \"<PLEASE_CHANGE>\"" "# GLOBAL_DEFAULT_SECRETS_KEYSTORE_PASSWORD: \"<PLEASE_CHANGE>\""
fi

# Additional steps: Copy and modify the vars.aws.yml file
cd ~/privacera/privacera-manager/config
cp sample-vars/vars.azure.yml custom-vars/

# Additional steps: Copy vars.helm.yml and vars.kubernetes.yml
cp sample-vars/vars.helm.yml custom-vars/
cp sample-vars/vars.kubernetes.yml custom-vars/

# Obtain the Kubernetes cluster name (last part after the slash)
K8S_CLUSTER_NAME=$(kubectl config current-context | awk -F'/' '{print $NF}')

# Replace <PLEASE_CHANGE> with the actual Kubernetes cluster name in vars.kubernetes.yml
replace_in_file "custom-vars/vars.kubernetes.yml" "K8S_CLUSTER_NAME: \"<PLEASE_CHANGE>\"" "K8S_CLUSTER_NAME: \"$K8S_CLUSTER_NAME\""

# Additional steps: Copy and modify vars.ssl.yml if SSL_DEFAULT_PASSWORD is set
cd ~/privacera/privacera-manager/config/
cp sample-vars/vars.ssl.yml custom-vars/

if [ -n "$SSL_DEFAULT_PASSWORD" ]; then
  # Uncomment and replace <PLEASE_CHANGE> with the actual SSL_DEFAULT_PASSWORD value in vars.ssl.yml
  replace_in_file "custom-vars/vars.ssl.yml" "#SSL_DEFAULT_PASSWORD: \"<PLEASE_CHANGE>\"" "SSL_DEFAULT_PASSWORD: \"$SSL_DEFAULT_PASSWORD\""
fi

# Conditionally handle database configuration based on DB type
if [ "$DB" == "MYSQL" ]; then
  cd ~/privacera/privacera-manager/config/
  cp sample-vars/vars.external.db.mysql.yml custom-vars/

  # Replace <PLEASE_CHANGE> with the corresponding environment variable values
  replace_in_file "custom-vars/vars.external.db.mysql.yml" "EXTERNAL_DB_HOST: \"<PLEASE_CHANGE>\"" "EXTERNAL_DB_HOST: \"$EXTERNAL_DB_HOST\""
  replace_in_file "custom-vars/vars.external.db.mysql.yml" "EXTERNAL_DB_NAME: \"<PLEASE_CHANGE>\"" "EXTERNAL_DB_NAME: \"$EXTERNAL_DB_NAME\""
  replace_in_file "custom-vars/vars.external.db.mysql.yml" "EXTERNAL_DB_USER: \"<PLEASE_CHANGE>\"" "EXTERNAL_DB_USER: \"$EXTERNAL_DB_USER\""
  echo "EXTERNAL_DB_PASSWORD: \"$EXTERNAL_DB_PASSWORD\"" >> $TEMP_FILE

  # Comment out the EXTERNAL_DB_PASSWORD line in the vars.external.db.mysql.yml
  replace_in_file "custom-vars/vars.external.db.mysql.yml" "EXTERNAL_DB_PASSWORD: \"<PLEASE_CHANGE>\"" "# EXTERNAL_DB_PASSWORD: \"<PLEASE_CHANGE>\""

  if [ -n "$EXTERNAL_DB_PORT" ]; then
    replace_in_file "custom-vars/vars.external.db.mysql.yml" "EXTERNAL_DB_PORT: \"3306\"" "EXTERNAL_DB_PORT: \"$EXTERNAL_DB_PORT\""
  fi

elif [ "$DB" == "POSTGRESQL" ]; then
  cd ~/privacera/privacera-manager/config/
  cp sample-vars/vars.external.db.postgres.yml custom-vars/

  # Replace <PLEASE_CHANGE> with the corresponding environment variable values
  replace_in_file "custom-vars/vars.external.db.postgres.yml" "EXTERNAL_DB_HOST: \"<PLEASE_CHANGE>\"" "EXTERNAL_DB_HOST: \"$EXTERNAL_DB_HOST\""
  replace_in_file "custom-vars/vars.external.db.postgres.yml" "EXTERNAL_DB_NAME: \"<PLEASE_CHANGE>\"" "EXTERNAL_DB_NAME: \"$EXTERNAL_DB_NAME\""
  replace_in_file "custom-vars/vars.external.db.postgres.yml" "EXTERNAL_DB_USER: \"<PLEASE_CHANGE>\"" "EXTERNAL_DB_USER: \"$EXTERNAL_DB_USER\""
  echo "EXTERNAL_DB_PASSWORD: \"$EXTERNAL_DB_PASSWORD\"" >> $TEMP_FILE

  # Comment out the EXTERNAL_DB_PASSWORD line in the vars.external.db.mysql.yml
  replace_in_file "custom-vars/vars.external.db.postgres.yml" "EXTERNAL_DB_PASSWORD: \"<PLEASE_CHANGE>\"" "# EXTERNAL_DB_PASSWORD: \"<PLEASE_CHANGE>\""

  if [ -n "$EXTERNAL_DB_PORT" ]; then
    replace_in_file "custom-vars/vars.external.db.postgres.yml" "EXTERNAL_DB_PORT: \"5432\"" "EXTERNAL_DB_PORT: \"$EXTERNAL_DB_PORT\""
  fi
fi

# Encrypt the updated secrets with Ansible Vault
~/privacera/privacera-manager/privacera-manager.sh shell ansible-vault encrypt --vault-password-file=$VAULT_PASS_FILE $TEMP_FILE

# Move the encrypted file to the desired location, forcefully overwriting if it exists
ENCRYPTED_FILE=~/privacera/privacera-manager/config/custom-vars/vars.privacera-secrets.yml
mv -f $TEMP_FILE $ENCRYPTED_FILE

# Change the owner and group of the encrypted file to the current user using sudo
sudo chown $(whoami):$(whoami) $ENCRYPTED_FILE

echo "Encrypted secrets have been stored in $ENCRYPTED_FILE"
echo "Kubernetes cluster name has been set in custom-vars/vars.kubernetes.yml"