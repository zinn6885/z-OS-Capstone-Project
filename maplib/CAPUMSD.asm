***********************************************************************
* Capstone - mapset for contact details
***********************************************************************
CAPUMSD  DFHMSD MODE=INOUT,                                            X
               CTRL=(FREEKB,FRSET),                                    X
               CURSLOC=YES,                                            X
               DSATTS=COLOR,                                           X
               MAPATTS=(COLOR,HILIGHT),                                X
               COLOR=TURQUOISE,                                        X
               STORAGE=AUTO,                                           X
               LANG=COBOL,                                             X
               TIOAPFX=YES,                                            X
               TYPE=&SYSPARM
CAPUMAP DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
TRANID  DFHMDF POS=(1,1),LENGTH=4,ATTRB=(ASKIP,NORM,FSET),             X
               COLOR=YELLOW
CDEET   DFHMDF POS=(1,28),LENGTH=20,ATTRB=(ASKIP,NORM),                X
               INITIAL='     Contact Details'
SCRTITL DFHMDF POS=(01,52),LENGTH=10,ATTRB=(ASKIP,NORM,FSET)


FNAMET  DFHMDF POS=(03,01),LENGTH=18,ATTRB=(ASKIP,NORM),               X
               INITIAL='      First Name: '
FNAME   DFHMDF POS=(03,20),LENGTH=30,ATTRB=(UNPROT,BRT,IC),            X
               COLOR=YELLOW,HILIGHT=UNDERLINE
        DFHMDF POS=(03,51),LENGTH=0


MNAMET  DFHMDF POS=(04,01),LENGTH=18,ATTRB=(ASKIP,NORM),               X
               INITIAL='     Middle Name: '
MNAME   DFHMDF POS=(04,20),LENGTH=30,ATTRB=(UNPROT,BRT),               X
               COLOR=YELLOW,HILIGHT=UNDERLINE
        DFHMDF POS=(04,51),LENGTH=0


SNAMET  DFHMDF POS=(05,01),LENGTH=18,ATTRB=(ASKIP,NORM),               X
               INITIAL='         Surname: '
SNAME   DFHMDF POS=(05,20),LENGTH=30,ATTRB=(UNPROT,BRT),               X
               COLOR=YELLOW,HILIGHT=UNDERLINE
        DFHMDF POS=(05,51),LENGTH=0


ANAMET  DFHMDF POS=(06,01),LENGTH=18,ATTRB=(ASKIP,NORM),               X
               INITIAL=' Additional Name: '
ANAME   DFHMDF POS=(06,20),LENGTH=30,ATTRB=(UNPROT,BRT),               X
               COLOR=YELLOW,HILIGHT=UNDERLINE
        DFHMDF POS=(06,51),LENGTH=0


LANGT   DFHMDF POS=(08,01),LENGTH=18,ATTRB=(ASKIP,NORM),               X
               INITIAL='        Language: '
LANG    DFHMDF POS=(08,20),LENGTH=2,ATTRB=(UNPROT,BRT),                X
               COLOR=YELLOW,HILIGHT=UNDERLINE
        DFHMDF POS=(08,23),LENGTH=0


EMAILT  DFHMDF POS=(10,01),LENGTH=18,ATTRB=(ASKIP,NORM),               X
               INITIAL='           Email: '
EMAIL   DFHMDF POS=(10,20),LENGTH=40,ATTRB=(UNPROT,BRT),               X
               COLOR=YELLOW,HILIGHT=UNDERLINE
        DFHMDF POS=(10,61),LENGTH=0

DNCT    DFHMDF POS=(11,01),LENGTH=18,ATTRB=(ASKIP,NORM),               X
               INITIAL='  Do Not Contact: '
DNC     DFHMDF POS=(11,20),LENGTH=1,ATTRB=(ASKIP,BRT),                 X
               COLOR=YELLOW


DFORMT  DFHMDF POS=(13,11),LENGTH=31,ATTRB=(ASKIP,NORM),               X
               INITIAL='Dates formatted in (YYYY/MM/DD)'

LCONTT  DFHMDF POS=(14,01),LENGTH=18,ATTRB=(ASKIP,NORM),               X
               INITIAL='    Last Contact: '
LCONT   DFHMDF POS=(14,29),PICOUT='9999/99/99',ATTRB=(ASKIP,BRT),      X
               COLOR=YELLOW


LRESPT  DFHMDF POS=(15,01),LENGTH=18,ATTRB=(ASKIP,NORM),               X
               INITIAL='   Last Response: '
LRESP   DFHMDF POS=(15,29),PICOUT='9999/99/99',ATTRB=(ASKIP,BRT),      X
               COLOR=YELLOW

MSG     DFHMDF POS=(23,1),LENGTH=79,ATTRB=(ASKIP,BRT),COLOR=YELLOW
INFOT   DFHMDF POS=(24,1),LENGTH=79,ATTRB=(ASKIP,NORM),                X
               INITIAL='ENTER Validate     PF5 Save     PF12 Cancel'
        DFHMSD TYPE=FINAL
        END
