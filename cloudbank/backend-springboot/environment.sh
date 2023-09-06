#!/bin/bash

export remotebankqueuename="BANKBQUEUE"
export remotebankqueueschema="aquser"
export localbankqueuename="BANKAQUEUE"
export localbankqueueschema="aquser"
export banksubscribername="banka_service"
export bankdbuser="bankauser"
export bankdburl="jdbc:oracle:thin:@//$(kubectl -n cloudbank get singleinstancedatabase cbtransfer01 -o jsonpath='{.status.pdbConnectString}')"
export bankdbpw="$(state_get .lab.fixed_demo_user_credential)"
