// Run with X-Small or Small Warehouse
// Run below queries and observe query profile

// Query is fetching results from Storage layer(Remote Disk)
SELECT * FROM  TPCH_SF1000.CUSTOMER; -- 2min 20sec

// Fetching METADATA info is very fast, look at query profile
SELECT COUNT(*) FROM  TPCH_SF1000.CUSTOMER; -- 70ms
SELECT MIN(C_CUSTKEY) FROM  TPCH_SF1000.CUSTOMER; -- 68 ms
SELECT MAX(C_CUSTKEY) FROM  TPCH_SF1000.CUSTOMER; -- 64 ms

// Run the same query again and observe time taken and query profile
SELECT * FROM  TPCH_SF1000.CUSTOMER; -- 113 ms

// Try to fetch same data by changing queries little bit and observe query profile
SELECT C_CUSTKEY, C_NAME, C_ACCTBAL, C_ADDRESS FROM TPCH_SF1000.CUSTOMER; -- 53 sec
SELECT C_CUSTKEY, C_ADDRESS FROM TPCH_SF1000.CUSTOMER; -- 36 sec
SELECT C_ADDRESS, C_CUSTKEY FROM TPCH_SF1000.CUSTOMER; -- 32 sec

// Try to fetch subset of data, with a filter
SELECT C_CUSTKEY, C_NAME, C_ACCTBAL, C_ADDRESS FROM TPCH_SF1000.CUSTOMER
    WHERE C_NATIONKEY in (1,2); -- 9.9 sec

==================================================================
// Turn off Results Cache, Suspend the VW, run same queries and see query profile
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

// First time, it will fetch the data from Remote Disk
SELECT * FROM  TPCH_SF1000.CUSTOMER; -- 2min 19sec

// Run the same query again and observe time taken and query profile
SELECT * FROM  TPCH_SF1000.CUSTOMER; -- 2 min 15sec

// Try to fetch same data by changing queries little bit and observe query profile
SELECT C_CUSTKEY, C_NAME, C_ACCTBAL, C_ADDRESS FROM TPCH_SF1000.CUSTOMER; -- 53sec
SELECT C_CUSTKEY, C_ADDRESS FROM TPCH_SF1000.CUSTOMER; -- 34sec
SELECT C_ADDRESS, C_CUSTKEY FROM TPCH_SF1000.CUSTOMER; -- 34sec

// Try to fetch subset of data, with a filter
SELECT C_CUSTKEY, C_NAME, C_ACCTBAL, C_ADDRESS FROM TPCH_SF1000.CUSTOMER
    WHERE C_CUSTKEY < 200000; -- 750 ms
    
SELECT C_CUSTKEY, C_NAME, C_ACCTBAL, C_ADDRESS FROM TPCH_SF1000.CUSTOMER
    WHERE C_NATIONKEY in (1,2,3,4,5); -- 12sec
==================================================================

// Increase VW size to L or XL, run same queries and see query profile

// First time, it will fetch the data from Remote Disk
SELECT * FROM  TPCH_SF1000.CUSTOMER; -- 13 sec

// Run the same query again and observe time taken and query profile
SELECT * FROM  TPCH_SF1000.CUSTOMER; -- 14 sec

// Try to fetch same data by changing queries little bit and observe query profile
SELECT C_CUSTKEY, C_NAME, C_ACCTBAL, C_ADDRESS FROM TPCH_SF1000.CUSTOMER; -- 4.8sec
SELECT C_CUSTKEY, C_ADDRESS FROM TPCH_SF1000.CUSTOMER; -- 7.9 sec
SELECT C_ADDRESS, C_CUSTKEY FROM TPCH_SF1000.CUSTOMER; -- 3.4 sec

// Try to fetch subset of data, with a filter
SELECT C_CUSTKEY, C_NAME, C_ACCTBAL, C_ADDRESS FROM TPCH_SF1000.CUSTOMER
    WHERE C_CUSTKEY < 200000; -- 891
    
SELECT C_CUSTKEY, C_NAME, C_ACCTBAL, C_ADDRESS FROM TPCH_SF1000.CUSTOMER
    WHERE C_NATIONKEY in (1,2,3,4,5); -- 1.6 sec
==================================================================