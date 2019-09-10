create database ALGO
user sys identified by manager
user system identified by manager
logfile group 1 ('q:/oradata/algo/redo01.log') size 512m,
 group 2 ('q:/oradata/algo/redo02.log') size 512m,
 group 3 ('q:/oradata/algo/redo03.log') size 512m,
 group 4 ('q:/oradata/algo/redo04.log') size 512m,
 group 5 ('q:/oradata/algo/redo05.log') size 512m,
 group 6 ('q:/oradata/algo/redo06.log') size 512m
character set WE8ISO8859P1
--extent management dictionary
datafile 'D:/oradata/algo/system01.dbf' size 512m autoextend on next 128m
sysaux datafile 'D:/oradata/algo/sysaux01.dbf' size 1024m autoextend on next 128m
default temporary tablespace TEMPTS1 tempfile 'D:/oradata/algo/temp01.dbf' size 1024m
undo tablespace UNDOTBS1 datafile 'm:/oradata/algo/undo01.dbf' size 512m autoextend on next 512m
;

#### LATEST ####
#CREATE DATABASE ALGO
#   USER SYS IDENTIFIED BY manager
#   USER SYSTEM IDENTIFIED BY manager
#   LOGFILE GROUP 1 ('c:/oracle/oradata/ALGO/redo01.log') SIZE 250M,
#           GROUP 2 ('c:/oracle/oradata/ALGO/redo02.log') SIZE 250M,
#           GROUP 3 ('c:/oracle/oradata/ALGO/redo03.log') SIZE 250M,
#           GROUP 4 ('c:/oracle/oradata/ALGO/redo04.log') SIZE 250M
#   MAXLOGFILES 32
#   MAXLOGMEMBERS 2
#   MAXLOGHISTORY 1
#   MAXDATAFILES 100
#   CHARACTER SET WE8ISO8859P1
#   EXTENT MANAGEMENT LOCAL
#   DATAFILE 'c:/oracle/oradata/ALGO/system01.dbf' SIZE 1024M
#   SYSAUX DATAFILE 'c:/oracle/oradata/ALGO/sysaux01.dbf' SIZE 512M
#   DEFAULT TABLESPACE users DATAFILE 'c:/oracle/oradata/ALGO/users01.dbf' SIZE 100M AUTOEXTEND OFF
#   DEFAULT TEMPORARY TABLESPACE tempts1 TEMPFILE 'c:/oracle/oradata/ALGO/temp01.dbf' SIZE 500M 
#   UNDO TABLESPACE undotbs1 DATAFILE 'm:/oradata/ALGO/undotbs01.dbf' SIZE 500M AUTOEXTEND OFF;
	  

@%ORACLE_HOME%\rdbms\admin\catalog.sql
@%ORACLE_HOME%\rdbms\admin\catproc.sql