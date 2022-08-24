#!/bin/bash
# This script is called by other scripts
# and with parameters on how to change the template


# set variables
yaml_src_location=$1
yaml_dst_location=$2
sidb_name=$3
sidb_namespace=$4
sidb_admin_pwd=$5

# copy source into destination file
cp $yaml_src_location $yaml_dst_location


# Replacing values
sed -e "s|%SIDB_NAME%|$sidb_name|g" $yaml_dst_location > /tmp/adb-wallet.yaml
mv -- /tmp/adb-wallet.yaml $yaml_dst_location

sed -e "s|%SIDB_NAMESPACE%|$sidb_namespace|g" $yaml_dst_location > /tmp/adb-wallet.yaml
mv -- /tmp/adb-wallet.yaml $yaml_dst_location

sed -e "s|%SIDB_ADMIN_PWD_SECRET%|$sidb_admin_pwd|g" $yaml_dst_location > /tmp/adb-wallet.yaml
mv -- /tmp/adb-wallet.yaml $yaml_dst_location

