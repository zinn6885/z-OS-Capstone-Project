       Identification Division.
       Program-Id. RATIO.
       Environment Division.
       Input-Output Section.
       File-Control.
           Select Sorted-File
               Assign to SFILE
               Organization Sequential
               Access Sequential
               File status Sorted-File-Status.
           Select Error-File
               Assign to EFILE
               Organization Sequential
               Access Sequential
               File status Error-File-Status.
           Select Clean-File
               Assign to CLFILE
               Organization Sequential
               Access Sequential
               File status Clean-File-Status.
       Data Division.
       File Section.
       FD  Sorted-File
           Recording mode F
           Record contains 143 characters
           Block contains 0 characters
           Data record FC-Sorted-Record.
       01  FC-Sorted-Record            pic x(143).
       FD  Error-File
           Recording mode F
           Record contains 143 characters
           Block contains 0 characters
           Data record FC-Error-Record.
       01  FC-Error-Record             pic x(143).
       FD  Clean-File
           Recording mode F
           Record contains 143 characters
           Block contains 0 characters
           Data record FC-Clean-Record.
       01  FC-Clean-Record             pic x(143).
       Working-Storage Section.
       01  Sorted-File-Status          pic x(2).
           copy STATUS.
       01  Error-File-Status           pic x(2).
           copy STATUS.
       01  Clean-File-Status           pic x(2).
           copy STATUS.
       01  Sorted-Record.
           copy COMMON.
       01  Clean-Record.
           copy COMMON.
       01  Name-Formated.
           05  English-Name.
               10  First-Name          pic x(100).
               10  Middle-Name         pic x(100).
               10  Last-Name           pic x(100).
               10  Addl-Name           pic x(100).
       01  Name-Length                 pic 9(3).
       01  Tally-Field                 pic 9(2).
       01  Error-Flag                  pic x.
           88 Record-Error             value 'E'.

       Procedure Division.
           perform 1000-Read-Sorted
           goback
           .

       1000-Read-Sorted.
           perform 1100-Open
           perform 1200-Read-Next
           perform until EOF of Sorted-File-Status
               perform 1200-Read-Next
           end-perform
           .

      ******************************************************************
      * Open Sorted-File
      ******************************************************************
       1100-Open.
           open input Sorted-File
           if not OK of Sorted-File-Status
               display 'Did not open file: '
                       Sorted-File-Status
           end-if
           .

      ******************************************************************
      * Read from Sorted-File sequentially, rationalize names, and
      * write out records
      ******************************************************************
       1200-Read-Next.
           read Sorted-File next into Sorted-Record end-read
           if not EOF of Sorted-File-Status
               if not OK of Sorted-File-Status                          us)
                   display 'Did not read file: '
                           Sorted-File-Status
               else
                   perform 3000-Rationalize-Names
                   perform 4000-Write
               end-if
           end-if
           .

       3000-Rationalize-Names.
           move zero to Tally-Field
           move Sorted-Record to Clean-Record
           move spaces to Name-Formated
           inspect function trim(C-Name of Sorted-Record)
               tallying Tally-Field for all ' '
           perform 3100-Check-DNC
           perform 3200-Check-Language-Code
           perform 3300-Check-Name
           perform 3400-Check-Email-Address
           .

       3100-Check-DNC.
           if not (C-DNC of Sorted-Record = ' ' or
                   C-DNC of Sorted-Record = 'R')
               move 'E' to Error-Flag
               display 'Error reading DNC'
           end-if
           .


       3200-Check-Language-Code.
           if C-Language-Code of Sorted-Record = ' '
               evaluate true
                   when Tally-Field = 1 or Tally-Field = 2
                       move 'EN' to C-Language-Code of Clean-Record
                   when Tally-Field = 3
                       move 'ES' to C-Language-Code of Clean-Record
                   when other
                       move 'E' to Error-Flag
                       display 'Error reading language code'
               end-evaluate
           end-if
           .

       3300-Check-Name.
           if Tally-Field > 3
               move 'E' to Error-Flag
               display 'Error reading name'
           else
               unstring C-Name of Sorted-Record
                   delimited by ' '
                   into First-Name Middle-Name
                        Last-Name Addl-Name
               end-unstring
               compute Name-Length =
                   function length(function trim (First-Name))
               end-compute
               if Name-Length > 30
                   move 'E' to Error-Flag
                   display 'Error name length too long'
               end-if
               compute Name-Length =
                   function length(function trim (Middle-Name))
               end-compute
               if Name-Length > 30
                   move 'E' to Error-Flag
                   display 'Error name length too long'
               end-if
               compute Name-Length =
                   function length(function trim (Last-Name))
               end-compute
               if Name-Length > 30
                   move 'E' to Error-Flag
                   display 'Error name length too long'
               end-if
               compute Name-Length =
                   function length(function trim (Addl-Name))
               end-compute
               if Name-Length > 30
                   move 'E' to Error-Flag
                   display 'Error name length too long'
               end-if
           end-if
           .

       3400-Check-Email-Address.
           continue
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
                   move Sorted-Record to FC-Error-Record
                   write FC-Error-Record
                   close Error-File
               end-if
           else
               open extend Clean-File
               if not OK of Clean-File-Status
                   display 'Did not open file: '
                           Clean-File-Status
               else
                   move Clean-Record to FC-Clean-Record
                   write FC-Clean-Record
                   close Clean-File
               end-if
           end-if
           move space to Error-Flag
           .
