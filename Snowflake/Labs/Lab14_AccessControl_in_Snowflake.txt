==============
Account Admin
==============
--- User 1 - Account Admins ---
CREATE USER Donald PASSWORD = 'abc123' /* Abcd@123*/
DEFAULT_ROLE = ACCOUNTADMIN 
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE ACCOUNTADMIN TO USER Donald;


--- User 2 - Security Admin ---
CREATE USER Charles PASSWORD = 'abc123' 
DEFAULT_ROLE = SECURITYADMIN 
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE SECURITYADMIN TO USER Charles;


--- User 3 - Sysadmin ---
CREATE USER Janet PASSWORD = 'abc123' 
DEFAULT_ROLE = SYSADMIN 
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE SYSADMIN TO USER Janet;

================
Security Admin
================
// Login as user Charles who is Security Admin and update password

// 1.Create Sales Roles & Users for SALES

CREATE ROLE sales_admin;
CREATE ROLE sales_users;

-- Create hierarchy
GRANT ROLE sales_users to ROLE sales_admin;
GRANT ROLE sales_admin to ROLE SYSADMIN;

-- create sales user
CREATE USER Amar_sales PASSWORD = 'abc123' DEFAULT_ROLE =  sales_users 
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE sales_users TO USER Amar_sales;

-- create user for sales administration
CREATE USER Akbar_sales_admin PASSWORD = 'abc123' DEFAULT_ROLE =  sales_admin
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE sales_admin TO USER  Akbar_sales_admin;



// 2.Create Roles & Users for HR

CREATE ROLE hr_admin;
CREATE ROLE hr_users;

-- Create hierarchy
GRANT ROLE hr_users to ROLE hr_admin;

-- This time we will not assign roles to SYSADMIN
-- grant role hr_admin to role SYSADMIN;


-- create hr user
CREATE USER Bobby_hr PASSWORD = 'abc123' DEFAULT_ROLE =  hr_users 
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE hr_users TO USER Bobby_hr;

-- create user for sales administration
CREATE USER Balu_hr_admin PASSWORD = 'abc123' DEFAULT_ROLE =  hr_admin
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE hr_admin TO USER Balu_hr_admin;


=============
System Admin
=============
// Login as user Janet who is Security Admin and update password

-- Create a warehouse of size SMALL
CREATE WAREHOUSE public_wh 
WITH
WAREHOUSE_SIZE='SMALL'
AUTO_SUSPEND=300 
AUTO_RESUME= TRUE;

-- grant usage on warehouse to role public
GRANT USAGE ON WAREHOUSE public_wh 
TO ROLE PUBLIC

-- create database accessible to everyone
CREATE DATABASE public_db;
GRANT USAGE ON DATABASE public_db TO ROLE PUBLIC


// create sales database
CREATE DATABASE sales_db;

-- grant ownership to sales_admin that we had created using SECURITY ADMIN
GRANT OWNERSHIP ON DATABASE sales_db TO ROLE sales_admin;

-- now the owner of this database is sales_admin which is assigned to SYSADMIN
GRANT OWNERSHIP ON SCHEMA sales_db.public TO ROLE sales_admin;


// create hr database
CREATE DATABASE hr_db;

-- grant ownership to hr_admin that we had created using SECURITY ADMIN
GRANT OWNERSHIP ON DATABASE hr_db TO ROLE hr_admin;

-- now the owner of this database is hr_admin which is not assigned to SYSADMIN
GRANT OWNERSHIP ON SCHEMA hr_db.public TO ROLE hr_admin;

-- try to drop hr_db - but we can't drop
DROP DATABASE hr_db;


=============
Custom Roles
=============

// Operate with the custom roles we had created
USE ROLE sales_admin;
USE sales_db;

-- Create a table --
create or replace table customers(
  id number,
  full_name varchar, 
  email varchar,
  phone varchar,
  create_date DATE DEFAULT CURRENT_DATE);

-- insert data in table --
insert into customers (id, full_name, email,phone)
values
  (1,'abc','abc@gmail.com','262-665-9168'),
  (2,'def','def@gmail.com','734-987-7120'),
  (3,'ghi','ghi@gmail.com','867-946-3659'),
  (4,'jkl','jkl@gmail.com','563-853-8192'),
  (5,'mno','mno@gmail.com','730-451-8637'),
  (6,'pqr','pqr@gmail.com','568-896-6138');
  
SHOW TABLES;


-- switch to sales_users role
USE ROLE sales_users;

SELECT* FROM CUSTOMERS;

-- switch back to admin role and grant access
USE ROLE sales_admin;

GRANT USAGE ON DATABASE sales_db TO ROLE sales_users;
GRANT USAGE ON SCHEMA sales_db.public TO ROLE sales_users;
GRANT SELECT ON TABLE sales_db.public.CUSTOMERS TO ROLE sales_users;


-- switch to sales_users role
USE ROLE sales_users;

SELECT* FROM CUSTOMERS;

-- try DML operations using sales_users role

DELETE FROM CUSTOMERS;
DROP TABLE CUSTOMERS;


-- switch back to admin role and grant delete/drop access
USE ROLE sales_admin;
GRANT ALL ON TABLE sales_db.public.CUSTOMERS TO ROLE sales_users;

-- switch to sales_users role
USE ROLE sales_users;
DELETE FROM CUSTOMERS;

-- you can't drop this object with All privileges, only owner can drop objects
DROP TABLE CUSTOMERS;

-- switch back to admin role and grant ownsership
USE ROLE sales_admin;
GRANT OWNERSHIP ON TABLE sales_db.public.CUSTOMERS TO ROLE sales_users;

-- Above query won't work, first we have to revoke other privileges then only we can grant ownership
REVOKE ALL ON TABLE sales_db.public.CUSTOMERS FROM ROLE SALES_USERS;

GRANT OWNERSHIP ON TABLE sales_db.public.CUSTOMERS TO ROLE SALES_USERS;

-- switch to sales_users role
USE ROLE sales_users;
DROP TABLE CUSTOMERS;


============
User Admin
============
// login with sECURITYADMIN and switch to USERADMIN
-- create roles
CREATE ROLE market_admin;
CREATE ROLE market_users;

-- Create hierarchy
GRANT ROLE market_users to ROLE market_admin;
GRANT ROLE market_admin to ROLE SYSADMIN;

-- create users and grant roles
CREATE USER bharath PASSWORD = 'abc123' DEFAULT_ROLE =  market_users 
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE market_users TO USER bharath;


CREATE USER chandra PASSWORD = 'abc123' DEFAULT_ROLE =  market_admin
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE market_admin TO USER chandra;