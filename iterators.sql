/*
 * script name : iterators.sql
 * description : accompanying script for the blog at
 *               https://www.werkenbijqualogy.com/blog/29/new-pl-sql-iterator-constructs
 */
clear screen
set serveroutput on size unlimited format wrapped
-- the old way of writing a stepped iteration
begin
  for i in 1 .. 10 loop
    if mod( i, 2 ) = 0 then
      dbms_output.put_line( to_char( i ) );
    end if;
  end loop;
end;
/
-- the new (21c and up) way of writing a stepped iteration
begin
  for i in 2 .. 10 by 2 loop
    dbms_output.put_line( to_char( i ) );
  end loop;
end;
/
-- a stepped iteration but will only use the integer values
begin
  for i in 2 .. 5 by .5 loop
    dbms_output.put_line( to_char( i ) );
  end loop;
end;
/
-- a stepped iteration with a floating point iterator
begin
  for i number( 2, 1 ) in 2 .. 5 by .5 loop
    dbms_output.put_line( to_char( i ) );
  end loop;
end;
/
-- try to change the value of the iterator in the iteration
begin
  for i number( 3, 2 ) in 2 .. 5 by .5 loop
    dbms_output.put_line( to_char( i ) );
    if i = 3
      then i := 3.25;
    end if;
  end loop;
end;
/
-- change the value of the, now mutable, iterator in the iteration
begin
  for i mutable number( 3, 2 ) in 2 .. 5 by .5 loop
    dbms_output.put_line( to_char( i ) );
    if i = 3
      then i := 3.25;
    end if;
  end loop;
end;
/
-- the following scripts use the drivers table in the f1data schema.
-- Check the introduction of Modern Oracle Database Programming on how to create this schema

-- display the contents of a dense collection
declare
  type driver_tt is table of f1data.drivers%rowtype
                 index by pls_integer;
  drivers driver_tt;
begin
  select d.*
  bulk   collect
  into   drivers
  from   f1data.drivers d
  where  d.nationality = 'Dutch'
  order  by d.forename;

  for driver in drivers.first .. drivers.last loop
    dbms_output.put_line(  drivers( driver ).forename
                        || ' '
                        || drivers( driver ).surname
                        );
  end loop;
end;
/
-- trying to display the contents of a sparse collection in the same way, will fail
declare
  type driver_tt is table of f1data.drivers%rowtype
                 index by pls_integer;
  drivers driver_tt;
begin
  select d.*
  bulk   collect
  into   drivers
  from   f1data.drivers d
  where  d.nationality = 'Dutch'
  order  by d.forename;

  drivers.delete( 13 ); -- Remove Max Verstappen
  for driver in drivers.first .. drivers.last loop
    dbms_output.put_line(  drivers( driver ).forename
                        || ' '
                        || drivers( driver ).surname
                        );
  end loop;
end;
/
-- display the contents of a sparse collection using the indices of operator
declare
  type driver_tt is table of f1data.drivers%rowtype
                 index by pls_integer;
  drivers driver_tt;
begin
  select d.*
  bulk   collect
  into   drivers
  from   f1data.drivers d
  where  d.nationality = 'Dutch'
  order  by d.forename;

  drivers.delete( 13 ); -- Remove Max Verstappen
  for driver in indices of drivers loop
    dbms_output.put_line(  drivers( driver ).forename
                        || ' '
                        || drivers( driver ).surname
                        );
  end loop;
end;
/
-- display the contents of a sparse collection using the values of operator
declare
  type driver_tt is table of f1data.drivers%rowtype
                 index by pls_integer;
  drivers driver_tt;
begin
  select d.*
  bulk   collect
  into   drivers
  from   f1data.drivers d
  where  d.nationality = 'Dutch'
  order  by d.forename;

  drivers.delete( 13 ); -- Remove Max Verstappen
  for driver in values of drivers loop
    dbms_output.put_line(  driver.forename
                        || ' '
                        || driver.surname
                        );
  end loop;
end;
/

