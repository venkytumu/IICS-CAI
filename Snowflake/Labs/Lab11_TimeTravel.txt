// where can you see the retention period?
SHOW TABLES in SCHEMA myown_db.public;
SHOW SCHEMAS in DATABASE myown_db;
SHOW DATABASES;

// how to set this at the time of table creation
CREATE OR REPLACE TABLE myown_db.public.timetravel_ex(id number, name string);

SHOW TABLES like 'timetravel_ex%';

CREATE OR REPLACE TABLE myown_db.public.timetravel_ex(id number, name string)
DATA_RETENTION_TIME_IN_DAYS = 10;

SHOW TABLES like 'timetravel_ex%';

// setting at schema level
CREATE SCHEMA myown_db.abcxyz DATA_RETENTION_TIME_IN_DAYS = 10;
SHOW SCHEMAS like 'abcxyz';

CREATE OR REPLACE TABLE myown_db.abcxyz.timetravel_ex2(id number, name string);
SHOW TABLES like 'timetravel_ex2%';

CREATE OR REPLACE TABLE myown_db.abcxyz.timetravel_ex2(id number, name string) DATA_RETENTION_TIME_IN_DAYS = 20;
SHOW TABLES like 'timetravel_ex2%';


// dont forget to change your schema back to public on right top corner
// how to alter retention period later?
ALTER TABLE myown_db.public.timetravel_ex 
SET DATA_RETENTION_TIME_IN_DAYS = 15;

SHOW TABLES like 'timetravel_ex%';


// Querying history data

// Updating some data first

// Case1: update some data in customer table

SELECT * FROM myown_db.public.customer;

SELECT * FROM myown_db.public.customer WHERE CUSTOMERID=1682100334099;

UPDATE myown_db.public.customer SET CUSTNAME='ABCXYZ' WHERE CUSTOMERID=1682100334099;

SELECT * FROM myown_db.public.customer WHERE CUSTOMERID=1682100334099;

=============

// Case2: delete some data from emp_data table

SELECT * FROM myown_db.public.emp_data;

SELECT * FROM myown_db.public.emp_data where id=1;

DELETE FROM myown_db.public.emp_data where id=1;

SELECT CURRENT_TIMESTAMP; -- 2022-07-08 19:47:48.916

SELECT * FROM myown_db.public.emp_data where id=1;

==============

// Case3: update some data in customer table

SELECT * FROM myown_db.public.orders;

SELECT * FROM myown_db.public.orders WHERE ORDER_ID='B-25601';

UPDATE myown_db.public.orders SET AMOUNT=0 WHERE ORDER_ID='B-25601'; -- 01a57b69-0004-25d4-0015-ab8700024536

SELECT * FROM myown_db.public.orders WHERE ORDER_ID='B-25601';

==============

// Case1: retrieve history data by using AT OFFSET

SELECT * FROM myown_db.public.customer WHERE CUSTOMERID=1682100334099;

SELECT * FROM myown_db.public.customer AT (offset => -60*5)
WHERE CUSTOMERID=1682100334099;

// Case2: retrieve history data by using AT TIMESTAMP
SELECT * FROM myown_db.public.emp_data where id=1;

SELECT * FROM myown_db.public.emp_data AT(timestamp => '2022-07-08 19:47:48.916'::timestamp)
WHERE id=1;


// Case3: retrieve history data by using BEFORE STATEMENT
SELECT * FROM myown_db.public.orders WHERE ORDER_ID='B-25601';

SELECT * FROM myown_db.public.orders 
before(statement => '01a57b69-0004-25d4-0015-ab8700024536')
WHERE ORDER_ID='B-25601';

CREATE TABLE myown_db.public.orders_tt
AS
SELECT * FROM myown_db.public.orders 
before(statement => '01a57b69-0004-25d4-0015-ab8700024536');

SELECT * FROM myown_db.public.orders WHERE ORDER_ID='B-25601';
SELECT * FROM myown_db.public.orders_tt WHERE ORDER_ID='B-25601';
=================

// Restoring Tables
SHOW TABLEs like 'customer%';
DROP TABLE myown_db.public.customer;
SHOW TABLEs like 'customer%';
UNDROP TABLE myown_db.public.customer;
SHOW TABLEs like 'customer%';

// Restoring Schemas
SHOW SCHEMAS in DATABASE myown_db;
DROP SCHEMA STAGE_TBLS;
SHOW SCHEMAS in DATABASE myown_db;
UNDROP SCHEMA STAGE_TBLS;
SHOW SCHEMAS in DATABASE myown_db;

====================
// Time Travel Cost

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_NAME = 'CUSTOMER_LARGE';

SELECT 	ID, 
		TABLE_NAME, 
		TABLE_SCHEMA,
        TABLE_CATALOG,
		ACTIVE_BYTES / (1024*1024*1024) AS STORAGE_USED_GB,
		TIME_TRAVEL_BYTES / (1024*1024*1024) AS TIME_TRAVEL_STORAGE_USED_GB
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_NAME = 'CUSTOMER_LARGE'
ORDER BY STORAGE_USED_GB DESC,TIME_TRAVEL_STORAGE_USED_GB DESC;

UPDATE myown_DB.public.customer_large set state='abc';

SELECT 	ID, 
		TABLE_NAME, 
		TABLE_SCHEMA,
        TABLE_CATALOG,
		ACTIVE_BYTES / (1024*1024*1024) AS STORAGE_USED_GB,
		TIME_TRAVEL_BYTES / (1024*1024*1024) AS TIME_TRAVEL_STORAGE_USED_GB
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_NAME = 'CUSTOMER_LARGE';