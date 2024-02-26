// Create required Database/Schemas
CREATE DATABASE IF NOT EXISTS MYDB;
CREATE SCHEMA IF NOT EXISTS  MYDB.EXT_STAGES

1.VALIDATION_MODE
------------------
// Create table
CREATE OR REPLACE TABLE  MYDB.PUBLIC.TBL_ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

// Case 1: Files without errors
// Create Stage Object
CREATE OR REPLACE STAGE MYDB.EXT_STAGES.sample_aws_stage
    url='s3://snowflakebucket-copyoption/size/';
	
LIST @MYDB.EXT_STAGES.sample_aws_stage;  
    
 //Load data using copy command
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;    
    
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
   VALIDATION_MODE = RETURN_10_ROWS ;
   
// Case 2: Files with errors
// Create Stage Object
CREATE OR REPLACE STAGE MYDB.EXT_STAGES.sample_aws_stage2
    url='s3://snowflakebucket-copyoption/returnfailed/';
	
LIST @MYDB.EXT_STAGES.sample_aws_stage2;  
    
 //Load data using copy command
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage2
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;    
    
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage2
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
   VALIDATION_MODE = RETURN_10_ROWS ;
   
   
2.RETURN_FAILED_ONLY
---------------------

//Create a table
CREATE OR REPLACE TABLE  MYDB.PUBLIC.TBL_ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

// Create Stage Object
CREATE OR REPLACE STAGE MYDB.EXT_STAGES.sample_aws_stage
    url='s3://snowflakebucket-copyoption/returnfailed/';
  
LIST @MYDB.EXT_STAGES.sample_aws_stage  
    
//Load data using copy command
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    RETURN_FAILED_ONLY = TRUE;    


3.ON_ERROR
-----------
CREATE OR REPLACE TABLE  MYDB.PUBLIC.TBL_ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));
	
// Create Stage Object
CREATE OR REPLACE STAGE MYDB.EXT_STAGES.sample_aws_stage
    url='s3://snowflakebucket-copyoption/returnfailed/';
  
LIST @MYDB.EXT_STAGES.sample_aws_stage

// First try without ON_ERROR property
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';
	
// Now try with ON_ERROR=CONTINUE
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    ON_ERROR = CONTINUE;
	
4.FORCE
--------
CREATE OR REPLACE TABLE  MYDB.PUBLIC.TBL_ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

// Create Stage Object
CREATE OR REPLACE STAGE MYDB.EXT_STAGES.sample_aws_stage
    url='s3://snowflakebucket-copyoption/size/';
  
LIST @MYDB.EXT_STAGES.sample_aws_stage;  
    
 //Load data using copy command
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';

// Try to load same file, Copy command will skip the file
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';
   
SELECT * FROM TBL_ORDERS;    

// Try Using the FORCE option, copy command will not fail but just skips the file
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    FORCE = TRUE;
    
SELECT * FROM PUBLIC.TBL_ORDERS;


5.TRUNCATE COLUMNS
-------------------
CREATE OR REPLACE TABLE  MYDB.PUBLIC.TBL_ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(10),
    SUBCATEGORY VARCHAR(30));

// Create Stage Object
CREATE OR REPLACE STAGE MYDB.EXT_STAGES.sample_aws_stage
    url='s3://snowflakebucket-copyoption/size/';
  
LIST @MYDB.EXT_STAGES.sample_aws_stage;  
    
 //Load data using copy command
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';

//With TRUNCATECOLUMNS property
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    TRUNCATECOLUMNS = TRUE; 
    
SELECT * FROM PUBLIC.TBL_ORDERS;    


6.SIZE_LIMIT
-------------
CREATE OR REPLACE TABLE  MYDB.PUBLIC.TBL_ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));    
    
// Create Stage Object
CREATE OR REPLACE STAGE MYDB.EXT_STAGES.sample_aws_stage
    url='s3://snowflakebucket-copyoption/size/';    
    
// List files in stage
LIST @sample_aws_stage;

//Load data using copy command
COPY INTO MYDB.PUBLIC.TBL_ORDERS
    FROM @sample_aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    SIZE_LIMIT=30000;