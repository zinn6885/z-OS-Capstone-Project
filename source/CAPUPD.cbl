       Identification Division.
       Program-Id. CAPUPD.
      *****************************************************************
      * Program for viewing, adding, deleting or updating records
      *****************************************************************
       Data Division.
       Working-Storage Section.
           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE CONTACTS END-EXEC.
           copy DFHAID.
           copy DFHBMSCA.
           copy CAPUMSD.
           copy CAPCON.
       01  CP-Container-Data.
           02  CON-First-Time                  pic x.
               88  First-Time                  value "Y".
           02  CP-Record.
               10 CP-C-ID                 PIC S9(9) USAGE COMP-5.
               10 CP-LANG                 PIC X(2).
               10 CP-SURNAME.
                  49 CP-SURNAME-LEN       PIC S9(4) USAGE COMP-5.
                  49 CP-SURNAME-TEXT      PIC X(30).
               10 CP-FIRST-NAME.
                  49 CP-FIRST-NAME-LEN    PIC S9(4) USAGE COMP-5.
                  49 CP-FIRST-NAME-TEXT   PIC X(30).
               10 CP-MIDDLE-NAME.
                  49 CP-MIDDLE-NAME-LEN   PIC S9(4) USAGE COMP-5.
                  49 CP-MIDDLE-NAME-TEXT  PIC X(30).
               10 CP-MIDDLE-NAME-IND      PIC S9(4) USAGE COMP.
               10 CP-ADDL-NAME.
                  49 CP-ADDL-NAME-LEN     PIC S9(4) USAGE COMP-5.
                  49 CP-ADDL-NAME-TEXT    PIC X(30).
               10 CP-ADDL-NAME-IND        PIC S9(4) USAGE COMP.
               10 CP-EMAIL-ADDR.
                  49 CP-EMAIL-ADDR-LEN    PIC S9(4) USAGE COMP-5.
                  49 CP-EMAIL-ADDR-TEXT   PIC X(40).
               10 CP-LAST-CONTACT         PIC X(10).
               10 CP-LAST-CONTACT-IND     PIC S9(4) USAGE COMP.
               10 CP-LAST-RESPONSE        PIC X(10).
               10 CP-LAST-RESPONSE-IND    PIC S9(4) USAGE COMP.
               10 CP-DO-NOT-CONTACT       PIC X(1).
               10 CP-DO-NOT-CONTACT-IND   PIC S9(4) USAGE COMP.
           02  Validation-Errors               pic x(79).
           02  Action-Key                      pic x.
               88  Add-Key                     value 'A'.
               88  Update-Key                  value 'C'.
               88  Delete-Key                  value 'D'.
       01  CICS-Response-Code                  pic s9(9) binary.
       01  Display-Messages.
           05  Highlight-Control               pic x.
               88  Highlight-Error             value "Y".
           05  MSG-Out                         pic x(79).
           05  MSG-Undefined-PF-Key            pic x(16)
               value 'Undefined PF key'.
           05  MSG-Initial-Prompt.
               10  filler                      pic x(79)
               value "Overtype values to be changed".
           05  MSG-Record-Added                pic x(79)
               value "Record successfully added".
           05  MSG-Record-Updated              pic x(79)
               value "Record successfully updated".
           05  MSG-Record-Deleted              pic x(79)
               value "Record successfully deleted".
           05  MSG-Container-Error.
               10  filler                      pic x(14)
               value 'GET CONTAINER('.
               10  ERR-Container-Name          pic x(16).
               10  filler                      pic x(10).
               10  ERR-Channel-Name            pic x(16).
               10  filler                      pic x(2) value ') '.
               10  ERR-Container-EIBRESP       pic 9(8).
               10  filler                      pic x value space.
               10  ERR-Container-EIBRESP2      pic 9(8).
           05  MSG-File-Error.
               10  ERR-Operation               pic x(12).
               10  filler                      pic x(6)
                   value '      '.
               10  ERR-File-Name               pic x(8) value spaces.
               10  filler                      pic x value space.
               10  ERR-SQL                     pic x(17).
       01 WS-DATE-NUMERIC pic 9(8).
       Procedure Division.
           perform 7000-Get-Container
           evaluate CICS-Response-Code
               when DFHRESP(NORMAL)
                   if First-Time
                       perform 0000-First-Time
                   else
                       perform 1000-Process-User-Input
                   end-if
               when DFHRESP(CHANNELERR)
               when DFHRESP(CONTAINERERR)
                   perform 9800-Start-Initial-Trans
               when other
                   perform 8100-Container-Error
           end-evaluate
           .
       0000-First-Time.
      *****************************************************************
      * Initiate the map and move appropriate values to display
      *****************************************************************
           move spaces to CON-First-Time
           move spaces to CAPUMAPO
           perform 4000-Copy-from-Record-to-Map
           move CP-Update-TransId to TRANIDO
           move MSG-Initial-Prompt to MSGO
           perform 7100-Put-Container
           perform 9100-Display-and-Return
           .
       1000-Process-User-Input.
      *****************************************************************
      * Check which keys the user pressed and route accordingly
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
               MAP(CP-Update-Map)
               MAPSET(CP-Update-Mapset)
               INTO(CAPUMAPI)
               ASIS
           END-EXEC
           .
       1200-Check-Attention-Id-Keys.
      *****************************************************************
      * Handle AID keys that trigger special action.
      *****************************************************************
           evaluate EIBAID
               when DFHENTER
                   if not Delete-Key
                       perform 2000-Validate-Input
                   end-if
               when DFHPF5
                   evaluate true
                       when Add-Key
                           perform 5100-Add-Changes
                       when Update-Key
                           perform 5000-Save-Changes
                       when other
                           perform 5200-Delete-Changes
                   end-evaluate
               when DFHPF12
                   perform 9500-Transfer-to-View
               when other
                   move MSG-Undefined-PF-Key to MSGO
                   perform 7100-Put-Container
                   perform 9100-Display-and-Return
           end-evaluate
           .
       1300-Set-Map.
      *****************************************************************
      * Set the correct titles for feilds depending on language
      *****************************************************************
           if CP-LANG = "EN"
               move "     Contact Details" to CDEETO
               move "      First Name: " to FNAMETO
               move "     Middle Name: " to MNAMETO
               move "         Surname: " to SNAMETO
               move " Additional Name: " to ANAMETO
               move "        Language: " to LANGTO
               move "           Email: " to EMAILTO
               move "  Do Not Contact: " to DNCTO
               move "Dates formatted in (YYYY/MM/DD)" to DFORMTO
               move "    Last Contact: " to LCONTTO
               move "   Last Response: " to LRESPTO
               move "ENTER Validate     PF5 Save     PF12 Cancel"
                 to INFOTO
           else
               move "Detalles de Contacto" to CDEETO
               move "   Primer Nombre: " to FNAMETO
               move "  Segundo Nombre: " to MNAMETO
               move " Primer Apellido: " to SNAMETO
               move "Segundo Apellido: " to ANAMETO
               move "          Idioma: " to LANGTO
               move "           Email: " to EMAILTO
               move "    No Contactar: " to DNCTO
               move "Fechas en formato (AAAA/MM/DD)" to DFORMTO
               move " Ultimo Contacto: " to LCONTTO
               move "Ultima Respuesta: " to LRESPTO
               move "ENTER Validar     PF5 Guardar     PF12 Cancelar"
                 to INFOTO
           end-if
           .
       2000-Validate-Input.
      *****************************************************************
      * Validate newly-submitted and previously-stored input values.
      *****************************************************************
           if FNAMEL greater than 0
               move FNAMEI to CP-FIRST-NAME-TEXT
           end-if
           if MNAMEL greater than 0
               move MNAMEI to CP-MIDDLE-NAME-TEXT
           end-if
           if SNAMEL greater than 0
               move SNAMEI to CP-SURNAME-TEXT
           end-if
           if ANAMEL greater than 0
               move ANAMEI to CP-ADDL-NAME-TEXT
           end-if
           if LANGL greater than 0
               move LANGI to CP-LANG
           end-if
           if EMAILL greater than 0
               move EMAILI to CP-EMAIL-ADDR-TEXT
           end-if
           if DNCL greater than 0
               move DNCI to CP-DO-NOT-CONTACT
           end-if
           if LCONTL greater than 0
               move LCONTI to CP-LAST-CONTACT
           end-if
           if LRESPL greater than 0
               move LRESPI to CP-LAST-RESPONSE
           end-if
           perform 7100-Put-Container
           EXEC CICS LINK
               PROGRAM(CP-Validation-Program)
               CHANNEL(CP-Channel-Name)
           END-EXEC

           perform 7000-Get-Container
           if Validation-Errors greater than spaces
               move Validation-Errors to MSGO
           end-if
           perform 4100-Set-Host-Variables
           perform 4000-Copy-from-Record-to-Map
           .
       4000-Copy-from-Record-to-Map.
      *****************************************************************
      * Populate output map from container data.
      *****************************************************************
           move CP-FIRST-NAME-TEXT to FNAMEO
           move CP-MIDDLE-NAME-TEXT to MNAMEO
           move CP-SURNAME-TEXT to SNAMEO
           move CP-ADDL-NAME-TEXT to ANAMEO
           move CP-LANG to LANGO
           move CP-EMAIL-ADDR-TEXT to EMAILO
           move CP-DO-NOT-CONTACT to DNCO
           MOVE CP-LAST-CONTACT(1:4) TO WS-DATE-NUMERIC(1:4)
           MOVE CP-LAST-CONTACT(6:2) TO WS-DATE-NUMERIC(5:2)
           MOVE CP-LAST-CONTACT(9:2) TO WS-DATE-NUMERIC(7:2)
           move WS-DATE-NUMERIC to LCONTO
           MOVE CP-LAST-RESPONSE(1:4) TO WS-DATE-NUMERIC(1:4)
           MOVE CP-LAST-RESPONSE(6:2) TO WS-DATE-NUMERIC(5:2)
           MOVE CP-LAST-RESPONSE(9:2) TO WS-DATE-NUMERIC(7:2)
           move WS-DATE-NUMERIC to LRESPO
           .
       4100-Set-Host-Variables.
      *****************************************************************
      * Format the variables to be passed to a sql statement
      *****************************************************************
           compute CP-FIRST-NAME-LEN =
               function length(function trim(CP-FIRST-NAME-TEXT))
           end-compute
           compute CP-MIDDLE-NAME-LEN =
               function length(function trim(CP-MIDDLE-NAME-TEXT))
           end-compute
           compute CP-SURNAME-LEN =
               function length(function trim(CP-SURNAME-TEXT))
           end-compute
           compute CP-ADDL-NAME-LEN =
               function length(function trim(CP-ADDL-NAME-TEXT))
           end-compute
           compute CP-EMAIL-ADDR-LEN =
               function length(function trim(CP-EMAIL-ADDR-TEXT))
           end-compute
           if CP-MIDDLE-NAME-TEXT = spaces
               move -1 to CP-MIDDLE-NAME-IND
           else
               move 0 to CP-MIDDLE-NAME-IND
           end-if
           if CP-ADDL-NAME-TEXT = spaces
               move -1 to CP-ADDL-NAME-IND
           else
               move 0 to CP-ADDL-NAME-IND
           end-if
           if CP-LAST-CONTACT = spaces
               move -1 to CP-LAST-CONTACT-IND
           else
               move 0 to CP-LAST-CONTACT-IND
           end-if
           if CP-LAST-RESPONSE = spaces
               move -1 to CP-LAST-RESPONSE-IND
           else
               move 0 to CP-LAST-RESPONSE-IND
           end-if
           if CP-DO-NOT-CONTACT = space
               move -1 to CP-DO-NOT-CONTACT-IND
           else
               move 0 to CP-DO-NOT-CONTACT-IND
           end-if
           .
       5000-Save-Changes.
      *****************************************************************
      * Update the record unless there are still validation errors.
      *****************************************************************
           perform 4000-Copy-from-Record-to-Map
           if Validation-Errors greater than spaces
               move Validation-Errors to MSGO
           else
               EXEC SQL
                   UPDATE CONTACTS
                      SET LANG               = :CP-LANG,
                          FIRST_NAME         = :CP-FIRST-NAME,
                          MIDDLE_NAME        = :CP-MIDDLE-NAME
                                                :CP-MIDDLE-NAME-IND,
                          SURNAME            = :CP-SURNAME,
                          ADDL_NAME          = :CP-ADDL-NAME
                                                :CP-ADDL-NAME-IND,
                          DO_NOT_CONTACT     = :CP-DO-NOT-CONTACT
                                                :CP-DO-NOT-CONTACT-IND
                    WHERE EMAIL_ADDR = :CP-EMAIL-ADDR
               END-EXEC
               if SQLCODE = 0
                   EXEC SQL COMMIT END-EXEC
                   move MSG-Record-Updated to MSGO
               else
                   EXEC SQL ROLLBACK END-EXEC
                   move "REWRITE" to ERR-Operation
                   perform 8200-SQL-Error
               end-if
           end-if
           .
       5100-Add-Changes.
      *****************************************************************
      * Add the record unless there are still validation errors.
      *****************************************************************
           perform 4000-Copy-from-Record-to-Map
           if Validation-Errors greater than spaces
               move Validation-Errors to MSGO
           else
               EXEC SQL
               INSERT INTO CONTACTS (
                 LANG, SURNAME, FIRST_NAME, MIDDLE_NAME, ADDL_NAME,
                 EMAIL_ADDR, LAST_CONTACT, LAST_RESPONSE, DO_NOT_CONTACT
               )
               VALUES (
                 :CP-LANG, :CP-SURNAME, :CP-FIRST-NAME,
                 :CP-MIDDLE-NAME :CP-MIDDLE-NAME-IND,
                 :CP-ADDL-NAME :CP-ADDL-NAME-IND,
                 :CP-EMAIL-ADDR, :CP-LAST-CONTACT :CP-LAST-CONTACT-IND,
                 :CP-LAST-RESPONSE :CP-LAST-RESPONSE-IND,
                 :CP-DO-NOT-CONTACT :CP-DO-NOT-CONTACT-IND)
               END-EXEC
               if SQLCODE = 0
                   EXEC SQL COMMIT END-EXEC
                   move MSG-Record-Added to MSGO
               else
                   EXEC SQL ROLLBACK END-EXEC
                   move "ADD" to ERR-Operation
                   perform 8200-SQL-Error
               end-if
           end-if
           .
       5200-Delete-Changes.
      *****************************************************************
      * Delete the record
      *****************************************************************
           if Validation-Errors greater than spaces
               move Validation-Errors to MSGO
           else
               EXEC SQL
                  DELETE FROM CONTACTS
                  WHERE EMAIL_ADDR = :CP-EMAIL-ADDR
                    AND SURNAME    = :CP-SURNAME
               END-EXEC
               if SQLCODE = 0
                   EXEC SQL COMMIT END-EXEC
                   move MSG-Record-Deleted to MSGO
               else
                   EXEC SQL ROLLBACK END-EXEC
                   move "ADD" to ERR-Operation
                   perform 8200-SQL-Error
               end-if
           end-if
           .

       7000-Get-Container.
      *****************************************************************
      * Copy container data to working storage.
      *****************************************************************
           EXEC CICS GET CONTAINER(CP-Container-Name)
               CHANNEL(CP-Channel-Name)
               INTO(CP-Container-Data)
               FLENGTH(length of CP-Container-Data)
               RESP(CICS-Response-Code)
           END-EXEC
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
       9100-Display-and-Return.
      *****************************************************************
      * Display the output map and do a pseudoconversational return.
      *****************************************************************
           perform 1300-Set-Map
           evaluate true
               when Add-Key
                   move "ADD" to SCRTITLO
               when Update-Key
                   move "UPDATE" to SCRTITLO
               when other
                   move "DELETE" to SCRTITLO
           end-evaluate
           if not Add-Key
               move DFHBMASK to EMAILA
           end-if
           move DFHBMASK to LCONTA
           move DFHBMASK to LRESPA
           if Delete-Key
               move DFHBMASK to FNAMEA
               move DFHBMASK to MNAMEA
               move DFHBMASK to SNAMEA
               move DFHBMASK to ANAMEA
               move DFHBMASK to LANGA
           end-if
           if Highlight-Error
               move DFHRED to MSGC
               move space to Highlight-Control
           end-if
           EXEC CICS SEND
               MAP(CP-Update-Map)
               MAPSET(CP-Update-Mapset)
               FROM(CAPUMAPO)
               ERASE
               FREEKB
           END-EXEC
           EXEC CICS RETURN
               TRANSID(CP-Update-TransId)
               CHANNEL(CP-Channel-Name)
           END-EXEC
           .
       9500-Transfer-to-View.
      *****************************************************************
      * Transfer back to the view screen terminate the update program
      *****************************************************************
           EXEC CICS START
               TRANSID(CP-View-TransId)
               TERMID(EIBTRMID)
           END-EXEC
           EXEC CICS RETURN
           END-EXEC
           .
       9800-Start-Initial-Trans.
      *****************************************************************
      * This program must be passed the record that is to be updated.
      * Therefore, if it is started directly from terminal input, we
      * end this transaction and start a View transaction.
      *****************************************************************
           EXEC CICS START
               TRANSID(CP-View-TransId)
               TERMID(EIBTRMID)
           END-EXEC
           EXEC CICS RETURN
           END-EXEC
           .
