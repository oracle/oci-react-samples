-- Copyright (c) 2022 Oracle and/or its affiliates.
-- Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

-- connect admin/"$DB1_ADMIN_PASSWORD"@$DB1_ALIAS

CREATE USER AQUSER IDENTIFIED BY Welcome12345;
-- CREATE USER AQUSER IDENTIFIED BY "$AQUSER_PASSWORD";
GRANT unlimited tablespace to AQUSER;
GRANT connect, resource TO AQUSER;
GRANT aq_user_role TO AQUSER;
GRANT EXECUTE ON sys.dbms_aqadm TO AQUSER;
GRANT EXECUTE ON sys.dbms_aq TO AQUSER;
-- for observability...
grant select on v_$session to aquser;
grant select on gv_$session to aquser;
grant select on gv_$persistent_subscribers to aquser;
grant select on v_$instance to aquser;
grant select on gv_$asm_diskgroup to aquser;
grant select on gv_$sysstat to aquser;
grant select on gv_$process to aquser;
grant select on gv_$system_wait_class to aquser;
grant select on gv_$osstat to aquser;


CREATE USER BANKAUSER IDENTIFIED BY Welcome12345;
-- CREATE USER BANKAUSER IDENTIFIED BY "$BANKAUSER_PASSWORD";
GRANT unlimited tablespace to BANKAUSER;
GRANT connect, resource TO BANKAUSER;
GRANT aq_user_role TO BANKAUSER;
GRANT EXECUTE ON sys.dbms_aq TO BANKAUSER;
GRANT SODA_APP to BANKAUSER;
GRANT SELECT ANY TABLE TO BANKAUSER;
GRANT select on gv_$session to BANKAUSER;
GRANT select on v_$diag_alert_ext to BANKAUSER;
GRANT select on DBA_QUEUE_SCHEDULES to BANKAUSER;

CREATE USER BANKBUSER IDENTIFIED BY Welcome12345;
-- CREATE USER BANKBUSER IDENTIFIED BY "$BANKBUSER_PASSWORD";
GRANT unlimited tablespace to BANKBUSER;
GRANT connect, resource TO BANKBUSER;
GRANT aq_user_role TO BANKBUSER;
GRANT EXECUTE ON sys.dbms_aq TO BANKBUSER;
GRANT SODA_APP to BANKBUSER;
GRANT SELECT ANY TABLE TO BANKBUSER;
GRANT select on gv_$session to BANKBUSER;
GRANT select on v_$diag_alert_ext to BANKBUSER;
GRANT select on DBA_QUEUE_SCHEDULES to BANKBUSER;
