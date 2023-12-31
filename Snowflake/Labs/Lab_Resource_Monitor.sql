===========================
Resource Monitor Examples
===========================

Example1: To create a monitor that starts monitoring immediately, resets at the beginning of each month, and suspends the assigned warehouse when the used credits reach 100% of the credit quota:

use role accountadmin;

create or replace resource monitor MONITOR1 with credit_quota=500
  triggers on 100 percent do suspend;

alter warehouse SAMPLE_WH set resource_monitor = MONITOR1;
----------------------------------------------------

Example2: To create a monitor that is similar to the above example, but suspends at 90% and suspends immediately at 100% to prevent all warehouses in the account from consuming credits after the quota has been reached:

create or replace resource monitor MONITOR2 with credit_quota=1000
  triggers on 90 percent do suspend
           on 100 percent do suspend_immediate;

alter warehouse WH_FINANCE set resource_monitor = MONITOR2;
----------------------------------------------------

Example3: To create a monitor that is similar to the above example, but lets the assigned warehouse exceed the quota by 10% and also includes two notification actions to alert account administrators as the used credits reach the halfway and 3/4 for the quota:

create or replace resource monitor MONITOR3 with credit_quota=1000
   triggers on 50 percent do notify
            on 75 percent do notify
            on 100 percent do suspend
            on 110 percent do suspend_immediate;

alter warehouse WH_IT set resource_monitor = MONITOR3;
-----------------------------------------------------------

Example4: To create a monitor that starts immediately (based on the current timestamp), resets monthly on the same day, has no end date or time, and suspends the assigned warehouse when the used credits reach 100% of the quota:

create or replace resource monitor MONITOR4 with credit_quota=1000
    frequency = monthly
    start_timestamp = immediately
    triggers on 100 percent do suspend;

alter warehouse WH_SALES set resource_monitor = MONITOR4;
-----------------------------------------------------------

Example5: To create a resource monitor that starts at a specific date and time in the future, resets weekly on the same day, has no end date or time, and performs two different suspend actions at different thresholds on two assigned warehouses:

create or replace resource monitor MONITOR5 with credit_quota=2000
    frequency = weekly
    start_timestamp = '2023-01-25 00:00 PST'
    triggers on 80 percent do suspend
             on 100 percent do suspend_immediate;

alter warehouse WH_MARKETING set resource_monitor = MONITOR5;

alter warehouse WH_HR set resource_monitor = MONITOR5;
--------------------------------------------------------

Example6: Increase credit limit for a resource monitor

alter resource monitor MONITOR5 set credit_quota=3000;
--------------------------------------------------------

Example7: Creating account level resource monitor

create resource monitor MONITOR_ACC with credit_quota=10000
  triggers on 90 percent do notify
   on 100 percent do suspend;

alter account set resource_monitor = MONITOR_ACC;
===================================================

To see Resource Monitors:
show resource monitors;

To Drop Resource Monitors:
Drop resource monitor MONITOR1;