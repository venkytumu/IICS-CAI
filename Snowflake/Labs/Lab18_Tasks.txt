=================
Creating Tasks 
=================
USE DATABASE MYOWN_DB;

CREATE SCHEMA MYTASKS;

// Create a sample table for inserting data using tasks
CREATE OR REPLACE TABLE MYOWN_DB.PUBLIC.TRACK_LOAD_TIME 
(
    ID INT AUTOINCREMENT START = 1 INCREMENT =1,
    NAME VARCHAR(20) DEFAULT 'JANARDHAN' ,
    LOAD_TIME TIMESTAMP
);


// Create task to insert data for every minute
CREATE OR REPLACE TASK MYTASKS.TASK_TRACK_TIME
    WAREHOUSE = MYOWN_WH
    SCHEDULE = '1 MINUTE'
AS 
INSERT INTO MYOWN_DB.PUBLIC.TRACK_LOAD_TIME(LOAD_TIME) 
	VALUES(CURRENT_TIMESTAMP);
	
// View the data
SELECT * FROM MYOWN_DB.PUBLIC.TRACK_LOAD_TIME;


// To see tasks
SHOW TASKS;

DESC TASK MYTASKS.TASK_TRACK_TIME;

// Starting and suspending tasks
ALTER TASK MYTASKS.TASK_TRACK_TIME RESUME;
--ALTER TASK MYTASKS.TASK_TRACK_TIME SUSPEND;


// Using Cron to load the data for every minute
CREATE OR REPLACE TASK MYTASKS.TASK_TRACK_TIME2
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON * * * * * UTC'
AS 
INSERT INTO MYOWN_DB.PUBLIC.TRACK_LOAD_TIME(NAME,LOAD_TIME) 
	VALUES('DONALD', CURRENT_TIMESTAMP);
	
    
ALTER TASK MYTASKS.TASK_TRACK_TIME2 RESUME;


// View the data
SELECT * FROM MYOWN_DB.PUBLIC.TRACK_LOAD_TIME;

// Some example schedules

// Every day at 7AM UTC timezone
SCHEDULE = 'USING CRON 0 7 * * * UTC'

// Every day at 10AM and 10PM
SCHEDULE = 'USING CRON 0 10,22 * * * UTC'

// Every month last day at 11 PM
SCHEDULE = 'USING CRON 0 23 L * * UTC'

// Every Monday at 6.30 AM
SCHEDULE = 'USING CRON 30 6 * * 1 UTC'

// First day of the month only from January to March
SCHEDULE = 'USING CRON 0 7 1 1-3 * UTC'

======================
Creating DAG of Tasks
======================
CREATE TABLE MYOWN_DB.PUBLIC.CUST_ADMIN
(CUSTID INT AUTOINCREMENT START = 1 INCREMENT =1, 
 CUST_NAME STRING DEFAULT 'JOHN',
 DEPT_NAME STRING DEFAULT 'SALES',
 LOAD_TIME TIMESTAMP
);

// Root task
CREATE OR REPLACE TASK MYTASKS.TASK_CUST_ADMIN
    WAREHOUSE = MYOWN_WH
    SCHEDULE = '1 MINUTE'
AS 
INSERT INTO MYOWN_DB.PUBLIC.CUST_ADMIN(LOAD_TIME) 
	VALUES(CURRENT_TIMESTAMP);
	
	
// Task for loading SALES Table 
CREATE OR REPLACE TASK MYTASKS.TASK_CUST_SALES
    WAREHOUSE = MYOWN_WH
    AFTER MYTASKS.TASK_CUST_ADMIN
AS 
CREATE OR REPLACE TABLE MYOWN_DB.PUBLIC.CUST_SALES
AS 
SELECT * FROM MYOWN_DB.PUBLIC.CUST_ADMIN 
	WHERE DEPT_NAME = 'SALES';
	
	
// Task for loading HR Table -- not mentioning warehouse, will use snowflake compute resources
CREATE OR REPLACE TASK MYTASKS.TASK_CUST_HR
    AFTER MYTASKS.TASK_CUST_ADMIN
AS 
CREATE OR REPLACE TABLE MYOWN_DB.PUBLIC.CUST_HR
AS 
SELECT * FROM MYOWN_DB.PUBLIC.CUST_ADMIN 
	WHERE DEPT_NAME = 'HR';


// Task for loading MARKETING Table -- not mentioning warehouse, will use snowflake compute resources
CREATE OR REPLACE TASK MYTASKS.TASK_CUST_MARKET
AS 
CREATE OR REPLACE TABLE MYOWN_DB.PUBLIC.CUST_MARKET
AS 
SELECT * FROM MYOWN_DB.PUBLIC.CUST_ADMIN 
	WHERE DEPT_NAME = 'MARKET';
    
    
// Add dependencies
ALTER TASK MYTASKS.TASK_CUST_MARKET ADD AFTER MYTASKS.TASK_CUST_SALES;
ALTER TASK MYTASKS.TASK_CUST_MARKET ADD AFTER MYTASKS.TASK_CUST_HR;

// Start the tasks - Child first then parent  
ALTER TASK MYTASKS.TASK_CUST_MARKET RESUME;
ALTER TASK MYTASKS.TASK_CUST_SALES RESUME;
ALTER TASK MYTASKS.TASK_CUST_HR RESUME;
ALTER TASK MYTASKS.TASK_CUST_ADMIN RESUME;

SHOW TASKS;
	
// View the data
SELECT * FROM MYOWN_DB.PUBLIC.CUST_ADMIN;
SELECT * FROM MYOWN_DB.PUBLIC.CUST_SALES;
SELECT * FROM MYOWN_DB.PUBLIC.CUST_HR;
SELECT * FROM MYOWN_DB.PUBLIC.CUST_MARKET;


// Alter the root task
ALTER TASK MYTASKS.TASK_CUST_ADMIN
MODIFY
AS 
INSERT INTO MYOWN_DB.PUBLIC.CUST_ADMIN(CUST_NAME,DEPT_NAME,LOAD_TIME) 
	VALUES('CHARLES','MARKET', CURRENT_TIMESTAMP);

// Suspend the task before altering
ALTER TASK TASK_CUST_ADMIN SUSPEND;

// Resume the task after altering
ALTER TASK TASK_CUST_ADMIN RESUME;

// View the data
SELECT * FROM MYOWN_DB.PUBLIC.CUST_ADMIN;
SELECT * FROM MYOWN_DB.PUBLIC.CUST_SALES;
SELECT * FROM MYOWN_DB.PUBLIC.CUST_HR;
SELECT * FROM MYOWN_DB.PUBLIC.CUST_MARKET;

=============
Task History
=============
// To see all tasks history with last executed task first
select  *   from table(information_schema.task_history())
  order by scheduled_time desc;  
  
// To see history of a specific task
select  *  from table(information_schema.task_history(
    task_name => 'TASK_TRACK_TIME')
	);

// To see results of a specific task in last 6 hours
select  *  from table(information_schema.task_history(
    scheduled_time_range_start => dateadd('hour',-6,current_timestamp()),
    result_limit => 10,
    task_name => 'TASK_TRACK_TIME')
	);	
    
// To see results in a given time period
select  *  from table(information_schema.task_history(
    scheduled_time_range_start => to_timestamp_ltz('2022-07-17 1:00:00.000 -0700'),
    scheduled_time_range_end => to_timestamp_ltz('2022-07-18 1:00:00.000 -0700'))
	); 

select to_timestamp_ltz(current_timestamp);

