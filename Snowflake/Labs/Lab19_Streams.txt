========
Streams 
========
USE DATABASE MYOWN_DB;

// Create a schema for Streams
CREATE SCHEMA IF NOT EXISTS MYSTREAMS;

// Create a schema for Source tables
CREATE SCHEMA IF NOT EXISTS STAGE_TBLS;

// Create a schema for Target tables
CREATE SCHEMA IF NOT EXISTS INTG_TBLS;

// Create sample table -- source table in stage schema
CREATE TABLE STAGE_TBLS.STG_EMPL
( EMPID INT,
  EMPNAME VARCHAR(30),
  SALARY FLOAT,
  AGE INT,
  DEPT VARCHAR(10),
  LOCATION VARCHAR(20)
);


// Create a stream on above Source table
CREATE STREAM MYSTREAMS.STREAM_EMPL ON TABLE STAGE_TBLS.STG_EMPL;

CREATE STREAM MYSTREAMS.STREAM_EMPL_2 ON TABLE STAGE_TBLS.STG_EMPL;

SHOW STREAMS IN SCHEMA MYSTREAMS;

SELECT * FROM MYSTREAMS.STREAM_EMPL;


// Create a target table -- final table in integration schema
CREATE TABLE INTG_TBLS.EMPL
( EMPID INT,
  EMPNAME VARCHAR(30),
  SALARY FLOAT,
  AGE INT,
  DEPT VARCHAR(15),
  LOCATION VARCHAR(20),
  INSRT_DT DATE,
  LST_UPDT_DT DATE
);


=============
Only Inserts
=============
// Insert some data into Stage source table
INSERT INTO STAGE_TBLS.STG_EMPL VALUES
(1, 'Amar', 80000, 35, 'SALES', 'Bangalore'),
(2, 'Bharath', 45000, 26, 'SALES', 'Hyderabad'),
(3, 'Charan', 76000, 34, 'TECHNOLOGY', 'Chennai'),
(4, 'Divya', 52000, 28, 'HR', 'Hyderabad'),
(5, 'Gopal', 24500, 22, 'TECHNOLOGY', 'Bangalore'),
(6, 'Haritha', 42000, 27, 'HR', 'Chennai')
;

// Check stage table data
SELECT * FROM STAGE_TBLS.STG_EMPL;

// Check stream object
SELECT * FROM MYSTREAMS.STREAM_EMPL;

// Consume stream object and load into final table
INSERT INTO INTG_TBLS.EMPL
( EMPID, EMPNAME, SALARY, AGE, DEPT, LOCATION, INSRT_DT, LST_UPDT_DT)
SELECT EMPID, EMPNAME, SALARY, AGE, DEPT, LOCATION, CURRENT_DATE, NULL
FROM  MYSTREAMS.STREAM_EMPL
WHERE METADATA$ACTION = 'INSERT'
AND METADATA$ISUPDATE = FALSE;

// View final target table data
SELECT * FROM INTG_TBLS.EMPL;

// Observe Stream object now
SELECT * FROM MYSTREAMS.STREAM_EMPL;

=============
Only Updates
=============
SELECT * FROM STAGE_TBLS.STG_EMPL;

// Update 2 records in stage table
UPDATE STAGE_TBLS.STG_EMPL SET SALARY=49000 WHERE EMPID=2;

UPDATE STAGE_TBLS.STG_EMPL SET LOCATION='Pune' WHERE EMPID=5;

// Check stage table data
SELECT * FROM STAGE_TBLS.STG_EMPL;

// Observe stream object now
SELECT * FROM MYSTREAMS.STREAM_EMPL;

// Consume stream object and merge into final table
MERGE INTO INTG_TBLS.EMPL E
USING MYSTREAMS.STREAM_EMPL S
	ON E.EMPID = S.EMPID
WHEN MATCHED 
    AND S.METADATA$ACTION ='INSERT'
    AND S.METADATA$ISUPDATE ='TRUE'  -- indicates the record has been updated 
THEN UPDATE 
    SET E.EMPNAME = S.EMPNAME,
		E.SALARY = S.SALARY,
		E.AGE = S.AGE,
		E.DEPT = S.DEPT,
		E.LOCATION = S.LOCATION,
		E.LST_UPDT_DT = CURRENT_DATE;
		
// View final target table data
SELECT * FROM INTG_TBLS.EMPL;

// Observe Stream object now
SELECT * FROM MYSTREAMS.STREAM_EMPL;

=============
Only Deletes
=============
SELECT * FROM STAGE_TBLS.STG_EMPL;

// Delete 2 records from stage table
DELETE FROM STAGE_TBLS.STG_EMPL WHERE EMPID in (3,4);

// Check stage table data
SELECT * FROM STAGE_TBLS.STG_EMPL;

// Observe Stream object now
SELECT * FROM MYSTREAMS.STREAM_EMPL;

// Consume stream object and merge into final table
MERGE INTO INTG_TBLS.EMPL E
USING MYSTREAMS.STREAM_EMPL S
	ON E.EMPID = S.EMPID
WHEN MATCHED 
    AND S.METADATA$ACTION ='DELETE'
    AND S.METADATA$ISUPDATE ='FALSE'
THEN DELETE;

// View final target table data
SELECT * FROM INTG_TBLS.EMPL;

// Observe Stream object now
SELECT * FROM MYSTREAMS.STREAM_EMPL;


