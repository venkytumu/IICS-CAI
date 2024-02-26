=============================================
--Processing semi-structured data - Parquet
=============================================

-- How to view parquet file data
https://www.youtube.com/watch?v=EfoWUzco8H0

-- Sample parquet file
https://docs.actian.com/vector/6.2/index.html#page/User/PARQUET_Files.htm

===============================
--Creating required schemas
CREATE SCHEMA IF NOT EXISTS MYOWN_DB.EXTERNAL_STAGES;
CREATE SCHEMA IF NOT EXISTS MYOWN_DB.FILE_FORMATS;

-- Add new aws s3 location to our storage int object
CREATE OR REPLACE STORAGE INTEGRATION S3_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE 
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::555064756008:role/snowflake_access_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://awss3bucketjana/csv/', 's3://awss3bucketjana/json/','s3://awss3bucketjana/pipes/csv/', 's3://awss3bucketjana/parquet/')
  COMMENT = 'Access to my s3 buckets' ;
  

--Creating file format object
CREATE OR REPLACE FILE FORMAT MYOWN_DB.FILE_FORMATS.FILE_FORMAT_PARQUET
    TYPE = 'parquet';

--Creating stage object
CREATE OR REPLACE STAGE MYOWN_DB.EXTERNAL_STAGES.STAGE_PARQUET
    url = 's3://snowflakeparquetdemo'
    FILE_FORMAT = MYOWN_DB.FILE_FORMATS.FILE_FORMAT_PARQUET;
	

-- Listing the files
LIST  @MYOWN_DB.EXTERNAL_STAGES.STAGE_PARQUET;   

-- To see the data from the file 
SELECT * FROM @MYOWN_DB.EXTERNAL_STAGES.STAGE_PARQUET;


-- Querying unstructured data before loading
-- by using above select query you can get the column names
SELECT 
$1:"__index_level_0__",
$1:"cat_id",
$1:"d",
$1:"date",
$1:"dept_id",
$1:"id",
$1:"item_id",
$1:"state_id",
$1:"store_id",
$1:"value"
FROM @MYOWN_DB.EXTERNAL_STAGES.STAGE_PARQUET;


-- Querying data with data type conversions and aliases
-- we can add some metadata fields as well

SELECT 
$1:__index_level_0__::int as index_level,
$1:cat_id::VARCHAR(50) as category,
DATE($1:date::int ) as Date,
$1:"dept_id"::VARCHAR(50) as Dept_ID,
$1:"id"::VARCHAR(50) as ID,
$1:"item_id"::VARCHAR(50) as Item_ID,
$1:"state_id"::VARCHAR(50) as State_ID,
$1:"store_id"::VARCHAR(50) as Store_ID,
$1:"value"::int as value,
METADATA$FILENAME as FILENAME,
METADATA$FILE_ROW_NUMBER as ROWNUMBER
FROM @MYOWN_DB.EXTERNAL_STAGES.STAGE_PARQUET;


-- Create target table

CREATE OR REPLACE TABLE MYOWN_DB.PUBLIC.PARQUET_DATA 
(
    ROW_NUMBER int,
    index_level int,
    cat_id VARCHAR(50),
    date date,
    dept_id VARCHAR(50),
    id VARCHAR(50),
    item_id VARCHAR(50),
    state_id VARCHAR(50),
    store_id VARCHAR(50),
    value int,
    Load_date timestamp default TO_TIMESTAMP_NTZ(current_timestamp)
);


-- Load the data to target table
   
COPY INTO MYOWN_DB.PUBLIC.PARQUET_DATA
FROM (SELECT 
            METADATA$FILE_ROW_NUMBER,
            $1:__index_level_0__::int,
            $1:cat_id::VARCHAR(50),
            DATE($1:date::int ),
            $1:"dept_id"::VARCHAR(50),
            $1:"id"::VARCHAR(50),
            $1:"item_id"::VARCHAR(50),
            $1:"state_id"::VARCHAR(50),
            $1:"store_id"::VARCHAR(50),
            $1:"value"::int,
            TO_TIMESTAMP_NTZ(current_timestamp)
         FROM @MYOWN_DB.EXTERNAL_STAGES.STAGE_PARQUET
     );
        
    
-- View final data
SELECT * FROM MYOWN_DB.PUBLIC.PARQUET_DATA;