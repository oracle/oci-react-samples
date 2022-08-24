#!/bin/bash
# This script is called by Jenkins, where $WORKSPACE has a value

# set locations
root=$WORKSPACE/examples/cloudbank
run_dir=$WORKSPACE/run
kubernetes_dir=$root/kubernetes
scripts_dir=$root/scripts
task=$scripts_dir/tasks

# create run directory if it doesn't exist
mkdir -p $run_dir

# set variables
src=$kubernetes_dir/sidb-create-template.yaml
dst=$run_dir/sidb-create.yaml
name=$1
ns="cloudbank"
admin_pwd_secret="sidb-admin-secret"

# run task
ls $task
$task/generate-yaml-sidb-create.sh $src $dst $name $ns $admin_pwd_secret
