# Docker image for Privacera Manager. It includes the repository URL and the image tag.
PRIV_MGR_IMAGE=""  # Example: "hub2.privacera.com/privacera-manager:rel_9.0.0.3"

# URL for the Privacera Manager package, usually hosted on an S3 bucket or a similar repository.
PRIV_MGR_PACKAGE=""  # Example: "https://privacera-host/path/privacera-manager.tar.gz"

# Username for accessing Privacera Hub, the central repository for Privacera images.
PRIVACERA_HUB_USER=""  # Example: "hub_user"

# Password for accessing Privacera Hub. This should be securely stored.
PRIVACERA_HUB_PASSWORD=""  # Example: "hub_password"

# Hub URLof the Destination Docker Hub.
DESTINATION_HUB_URL=""  # Example: "hub_user"

# Username for accessing Destination Hub.
DESTINATION_HUB_USER=""  # Example: "hub_user"

# Password for accessing Destination Hub
DESTINATION_HUB_PASSWORD=""  # Example: "hub_password"

### SSH Details of Privacera Host ###
PM_HOSTNAME=""  # Example: "10.127.2.1"
PM_HOST_USERNAME=""  # Example: "privacera"
REMOTE_DIR=""  # It should be "/home/<PM_HOST_USERNAME>/privacera"