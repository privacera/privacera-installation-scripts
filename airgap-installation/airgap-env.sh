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

#############################
### Components to install ###
#############################
# Set the value of below components as y/n as per your requirement. 
## Core components have these images: Privacera Manager, Portal, Solr, ZK, Ranger, Privacera Usersync, Ranger Tagsync and Usersync, Audit Server and Audit Fluentd
DOWNLOAD_CORE_COMPONENTS=""
DOWNLOAD_MARIADB=""
DOWNLOAD_DATASERVER_COMPONENTS=""
DOWNLOAD_DISCOVERY_COMPONENTS=""
DOWNLOAD_MASKING_AND_ENCRYPTION_COMPONENTS=""
DOWNLOAD_OPS_SERVER_COMPONENTS=""
DOWNLOAD_DIAGNOSTICS_COMPONENTS=""
DOWNLOAD_MONITORING_COMPONENTS=""

### Connector components
DOWNLOAD_CONNECTOR_COMPONENTS=""
# If connector component is set to "y" then please select the connetcors to install and set the value to y/n.
POLICYSYNC_MSSQL_IMAGE=""
POLICYSYNC_POSTGRES_IMAGE=""
POLICYSYNC_SNOWFLAKE_IMAGE=""
POLICYSYNC_DATABRICKS_IMAGE=""
POLICYSYNC_DREMIO_IMAGE=""
POLICYSYNC_REDSHIT_IMAGE=""
POLICYSYNC_POWERBI_IMAGE=""
POLICYSYNC_BIGQUERY_IMAGE=""
POLICYSYNC_LAKEFORMATION_IMAGE=""
POLICYSYNC_DATABRICKS_UNITY_CATALOG_IMAGE=""
POLICYSYNC_VERTICA_IMAGE=""