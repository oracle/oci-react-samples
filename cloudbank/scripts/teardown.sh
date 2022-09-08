#!/bin/bash
CURRENT_TIME=$( date '+%F_%H:%M:%S' )

# check if this script needs to run again
PYTHON_FUNCTION=$CB_STATE_DIR/tasks/lab-utils.py
COMPLETED_BEFORE=$(python "$PYTHON_FUNCTION" json -p state.terminate.STARTED)
echo -n "Starting Teardown of resources on OCI..."
if [ -n "$COMPLETED_BEFORE" ]; then
  echo "SKIPPED"
  exit 0;
else
  echo "STARTED"
fi;


# create log-file and set state
state_set '.state.terminate.STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"
touch $CB_STATE_DIR/logs/$CURRENT_TIME-kubectl-version.log

# if kubernetes cluster exists
if kubectl version >> $CB_STATE_DIR/logs/$CURRENT_TIME-kubectl-version.log; then

  # if ADB resource still exists
  ADB_EXISTS=$(kubectl get AutonomousDatabase cloudbankdb -o "jsonpath={.status.lifecycleState}")
  if [ $? -eq 0 ]; then
    ./gen-adb-delete.sh >> $CB_STATE_DIR/logs/$CURRENT_TIME-kubectl-version.log;
    kubectl apply -f $CB_STATE_DIR/generated/adb-delete.yaml
    kubectl delete AutonomousDatabase/cloudbankdb
  fi

  # if Frontend service still exists
  FESERVICE=$(kubectl get svc -o name | grep service/frontend-service)
  if [ $? -eq 0 ]; then
    kubectl delete service/frontend-service
  fi

fi

# Generate Terraform Vars file
echo -n 'Preparing terraform...'
envfile=$CB_TERRAFORM_DIR/terraform.env
. $envfile
echo 'DONE'

# Run terraform
$CB_STATE_DIR/tasks/terraform-destroy.sh &


# Restore bashrc/zshrc
echo -n 'Restoring bashrc...'
$CB_STATE_DIR/tasks/restore-bashrc.sh
echo 'DONE'

# return
cd $LAB_HOME