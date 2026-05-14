       Identification Division.
       Program-Id. SENDM.
       Environment Division.
       Input-Output Section.
       File-Control.
           Select Send-File
               Assign to SEFILE
               Organization Sequential
               Access Sequential
               File status Send-File-Status.
           Select Sent-File
               Assign to STFILE
               Organization Sequential
               Access Sequential
               File status Sent-File-Status.
       Data Division.
       File Section.
       FD  Send-File
           Recording mode F
           Record contains 70 characters
           Block contains 0 characters
           Data record FC-Send-Record.
       01  FC-Send-Record.
           05  SE-Email-Addr         pic x(40).
           05  SE-Surname            pic x(30).
       FD  Sent-File
           Recording mode F
           Record contains 70 characters
           Block contains 0 characters
           Data record FC-Sent-Record.
       01  FC-Sent-Record.
           05  ST-Email-Addr         pic x(40).
           05  ST-Surname            pic x(30).
       Working-Storage Section.
           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE CONTACTS END-EXEC.
       01  Send-File-Status          pic x(2).
           copy STATUS.
       01  Sent-File-Status          pic x(2).
           copy STATUS.
       01  Send-Record.
           05  WS-Email-Addr            pic x(40).
           05  WS-Surname               pic x(30).
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
           perform 0000-Get-Current-Date
           perform 1600-Open-Sent-File
           perform 1000-Read-Send
           perform 1610-Close-Sent-File
           goback
           .

       0000-Get-Current-Date.
      *****************************************************************
      * Get today's date and format it for the DB2 LAST_CONTACT column.
      *****************************************************************
           move function current-date(1:8) to WS-Current-Date
           move corr WS-Current-Date to WS-Current-Date-Formated
           .

       1000-Read-Send.
      *****************************************************************
      * Read each selected contact, send the message, and update history
      *****************************************************************
           perform 1100-Open-Send-File
           perform 1200-Read-Next
           perform until EOF of Send-File-Status
               call 'MAILSND' using WS-Email-Addr WS-Surname
               perform 1300-Update-Contacts
               perform 1200-Read-Next
           end-perform
           perform 1110-Close-Send-File
           .

       1100-Open-Send-File.
      *****************************************************************
      * Open SEFILE as input to read contacts selected for messaging.
      *****************************************************************
           open input Send-File
           if not OK of Send-File-Status
               display 'Did not open file: '
                       Send-File-Status
           end-if
           .

       1110-Close-Send-File.
      *****************************************************************
      * Close SEFILE after all selected contacts are processed.
      *****************************************************************
           close Send-File
           if not OK of Send-File-Status
               display "Error closing SEFILE " Send-File-Status
           end-if
           .

       1200-Read-Next.
      *****************************************************************
      * Read the next selected contact from SEFILE.
      *****************************************************************
           read Send-File next into Send-Record end-read
           if not EOF of Send-File-Status
               if not OK of Send-File-Status
                   display 'Did not read file: '
                           Send-File-Status
               end-if
           end-if
           .

       1300-Update-Contacts.
      *****************************************************************
      * Update CONTACTS with today's date after send attempt.
      *****************************************************************
           perform 1400-Set-Host-Variables
           EXEC SQL
                UPDATE CONTACTS
                   SET LAST_CONTACT  = :LAST-CONTACT :LAST-CONTACT-IND
                 WHERE EMAIL_ADDR = :EMAIL-ADDR
                   AND SURNAME    = :SURNAME
           END-EXEC
           if not SQLCODE = 0
               display "Error updating record: " SQLCODE
           else
               perform 1500-Write-Record
           end-if
           .

       1400-Set-Host-Variables.
      *****************************************************************
      * Build DB2 host variables from the selected contact record.
      *****************************************************************
           move WS-Current-Date-Formated to LAST-CONTACT
           move 0 to LAST-CONTACT-IND
           move function trim(WS-Email-Addr leading) to EMAIL-ADDR-TEXT
           move function trim(WS-Surname leading) to SURNAME-TEXT
           compute EMAIL-ADDR-LEN =
               function length(function trim(EMAIL-ADDR-TEXT))
           end-compute
           compute SURNAME-LEN =
               function length(function trim(SURNAME-TEXT))
           end-compute
           .

       1500-Write-Record.
      *****************************************************************
      * Write successfully processed contact to the sent history file.
      *****************************************************************
           move EMAIL-ADDR-TEXT to ST-Email-Addr
           move SURNAME-TEXT to ST-Surname
           write FC-Sent-Record
           if not OK of Sent-File-Status
               display "Error writing to SEFILE " Sent-File-Status
           end-if
           .

       1600-Open-Sent-File.
      *****************************************************************
      * Open STFILE for sent contact history.
      *****************************************************************
           open extend Sent-File
           if not OK of Sent-File-Status
               display "Error opening SEFILE " Sent-File-Status
           end-if
           .

       1610-Close-Sent-File.
      *****************************************************************
      * Open STFILE for sent contact history.
      *****************************************************************
           close Sent-File
           if not OK of Sent-File-Status
               display "Error closing SEFILE " Sent-File-Status
           end-if
           .

