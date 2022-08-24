# initialization
STATE_LOCATION=$CB_STATE_DIR/state.json

# generate YAML
echo -n "Generating YAML file..."
SRC_FILE=$CB_KUBERNETES_TEMPLATES_DIR/sidb-create-template.yaml
YAML_FILE=$CB_KUBERNETES_GEN_FILES_DIR/sidb-create.yaml
SIDB_NAME=cloudbankdb
SIDB_NAMESPACE=cloudbank
SIDB_PWD_SECRET=sidb-admin-secret

# run task
$CB_STATE_DIR/tasks/generate-yaml-sidb-create.sh $SRC_FILE $YAML_FILE $SIDB_NAME $SIDB_NAMESPACE $SIDB_PWD_SECRET

# Output copy
echo ""
echo "To apply:"
echo "kubectl apply -f $YAML_FILE"
echo ""
