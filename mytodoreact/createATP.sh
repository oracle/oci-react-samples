#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ________________________________________
echo creating MTDRDB ATP ...
echo ________________________________________

export WORKINGDIR=workingdir
echo WORKINGDIR = $WORKINGDIR

export MTDRWORKSHOP_COMPARTMENT_ID=$(cat $WORKINGDIR/mtdrworkshopcompartmentid.txt)
echo console created compartment ...
echo MTDRWORKSHOP_COMPARTMENT_ID... $MTDRWORKSHOP_COMPARTMENT_ID

echo reading password_from_console
read -s -p "Database Admin Password: " mtdrdb_admin_password
umask 177
cat >pw <<!
{ "adminPassword": "$mtdrdb_admin_password" }
!
echo create MTDRDB PDB...
oci db autonomous-database create --compartment-id $MTDRWORKSHOP_COMPARTMENT_ID --cpu-core-count 1 --data-storage-size-in-tbs 1 --db-name MTDRDB --display-name MTDRDB --from-json file://pw| jq --raw-output '.data | .["id"] ' > $WORKINGDIR/mtdrworkshopdbid.txt
export MTDRWORKSHOP_MTDRDBDB_ID=$(cat $WORKINGDIR/mtdrworkshopdbid.txt)
rm pw

echo MTDRWORKSHOP_MTDRDB_ID... $MTDRWORKSHOP_MTDRDBDB_ID
