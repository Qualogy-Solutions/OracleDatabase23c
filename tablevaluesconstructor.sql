/*
 * script name : tablevaluesconstructor.sql
 * description : accompanying script for the blog at 
 *               https://www.werkenbijqualogy.com/blog/26/table-values-constructor
 */
clear screen
set serveroutput on size unlimited format wrapped

-- first cleanup the demo tables if they exist
drop table if exists constructordrivers purge
/
drop table if exists constructors purge
/
drop table if exists drivers purge
/

-- create a table to hold the constructors
create table if not exists constructors
( 
  constructorid number         generated by default on null as identity
, name          varchar2( 16 )
, nationality   varchar2( 16 )
)
/

-- create a table to hold the drivers
create table if not exists drivers
( 
  driverid      number         generated by default on null as identity
, driver_number number  (  2 )
, code          varchar2(  3 )
, driver_name   varchar2( 32 )
, dob           date
, nationality   varchar2( 16 )
)
/

-- create a table to register which drivers is connected to which constructor
create table if not exists constructordrivers
( 
  constructordriverid number         generated by default on null as identity
, constructorid       number
, driverid            number
)
/

-- insert a couple of constructors, the slow way.
insert into constructors ( name, nationality ) values ( 'Alfa Romeo'    , 'Swiss'    );
insert into constructors ( name, nationality ) values ( 'AlphaTauri'    , 'Italian'  );
insert into constructors ( name, nationality ) values ( 'Alpine F1 Team', 'French'   );
insert into constructors ( name, nationality ) values ( 'Aston Martin'  , 'British'  );

-- insert a couple more constructors, a bit faster, because less round-trips
begin
  insert into constructors ( name, nationality ) values ( 'Ferrari'       , 'Italian'  );
  insert into constructors ( name, nationality ) values ( 'Haas F1 Team'  , 'American' );
  insert into constructors ( name, nationality ) values ( 'McLaren'       , 'British'  );
  insert into constructors ( name, nationality ) values ( 'Mercedes'      , 'German'   );
  insert into constructors ( name, nationality ) values ( 'Red Bull'      , 'Austrian' );
  insert into constructors ( name, nationality ) values ( 'Williams'      , 'British'  );
end;
/

-- insert all the drivers in the 23c way
insert into drivers
  ( driver_number, code, driver_name, dob, nationality )
values
  ( 44, 'HAM', 'Lewis Hamilton'  , to_date( '19850107', 'YYYYMMDD' ), 'British'    )
, ( 14, 'ALO', 'Fernando Alonso' , to_date( '19810729', 'YYYYMMDD' ), 'Spanish'    )
, ( 10, 'GAS', 'Pierre Gasly'    , to_date( '19960207', 'YYYYMMDD' ), 'French'     )
, ( 27, 'HUL', 'Nico H�lkenberg' , to_date( '19870819', 'YYYYMMDD' ), 'German'     )
, ( 11, 'PER', 'Sergio P�rez'    , to_date( '19900126', 'YYYYMMDD' ), 'Mexican'    )
, ( 77, 'BOT', 'Valtteri Bottas' , to_date( '19890828', 'YYYYMMDD' ), 'Finnish'    )
, ( 20, 'MAG', 'Kevin Magnussen' , to_date( '19921005', 'YYYYMMDD' ), 'Danish'     )
, ( 33, 'VER', 'Max Verstappen'  , to_date( '19970930', 'YYYYMMDD' ), 'Dutch'      )
, ( 55, 'SAI', 'Carlos Sainz'    , to_date( '19940901', 'YYYYMMDD' ), 'Spanish'    )
, ( 31, 'OCO', 'Esteban Ocon'    , to_date( '19960917', 'YYYYMMDD' ), 'French'     )
, ( 18, 'STR', 'Lance Stroll'    , to_date( '19981029', 'YYYYMMDD' ), 'Canadian'   )
, ( 16, 'LEC', 'Charles Leclerc' , to_date( '19971016', 'YYYYMMDD' ), 'Monegasque' )
, (  4, 'NOR', 'Lando Norris'    , to_date( '19991113', 'YYYYMMDD' ), 'British'    )
, ( 63, 'RUS', 'George Russell'  , to_date( '19980215', 'YYYYMMDD' ), 'British'    )
, ( 23, 'ALB', 'Alexander Albon' , to_date( '19960323', 'YYYYMMDD' ), 'Thai'       )
, ( 22, 'TSU', 'Yuki Tsunoda'    , to_date( '20000511', 'YYYYMMDD' ), 'Japanese'   )
, ( 24, 'ZHO', 'Guanyu Zhou'     , to_date( '19990530', 'YYYYMMDD' ), 'Chinese'    )
, ( 21, 'DEV', 'Nyck de Vries'   , to_date( '19950206', 'YYYYMMDD' ), 'Dutch'      )
, ( 81, 'PIA', 'Oscar Piastri'   , to_date( '20010406', 'YYYYMMDD' ), 'Australian' )
, (  2, 'SAR', 'Logan Sargeant'  , to_date( '20001231', 'YYYYMMDD' ), 'American'   )
/

-- also insert all the connections between drivers and constructors
insert into constructordrivers
  ( constructorid, driverid )
values
  ( 8,  1  )
, ( 4,  2  )
, ( 3,  3  )
, ( 6,  4  )
, ( 9,  5  )
, ( 1,  6  )
, ( 6,  7  )
, ( 9,  8  )
, ( 5,  9  )
, ( 3,  10 )
, ( 4,  11 )
, ( 5,  12 )
, ( 7,  13 )
, ( 8,  14 )
, ( 10, 15 )
, ( 2,  16 )
, ( 1,  17 )
, ( 2,  18 )
, ( 7,  19 )
, ( 10, 20 )
/

commit
/

