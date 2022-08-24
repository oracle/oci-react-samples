#!/bin/bash
CURRENT_TIME=$( date '+%F_%H:%M:%S' )

# create log-file and set state
state_set '.state.terminate.STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"
touch $CB_STATE_DIR/logs/$CURRENT_TIME-kubectl-version.log

# if kubernetes cluster exists
if kubectl version >> $CB_STATE_DIR/logs/$CURRENT_TIME-kubectl-version.log; then

  # if ADB resource still exists
  ADB_EXISTS=$(kubectl get AutonomousDatabase cloudbankdb -o "jsonpath={.status.lifecycleState}")
  if [ $? -eq 0 ]; then
    ./gen-adb-delete.sh
    kubectl apply -f $CB_STATE_DIR/generated/adb-delete.yaml
    kubectl delete AutonomousDatabase/cloudbankdb
  fi

  # if Frontend service still exists
  FESERVICE=$(kubectl get svc/frontend-service -o name | grep service/frontend-service)
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

# return
cd $LAB_HOME