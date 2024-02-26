=================
Masking Policies 
=================
USE DATABASE PUBLIC_DB;

// Create a schema for policies
CREATE SCHEMA MYPOLICIES ;

// Try to clone from sample data -- we can't clone tables from shared databases
CREATE TABLE PUBLIC.CUSTOMER
CLONE SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

// Create a sample table
CREATE TABLE PUBLIC.CUSTOMER
AS SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

SELECT * FROM PUBLIC.CUSTOMER;

// Grant access to other roles
GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE sales_users;
GRANT USAGE ON SCHEMA PUBLIC_DB.public TO ROLE sales_users;
GRANT SELECT ON TABLE PUBLIC_DB.public.CUSTOMER TO ROLE sales_users;

GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE sales_admin;
GRANT USAGE ON SCHEMA PUBLIC_DB.public TO ROLE sales_admin;
GRANT SELECT ON TABLE PUBLIC_DB.public.CUSTOMER TO ROLE sales_admin;

GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE market_users;
GRANT USAGE ON SCHEMA PUBLIC_DB.public TO ROLE market_users;
GRANT SELECT ON TABLE PUBLIC_DB.public.CUSTOMER TO ROLE market_users;

GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE market_admin;
GRANT USAGE ON SCHEMA PUBLIC_DB.public TO ROLE market_admin;
GRANT SELECT ON TABLE PUBLIC_DB.public.CUSTOMER TO ROLE market_admin;

======================

// Want to Hide Phone and Account Balance
CREATE OR REPLACE MASKING POLICY customer_phone 
    as (val string) returns string->
CASE WHEN CURRENT_ROLE() in ('SALES_ADMIN', 'MARKET_ADMIN') THEN val
    ELSE '##-###-###-'||SUBSTRING(val,12,4) 
    END;
    
    
CREATE OR REPLACE MASKING POLICY customer_accbal 
    as (val number) returns number->
CASE WHEN CURRENT_ROLE() in ('SALES_ADMIN', 'MARKET_ADMIN') THEN val
    ELSE '####' 
    END;
    
    
CREATE OR REPLACE MASKING POLICY customer_accbal2
    as (val number) returns number->
CASE WHEN CURRENT_ROLE() in ('SALES_ADMIN', 'MARKET_ADMIN') THEN val
    ELSE 0 
    END;
    

// Apply masking policies on columns of CUSTOMER table
ALTER TABLE PUBLIC.CUSTOMER MODIFY COLUMN C_PHONE
    SET MASKING POLICY customer_phone;
    
ALTER TABLE PUBLIC.CUSTOMER MODIFY COLUMN C_ACCTBAL
    SET MASKING POLICY customer_accbal;
    
// switch to sales_users and see the data
USE ROLE sales_users;

SELECT * FROM PUBLIC.CUSTOMER;

// Unset policy customer_accbal and set to customer_accbal2
ALTER TABLE PUBLIC.CUSTOMER MODIFY COLUMN C_ACCTBAL
    UNSET MASKING POLICY;

ALTER TABLE PUBLIC.CUSTOMER MODIFY COLUMN C_ACCTBAL
    SET MASKING POLICY customer_accbal2;
    
    
// switch to sales_admin and see the data
USE ROLE sales_admin;

SELECT * FROM PUBLIC.CUSTOMER;


// Altering policies
ALTER MASKING POLICY customer_phone SET body ->
CASE WHEN CURRENT_ROLE() in ('SALES_ADMIN', 'MARKET_ADMIN') THEN val
    ELSE '##########' 
    END;

// switch to sales_users and see the data
USE ROLE sales_users;

SELECT * FROM PUBLIC.CUSTOMER;

// To see masking policies
USE ROLE SYSADMIN;

SHOW MASKING POLICIES;

DESC MASKING POLICY CUSTOMER_PHONE;

// To see wherever you applied the policy
SELECT * FROM table(information_schema.policy_references(policy_name=>'CUSTOMER_PHONE'));


// Applying on views
ALTER VIEW MYVIEWS.VW_CUSTOMER MODIFY COLUMN C_PHONE
    SET MASKING POLICY customer_phone;
    
// switch to sales_users and see the data
USE ROLE sales_users;

SELECT * FROM MYVIEWS.VW_CUSTOMER;


// Dropping masking policies
DROP MASKING POLICY customer_phone;

ALTER TABLE PUBLIC.CUSTOMER MODIFY COLUMN C_ACCTBAL
    UNSET MASKING POLICY;
    
DROP MASKING POLICY customer_accbal2;
