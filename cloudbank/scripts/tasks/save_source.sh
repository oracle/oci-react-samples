#!/bin/bash
# expects state_functions.env to exist inside CB_STATE_DIR
# expects environment variables set by source.env or ~/.bashrc

# check if this script needs to run again
PYTHON_FUNCTION=$CB_STATE_DIR/tasks/lab-utils.py
COMPLETED_BEFORE=$(python $PYTHON_FUNCTION json -p state.source.SET)
echo -n 'Saving Lab settings...'
if [ -n "$COMPLETED_BEFORE" ]; then
  echo "SKIPPED"
  exit 0;
fi;

# write state/source.env
echo """
# ====================== BEGIN CLOUDBANK SOURCE ENV ======================

export LAB_HOME=${LAB_HOME}
export ROOT_DIR=${ROOT_DIR}
export CB_ROOT_DIR=${CB_ROOT_DIR}
export CB_STATE_DIR=${CB_STATE_DIR}
export CB_TERRAFORM_DIR=${CB_TERRAFORM_DIR}
export CB_KUBERNETES_TEMPLATES_DIR=${CB_KUBERNETES_TEMPLATES_DIR}
export CB_KUBERNETES_GEN_FILES_DIR=${CB_KUBERNETES_GEN_FILES_DIR}

source ${CB_STATE_DIR}/state_functions.env
# ====================== END CLOUDBANK SOURCE ENV ==========================
""" > $CB_STATE_DIR/source.env



# check bashrc
if [ -f ~/.bashrc ]; then
  # for BASH, create backup
  cp ~/.bashrc ~/.bashrc-cbworkshop-backup
  cat $CB_STATE_DIR/source.env >> ~/.bashrc

elif [ -f ~/.zshrc ]; then
  # for ZSH, create backup
  cp ~/.zshrc ~/.zshrc-cbworkshop-backup
  cat $CB_STATE_DIR/source.env >> ~/.zshrc

fi

# mark done
state_set '.state.source.SET |= $VAL' "$( date '+%F_%H:%M:%S' )"
echo 'DONE'

