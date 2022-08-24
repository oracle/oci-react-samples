#!/bin/bash

location=$1
password=$2
connection=$3

{
  echo "set cloudconfig $location"
  echo "conn admin/$password@$connection"
  echo "@AdminCreateUsers.sql"
  echo "conn aquser/$password@$connection"
  echo "@AQUserCreateQueues.sql"
  echo "conn bankauser/$password@$connection"
  echo "@BankAUser.sql"
  echo "conn bankbuser/$password@$connection"
  echo "@BankBUser.sql"
} | sql /nolog