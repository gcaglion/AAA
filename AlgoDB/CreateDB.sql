create database ALGO
user sys identified by manager
user system identified by manager
logfile group 1 ('D:/oradata/algo/redo01.log') size 512m,
 group 2 ('D:/oradata/algo/redo02.log') size 512m,
 group 3 ('D:/oradata/algo/redo03.log') size 512m,
 group 4 ('D:/oradata/algo/redo04.log') size 512m,
 group 5 ('D:/oradata/algo/redo05.log') size 512m,
 group 6 ('D:/oradata/algo/redo06.log') size 512m
character set WE8ISO8859P1
--extent management dictionary
datafile 'D:/oradata/algo/system01.dbf' size 512m autoextend on next 128m
sysaux datafile 'D:/oradata/algo/sysaux01.dbf' size 512m autoextend on next 128m
default temporary tablespace TEMPTS1 tempfile 'D:/oradata/algo/temp01.dbf' size 256m
undo tablespace UNDOTBS1 datafile 'D:/oradata/algo/undo01.dbf' size 512m autoextend on next 512m
;

@%ORACLE_HOME%\rdbms\admin\catalog.sql
@%ORACLE_HOME%\rdbms\admin\catproc.sql