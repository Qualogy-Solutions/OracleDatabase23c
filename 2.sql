column table_name new_value tablename
select 'sys_reservjrnl_' || to_char( object_id ) as table_name
from   user_objects
where  object_name = 'STANDS'
/

select ora_status$
     , ora_stmt_type$
     , standid
     , seatssold_op
     , seatssold_reserved
from   &tablename
/

