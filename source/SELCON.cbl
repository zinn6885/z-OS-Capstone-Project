       Identification Division.
       Program-Id. SELCON.
       Environment Division.
       Input-Output Section.
       File-Control.
           Select Send-File
               Assign to SEFILE
               Organization Sequential
               Access Sequential
               File status Send-File-Status.
       Data Division.
       File Section.
       FD  Send-File
           Recording mode F
           Record contains 70 characters
           Block contains 0 characters
           Data record FC-Send-Record.
       01  FC-Send-Record.
           05  FC-Email-Addr         pic x(40).
           05  FC-Surname            pic x(30).
       Working-Storage Section.
           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE CONTACTS END-EXEC.
       01  Send-File-Status          pic x(2).
           copy STATUS.

       Procedure Division.
           perform 1000-Select-Contacts
           goback
           .

       1000-Select-Contacts.
      *****************************************************************
      * Cursor selects contacts that may be contacted again.
      * Excludes rows marked DO_NOT_CONTACT = 'X'.
      * Includes rows never contacted or contacted over one month ago.
      *****************************************************************
           move 'X' to DO-NOT-CONTACT
           EXEC SQL
               DECLARE SELECT_CURSOR CURSOR FOR
                   SELECT EMAIL_ADDR,
                          SURNAME
                   FROM CONTACTS
                   WHERE (DO_NOT_CONTACT IS NULL
                          OR DO_NOT_CONTACT <> :DO-NOT-CONTACT)
                     AND (LAST_CONTACT IS NULL
                          OR LAST_CONTACT < CURRENT DATE - 1 MONTH)
           END-EXEC

           EXEC SQL OPEN SELECT_CURSOR END-EXEC
           if not SQLCODE = 0
               display "Error opening cursor: " SQLCODE
                       EMAIL-ADDR SURNAME
           end-if

           perform 1310-Open
           perform 1200-Fetch-Record until SQLCODE = 100

           EXEC SQL CLOSE SELECT_CURSOR END-EXEC
           if not SQLCODE = 0
               display "Error closing cursor: " SQLCODE
                       EMAIL-ADDR SURNAME
           end-if
           perform 1320-Close
           .

       1200-Fetch-Record.
      *****************************************************************
      * Fetch one selected contact from DB2.
      * If a row is found, write it to the sequential output file.
      *****************************************************************
           initialize DCLCONTACTS
           EXEC SQL
               FETCH SELECT_CURSOR
               INTO :EMAIL-ADDR,
                    :SURNAME
           END-EXEC
           if not SQLCODE = 0
               display "Error fetching record: " SQLCODE
                       EMAIL-ADDR SURNAME
           else
               perform 1300-Write-Record
           end-if
           .

       1300-Write-Record.
      *****************************************************************
      * Move selected DB2 contact fields into the output record
      * and write the record to SEFILE.
      *****************************************************************
           move EMAIL-ADDR-TEXT to FC-Email-Addr
           move SURNAME-TEXT to FC-Surname
           write FC-Send-Record
           if not OK
               display "Error writing to SEFILE " Send-File-Status
           end-if
           .

       1310-Open.
      *****************************************************************
      * Open SEFILE for appending selected contact records.
      *****************************************************************
           open extend Send-File
           if not OK
               display "Error opening SEFILE " Send-File-Status
           end-if
           .

       1320-Close.
      *****************************************************************
      * Close SEFILE after all selected contacts are written.
      *****************************************************************
           close Send-File
           if not OK
               display "Error closing SEFILE " Send-File-Status
           end-if
           .