======================
All changes at a time
======================
SELECT * FROM STAGE_TBLS.STG_EMPL;

// Insert 2 new records 
INSERT INTO STAGE_TBLS.STG_EMPL VALUES
(7, 'Janaki', 61000, 29, 'SALES', 'Pune'),
(8, 'Kamal', 92000, 33, 'TECHNOLOGY', 'Bangalore');

// Update existing record
UPDATE STAGE_TBLS.STG_EMPL 
SET SALARY=85000, LOCATION='Hyderabad' 
WHERE EMPID=1;

// Delete one existing record
DELETE FROM STAGE_TBLS.STG_EMPL WHERE EMPID in (6);


// Check stage table data
SELECT * FROM STAGE_TBLS.STG_EMPL;

// Observe stream object now
SELECT * FROM MYSTREAMS.STREAM_EMPL;


// Consume all changes from stream and merge into final table
MERGE INTO INTG_TBLS.EMPL T
USING MYSTREAMS.STREAM_EMPL S
	ON T.EMPID = S.EMPID
WHEN MATCHED                        -- DELETE condition
    AND S.METADATA$ACTION ='DELETE' 
    AND S.METADATA$ISUPDATE = 'FALSE'
    THEN DELETE                   
WHEN MATCHED                        -- UPDATE condition
    AND S.METADATA$ACTION ='INSERT' 
    AND S.METADATA$ISUPDATE  = 'TRUE'       
    THEN UPDATE 
    SET T.EMPNAME = S.EMPNAME,
		T.SALARY = S.SALARY,
		T.AGE = S.AGE,
		T.DEPT = S.DEPT,
		T.LOCATION = S.LOCATION,
		T.LST_UPDT_DT = CURRENT_DATE
WHEN NOT MATCHED 					-- INSERT records
    AND S.METADATA$ACTION ='INSERT'
	AND S.METADATA$ISUPDATE  = 'FALSE'
    THEN INSERT( EMPID, EMPNAME, SALARY, AGE, DEPT, LOCATION, INSRT_DT, LST_UPDT_DT)
	VALUES(S.EMPID, S.EMPNAME, S.SALARY, S.AGE, S.DEPT, S.LOCATION, CURRENT_DATE, NULL)
;


// View final target table data
SELECT * FROM INTG_TBLS.EMPL;

// Observe Stream object now
SELECT * FROM MYSTREAMS.STREAM_EMPL;

===================
Streams with Tasks
===================
CREATE OR REPLACE TASK MYTASKS.TASK_EMPL_DATA_LOAD
    WAREHOUSE = MYOWN_WH
    SCHEDULE = '5 MINUTES'
    WHEN SYSTEM$STREAM_HAS_DATA('MYSTREAMS.STREAM_EMPL')
AS 
MERGE INTO INTG_TBLS.EMPL T
USING MYSTREAMS.STREAM_EMPL S
	ON T.EMPID = S.EMPID
WHEN MATCHED
    AND S.METADATA$ACTION ='DELETE' 
    AND S.METADATA$ISUPDATE = 'FALSE'
    THEN DELETE                   
WHEN MATCHED
    AND S.METADATA$ACTION ='INSERT' 
    AND S.METADATA$ISUPDATE  = 'TRUE'       
    THEN UPDATE 
    SET T.EMPNAME = S.EMPNAME,
		T.SALARY = S.SALARY,
		T.AGE = S.AGE,
		T.DEPT = S.DEPT,
		T.LOCATION = S.LOCATION,
		T.LST_UPDT_DT = CURRENT_DATE
WHEN NOT MATCHED
    AND S.METADATA$ACTION ='INSERT'
	AND S.METADATA$ISUPDATE  = 'FALSE'
    THEN INSERT( EMPID, EMPNAME, SALARY, AGE, DEPT, LOCATION, INSRT_DT, LST_UPDT_DT)
	VALUES(S.EMPID, S.EMPNAME, S.SALARY, S.AGE, S.DEPT, S.LOCATION, CURRENT_DATE, NULL)
;

// Start the task
ALTER TASK MYTASKS.TASK_EMPL_DATA_LOAD RESUME;


SELECT * FROM STAGE_TBLS.STG_EMPL;

// Insert 1 new record
INSERT INTO STAGE_TBLS.STG_EMPL VALUES
(9, 'Latha', 47000, 25, 'HR', 'Chennai');

// Update existing record
UPDATE STAGE_TBLS.STG_EMPL 
SET SALARY=67000 WHERE EMPID=7;

// Delete one existing record
DELETE FROM STAGE_TBLS.STG_EMPL WHERE EMPID in (8);


// Observe Stream object now
SELECT * FROM MYSTREAMS.STREAM_EMPL;

// Check the data after 5 mins
SELECT * FROM INTG_TBLS.EMPL;

// Observe Stream object now
SELECT * FROM MYSTREAMS.STREAM_EMPL;


==============================================================
How to build type 2 dimensions in snowflake by using streams?
==============================================================
// Please go through below links, explained with example

// Setting up data first
https://community.snowflake.com/s/article/Building-a-Type-2-Slowly-Changing-Dimension-in-Snowflake-Using-Streams-and-Tasks-Part-1

// Creating streams and writing merge query
https://community.snowflake.com/s/article/Building-a-Type-2-Slowly-Changing-Dimension-in-Snowflake-Using-Streams-and-Tasks-Part-2 
