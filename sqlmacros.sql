/*
 * script name : sqlmacros.sql
 * description : accompanying script for the blog at
 *               https://www.werkenbijqualogy.com/blog/31/sql-macros
 * depends on  : tablevaluesconstructor.sql
 */
clear screen
set serveroutput on size unlimited format wrapped
-- For this script to work correctly, run the tablevaluesconstructor.sql script first
-- to setup the tables.
-- The tablevaluesconstructor.sql can be found at
-- https://github.com/Qualogy-Solutions/OracleDatabase23c/blob/main/tablevaluesconstructor.sql
@tablevaluesconstructor.sql
-- create a table macro to retrieve the drivers with their constructor
create or replace function driverconstructor
return varchar2 sql_macro( table )
is
begin
  return q'[
select drv.driverid       as driverid
     , drv.driver_number  as drivernumber
     , drv.code           as drivercode
     , drv.driver_name    as drivername
     , drv.dob            as driverdob
     , drv.nationality    as drivernationality
     , con.constructorid  as constructorid
     , con.name           as constructorname
     , con.nationality    as constructornationality
from   drivers            drv
join   constructordrivers condrv on ( drv.driverid         = condrv.driverid   )
join   constructors       con    on ( condrv.constructorid = con.constructorid )
  ]';
end;
/
-- select the data using the SQLMacro
select *
from   driverconstructor()
/
-- create a table macro to retrieve the drivers with their constructor for a specific nationality
create or replace function driverconstructor( nationality_in in varchar2 )
return varchar2 sql_macro( table )
is
begin
  return q'[
select drv.driverid       as driverid
     , drv.driver_number  as drivernumber
     , drv.code           as drivercode
     , drv.driver_name    as drivername
     , drv.dob            as driverdob
     , drv.nationality    as drivernationality
     , con.constructorid  as constructorid
     , con.name           as constructorname
     , con.nationality    as constructornationality
from   drivers            drv
join   constructordrivers condrv on ( drv.driverid         = condrv.driverid   )
join   constructors       con    on ( condrv.constructorid = con.constructorid )
where  (    drv.nationality like driverconstructor.nationality_in
         or con.nationality like driverconstructor.nationality_in
       )
  ]';
end;
/
-- do some formatting
column drivername             format a20
column drivernationality      format a10
column constructorname        format a20
column constructornationality format a10

-- retrieve the Dutch drivers and/or constructors
select drivername
     , drivernationality
     , constructorname
     , constructornationality
from   driverconstructor( nationality_in => 'Dutch' )
/

-- retrieve the German drivers and/or constructors
select drivername
     , drivernationality
     , constructorname
     , constructornationality
from   driverconstructor( nationality_in => 'German' )
/

column driverid          format 99999
column drivernumber      format 99999
column drivercode        format a3
column drivername        format a20
column driverdob         format a10
column drivernationality format a10

-- create a macro where we concatenate the input parameter
create or replace function driverinfo( nationality_in in varchar2 )
return varchar2 sql_macro( table )
is
begin
  return q'[
select drv.driverid       as driverid
     , drv.driver_number  as drivernumber
     , drv.code           as drivercode
     , drv.driver_name    as drivername
     , drv.dob            as driverdob
     , drv.nationality    as drivernationality
from   drivers            drv
where  drv.nationality like ']' || driverinfo.nationality_in || q'['
  ]';
end;
/
-- this will result in no rows
select *
from   driverinfo( 'Dutch' )
/
-- create a macro using the parameter in the correct way
create or replace function driverinfo( nationality_in in varchar2 )
return varchar2 sql_macro( table )
is
begin
  return q'[
select drv.driverid       as driverid
     , drv.driver_number  as drivernumber
     , drv.code           as drivercode
     , drv.driver_name    as drivername
     , drv.dob            as driverdob
     , drv.nationality    as drivernationality
from   drivers            drv
where  drv.nationality like driverinfo.nationality_in
  ]';
end;
/
select *
from   driverinfo( 'Dutch' )
/
column value     format a15
column formatted format a15
/
-- create a 'normal' PL/SQL function to format a number
create or replace function formatnumber( productionnumber_in in varchar2 )
return varchar2
is
begin
  return
  regexp_replace( formatnumber.productionnumber_in, '(.{3})','\1.' )
  ;
end;
/
-- select the original and formatted value
with t as ( select 'V000000003' value )
select value
     , formatnumber( value ) formatted
from   t
/
-- create a scalar macro to format a number
create or replace function formatnumber( productionnumber_in in varchar2 )
return varchar2 sql_macro( scalar )
is
begin
  return q'[
  regexp_replace( formatnumber.productionnumber_in, '(.{3})','\1.' )
  ]';
end;
/
-- select the original and formatted value
with t as ( select 'V000000003' value )
select value
     , formatnumber( value ) formatted
from   t
/
-- create a scalar macro to mimic other databases
create or replace function now
return varchar2 sql_macro( scalar ) is
begin
return 'sysdate';
end;
/

select now, sysdate
/
-- to view the sql that is actually executed
declare
  l_input  clob;
  l_output clob;
begin
  l_input := q'[ select sysdate ]';
  dbms_utility.expand_sql_text( input_sql_text  => l_input
                              , output_sql_text => l_output
                              );
  dbms_output.put_line( l_output );
end;
/
--declare
--  l_input  clob;
--  l_output clob;
--begin
--  l_input := q'[
--select *
--from   driverinfo( 'Dutch' )
--]';
--  dbms_utility.expand_sql_text( input_sql_text  => l_input
--                              , output_sql_text => l_output
--                              );
--  dbms_output.put_line( l_output );
--end;
--/


