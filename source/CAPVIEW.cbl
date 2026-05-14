       Identification Division.
       Program-Id. CAPVIEW.
      *****************************************************************
      * View Free Throw statistics
      *****************************************************************
       Data Division.
       Working-Storage Section.
           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE CONTACTS END-EXEC.
           copy DFHAID.
           copy DFHBMSCA.
           copy CAPVMSD2.
           copy CAPCON.
       01  Free-Throw-Record.
           copy CONTACT.
       01  WS-Key.
           05 WS-EMAIL-ADDR.
              49 WS-EMAIL-ADDR-LEN    PIC S9(4) USAGE COMP-5.
              49 WS-EMAIL-ADDR-TEXT   PIC X(40).
           05 WS-SURNAME.
              49 WS-SURNAME-LEN       PIC S9(4) USAGE COMP-5.
              49 WS-SURNAME-TEXT      PIC X(30).
       01  CP-Container-Data.
           05  CON-Page-Number                pic 9(04).
           05  CON-End-of-File-Reached        pic x.
               88  End-of-File-Reached        value 'Y'.
           05  CON-First-Key.
               15 FK-EMAIL-ADDR.
                  49 FK-EMAIL-ADDR-LEN    PIC S9(4) USAGE COMP-5.
                  49 FK-EMAIL-ADDR-TEXT   PIC X(40).
               15 FK-SURNAME.
                  49 FK-SURNAME-LEN       PIC S9(4) USAGE COMP-5.
                  49 FK-SURNAME-TEXT      PIC X(30).
           05  CON-Last-Key.
               15 LK-EMAIL-ADDR.
                  49 LK-EMAIL-ADDR-LEN    PIC S9(4) USAGE COMP-5.
                  49 LK-EMAIL-ADDR-TEXT   PIC X(40).
               15 LK-SURNAME.
                  49 LK-SURNAME-LEN       PIC S9(4) USAGE COMP-5.
                  49 LK-SURNAME-TEXT      PIC X(30).
       01  Container-to-Pass.
           05  First-Time-Flag                pic x.
           05  Record-to-Pass                 pic x(207).
           05  filler                         pic x(79).
           05  Action-Key                     pic x.
               88  Add-Key                    value 'A'.
               88  Update-Key                 value 'C'.
               88  Delete-Key                 value 'D'.
       01  Pagination-Fields.
           05  HV-Key.
               15 HV-EMAIL-ADDR.
                  49 HV-EMAIL-ADDR-LEN    PIC S9(4) USAGE COMP-5.
                  49 HV-EMAIL-ADDR-TEXT   PIC X(40).
               15 HV-SURNAME.
                  49 HV-SURNAME-LEN       PIC S9(4) USAGE COMP-5.
                  49 HV-SURNAME-TEXT      PIC X(30).
           05  PAG-Subscript                  pic s9(4) binary.
           05  PAG-End-of-Data                pic x.
               88  End-of-Data                value 'Y'.
           05  Max-Rows-per-Page              pic s9(4) binary
                                              value +8.
       01  CICS-Response-Code                 pic s9(9) binary.
       01  Transaction-Id-to-Return           pic x(4).
       01  Transfer-to-Program                pic x(8).
       01  Display-Messages.
           05  Highlight-Control              pic x.
               88  Highlight-Error            value 'Y'.
           05  MSG-Out                        pic x(79).
           05  MSG-Undefined-PF-Key           pic x(16)
               value 'Undefined PF key'.
           05  MSG-Initial-Prompt.
               10  filler                     pic x(79)
                   value 'Provide filter criteria and press Enter, or om
      -                  'it criteria to see all records.'.
           05  MSG-Top-of-File                pic x(11)
               value 'Top of file'.
           05  MSG-No-More-Records            pic x(26)
               value 'No more records to display'.
           05  MSG-Container-Error.
               10  filler                     pic x(14)
               value 'GET CONTAINER('.
               10  ERR-Container-Name         pic x(16).
               10  filler                     pic x(10).
               10  ERR-Channel-Name           pic x(16).
               10  filler                     pic x(2) value ') '.
               10  ERR-Container-EIBRESP      pic 9(8).
               10  filler                     pic x value space.
               10  ERR-Container-EIBRESP2     pic 9(8).
           05  MSG-File-Error.
               10  ERR-Operation              pic x(12).
               10  filler                     pic x(6)
                   value '      '.
               10  ERR-File-Name              pic x(8) value spaces.
               10  filler                     pic x value space.
               10  ERR-SQL                    pic x(17).
       Procedure Division.
           EXEC CICS GET CONTAINER(CP-Container-Name)
               CHANNEL(CP-Channel-Name)
               INTO(CP-Container-Data)
               RESP(CICS-Response-Code)
           END-EXEC
           evaluate CICS-Response-Code
               when DFHRESP(NORMAL)
                   perform 1000-Process-User-Input
               when DFHRESP(CHANNELERR)
               when DFHRESP(CONTAINERERR)
                   perform 0000-First-Time
               when other
                   perform 8100-Container-Error
           end-evaluate
           .
       0000-First-Time.
      *****************************************************************
      * First entry into this program in a conversation.
      *****************************************************************
           initialize CP-Container-Data
           move zero to CON-Page-Number
           move "N" to CON-End-of-File-Reached
           move "N" to PAG-End-of-Data
           initialize HV-Key
           move low-values to CAPVMAPO
           move CP-View-TransId to TRANIDO
           perform 2000-Browse-Forward-Fill-Map
           perform 7100-Put-Container
           perform 9100-Display-and-Return
           .
       1000-Process-User-Input.
      *****************************************************************
      * Route control to the appropriate paragraph based on transid.
      *****************************************************************
           perform 1100-Receive-Map
           perform 1200-Check-Attention-Id-Keys
           perform 7100-Put-Container
           perform 9100-Display-and-Return
           .
       1100-Receive-Map.
      *****************************************************************
      * Receive mapped data from the terminal.
      *****************************************************************
           EXEC CICS RECEIVE
               MAP(CP-View-Map)
               MAPSET(CP-View-Mapset)
               INTO(CAPVMAPI)
               ASIS
           END-EXEC
           .
       1200-Check-Attention-Id-Keys.
      *****************************************************************
      * Handle AID keys that trigger special action.
      *****************************************************************
           evaluate EIBAID
               when DFHPF12
                   perform 9900-End-Transaction
               when DFHPF8
                   if End-of-File-Reached
                       subtract 1 from CON-Page-Number
                       move CON-First-Key to HV-Key
                   else
                       move CON-Last-Key to HV-Key
                       perform 1210-Increment-Key
                   end-if
                   perform 2000-Browse-Forward-Fill-Map
               when DFHPF7
                   if CON-Page-Number less than 2
                       move zero to CON-Page-Number
                       move CON-First-Key to HV-Key
                       perform 2000-Browse-Forward-Fill-Map
                   else
                       move CON-First-Key to HV-Key
                       perform 1220-Decrement-Key
                       move space to CON-End-of-File-Reached
                       perform 2500-Browse-Backward-Fill-Map
                   end-if
               when DFHENTER
                   perform varying PAG-Subscript from 1 by 1
                           until PAG-Subscript
                               greater than Max-Rows-per-Page
                       if ACTI(PAG-Subscript) = 'A' or
                          ACTI(PAG-Subscript) = 'C' or
                          ACTI(PAG-Subscript) = 'D'
                           perform 1300-Copy-Selected-Record
                           move CP-Update-Program
                                to Transfer-to-Program
                           perform 9400-Transfer
                       end-if
                   end-perform
               when other
                   perform 9900-End-Transaction
           end-evaluate
           .
       1210-Increment-Key.
      *****************************************************************
      * Grab the Key before forward filling map
      *****************************************************************
           EXEC SQL
           SELECT
               EMAIL_ADDR,
               SURNAME
           INTO
               :HV-EMAIL-ADDR,
               :HV-SURNAME
           FROM
               CONTACTS
           WHERE
               (EMAIL_ADDR > :HV-EMAIL-ADDR)
               OR
               (EMAIL_ADDR = :HV-EMAIL-ADDR
                AND SURNAME > :HV-SURNAME)
           ORDER BY
               EMAIL_ADDR ASC,
               SURNAME ASC
           FETCH FIRST 1 ROW ONLY
           END-EXEC
           if not SQLCODE = 0
                move "INCREMENT" to ERR-Operation
                perform 8200-SQL-Error
           end-if
           .
       1220-Decrement-Key.
      *****************************************************************
      * Grab the previous row before backward filling map
      *****************************************************************
           EXEC SQL
           SELECT
               EMAIL_ADDR,
               SURNAME
           INTO
               :HV-EMAIL-ADDR,
               :HV-SURNAME
           FROM
               CONTACTS
           WHERE
               (EMAIL_ADDR < :HV-EMAIL-ADDR)
               OR
               (EMAIL_ADDR = :HV-EMAIL-ADDR
                AND SURNAME < :HV-SURNAME)
           ORDER BY
               EMAIL_ADDR DESC,
               SURNAME DESC
           FETCH FIRST 1 ROW ONLY
           END-EXEC
           if not SQLCODE = 0
                move "DECREMENT" to ERR-Operation
                perform 8200-SQL-Error
           end-if
           .
       1300-Copy-Selected-Record.
      *****************************************************************
      * Copy the selected record fields from the input map to the
      * container to pass to the update or delete program.
      *****************************************************************
           move spaces to Container-to-Pass
           move ACTI(PAG-Subscript) to Action-Key
           move "Y" to First-Time-Flag
           initialize DCLCONTACTS
           if not Add-Key
               move EMAILI(PAG-Subscript) to EMAIL-ADDR-TEXT
               move NAMEI(PAG-Subscript) to SURNAME-TEXT
               move DNCI(PAG-Subscript) to DO-NOT-CONTACT
               compute EMAIL-ADDR-LEN =
                   function length(function trim(EMAIL-ADDR-TEXT))
               end-compute
               compute SURNAME-LEN =
                   function length(function trim(SURNAME-TEXT))
               end-compute
               if DO-NOT-CONTACT = spaces
                   move -1 to DO-NOT-CONTACT-IND
               else
                   move 0 to DO-NOT-CONTACT-IND
               end-if
               EXEC SQL
               SELECT
                      LANG,
                      FIRST_NAME,
                      MIDDLE_NAME,
                      ADDL_NAME,
                      LAST_CONTACT,
                      LAST_RESPONSE,
                      DO_NOT_CONTACT
               INTO
                      :LANG,
                      :FIRST-NAME,
                      :MIDDLE-NAME :MIDDLE-NAME-IND,
                      :ADDL-NAME :ADDL-NAME-IND,
                      :LAST-CONTACT :LAST-CONTACT-IND,
                      :LAST-RESPONSE :LAST-RESPONSE-IND,
                      :DO-NOT-CONTACT :DO-NOT-CONTACT-IND
               FROM CONTACTS
               WHERE EMAIL_ADDR = :EMAIL-ADDR
                 AND SURNAME    = :SURNAME
               END-EXEC
           end-if
           move DCLCONTACTS to Record-To-Pass
           move Max-Rows-per-Page to PAG-Subscript
           .
       2000-Browse-Forward-Fill-Map.
      *****************************************************************
      * Browse to end of file or until output map is filled.
      *****************************************************************
           perform 2100-Start-Browse
           perform 2200-Read-Forward
           perform 2900-End-Browse-Forward
           .
       2100-Start-Browse.
      *****************************************************************
      * Initiate browse based on the key currently set.
      *****************************************************************
           move spaces to CON-First-Key CON-Last-Key
           if HV-EMAIL-ADDR-TEXT = spaces
               EXEC SQL
               SELECT
                   EMAIL_ADDR,
                   SURNAME
               INTO
                   :HV-EMAIL-ADDR,
                   :HV-SURNAME
               FROM
                   CONTACTS
               ORDER BY
                   EMAIL_ADDR,
                   SURNAME
               FETCH FIRST 1 ROW ONLY
               END-EXEC
           end-if

           EXEC SQL
           DECLARE FORWARD_READ_CURSOR CURSOR FOR
           SELECT
               EMAIL_ADDR,
               SURNAME,
               DO_NOT_CONTACT
           FROM CONTACTS
           WHERE
               (EMAIL_ADDR > :HV-EMAIL-ADDR)
               OR (EMAIL_ADDR = :HV-EMAIL-ADDR
                   AND SURNAME >= :HV-SURNAME)
           ORDER BY
               EMAIL_ADDR,
               SURNAME
           END-EXEC
           EXEC SQL
               OPEN FORWARD_READ_CURSOR
           END-EXEC
           if not SQLCODE = 0
                move "OPEN" to ERR-Operation
                perform 8200-SQL-Error
           end-if
           .
       2110-Start-Browse-Backwards.
      *****************************************************************
      * Initiate browse based on the key currently set.
      *****************************************************************
           move spaces to CON-First-Key CON-Last-Key
           EXEC SQL
           DECLARE BACKWARD_READ_CURSOR CURSOR FOR
           SELECT
               EMAIL_ADDR,
               SURNAME,
               DO_NOT_CONTACT
           FROM CONTACTS
           WHERE
               (EMAIL_ADDR < :HV-EMAIL-ADDR)
               OR (EMAIL_ADDR = :HV-EMAIL-ADDR
                   AND SURNAME <= :HV-SURNAME)
           ORDER BY
               EMAIL_ADDR DESC,
               SURNAME DESC
           END-EXEC
           EXEC SQL
               OPEN BACKWARD_READ_CURSOR
           END-EXEC
           if not SQLCODE = 0
                move "OPEN" to ERR-Operation
                perform 8200-SQL-Error
           end-if
           .
       2200-Read-Forward.
      *****************************************************************
      * Read forward to end of file or until max lines on the map.
      *****************************************************************
           add 1 to CON-Page-Number
           move "N" to PAG-End-of-Data
           perform varying PAG-Subscript from 1 by 1
                   until PAG-Subscript greater than Max-Rows-per-Page
                   or End-of-Data
               perform 2300-Next-Record
           end-perform
           if End-of-Data
               set End-of-File-Reached to true
               subtract 1 from PAG-Subscript
               perform varying PAG-Subscript
                       from PAG-Subscript by 1
                       until PAG-Subscript
                             greater than Max-Rows-per-Page
                   move DFHPROTN to
                            ACTA(PAG-Subscript)
                            EMAILA(PAG-Subscript)
                            NAMEA(PAG-Subscript)
                            DNCA(PAG-Subscript)
               end-perform
           end-if
           .
       2300-Next-Record.
      *****************************************************************
      * Read the next record and populate the output map.
      *****************************************************************
           perform 2400-Read-Next
           if SQLCODE = 0
               perform 4000-Copy-from-Record-to-Map
           else
               if SQLCODE = 100
                   set End-of-Data to true
               else
                   move "READNEXT" to ERR-Operation
                   perform 8200-SQL-Error
               end-if
           end-if
           .
       2400-Read-Next.
      *****************************************************************
      * READNEXT command performed from multiple places.
      *****************************************************************
           initialize DCLCONTACTS
           EXEC SQL
           FETCH FORWARD_READ_CURSOR
           INTO
               :EMAIL-ADDR,
               :SURNAME,
               :DO-NOT-CONTACT :DO-NOT-CONTACT-IND
           END-EXEC
           move EMAIL-ADDR to CP-Email-Addr
           move SURNAME to CP-Surname
           move DO-NOT-CONTACT to CP-Do-Not-Contact
           .
       2500-Browse-Backward-Fill-Map.
      *****************************************************************
      * Browse to beginning of file or until output map is filled.
      *****************************************************************
           perform 2110-Start-Browse-Backwards
           perform 2600-Read-Backward
           perform 2910-End-Browse-Backward
           .
       2600-Read-Backward.
      *****************************************************************
      * Read backward and populate output map fields.
      *****************************************************************
           subtract 1 from CON-Page-Number
           move HV-Key to CON-Last-Key
           move spaces to PAG-End-of-Data
           perform varying PAG-Subscript from Max-Rows-per-Page by -1
                   until PAG-Subscript is less than 1
                   or End-of-Data
               perform 2700-Previous-Record
           end-perform
           .
       2700-Previous-Record.
      *****************************************************************
      * Read the previous record and populate the output map.
      *****************************************************************
           perform 2800-Read-Previous
           if SQLCODE = 0
               perform 4000-Copy-from-Record-to-Map
           else
               if SQLCODE = 100
                   set End-of-Data to true
               else
                   move "READPREV" to ERR-Operation
                   perform 8200-SQL-Error
               end-if
           end-if
           .
       2800-Read-Previous.
      *****************************************************************
      * READPREV command performed from multiple places.
      *****************************************************************
           initialize DCLCONTACTS
           EXEC SQL
           FETCH BACKWARD_READ_CURSOR
           INTO
               :EMAIL-ADDR,
               :SURNAME,
               :DO-NOT-CONTACT :DO-NOT-CONTACT-IND
           END-EXEC
           move EMAIL-ADDR to CP-Email-Addr
           move SURNAME to CP-Surname
           move DO-NOT-CONTACT to CP-Do-Not-Contact
           .
       2900-End-Browse-Forward.
      *****************************************************************
      * Terminate the current browse and save first and last keys.
      *****************************************************************
           EXEC SQL
               CLOSE FORWARD_READ_CURSOR
           END-EXEC
           if not SQLCODE = 0
                move "CLOSE" to ERR-Operation
                perform 8200-SQL-Error
           end-if
           move HV-Key to CON-First-Key
           move EMAIL-ADDR to WS-Email-Addr
           move SURNAME TO WS-Surname
           move WS-Key to CON-Last-Key
           .
       2910-End-Browse-Backward.
      *****************************************************************
      * Terminate the current browse and save first and last keys.
      *****************************************************************
           EXEC SQL
               CLOSE BACKWARD_READ_CURSOR
           END-EXEC
           if not SQLCODE = 0
                move "CLOSE" to ERR-Operation
                perform 8200-SQL-Error
           end-if
           move EMAIL-ADDR to WS-Email-Addr
           move SURNAME TO WS-Surname
           move WS-Key to CON-First-Key
           move HV-Key to CON-Last-Key
           .
       4000-Copy-from-Record-to-Map.
      *****************************************************************
      * Populate a line in the output map from the current record.
      *****************************************************************
            move CP-Email-Addr-Text to EMAILO(PAG-Subscript)
            move CP-Surname-Text to NAMEO(PAG-Subscript)
            move CP-Do-Not-Contact to DNCO(PAG-Subscript)
           .
       7100-Put-Container.
      *****************************************************************
      * Copy working storage data to the container.
      *****************************************************************
           EXEC CICS PUT CONTAINER(CP-Container-Name)
               CHANNEL(CP-Channel-Name)
               FROM(CP-Container-Data)
               FLENGTH(length of CP-Container-Data)
               RESP(CICS-Response-Code)
           END-EXEC
           if CICS-Response-Code equal DFHRESP(NORMAL)
               continue
           else
               perform 8100-Container-Error
           end-if
           .
       8100-Container-Error.
      *****************************************************************
      * Display response codes after unexpected condition when
      * getting a container.
      *****************************************************************
           move CP-Channel-Name to ERR-Channel-Name
           move CP-Container-Name to ERR-Container-Name
           move EIBRESP to ERR-Container-EIBRESP
           move EIBRESP2 to ERR-Container-EIBRESP2
           move MSG-Container-Error to MSGO
           perform 9100-Display-and-Return
           .
       8200-SQL-Error.
      *****************************************************************
      * Display response codes after unexpected condition when
      * performing a File Control operation.
      *****************************************************************
           move SQLCODE to ERR-SQL
           move MSG-File-Error to MSG-Out
           set Highlight-Error to true
           perform 9100-Display-and-Return
           .
      *****************************************************************
      * Display the output map and do a pseudoconversational return.
      *****************************************************************
       9100-Display-and-Return.
           move CON-Page-Number to PAGEO
           if Highlight-Error
               move DFHRED to MSGC
               move space to Highlight-Control
           end-if
           if End-of-Data
               move DFHPROTN to HLPPF8A
               move MSG-No-More-Records to MSGO
           end-if
           if CON-Page-Number less than 2
               move DFHPROTN to HLPPF7A
               move MSG-Top-of-File to MSGO
           end-if
           EXEC CICS SEND
               MAP(CP-View-Map)
               MAPSET(CP-View-Mapset)
               FROM(CAPVMAPO)
               ERASE
               FREEKB
           END-EXEC
           EXEC CICS RETURN
               TRANSID(CP-View-TransId)
               CHANNEL(CP-Channel-Name)
           END-EXEC
           .
       9400-Transfer.
           EXEC CICS PUT CONTAINER(CP-Container-Name)
               CHANNEL(CP-Channel-Name)
               FROM(Container-to-Pass)
               FLENGTH(length of Container-to-Pass)
           END-EXEC
           EXEC CICS XCTL
               PROGRAM(Transfer-to-Program)
               CHANNEL(CP-Channel-Name)
           END-EXEC
           .
       9900-End-Transaction.
           EXEC CICS SEND CONTROL
               ERASE FREEKB
           END-EXEC
           EXEC CICS RETURN END-EXEC
           .
