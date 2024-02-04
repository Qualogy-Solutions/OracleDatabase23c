/*
 * script name : immutabletables.sql
 * description : accompanying script for the blog at
 *               https://www.werkenbijqualogy.com/blog/29/immutable-tables
 */
clear screen
set serveroutput on size unlimited format wrapped
-- create an immutable table.
-- Be aware that when you set the no drop until x days idle clause to anything other than 0
-- you cannot drop the table until it hasn't been used for x days.
create immutable table if not exists circuits
( circuitid  number          generated by default on null as identity
, name       varchar2( 128 )
, location   varchar2( 128 )
, country    varchar2( 128 )
, constraint pk_circuit      primary key ( circuitid )
)
no drop until 0 days idle
no delete until 16 days after insert
/
-- insert all the circuits using the table values constructor
insert into circuits
  ( name, location, country )
values
  ( 'Bahrain International Circuit'  , 'Sakhir'      , 'Bahrain'       )
, ( 'Jeddah Corniche Circuit'        , 'Jeddah'      , 'Saudi Arabia'  )
, ( 'Albert Park Grand Prix Circuit' , 'Melbourne'   , 'Australia'     )
, ( 'Baku City Circuit'              , 'Baku'        , 'Azerbaijan'    )
, ( 'Miami International Autodrome'  , 'Miami'       , 'USA'           )
, ( 'Circuit de Monaco'              , 'Monte-Carlo' , 'Monaco'        )
, ( 'Circuit de Barcelona-Catalunya' , 'Montmel�'    , 'Spain'         )
, ( 'Circuit Gilles Villeneuve'      , 'Montreal'    , 'Canada'        )
, ( 'Red Bull Ring'                  , 'Spielberg'   , 'Austria'       )
, ( 'Silverstone Circuit'            , 'Silverstone' , 'UK'            )
, ( 'Hungaroring'                    , 'Budapest'    , 'Hungary'       )
, ( 'Circuit de Spa-Francorchamps'   , 'Spa'         , 'Belgium'       )
, ( 'Circuit Park Zandvoort'         , 'Zandvoort'   , 'Netherlands'   )
, ( 'Autodromo Nazionale di Monza'   , 'Monza'       , 'Italy'         )
, ( 'Marina Bay Street Circuit'      , 'Marina Bay'  , 'Singapore'     )
, ( 'Suzuka Circuit'                 , 'Suzuka'      , 'Japan'         )
, ( 'Losail International Circuit'   , 'Al Daayen'   , 'Qatar'         )
, ( 'Circuit of the Americas'        , 'Austin'      , 'USA'           )
, ( 'Aut�dromo Hermanos Rodr�guez'   , 'Mexico City' , 'Mexico'        )
, ( 'Aut�dromo Jos� Carlos Pace'     , 'S�o Paulo'   , 'Brazil'        )
, ( 'Las Vegas Strip Street Circuit' , 'Las Vegas'   , 'United States' )
, ( 'Yas Marina Circuit'             , 'Abu Dhabi'   , 'UAE'           )
/
set linesize 120
column circuitid format 999
column name format a35
column location format a25
column country format a15

-- select a row from the table
select name
     , location
     , country
from   circuits cir
/
-- you cannot update a row in the table
update circuits cir
set    cir.name = 'Circuit park Zandvoort'
where  cir.circuitid = 13
/
-- you cannot delete a row from the table
delete
from   circuits cir
where  cir.circuitid = 13
/

-- drop the table (because the drop clause was set to 0 days)
drop table if exists circuits
/

