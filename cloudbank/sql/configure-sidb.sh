#!/bin/bash

database=$1
password=$2
connection='XEPDB1'

{
  echo "alter session set container=XEPDB1;"
  echo "connect sys/$password@$connection as sysdba"
  cat AdminCreateUsers-SIDBXE.sql
  echo "conn aquser/$password@$connection"
  cat AQUserCreateQueues.sql
  echo "conn bankauser/$password@$connection"
  cat BankAUser.sql
  echo "conn bankbuser/$password@$connection"
  cat BankBUser.sql
} | kubectl exec -i $(kubectl get pods | grep $database) -- sqlplus / as sysdba