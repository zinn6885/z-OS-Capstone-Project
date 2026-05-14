       Identification Division.
       Program-Id. FEEDNRM.
       Environment Division.
       Input-Output Section.
       File-Control.
           Select Feed1-File
               Assign to F1FILE
               Organization Sequential
               Access Sequential
               File status Feed1-File-Status.
           Select Feed2-File
               Assign to F2FILE
               Organization Sequential
               Access Sequential
               File status Feed2-File-Status.
           Select Feed3-File
               Assign to F3FILE
               Organization Sequential
               Access Sequential
               File status Feed3-File-Status.
           Select Common-File
               Assign to CFILE
               Organization Sequential
               Access Sequential
               File status Common-File-Status.
           Select Error-File
               Assign to EFILE
               Organization Sequential
               Access Sequential
               File status Error-File-Status.
       Data Division.
       File Section.
       FD  Feed1-File
           Recording mode F
           Record contains 133 characters
           Block contains 0 characters
           Data record FC-Feed1-Record.
       01  FC-Feed1-Record             pic x(133).
       FD  Feed2-File
           Recording mode F
           Record contains 154 characters
           Block contains 0 characters
           Data record FC-Feed2-Record.
       01  FC-Feed2-Record             pic x(154).
       FD  Feed3-File
           Recording mode F
           Record contains 151 characters
           Block contains 0 characters
           Data record FC-Feed3-Record.
       01  FC-Feed3-Record             pic x(151).
       FD  Common-File
           Recording mode F
           Record contains 143 characters
           Block contains 0 characters
           Data record FC-Common-Record.
       01  FC-Common-Record            pic x(143).
       FD  Error-File
           Recording mode F
           Record contains 143 characters
           Block contains 0 characters
           Data record FC-Error-Record.
       01  FC-Error-Record             pic x(143).
       Working-Storage Section.
       01  Feed1-File-Status           pic x(2).
           copy STATUS.
       01  Feed2-File-Status           pic x(2).
           copy STATUS.
       01  Feed3-File-Status           pic x(2).
           copy STATUS.
       01  Common-File-Status          pic x(2).
           copy STATUS.
       01  Error-File-Status           pic x(2).
           copy STATUS.
       01  Feed1-Record.
           copy FEED1.
       01  Feed2-Record.
           copy FEED2.
       01  Feed3-Record.
           copy FEED3.
       01  Common-Record.
           copy COMMON.
       01  Tally-Field                 pic 9(2).
       01  Error-Flag                  pic x.
           88 Record-Error             value 'E'.
       01  Email-Split.
           05  Before-At               pic x(20).
           05  After-At                pic x(20).

       Procedure Division.
           perform 1000-Read-Feed1
           perform 2000-Read-Feed2
           perform 3000-Read-Feed3
           goback
           .

       1000-Read-Feed1.
           perform 1100-Open
           perform 1200-Read-Next
           perform until EOF of Feed1-File-Status
               perform 1200-Read-Next
           end-perform
           .

       1100-Open.
           open input Feed1-File
           if not OK of Feed1-File-Status
               display 'Did not open file: '
                       Feed1-File-Status
           end-if
           .

       1200-Read-Next.
           read Feed1-File next into Feed1-Record end-read
           if not EOF of Feed1-File-Status
               if not OK of Feed1-File-Status                           us)
                   display 'Did not read file: '
                           Feed1-File-Status
               else
                   perform 1300-Reformat
                   perform 4000-Write
               end-if
           end-if
           .

      ******************************************************************
      * Reformat Feed-1 record to Common Record
      ******************************************************************
       1300-Reformat.
           move zero to Tally-Field
           move spaces to Common-record
           inspect F1-Name
               tallying Tally-Field for all ','
           evaluate true
               when Tally-Field = 1 or Tally-Field = 2
                   inspect F1-Name
                       replacing all ',' by ' '
                   move F1-Name to C-Name
                   move 'EN' to C-Language-Code
               when Tally-Field = 3
                   inspect F1-Name
                       replacing all ',' by ' '
                   move F1-Name to C-Name
                   move 'ES' to C-Language-Code
               when other
                   move 'E' to Error-Flag
                   display 'Error reading F1 name'
           end-evaluate
           perform 1310-Validate-Email
           if Record-Error
               display 'Error reading F1 email address'
           end-if
           move F1-Email-Address to C-Email-Address
           if not F1-DNC = spaces
               move 'R' to C-DNC
           end-if
           display Common-Record
           .

      ******************************************************************
      * Ensure email is valid by checking for @ and . after @
      ******************************************************************
       1310-Validate-Email.
           move zero to Tally-Field
           inspect F1-Email-Address
               Tallying Tally-Field for all '@'
           if Tally-Field = 1
               unstring F1-Email-Address
                   delimited by '@'
                   into Before-At After-At
               end-unstring
               inspect After-At
                   Tallying Tally-Field for all '.'
               if not Tally-Field = 2
                   move 'E' to Error-Flag
               end-if
           else
               move 'E' to Error-Flag
           end-if
           .

       2000-Read-Feed2.
           perform 2100-Open
           perform 2200-Read-Next
           perform until EOF of Feed2-File-Status
               perform 2200-Read-Next
           end-perform
           .

       2100-Open.
           open input Feed2-File
           if not OK of Feed2-File-Status
               display 'Did not open file: '
                       Feed2-File-Status
           end-if
           .

       2200-Read-Next.
           read Feed2-File next into Feed2-Record end-read
           if not EOF of Feed2-File-Status
               if not OK of Feed2-File-Status                           us)
                   display 'Did not read file: '
                           Feed2-File-Status
               else
                   perform 2300-Reformat
                   perform 4000-Write
               end-if
           end-if
           .

      ******************************************************************
      * Reformat Feed-2 record to Common Record
      ******************************************************************
       2300-Reformat.
           move spaces to Common-record
           perform 2310-Validate-Email
           if Record-Error
               display 'Error reading F2 email address'
           end-if
           move F2-Email-Address to C-Email-Address
           string
               F2-First-Name delimited by space
               space delimited by size
               F2-Middle-Name delimited by space
               space delimited by size
               F2-Last-Name delimited by space
               space delimited by size
               F2-Suffix delimited by space
               space delimited by size
               into C-Name
           end-string
           if not F2-DNC = spaces
               move 'R' to C-DNC
           end-if
           if not F2-Language-Code = spaces
               move F2-Language-Code to C-Language-Code
           else
               move "EN" to C-Language-Code
           end-if
           display Common-record
           .

       2310-Validate-Email.
           move zero to Tally-Field
           inspect F2-Email-Address
               Tallying Tally-Field for all '@'
           if Tally-Field = 1
               unstring F2-Email-Address
                   delimited by '@'
                   into Before-At After-At
               end-unstring
               inspect After-At
                   Tallying Tally-Field for all '.'
               if not Tally-Field = 2
                   move 'E' to Error-Flag
               end-if
           else
               move 'E' to Error-Flag
           end-if
           .

       3000-Read-Feed3.
           perform 3100-Open
           perform 3200-Read-Next
           perform until EOF of Feed3-File-Status
               perform 3200-Read-Next
           end-perform
           .

       3100-Open.
           open input Feed3-File
           if not OK of Feed3-File-Status
               display 'Did not open file: '
                       Feed3-File-Status
           end-if
           .

       3200-Read-Next.
           read Feed3-File next into Feed3-Record end-read
           if not EOF of Feed3-File-Status
               if not OK of Feed3-File-Status                           us)
                   display 'Did not read file: '
                           Feed3-File-Status
               else
                   perform 3300-Reformat
                   perform 4000-Write
               end-if
           end-if
           .

      ******************************************************************
      * Reformat Feed-3 record to Common Record
      ******************************************************************
       3300-Reformat.
           move spaces to Common-record
           if F3-Middle-Name = "STOP"
               string
                   F3-First-Name delimited by space
                   space delimited by size
                   F3-Last-Name delimited by space
                   space delimited by size
                   into C-Name
               end-string
               move 'R' to C-DNC
           else
               string
                   F3-First-Name delimited by space
                   space delimited by size
                   F3-Middle-Name delimited by space
                   space delimited by size
                   F3-Last-Name delimited by space
                   space delimited by size
                   into C-Name
               end-string
           end-if
           perform 3310-Validate-Email
           if Record-Error
               display 'Error reading F3 email address'
           end-if
           move F3-Email-Address to C-Email-Address
           if F3-Language-Code = "1"
               move "EN" to C-Language-Code
           else
               if F3-Language-Code = "2"
                   move "ES" to C-Language-Code
               else
                   move 'E' to Error-Flag
                   display 'Error reading F3 Language-Code'
               end-if
           end-if
           display Common-record
           .

       3310-Validate-Email.
           move zero to Tally-Field
           inspect F3-Email-Address
               Tallying Tally-Field for all '@'
           if Tally-Field = 1
               unstring F3-Email-Address
                   delimited by '@'
                   into Before-At After-At
               end-unstring
               inspect After-At
                   Tallying Tally-Field for all '.'
               if not Tally-Field = 2
                   move 'E' to Error-Flag
               end-if
           else
               move 'E' to Error-Flag
           end-if
           .

      ******************************************************************
      * Write errors to Error-File and Common records to Common-File
      ******************************************************************
       4000-Write.
           if Record-Error
               open extend Error-File
               if not OK of Error-File-Status
                   display 'Did not open file: '
                           Error-File-Status
               else
                   move Common-Record to FC-Error-Record
                   write FC-Error-Record
                   close Error-File
               end-if
           else
               open extend Common-File
               if not OK of Common-File-Status
                   display 'Did not open file: '
                           Common-File-Status
               else
                   move Common-Record to FC-Common-Record
                   write FC-Common-Record
                   close Common-File
               end-if
           end-if
           move space to Error-Flag
           .

