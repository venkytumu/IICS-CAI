// Cloning a Table
CREATE TABLE myown_db.public.customer_clone
CLONE myown_db.public.customer;

SELECT * FROM myown_db.public.customer;
SELECT * FROM myown_db.public.customer_clone;

// Cloning Schema
CREATE SCHEMA myown_db.copy_of_file_formats
CLONE myown_db.file_formats;


// Cloning Database
CREATE DATABASE myown_db_copy
CLONE myown_db;


//Update data in source and cloned objects and observer both the tables

select * from myown_db.public.customer where customerid=1684012735799;
UPDATE myown_db.public.customer SET CUSTNAME='ABCDEFGH' WHERE CUSTOMERID=1684012735799;
select * from myown_db.public.customer where customerid=1684012735799;
select * from myown_db.public.customer_clone where customerid=1684012735799;

select * from myown_db.public.customer_clone where customerid=1654101252899;
UPDATE myown_db.public.customer_clone SET CITY='XYZ' WHERE CUSTOMERID=1654101252899;
select * from myown_db.public.customer_clone where customerid=1654101252899;
select * from myown_db.public.customer where customerid=1654101252899;


//Dropping cloned objects
DROP DATABASE myown_db_copy;
DROP SCHEMA myown_db.copy_of_file_formats;
DROP TABLE myown_db.public.customer_clone;


// Clone using Time Travel

SELECT * FROM myown_db.public.customer;
DELETE FROM myown_db.public.customer;
SELECT * FROM myown_db.public.customer;

CREATE OR REPLACE TABLE myown_db.PUBLIC.customer_tt_clone
CLONE myown_db.public.customer at (OFFSET => -60*5);

SELECT * FROM myown_db.public.customer_tt_clone;