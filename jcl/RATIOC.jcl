//MATEGD99 JOB (123),'RATIOC',CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//PLIB    JCLLIB ORDER=(MATE1.PROCLIB)
//************************************************************
//* DEFINE GDG                                               *
//************************************************************
//DEFINE   EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE MATEGD.CAP.CLEAN GDG FORCE
  IF LASTCC < 9 THEN -
  DEFINE GDG(NAME(MATEGD.CAP.CLEAN) -
    LIMIT(50) -
    NOEMPTY -
    SCRATCH)
/*
//************************************************************
//* ALLOCATE PS DATA SET USING IEFBR14 UTILITY               *
//************************************************************
//ALLOC    EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSDUMP  DD SYSOUT=*
//DD1      DD DSN=&SYSUID..CAP.CLEAN(+1),
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(1,1),RLSE),UNIT=SYSDA,
//            VOL=SER=DEVHD1,
//            DCB=(DSORG=PS,RECFM=FB,LRECL=143,BLKSIZE=14300)
//************************************************************
//* COMPILE AND RUN COBOL CODE                               *
//************************************************************
//CL      EXEC COBOLCL,
//             COPYLIB=&SYSUID..CAP.COPY,
//             LOADLIB=&SYSUID..CAP.LOAD,
//             SRCLIB=&SYSUID..CAP.SOURCE,
//             MEMBER=RATIO
//RUNCODE EXEC PGM=RATIO
//SFILE   DD DSN=&SYSUID..CAP.SORTED(0),DISP=SHR
//EFILE   DD DSN=&SYSUID..CAP.ERRORS,DISP=SHR
//CLFILE  DD DSN=&SYSUID..CAP.CLEAN(+1),DISP=SHR
//STEPLIB DD DSN=&SYSUID..CAP.LOAD,DISP=SHR
