/*
 * script name : groupbyalias.sql
 * description : accompanying script for the blog at 
 *               https://https://www.werkenbijqualogy.com/blog/24/group-by-alias
 */
-- this parameters is false by default, but to make sure to get expected results
alter session set GROUP_BY_POSITION_ENABLED = false
/
-- script to group by a calculated column before Oracle Database 23c
select e.sal + nvl(e.comm, 0) total
     , count(*) thecount
from   scott.emp e
where  e.deptno = 20
group  by e.sal + nvl(e.comm, 0)
/
-- script to group by a calculated column in Oracle Database 23c and up
select e.sal + nvl(e.comm, 0) total
     , count(*) thecount
from   scott.emp e
where  e.deptno = 20
group  by total
/
-- script to group by a calculated column by position, failes
select e.sal + nvl(e.comm, 0) total
     , count(*) thecount
from   scott.emp e
where  e.deptno = 20
group  by 1
/
-- enable the session parameter
alter session set GROUP_BY_POSITION_ENABLED = true
/
-- now the script to group by a calculated column by position completes succesfully
select e.sal + nvl(e.comm, 0) total
     , count(*) thecount
from   scott.emp e
where  e.deptno = 20
group  by 1
/

