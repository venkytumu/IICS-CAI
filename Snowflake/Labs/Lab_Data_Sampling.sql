==============
Data Sampling
==============

Examples:
1. select * from tablename sample row(10);
Return a sample with 10% of rows

2. select * from tablename tablesample block (20);
Return a sample with data from 20% blocks

3. select * from tablename sample system (10) seed (111) ;
Return a sample with data from 10% of blocks and guarantees same data set if we use seed 111 next time.

4. select * from tablename tablesample (100);
Return an entire table, including all rows into the sample

5. select * from tablename sample row (0);
Return an empty sample

6. select * from tablename sample (10 rows);
Return a fixed-size sample of 10 rows

-------------
Lab Queries:
-------------
CREATE DATABASE IF NOT EXISTS DEV_DB;

USE DATABASE DEV_DB;
USE SCHEMA PUBLIC;

// Creating tables with sample data

// Bernoulli or Row
CREATE TABLE CUST_SAMPLE_1 AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER
    SAMPLE (10);
    
CREATE TABLE CUST_SAMPLE_2 AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER
    SAMPLE ROW (10);
    
SELECT COUNT(1) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER;
SELECT COUNT(1) FROM DEV_DB.PUBLIC.CUST_SAMPLE_1;
SELECT COUNT(1) FROM DEV_DB.PUBLIC.CUST_SAMPLE_2;    


// System or Block    
CREATE TABLE CUST_SAMPLE_3 AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER
    SAMPLE BLOCK (5);
    
CREATE TABLE CUST_SAMPLE_4 AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER
    SAMPLE SYSTEM (5) SEED (111);

SELECT COUNT(1) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER;
SELECT COUNT(1) FROM DEV_DB.PUBLIC.CUST_SAMPLE_3;
SELECT COUNT(1) FROM DEV_DB.PUBLIC.CUST_SAMPLE_4;


// Sample with fixed number of rows
CREATE TABLE CUST_SAMPLE_5 AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER
    SAMPLE ROW (1000 rows);
    
SELECT COUNT(1) FROM CUST_SAMPLE_5;
    

// Just selecting sample data
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER
    SAMPLE BERNOULLI (10);

SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER
    SAMPLE SYSTEM (5) SEED (111);
	

// Check the seed is same or not
SELECT * FROM CUST_SAMPLE_4
MINUS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER
    SAMPLE SYSTEM (5) SEED (111); -- Same
    
SELECT * FROM CUST_SAMPLE_3
MINUS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER
    SAMPLE SYSTEM (5) SEED (111); -- Not Same