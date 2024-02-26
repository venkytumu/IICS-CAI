==================================================
Unloading data to external cloud storage locations
===================================================
// Create required Database and Schemas
CREATE DATABASE IF NOT EXISTS MYDB;
CREATE SCHEMA IF NOT EXISTS MYDB.EXT_STAGES;
CREATE SCHEMA IF NOT EXISTS MYDB.FILE_FORMATS;

----------------------------
// Add new aws s3 location to our storage int object to store output files

CREATE OR REPLACE STORAGE INTEGRATION S3_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE 
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::555064756008:role/snowflake_access_role2'
  STORAGE_ALLOWED_LOCATIONS = ('s3://awss3bucketjana/csv/', 's3://awss3bucketjana/json/','s3://awss3bucketjana/pipes/csv/', 's3://awss3bucketjana/output/')
  COMMENT = 'Integration with aws s3 buckets' ;
  
  OR 
  
ALTER STORAGE INTEGRATION S3_INT
  SET STORAGE_ALLOWED_LOCATIONS = ('s3://awss3bucketjana/csv/', 's3://awss3bucketjana/json/','s3://awss3bucketjana/pipes/csv/', 's3://awss3bucketjana/output/');
  
  
// Create file format object
CREATE OR REPLACE FILE FORMAT MYDB.FILE_FORMATS.CSV_FILEFORMAT
    type = csv
    field_delimiter = '|'
    skip_header = 1
    empty_field_as_null = TRUE;	
	
// Create stage object with integration object & file format object
// Using the Storeage Integration object that was already created

CREATE OR REPLACE STAGE MYDB.EXT_STAGES.MYS3_OUTPUT
    URL = 's3://awss3bucketjana/output/'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = MYDB.FILE_FORMATS.CSV_FILEFORMAT ;
	

// Generate files and store them in the stage location
COPY INTO @MYDB.EXT_STAGES.MYS3_OUTPUT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

//Listing files under my s3 bucket
LIST @MYDB.EXT_STAGES.MYS3_OUTPUT;

===================
Unloading Options
===================
OVERWRITE = TRUE | FALSE - Specifies to Overwrite existing files
SINGLE = TRUE | FALSE - Specifies whether to generate a single file or multiple files
MAX_FILE_SIZE = NUMBER - Maximum file size
INCLUDE_QUERY_ID = TRUE | FALSE - Specifies whether to uniquely identify unloaded files by including a universally unique identifier
DETAILED_OUTPUT = TRUE | FALSE - Shows the path and name for each file, its size, and the number of rows that were unloaded to the file.;


// We can mentione file name like 'customer', maximum files size

// Specifiy the filename in the copy command
COPY INTO @MYDB.EXT_STAGES.MYS3_OUTPUT/customer
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

// MAX_FILE_SIZE
COPY INTO @MYDB.EXT_STAGES.MYS3_OUTPUT/customer
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
MAX_FILE_SIZE=2000000;

// Use OVERWRTIE=TRUE
// If we want to overwrite existing file we can set that to TRUE
COPY INTO @MYDB.EXT_STAGES.MYS3_OUTPUT/customer
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
MAX_FILE_SIZE=2000000
OVERWRITE = TRUE;
	
//Listing files under my s3 bucket
LIST @MYDB.EXT_STAGES.MYS3_OUTPUT;

//generate single file
COPY INTO @MYDB.EXT_STAGES.MYS3_OUTPUT/CUST
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
SINGLE = TRUE;

//detailed output
COPY INTO @MYDB.EXT_STAGES.MYS3_OUTPUT/cust_data
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
DETAILED_OUTPUT = TRUE;

