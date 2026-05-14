       Identification Division.
       Program-Id. UPDATE.
       Environment Division.
       Input-Output Section.
       File-Control.
           Select Clean-File
               Assign to CLFILE
               Organization Sequential
               Access Sequential
               File status Clean-File-Status.
           Select Error-File
               Assign to EFILE
               Organization Sequential
               Access Sequential
               File status Error-File-Status.
       Data Division.
       File Section.
       FD  Clean-File
           Recording mode F
           Record contains 143 characters
           Block contains 0 characters
           Data record FC-Clean-Record.
       01  FC-Clean-Record            pic x(143).
       FD  Error-File
           Recording mode F
           Record contains 143 characters
           Block contains 0 characters
           Data record FC-Error-Record.
       01  FC-Error-Record            pic x(143).
       Working-Storage Section.
           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE CONTACTS END-EXEC.
       01  Clean-File-Status          pic x(2).
           copy STATUS.
       01  Error-File-Status          pic x(2).
           copy STATUS.
       01  Clean-Record.
           copy COMMON.
       01  Tally-Field                pic 9(2).
       01  Host-Variables.
           05  HV-EMAIL-ADDR.
               49  HV-EMAIL-ADDR-LEN  pic s9(4) usage comp-5.
               49  HV-EMAIL-ADDR-TEXT pic x(40).
           05  HV-SURNAME.
               49  HV-SURNAME-LEN     pic s9(4) usage comp-5.
               49  HV-SURNAME-TEXT    pic x(30).
           05  HV-DO-NOT-CONTACT      pic x(1).
           05  HV-DO-NOT-CONTACT-IND  pic s9(4) usage comp.
       01  WS-Date.
           05  WS-Current-Date.
               10  WS-Curr-Year           pic x(4).
               10  WS-Curr-Month          pic x(2).
               10  WS-Curr-Day            pic x(2).
           05  WS-Current-Date-Formated.
               10  WS-Curr-Year           pic x(4).
               10  filler                 piC x value '-'.
               10  WS-Curr-Month          pic x(2).
               10  filler                 piC x value '-'.
               10  WS-Curr-Day            pic x(2).

       Procedure Division.
           perform 1000-Read-Clean
           goback
           .

       1000-Read-Clean.
      ******************************************************************
      * Open clean input file and process each contact record.
      ******************************************************************
           perform 1100-Open
           perform 2130-Get-Current-Date
           perform 1200-Read-Next
           perform until EOF of Clean-File-Status
               perform 1200-Read-Next
           end-perform
           perform 1300-Close-Clean
           .

       1100-Open.
      ******************************************************************
      * Open cleaned contact input file.
      ******************************************************************
           open input Clean-File
           if not OK of Clean-File-Status
               display 'Did not open file: '
                       Clean-File-Status
           end-if
           .

       1200-Read-Next.
      ******************************************************************
      * Read next clean record and update CONTACTS if read succeeds.
      ******************************************************************
           read Clean-File next into Clean-Record end-read
           if not EOF of Clean-File-Status
               if not OK of Clean-File-Status
                   display 'Did not read file: '
                           Clean-File-Status
               else
                   perform 2000-Contacts-Update
           end-if
           .

       2000-Contacts-Update.
           perform 2100-Create-Record
           perform 2200-Update-Table
           .

       1300-Close-Clean.
      ******************************************************************
      * Close cleaned contact input file.
      ******************************************************************
           close Clean-File
           if not OK of Clean-File-Status
               display 'Did not open file: '
                       Clean-File-Status
           end-if
           .

       2100-Create-Record.
      ******************************************************************
      * Build CONTACTS host variables from the clean input record.
      ******************************************************************
           perform 2110-Initialize-Record
           move C-Language-Code to LANG
           perform 2120-Create-Name
           move C-Email-Address to EMAIL-ADDR-TEXT
           compute EMAIL-ADDR-LEN =
               function length(function trim(EMAIL-ADDR-TEXT))
           end-compute
           move WS-Current-Date-Formated to LAST-CONTACT
           move WS-Current-Date-Formated to LAST-RESPONSE
           move 0 to LAST-RESPONSE-IND
           move C-DNC to DO-NOT-CONTACT
           if not C-DNC = space
               move zero to DO-NOT-CONTACT-IND
           end-if
           .

       2110-Initialize-record.
      ******************************************************************
      * Clear CONTACTS fields and set nullable columns to NULL.
      ******************************************************************
           initialize DCLCONTACTS
           move -1 to MIDDLE-NAME-IND
           move -1 to ADDL-NAME-IND
           move -1 to LAST-CONTACT-IND
           move -1 to LAST-RESPONSE-IND
           move -1 to DO-NOT-CONTACT-IND
           move function upper-case(C-Name) To C-Name
           move function upper-case(C-Email-Address) to C-Email-Address
           .

       2120-Create-Name.
      ******************************************************************
      * Split full name into first, middle, surname, and addl names.
      ******************************************************************
           move zero to Tally-Field
           inspect function trim(C-Name)
               tallying Tally-Field for all space
           evaluate true
               when Tally-Field = 1
                   unstring C-Name
                       delimited by space
                       into FIRST-NAME-TEXT SURNAME-TEXT
                   end-unstring
                   compute FIRST-NAME-LEN =
                       function length(function trim(FIRST-NAME-TEXT))
                   end-compute
                   compute SURNAME-LEN =
                       function length(function trim(SURNAME-TEXT))
                   end-compute
               when Tally-Field = 2
                   unstring C-Name
                       delimited by space
                       into FIRST-NAME-TEXT MIDDLE-NAME-TEXT
                            SURNAME-TEXT
                   end-unstring
                   compute FIRST-NAME-LEN =
                       function length(function trim(FIRST-NAME-TEXT))
                   end-compute
                   compute MIDDLE-NAME-LEN =
                       function length(function trim(MIDDLE-NAME-TEXT))
                   end-compute
                   compute SURNAME-LEN =
                       function length(function trim(SURNAME-TEXT))
                   end-compute
                   move zero to MIDDLE-NAME-IND
               when Tally-Field = 3
                   unstring C-Name
                       delimited by space
                       into FIRST-NAME-TEXT MIDDLE-NAME-TEXT
                            SURNAME-TEXT ADDL-NAME-TEXT
                   end-unstring
                   compute FIRST-NAME-LEN =
                       function length(function trim(FIRST-NAME-TEXT))
                   end-compute
                   compute MIDDLE-NAME-LEN =
                       function length(function trim(MIDDLE-NAME-TEXT))
                   end-compute
                   compute SURNAME-LEN =
                       function length(function trim(SURNAME-TEXT))
                   end-compute
                   compute ADDL-NAME-LEN =
                       function length(function trim(ADDL-NAME-TEXT))
                   end-compute
                   move zero to MIDDLE-NAME-IND
                   move zero to ADDL-NAME-IND
               when other
                   display 'Error reading C name: '
           end-evaluate
           .

       2130-Get-Current-Date.
      ******************************************************************
      * Format current date as YYYY-MM-DD for DB2 DATE columns.
      ******************************************************************
           move function current-date(1:8) to WS-Current-Date
           move corr WS-Current-Date to WS-Current-Date-Formated
           .

       2200-Update-Table.
      ******************************************************************
      * Check if contact exists, then insert or update as needed.
      ******************************************************************
           move spaces to Host-Variables
           EXEC SQL
           SELECT EMAIL_ADDR, SURNAME, DO_NOT_CONTACT
           INTO
             :HV-EMAIL-ADDR, :HV-SURNAME,
             :HV-DO-NOT-CONTACT :HV-DO-NOT-CONTACT-IND
           FROM CONTACTS
           WHERE EMAIL_ADDR = :EMAIL-ADDR
             AND SURNAME = :SURNAME
           END-EXEC

           if HV-EMAIL-ADDR = spaces
               perform 2210-Insert-Record
           else
               perform 2220-Update-Record
           end-if
           .

       2210-Insert-Record.
      ******************************************************************
      * Insert new contact into CONTACTS.
      ******************************************************************
           if DO-NOT-CONTACT = 'R'
               move 'P' to DO-NOT-CONTACT
           end-if
           EXEC SQL
           INSERT INTO CONTACTS (
             LANG, SURNAME, FIRST_NAME, MIDDLE_NAME, ADDL_NAME,
             EMAIL_ADDR, LAST_CONTACT, LAST_RESPONSE, DO_NOT_CONTACT)
           VALUES (
             :LANG, :SURNAME, :FIRST-NAME,
             :MIDDLE-NAME :MIDDLE-NAME-IND,
             :ADDL-NAME :ADDL-NAME-IND,
             :EMAIL-ADDR, :LAST-CONTACT :LAST-CONTACT-IND,
             :LAST-RESPONSE :LAST-RESPONSE-IND,
             :DO-NOT-CONTACT :DO-NOT-CONTACT-IND)
           END-EXEC
           if not SQLCODE = 0
               display "Error inserting SQLCODE: " SQLCODE
                       EMAIL-ADDR SURNAME
           else
               display "Inserted record: " DCLCONTACTS
           end-if
           .

       2220-Update-Record.
      ******************************************************************
      * Update existing contact including DNC status.
      ******************************************************************
           if DO-NOT-CONTACT = 'R'
               if HV-DO-NOT-CONTACT = ' '
                   move 'P' to DO-NOT-CONTACT
               else
                   move 'X' to DO-NOT-CONTACT
               end-if
           else
               move HV-DO-NOT-CONTACT to DO-NOT-CONTACT
           end-if
           EXEC SQL
           UPDATE CONTACTS
              SET LANG          = :LANG,
                  SURNAME       = :SURNAME,
                  FIRST_NAME    = :FIRST-NAME,
                  MIDDLE_NAME   = :MIDDLE-NAME :MIDDLE-NAME-IND,
                  ADDL_NAME     = :ADDL-NAME :ADDL-NAME-IND,
                  EMAIL_ADDR    = :EMAIL-ADDR,
                  LAST_CONTACT  = :LAST-CONTACT :LAST-CONTACT-IND,
                  LAST_RESPONSE = :LAST-RESPONSE :LAST-RESPONSE-IND,
                  DO_NOT_CONTACT = :DO-NOT-CONTACT :DO-NOT-CONTACT-IND
            WHERE EMAIL_ADDR = :EMAIL-ADDR
              AND SURNAME    = :SURNAME
           END-EXEC
           if not SQLCODE = 0
               display "Error updating SQLCODE: " SQLCODE
                       EMAIL-ADDR SURNAME
           else
               display "Update record: " DCLCONTACTS
           end-if
           .

