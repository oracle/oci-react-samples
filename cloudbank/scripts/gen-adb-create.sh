#!/bin/bash

# initialization
STATE_LOCATION=$CB_STATE_DIR/state.json

# requires compartment OCID
echo -n "Retreiving Compartment OCID..."
COMPOCID="$(state_get .lab.ocid.compartment)"
if [[ $COMPOCID == null ]]; then
  echo "NOT FOUND"
  read -p "Enter the compartment OCID to provision resources in: " OCID
  state_set '.lab.ocid.compartment |= $VAL' $OCID
elif [[ ! $COMPOCID == null ]]; then
  echo "DONE"
fi
echo ""


# Get compartment OCID variable
COMPARTMENT_OCID=$(state_get .lab.ocid.compartment)


# generate YAML
echo -n "Generating YAML file..."
YAML_FILE=$CB_KUBERNETES_GEN_FILES_DIR/adb-create.yaml
cp $CB_KUBERNETES_TEMPLATES_DIR/adb-create-template.yaml $YAML_FILE
echo "DONE"


# Replacing Compartment OCID
echo -n "Updating generated YAML file..."
sed -e  "s|%ADB_COMPARTMENT%|$COMPARTMENT_OCID|g" $YAML_FILE > /tmp/adb-create.yaml
mv -- /tmp/adb-create.yaml $YAML_FILE
echo "DONE"


# Output copy
echo ""
echo "To apply:"
echo "kubectl apply -f $YAML_FILE"
echo ""
