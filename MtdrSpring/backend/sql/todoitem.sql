-- MyToDoReact version 2.0.0
--
-- Copyright (c) 2024 Oracle, Inc.
-- Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/


CREATE TABLE TODOOWNER.TODOITEM
(
    ID          NUMBER GENERATED ALWAYS AS IDENTITY,
    DESCRIPTION VARCHAR2(4000),
    CREATION_TS TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    DONE        NUMBER(1, 0)             DEFAULT 0,
    PRIMARY KEY (ID)
);

INSERT INTO TODOOWNER.TODOITEM (DESCRIPTION)
VALUES ('My first task!');