//MATEGE99 JOB (123),'FEEDC',CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//PLIB    JCLLIB ORDER=(MATE1.PROCLIB)
//************************************************************
//* COMMON FILE DATA SET                                     *
//************************************************************
//DELETE   EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSDUMP  DD SYSOUT=*
//DD1      DD DSN=&SYSUID..CAP.COMMON,
//            DISP=(MOD,DELETE,DELETE),
//            SPACE=(TRK,(0)),
//            UNIT=SYSDA,
//            VOL=SER=DEVHD1,
//            DCB=(DSORG=PS,RECFM=FB,LRECL=143,BLKSIZE=14300)
//ALLOC    EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSDUMP  DD SYSOUT=*
//DD2      DD DSN=&SYSUID..CAP.COMMON,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(1,1),RLSE),
//            UNIT=SYSDA,
//            VOL=SER=DEVHD1,
//            DCB=(DSORG=PS,RECFM=FB,LRECL=143,BLKSIZE=14300)
//************************************************************
//* DEFINE GDG                                               *
//************************************************************
//DEFINE   EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE MATEGE.CAP.SORTED GDG FORCE
  IF LASTCC < 9 THEN -
  DEFINE GDG(NAME(MATEGE.CAP.SORTED) -
    LIMIT(50) -
    NOEMPTY -
    SCRATCH)
/*
//************************************************************
//* ERROR DATA SET                                           *
//************************************************************
//DELETE   EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSDUMP  DD SYSOUT=*
//DD1      DD DSN=&SYSUID..CAP.ERRORS,
//            DISP=(MOD,DELETE,DELETE),
//            SPACE=(TRK,(0)),
//            UNIT=SYSDA,
//            VOL=SER=DEVHD1,
//            DCB=(DSORG=PS,RECFM=FB,LRECL=143,BLKSIZE=14300)
//ALLOC    EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSDUMP  DD SYSOUT=*
//DD2      DD DSN=&SYSUID..CAP.ERRORS,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(1,1),RLSE),
//            UNIT=SYSDA,
//            VOL=SER=DEVHD1,
//            DCB=(DSORG=PS,RECFM=FB,LRECL=143,BLKSIZE=14300)
//************************************************************
//* COMPILE AND RUN COBOL CODE                               *
//************************************************************
//CL      EXEC COBOLCL,
//             COPYLIB=&SYSUID..CAP.COPY,
//             LOADLIB=&SYSUID..CAP.LOAD,
//             SRCLIB=&SYSUID..CAP.SOURCE,
//             MEMBER=FEEDNRM
//RUNCODE EXEC PGM=FEEDNRM
//F1FILE  DD DSN=&SYSUID..CAP.FEED1,DISP=SHR
//F2FILE  DD DSN=&SYSUID..CAP.FEED2,DISP=SHR
//F3FILE  DD DSN=&SYSUID..CAP.FEED3,DISP=SHR
//CFILE   DD DSN=&SYSUID..CAP.COMMON,DISP=SHR
//EFILE   DD DSN=&SYSUID..CAP.ERRORS,DISP=SHR
//STEPLIB DD DSN=&SYSUID..CAP.LOAD,DISP=SHR
//************************************************************
//* ALLOCATE PS DATA SET USING IEFBR14 UTILITY               *
//************************************************************
//ALLOC    EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSDUMP  DD SYSOUT=*
//DD1      DD DSN=&SYSUID..CAP.SORTED(+1),
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(1,1),RLSE),UNIT=SYSDA,
//            VOL=SER=DEVHD1,
//            DCB=(DSORG=PS,RECFM=FB,LRECL=143,BLKSIZE=14300)
//************************************************************
//* SORT common  file                                        *
//************************************************************        
//SORT     EXEC PGM=SORT
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=&SYSUID..CAP.COMMON,
//            DISP=SHR
//SORTOUT  DD DSN=&SYSUID..CAP.SORTED(+1),
//SYMNAMES DD *
NAME,1,100,CH
LANGCODE,101,2,CH
EMAIL,103,40,CH
DNC,143,1,CH
/*
//SYSIN    DD *
  SORT FIELDS=(EMAIL,A,NAME,A)
/*
//*END FEEDC
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
//SFILE   DD DSN=&SYSUID..CAP.SORTED(+1),DISP=SHR
//EFILE   DD DSN=&SYSUID..CAP.ERRORS,DISP=SHR
//CLFILE  DD DSN=&SYSUID..CAP.CLEAN(+1),DISP=SHR
//STEPLIB DD DSN=&SYSUID..CAP.LOAD,DISP=SHR
//************************************************************
//* COMPArE Two files for diff                               *
//************************************************************                                             
//STEP1    EXEC PGM=ISRSUPC,PARM=(DELTAL,LINECMP) 
//NEWDD    DD DSN=MATEGE.CAP.CLEAN(+1),DISP=SHR 
//OLDDD    DD DSN=MATEGE.CAP.EXPECTED,DISP=SHR
//OUTDD    DD SYSOUT=*                            
//SYSIN    DD DUMMY                               
/*                                                