=======================================
Data Sharing to Other Snowflake Users 
=======================================
// Create a Database
CREATE DATABASE CUST_DB;

// Create schemas
CREATE SCHEMA CUST_TBLS;
CREATE SCHEMA CUST_VIEWS;

// Create some tables in tbls schema
CREATE TABLE CUST_DB.CUST_TBLS.CUSTOMER
AS SELECT * FROM SAMPLE_DATA.TPCH_SF1.CUSTOMER;

CREATE TABLE CUST_DB.CUST_TBLS.ORDERS
AS SELECT * FROM SAMPLE_DATA.TPCH_SF1.ORDERS;


// Create a view in views schema
CREATE OR REPLACE VIEW CUST_VIEWS.VW_CUST
AS
SELECT CST.C_CUSTKEY, CST.C_NAME, CST.C_ADDRESS, CST.C_PHONE FROM 
SAMPLE_DATA.TPCH_SF10.CUSTOMER CST
INNER JOIN SAMPLE_DATA.TPCH_SF10.NATION NTN
ON CST.C_NATIONKEY = NTN.N_NATIONKEY
WHERE NTN.N_NAME='BRAZIL';

// Create a secure view in views schema
CREATE OR REPLACE SECURE VIEW CUST_VIEWS.SEC_VW_CUST
AS
SELECT CST.C_CUSTKEY, C_NAME,C_ADDRESS, C_PHONE 
FROM CUST_DB.CUST_TBLS.CUSTOMER CST;

// Create a  mat view in views schema
CREATE MATERIALIZED VIEW CUST_DB.CUST_VIEWS.MAT_VW_ORDERS
AS
SELECT * FROM CUST_DB.CUST_TBLS.CUSTOMER;

// Create a secure mat view in views schema
CREATE SECURE MATERIALIZED VIEW CUST_DB.CUST_VIEWS.SEC_MAT_VW_ORDERS
AS
SELECT * FROM CUST_DB.CUST_TBLS.CUSTOMER;

===============================

// Create a share object
-- we can create and manage share objects in two ways
-- 1. By using sql queries 2. By using share tabs in UI

CREATE OR REPLACE SHARE CUST_DATA_SHARE;

// Grant access to share object
GRANT USAGE ON DATABASE CUST_DB TO SHARE CUST_DATA_SHARE; 

GRANT USAGE ON SCHEMA CUST_DB.CUST_TBLS TO SHARE CUST_DATA_SHARE; 
GRANT SELECT ON TABLE CUST_DB.CUST_TBLS.CUSTOMER TO SHARE CUST_DATA_SHARE; 
GRANT SELECT ON TABLE CUST_DB.CUST_TBLS.ORDERS TO SHARE CUST_DATA_SHARE;

GRANT USAGE ON SCHEMA CUST_DB.CUST_VIEWS TO SHARE CUST_DATA_SHARE; 
GRANT SELECT ON TABLE CUST_DB.CUST_VIEWS.VW_CUST TO SHARE CUST_DATA_SHARE; 
GRANT SELECT ON TABLE CUST_DB.CUST_VIEWS.SEC_VW_CUST TO SHARE CUST_DATA_SHARE;
GRANT SELECT ON TABLE CUST_DB.CUST_VIEWS.MAT_VW_ORDERS TO SHARE CUST_DATA_SHARE;
GRANT SELECT ON TABLE CUST_DB.CUST_VIEWS.SEC_MAT_VW_ORDERS TO SHARE CUST_DATA_SHARE;


// How to see share objects
SHOW SHARES; -- or we can use shares tab

// How to see the grants of a share object
SHOW GRANTS TO SHARE CUST_DATA_SHARE;

// Add the consumer account to share the data
ALTER SHARE CUST_DATA_SHARE ADD ACCOUNT = consumer-account-id;


// How to share complete schema
GRANT SELECT ON ALL TABLES IN SCHEMA CUST_DB.CUST_TBLS TO SHARE CUST_DATA_SHARE;

// How to share complete database
GRANT SELECT ON ALL TABLES IN DATABASE CUST_DB TO SHARE CUST_DATA_SHARE;

=============================
Consumer side database setup
=============================

SHOW SHARES;

DESC SHARE share-name;

// Create a database to consume the shared data
CREATE DATABASE CUST_DB_SHARED FROM SHARE share-name;

SELECT * FROM CUST_DB_SHARED.CUST_TBLS.CUSTOMER;


====================================
Data Sharing to Non-Snowflake Users 
====================================

// Create a reader account

CREATE MANAGED ACCOUNT CUSTOMER_ANALYST
ADMIN_NAME = cust_analyst,
ADMIN_PASSWORD = 'Abcd@123',
TYPE = READER;

// How to see reader accounts
SHOW MANAGED ACCOUNTS;

// Add reader account to share object
ALTER SHARE CUST_DATA_SHARE  ADD ACCOUNT = reader-account-id;

ALTER SHARE CUST_DATA_SHARE  ADD ACCOUNT =  reader-account-id
SHARE_RESTRICTIONS=false;


=============================
Reader side database setup
=============================

SHOW SHARES;

DESC SHARE share-name;

// Get url of reader account and login to that reader account

// Get inbound share details
SHOW SHARES;

// Create a database to consume the shared data
CREATE DATABASE CUST_DB_SHARED FROM SHARE share-name;

// Query the shared tables
SELECT * FROM CUST_DB_SHARED.CUST_TBLS.CUSTOMER;

// Create a virtual warehouse
CREATE WAREHOUSE READER_WH WITH
WAREHOUSE_SIZE='X-SMALL'
AUTO_SUSPEND = 180
AUTO_RESUME = TRUE;


SELECT * FROM CUST_DB_SHARED.CUST_TBLS.CUSTOMER;

