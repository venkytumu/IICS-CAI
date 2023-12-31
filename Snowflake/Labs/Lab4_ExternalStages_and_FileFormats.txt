// Create Database and schema.

CREATE DATABASE IF NOT EXISTS MYDB;
CREATE SCHEMA IF NOT EXISTS external_stages;

// Publicly accessible staging area    
CREATE OR REPLACE STAGE MYDB.external_stages.sample_stage
    url='s3://bucketsnowflakes3';

// Description of external stage
DESC STAGE MYDB.external_stages.sample_stage;    
    
// List files in stage
LIST @external_stages.sample_stage;


// Creating ORDERS table
CREATE OR REPLACE TABLE MYDB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));
    
SELECT * FROM MYDB.PUBLIC.ORDERS;

//Load data using copy command

// Copy command with specified file(s)

COPY INTO MYDB.PUBLIC.ORDERS
    FROM @MYDB.external_stages.sample_stage
    file_format = (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails.csv');
    
SELECT * FROM MYDB.PUBLIC.ORDERS;


// Copy command with pattern for file names

COPY INTO MYDB.PUBLIC.ORDERS
    FROM @MYDB.external_stages.sample_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';
    
SELECT * FROM MYDB.PUBLIC.ORDERS;
	
============
File Formats
=============

// Creating schema to keep file formats
CREATE SCHEMA IF NOT EXISTS MYDB.file_formats;

// Creating file format object
CREATE file format MYDB.file_formats.csv_file_format;

// See properties of file format object
DESC file format MYDB.file_formats.csv_file_format;


// Creating table
CREATE OR REPLACE TABLE MYDB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

// Using file format object in Copy command       
COPY INTO MYDB.PUBLIC.ORDERS_EX
    FROM @MYDB.external_stages.sample_stage
    file_format= (FORMAT_NAME = MYDB.file_formats.csv_file_format)
    files = ('OrderDetails.csv');

    
// Altering file format object
ALTER file format MYDB.file_formats.csv_file_format
    SET SKIP_HEADER = 1;
    
DESC file format MYDB.file_formats.csv_file_format;

	
// Using file format object in Copy command       
COPY INTO MYDB.PUBLIC.ORDERS_EX
    FROM @MYDB.external_stages.sample_stage
    file_format= (FORMAT_NAME=MYDB.file_formats.csv_file_format)
    files = ('OrderDetails.csv');
    
select * from MYDB.PUBLIC.ORDERS_EX;