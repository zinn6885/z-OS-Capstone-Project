      ******************************************************************
      * DCLGEN TABLE(CONTACTS)                                         *
      *        LIBRARY(MATEGD.DCLGEN.COBOL(CONTACTS))                  *
      *        ACTION(REPLACE)                                         *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE CONTACTS TABLE
           ( C_ID                           INTEGER NOT NULL,
             LANG                           CHAR(2) NOT NULL,
             SURNAME                        VARCHAR(30) NOT NULL,
             FIRST_NAME                     VARCHAR(30) NOT NULL,
             MIDDLE_NAME                    VARCHAR(30),
             ADDL_NAME                      VARCHAR(30),
             EMAIL_ADDR                     VARCHAR(40) NOT NULL,
             LAST_CONTACT                   DATE,
             LAST_RESPONSE                  DATE,
             DO_NOT_CONTACT                 CHAR(1)
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE CONTACTS                           *
      ******************************************************************
       01  DCLCONTACTS.
           10 C-ID                 PIC S9(9) USAGE COMP-5.
           10 LANG                 PIC X(2).
           10 SURNAME.
              49 SURNAME-LEN       PIC S9(4) USAGE COMP-5.
              49 SURNAME-TEXT      PIC X(30).
           10 FIRST-NAME.
              49 FIRST-NAME-LEN    PIC S9(4) USAGE COMP-5.
              49 FIRST-NAME-TEXT   PIC X(30).
           10 MIDDLE-NAME.
              49 MIDDLE-NAME-LEN   PIC S9(4) USAGE COMP-5.
              49 MIDDLE-NAME-TEXT  PIC X(30).
           10 MIDDLE-NAME-IND      PIC S9(4) USAGE COMP.
           10 ADDL-NAME.
              49 ADDL-NAME-LEN     PIC S9(4) USAGE COMP-5.
              49 ADDL-NAME-TEXT    PIC X(30).
           10 ADDL-NAME-IND        PIC S9(4) USAGE COMP.
           10 EMAIL-ADDR.
              49 EMAIL-ADDR-LEN    PIC S9(4) USAGE COMP-5.
              49 EMAIL-ADDR-TEXT   PIC X(40).
           10 LAST-CONTACT         PIC X(10).
           10 LAST-CONTACT-IND     PIC S9(4) USAGE COMP.
           10 LAST-RESPONSE        PIC X(10).
           10 LAST-RESPONSE-IND    PIC S9(4) USAGE COMP.
           10 DO-NOT-CONTACT       PIC X(1).
           10 DO-NOT-CONTACT-IND   PIC S9(4) USAGE COMP.
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 10      *
      ******************************************************************
