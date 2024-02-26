// Alter storage integration to add xml files location
alter storage integration s3_int
set STORAGE_ALLOWED_LOCATIONS = ('s3://awss3bucketjana/xml/', 's3://awss3bucketjana/csv', 's3://awss3bucketjana/json/');

DESC integration s3_int;

// Create required datbase and schemas
create database if not exists mydb
create schema if not exists mydb.file_formats;
create schema if not exists mydb.external_stages;
create schema if not exists mydb.stage_tbls;
create schema if not exists mydb.intg_tbls;

// Create file format object for xml files
CREATE OR REPLACE file format mydb.file_formats.xml_fileformat
    type = xml;

// Create stage on external s3 location
CREATE OR REPLACE STAGE mydb.external_stages.aws_s3_xml
    URL = 's3://awss3bucketjana/xml/'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = mydb.file_formats.xml_fileformat ;

// Listing files under your s3 xml bucket
list @mydb.external_stages.aws_s3_xml;

// View data from xml file
select * from @mydb.external_stages.aws_s3_xml/books_20230304.xml;

// Create variant table to load xml file
CREATE OR REPLACE TABLE mydb.stage_tbls.STG_BOOKS(xml_data variant);

// Load xml file to variant table
copy into mydb.stage_tbls.STG_BOOKS
from @mydb.external_stages.aws_s3_xml
files=('books_20230304.xml')
force=TRUE;

// Query stage table
select * from mydb.stage_tbls.STG_BOOKS;

// Create Target table to load final data 
CREATE OR REPLACE TABLE intg_tbls.BOOKS
( 
	book_id varchar(20) not null,
	author varchar(50),
	title varchar(50),
	genre varchar(20),
	price number(10,2),
	publish_date date,
	description varchar(255),
	PRIMARY KEY(book_id)
);


// To get the root element name
select xml_data:"@" from mydb.stage_tbls.STG_BOOKS;

// To get root element value
select xml_data:"$" from mydb.stage_tbls.STG_BOOKS;

// Get the content using xmlget function, index position
select xmlget(xml_data,'book',0):"$" from mydb.stage_tbls.STG_BOOKS;
select xmlget(xml_data,'book',1):"$" from mydb.stage_tbls.STG_BOOKS;

// Fetch actual data from file
SELECT 
XMLGET(bk.value, 'id' ):"$" as "book_id",
XMLGET(bk.value, 'author' ):"$" as "author"
FROM mydb.stage_tbls.STG_BOOKS,
LATERAL FLATTEN(to_array(STG_BOOKS.xml_data:"$" )) bk;

// Fetch data and assign datatypes
SELECT 
XMLGET(bk.value, 'id' ):"$" :: varchar as "book_id",
XMLGET(bk.value, 'author' ):"$" :: varchar as "author",
XMLGET(bk.value, 'title' ):"$" :: varchar as "title",
XMLGET(bk.value, 'genre' ):"$" :: varchar as "genre",
XMLGET(bk.value, 'price' ):"$" :: number(10,2) as "price",
XMLGET(bk.value, 'publish_date' ):"$" :: date as "publish_date",
XMLGET(bk.value, 'description' ):"$" :: varchar as "description"

FROM mydb.stage_tbls.STG_BOOKS,
LATERAL FLATTEN(to_array(STG_BOOKS.xml_data:"$" )) bk;


// Insert data from stage table to final target table
INSERT INTO intg_tbls.BOOKS
SELECT 
XMLGET(bk.value, 'id' ):"$" :: varchar as "book_id",
XMLGET(bk.value, 'author' ):"$" :: varchar as "author",
XMLGET(bk.value, 'title' ):"$" :: varchar as "title",
XMLGET(bk.value, 'genre' ):"$" :: varchar as "genre",
XMLGET(bk.value, 'price' ):"$" :: number(10,2) as "price",
XMLGET(bk.value, 'publish_date' ):"$" :: date as "publish_date",
XMLGET(bk.value, 'description' ):"$" :: varchar as "description"
FROM mydb.stage_tbls.STG_BOOKS,
LATERAL FLATTEN(to_array(STG_BOOKS.xml_data:"$" )) bk;


// View final data
SELECT * FROM intg_tbls.BOOKS;