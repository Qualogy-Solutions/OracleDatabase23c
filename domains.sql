/*
 * script name : domains.sql
 * description : accompanying script for the blog at
 *               https://www.werkenbijqualogy.com/blog/34/sql-domains
 */
clear screen
set serveroutput on size unlimited format wrapped

-- drop the tables and domains that will be recreated, so the script runs without errors
-- drop the tables
drop table if exists domaintest purge
/
drop table if exists nonstrictdomaintest purge
/
drop table if exists strictdomaintest purge
/

-- drop the domains
drop domain if exists zipcode_d
/
drop domain if exists vc10_d
/
drop domain if exists vc10_sd
/

-- create a domain to check a (dutch) zipcode
create      domain zipcode_d as varchar2( 7 char )
constraint  zipcode_c check ( regexp_like ( zipcode_d, '^[1-9][[:alnum:]]{3}[ ]{0,1}[[:alpha:]]{2}$' ) )
deferrable  initially deferred
display     upper( replace( zipcode_d, ' ', '' ) )
order       lower( replace( zipcode_d, ' ', '' ) )
annotations ( Description 'Domain for Dutch zip codes' )
/
-- create a table that uses the newly created domain
create table if not exists domaintest
( zipcode domain zipcode_d )
/
--insert a row into the table
insert into domaintest (zipcode) values ('2288 EC')
/
commit
/
--insert a row into the table
insert into domaintest (zipcode) values ('1098 xh')
/
commit
/
--insert a row into the table, this one will fail
insert into domaintest (zipcode) values ('0288 EC')
/
commit
/
-- select the rows from the table, using the domain_display operation
select zipcode
     , domain_display( zipcode )
from   domaintest
/
-- modify the display clause of the domain
alter   domain zipcode_d
modify
display     case sys_context( 'userenv', 'session_user' )
              when 'PATRICK' then replace( zipcode_d, ' ', '' )
              else                upper( replace( zipcode_d, ' ', '' ) )
            end
/
-- select the rows from the table, using the domain_display operation
-- this will only display different output, when connected as 'PATRICK'
select zipcode
     , domain_display( zipcode )
from   domaintest
/

-- create a non-strict domain
Create domain vc10_d as varchar2( 10 )
/
-- use the domain in a table, where the length is not the same as the domain
create table if not exists nonstrictdomaintest
( text varchar2( 128 ) domain vc10_d
)
/
-- create a strict domain
Create domain vc10_sd as varchar2( 10 ) strict
/
-- use the domain in a table, where the length is not the same as the domain
create table if not exists strictdomaintest
( text varchar2( 128 ) domain vc10_sd
)
/
-- use the domain in a table, where the length is the same as the domain
create table if not exists strictdomaintest
( text varchar2( 10 ) domain vc10_sd
)
/
-- Multicolumn domain
-- drop the tables and domains that will be recreated, so the script runs without errors
-- drop the tables
drop table if exists amounts purge
/
-- drop the domains
drop domain if exists currency_d
/
-- create a multicolumn domain
create domain currency_d as
( amount            as number
, iso_currency_code as char( 3 char )
)
display iso_currency_code || to_char( amount, '999,999,990.00' )
order   to_char( amount, '999,999,990.00' ) || iso_currency_code
/
-- create a table that uses the newly created multicolumn domain
create table if not exists amounts
( amount   number
, currency char( 3 char )
, domain currency_d( amount, currency )
)
/
-- insert a couple of rows into the table, using a Table Values Constructor
insert into amounts( amount, currency )
values ( 100, 'EUR' )
     , ( 200, 'USD' )
     , ( 50,  'GBP' )
/
commit
/
-- select the data from the table using the domain_display and domain_order operations
select amount
     , currency
     , domain_display( amount, currency ) as display
from   amounts
order  by domain_order( amount, currency )
/

-- flexible usage domain
-- first drop everything that will be recreated, to make sure the script runs without errors
-- drop the tables
drop table if exists domaintest purge
/
-- drop the domains
drop domain if exists zipcode_d
/
drop domain if exists zipcode_nl_d
/
drop domain if exists zipcode_us_d
/
drop domain if exists zipcode_es_d
/
drop domain if exists zipcode_d
/
-- create the individual 'simple' domains
create domain zipcode_nl_d as varchar2( 7 char )
constraint  zipcode_nl_c check ( regexp_like ( zipcode_nl_d, '^[1-9][[:alnum:]]{3}[ ]{0,1}[[:alpha:]]{2}$' ) )
deferrable  initially deferred
display     upper( replace( zipcode_nl_d, ' ', '' ) )
order       lower( replace( zipcode_nl_d, ' ', '' ) )
annotations ( Description 'Domain for Dutch zip codes' )
/
-- for the following domains we don't need a display or order clause
create domain zipcode_us_d as varchar2( 7 char )
constraint  zipcode_us_c check ( regexp_like ( zipcode_us_d, '^[[:alnum:]]{5}$' ) )
deferrable  initially deferred
annotations ( Description 'Domain for US zip codes' )
/
create domain zipcode_es_d as varchar2( 7 char )
constraint  zipcode_es_c check ( regexp_like ( zipcode_es_d, '^[0-5][[:alnum:]]{4}$' ) )
deferrable  initially deferred
annotations ( Description 'Domain for Spanish zip codes' )
/
-- create the flexible domain for the zipcodes that uses the previously created 'simple' domains
create flexible domain zipcode_d (
  zipcode
)
choose domain using ( country char( 2 ) )
from ( case country
         when 'NL' then zipcode_nl_d ( zipcode )
         when 'US' then zipcode_us_d ( zipcode )
         when 'ES' then zipcode_es_d ( zipcode )
       end
     )
/
-- create a table using the flexible domain
create table if not exists domaintest
( zipcode     varchar2( 7 )
, countrycode char    ( 2 )
, domain zipcode_d ( zipcode )
    using ( countrycode )
)
/
--insert a correct row into the table
insert into domaintest ( zipcode, countrycode ) values ( '2288 EC', 'NL' )
/
commit
/
--insert a correct row into the table
insert into domaintest ( zipcode, countrycode ) values ( '1098 xh', 'NL' )
/
commit
/
--insert an incorrect row into the table
insert into domaintest ( zipcode, countrycode ) values ( '80203', 'ES' )
/
commit
/
--insert a correct row into the table
insert into domaintest ( zipcode, countrycode ) values ( '80203', 'US' )
/
commit
/
--insert a correct row into the table
insert into domaintest ( zipcode, countrycode ) values ( '17246', 'ES' )
/
commit
/
--insert a row that will not be checked
insert into domaintest ( zipcode, countrycode ) values ( '17246AB', 'FR' )
/
commit
/




