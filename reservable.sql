/*
 * script name : reservable.sql
 * description : accompanying script for the blog at
 *               https://www.werkenbijqualogy.com/blog/36/lock-free-reservation
 */
clear screen
set serveroutput on size unlimited format wrapped
set echo on
select sysdate
/


alter table if exists stands
modify seatssold number not reservable
/
drop table if exists stands purge
/
drop table if exists circuits purge
/
create table if not exists circuits
( circuitid  number  (  11 ) generated by default on null
                             as identity
, name       varchar2( 256 )
, location   varchar2( 256 )
, country    varchar2( 256 )
, constraint pk_circuits primary key( circuitid )
);
create table if not exists stands
( standid    number  (  11 ) generated by default on null
                             as identity
, circuitid  number  (  11 )
, name       varchar2( 256 )
, seatcount  number  (   5 )
, seatssold  number  (   5 ) reservable
, constraint pk_stands          primary key ( standid )
, constraint fk_stands_circuits foreign key ( circuitid )
                                references circuits( circuitid )
, constraint ck_seat_available  check ( seatcount >= seatssold )
)
/

/* For the 2023 season there were 22 races on the Calendar,
   but for the example we just use Zandvoort
insert into circuits
  ( name, location, country )
values ('Bahrain International Circuit', 'Sakhir', 'Bahrain')
     , ('Jeddah Corniche Circuit', 'Jeddah', 'Saudi Arabia')
     , ('Albert Park Grand Prix Circuit', 'Melbourne', 'Australia')
     , ('Baku City Circuit', 'Baku', 'Azerbaijan')
     , ('Miami International Autodrome', 'Miami', 'USA')
     , ('Circuit de Monaco', 'Monte-Carlo', 'Monaco')
     , ('Circuit de Barcelona-Catalunya', 'Montmeló', 'Spain')
     , ('Circuit Gilles Villeneuve', 'Montreal', 'Canada')
     , ('Red Bull Ring', 'Spielberg', 'Austria')
     , ('Silverstone Circuit', 'Silverstone', 'UK')
     , ('Hungaroring', 'Budapest', 'Hungary')
     , ('Circuit de Spa-Francorchamps', 'Spa', 'Belgium')
     , ('Circuit Park Zandvoort', 'Zandvoort', 'Netherlands')
     , ('Autodromo Nazionale di Monza', 'Monza', 'Italy')
     , ('Marina Bay Street Circuit', 'Marina Bay', 'Singapore')
     , ('Suzuka Circuit', 'Suzuka', 'Japan')
     , ('Losail International Circuit', 'Al Daayen', 'Qatar')
     , ('Circuit of the Americas', 'Austin', 'USA')
     , ('Autódromo Hermanos Rodríguez', 'Mexico City', 'Mexico')
     , ('Autódromo José Carlos Pace', 'São Paulo', 'Brazil')
     , ('Las Vegas Strip Street Circuit', 'Las Vegas', 'United States')
     , ('Yas Marina Circuit', 'Abu Dhabi', 'UAE')
/
*/
insert into circuits
  ( name, location, country )
values ('Circuit Park Zandvoort', 'Zandvoort', 'Netherlands')
/
/* Zandvoort has multiple stands, like Tarzan, Pit, Main, Ben Pon,
   but for the example we just use the Main stand
*/
insert into stands
  ( circuitid, name, seatcount, seatssold )
values ( 1, 'Main', 2750, 0 )
/

/*
insert into stands
  ( circuitid, name, seatcount, seatssold )
values ( ( select circuitid from circuits where location = 'Zandvoort'), 'Main', 2750, 0 )
/
*/

commit
/

-- This will result in an error.
update stands
set    seatssold = 10
where  standid   = 1
/
-- You can only increase or decrease the value of the reservable column
update stands
set    seatssold = seatssold + 10
where  standid   = 1
/
-- run this statement in a different session
set echo off
prompt update stands
prompt set    seatssold = seatssold + 42
prompt where  standid   = 1
prompt /
set echo on
pause reserve 42 seats in a different session

-- check how many seats are sold
column name      format a10
column seatcount format 999999999
column seatssold format 999999999
select name
     , seatcount
     , seatssold
from   stands
where  standid = 1
/

-- find the journalling table
-- sys_reservjrnl_ + the object_id of the table
column table_name new_value tablename
select 'sys_reservjrnl_' || to_char( object_id ) as table_name
from   user_objects
where  object_name = 'STANDS'
/
-- query the journalling table
select ora_status$
     , ora_stmt_type$
     , standid
     , seatssold_op
     , seatssold_reserved
from   &tablename
/

-- now try to reserve 2740 seats in this session
-- this fails because there a already a total of 52 seats sold
update stands
set    seatssold = seatssold + 2740
where  standid   = 1
/

commit;



