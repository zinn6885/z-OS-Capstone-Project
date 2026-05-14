# z/OS Training

## Capstone Projects

### 1. Mass-Mailing Solution

#### Back Story

Our company, a revered financial institution, sends unsolicited emails to unsuspecting people to advertise unwanted products.

It is a time-honored business model that everyone loves.

#### Application Overview

We purchase mailing lists from three external suppliers, who send us sequential data sets we call _data feeds_
.
We run a batch job that performs extract-transform-load (ETL) operations on the data feeds to produce a single sequential data set that contains contact information in a common format.

The job then processes that data set to update our system of record with new contacts and to set a "do not contact" indicator if requested.

Another batch job runs on a monthly basis. It looks for contacts in the system of record who have not received a mailing within the past month. If their "do not contact" indicator is not set, they are selected for the next mailing.

The next step in the job reads the selected contact records and sends the emails with fake "from" addresses, to foil blocklists.

Our customer service department uses a CICS application to browse the Contacts. Just like a real customer service department, they can't change anything in the system.

#### Skills to Demonstrate

The project offers the opportunity to demonstrate the following skills:

- Using ISPF panels to allocate data sets.
- Using SDSF to review batch job output.
- Writing JCL to run IBM utilities such as IEFBR14, IEBGENER, DFSORT, and IDCAMS.
- Writing DFSORT commands to reformat, sort, and merge data sets.
- Working with Generation Data Groups (GDGs).
- Conditional job step execution using either COND or IF/ELSE.
- Step restart after job failure, including handling Generation Data Sets correctly.
- Writing batch COBOL programs that access either DB2 or a VSAM KSDS, as well as sequential data sets.
- Writing COBOL logic to manipulate textual data and perform date arithmetic.
- Designing and coding a BMS mapset (full bootcamp only).
- Writing a COBOL program to access either DB2 or VSAM in the CICS environment (full bootcamp only).

#### System of Record

The system of record for our solution contains Contact information.

Depending on the topics included in your training program, this will be either a DB2 database containing one table or a single VSAM Key-Sequenced Data Set (not both).

The data store for the system of record is _not_ provided. Creating it is part of the capstone exercise.

_System of Record – VSAM KSDS_

Average and maximum record sizes: 219 219

Key length and offset: 80 0

Record layout:

| Positions | Field           | Description                                        |
| --------- | --------------- | -------------------------------------------------- |
| 1-40      | Email-Address   | Email address (RID)                                |
| 41-80     | Surname         | English: Last name, Spanish: Primer Apellido (RID) |
| 81-120    | First-Name      | English: First name, Spanish: Primer Nombre        |
| 121-160   | Middle-Name     | English: Middle name, Spanish: Segundo Nombre      |
| 161-200   | Additional-Name | English: spaces, Spanish: Segundo Apellido         |
| 201-202   | Language        | EN or ES                                           |
| 203-210   | Last-Contact    | YYYYMMDD                                           |
| 211-218   | Last-Response   | YYYYMMDD                                           |
| 219-219   | Do-Not-Contact  | "X" or "P" or space                                |

Seed data for the KSDS: Mailout_Seed_Data.txt. Upload as `<userid>.INNOV.MAILSEED`, DSORG=PS, RECFM=FB, LRECL=219, BLKSIZE=21900.

_System of Record - DB2_

Table Name: **CONTACTS**

| Column         | Type         | Notes       | Description                                   |
| -------------- | ------------ | ----------- | --------------------------------------------- |
| ID             |              | primary key | System generated                              |
| LANG           | CHARACTER(2) | not null    | "EN" or "ES"                                  |
| SURNAME        | VARCHAR(30)  | not null    | English: Last Name, Spanish: Primer Apellido  |
| FIRST_NAME     | VARCHAR(30)  | not null    | English: First Name, Spanish: Primer Nombre   |
| MIDDLE_NAME    | VARCHAR(30)  | null        | English: Middle Name, Spanish: Segundo Nombre |
| ADDL_NAME      | VARCHAR(30)  | null        | English: N/A, Spanish: Segundo Apellido       |
| EMAIL_ADDR     | VARCHAR(40)  | not null    | Email address                                 |
| LAST_CONTACT   | DATE         | null        | Date of latest mailout                        |
| LAST_RESPONSE  | DATE         | null        | Date of latest response                       |
| DO_NOT_CONTACT | CHARACTER(1) | null        | "X" do not send, "P" pending request, or null |

#### Batch Job #1 - Ingest Data Feeds

The first batch job will comprise several steps to read data feeds in different formats, reformat them into a common format, normalize the names, sort the records and merge the files before updating the system of record with new and modified contact information. The number of job steps will depend on how you choose to design the solution.

![Fig. 1: Ingest data feeds (overview)](Pictures/Mailout_Fig_1.png)

The first few steps of the job must read the three data feeds and sort them.

![Fig. 2: Read and sort 3 data feeds](pictures/Mailout_Fig_2.png)

_Data Feed #1_

Upload `capstone/Mailout_Data_Feed_1.txt` as `<userid>.INNOV.FEED1`.

Data set type: PS (sequential)

Record format: Fixed, blocked

Logical record length: 133

Block size: Your choice

Record layout:

| Positions | Contents                                                                |
| --------- | ----------------------------------------------------------------------- |
| 1 - 100   | Name - comma-delimited list of tokens. May contain:                     |
|           | first-name, last-name                                                   |
|           | first-name, middle-name, last-name                                      |
|           | primer-nombre, segundo-nombre, primer-apellido, segundo-apellido        |
|           | if blank, it's an error                                                 |
|           | if it contains fewer than 2 tokens or more than 4 tokens, it's an error |
| 101 - 132 | Email Address - could be invalid                                        |
| 133 - 133 | Do Not Contact requested - any non-blank value                          |

This format contains no language indicator. Normalization logic must guess based on the number of tokens in the Name field

_Data Feed #2_

Upload `capstone/Mailout_Data_Feed_2.txt` as `<userid>.INNOV.FEED2`.

Data set type: PS (sequential)

Record format: Fixed, blocked

Logical record length: 154

Block size: Your choice

Record layout:

| Positions | Contents                                                                 |
| --------- | ------------------------------------------------------------------------ |
| 1 - 40    | Email address - could be invalid                                         |
| 41 - 70   | Last name or primer apellido                                             |
| 71 -100   | First name or primer nombre                                              |
| 101 -130  | Middle name or segundo nombre or blank                                   |
| 131 - 150 | "Jr." or segundo apellido or blank                                       |
| 151 - 152 | Do Not Contact - "N" or blank                                            |
| 153 - 154 | Language code - "EN", "ES", or an erroneous value. If blank assume "EN". |

_Data Feed #3_

Upload `capstone/Mailout_Data_Feed_3.txt` as `<userid>.INNOV.FEED3`.

Data set type: PS (sequential)

Record format: Fixed, blocked

Logical record length: 151

Block size: Your choice

Record layout:

| Positions | Contents                                                                                                                                                       |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 - 40    | Last name or primer apellido                                                                                                                                   |
| 41 - 80   | First name or primer nombre                                                                                                                                    |
| 81 - 120  | Middle name or segundo nombre or "STOP" in positions 81 - 84. "STOP" is a request not to contact. In that case, middle name or segundo nombre is not provided. |
| 121 - 150 | Email address - could be invalid                                                                                                                               |
| 151 - 151 | Language code - "1" = English, "2" = Spanish. Could be invalid. Blank is an error.                                                                             |

_Common Input Format (Result of reformatting)_

Data set type: PS (sequential)

Record format: Fixed, blocked

Logical record length: 143

Block size: Your choice

Record layout:

| Positions | Contents                                                                                                                                                                                            |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 - 100   | Name as a single field with name elements in the same order as in Data Feed format #1, separated by one or more spaces. Name elements that contain embedded spaces are encloded in quotation marks. |
| 101 - 102 | Language code - "EN" = English, "ES" - Spanish, blank = undetermined                                                                                                                                |
| 103 - 142 | Email address                                                                                                                                                                                       |
| 143 - 143 | Do Not Contact requested - "R". Otherwise blank                                                                                                                                                     |

![Fig. 3: Rationalize names and guess the language if it is undetermined](pictures/Mailout_Fig_3.png)

Write a COBOL program to clean up the input data and write good records to a Generation Data Set. Write "bad" records to an error file.

For records with blanks in the language code field, guess the language based on the number of tokens in the name field. If there are four tokens, assume Spanish. Otherwise, assume English.

![Fig. 4: Apply updates to the system of record data store](pictures/Mailout_Fig_4.png)

Update either the VSAM KSDS or DB2 CONTACTS table based on the sorted, merged, and rationalized input data.

Records that match on both email address and surname are deemed to be duplicates.

Our policy regarding "do not contact" indicators:

We do not set "do not contact" when we first receive a contact through our external suppliers.
If the inbound record matches an existing contact in our system of record, then we check the "do not contact" request field in the input record. Our policy is not to set the "do not contact" indicator until the contact requests it twice. First time, we set it to "P"; second time, to "X".

| Input: DNC Requested | System of Record Current Value | System of Record New Value |
| -------------------- | ------------------------------ | -------------------------- |
| R                    | X                              | no change                  |
| R                    | P                              | X                          |
| R                    | not set                        | P                          |
| blank                | any                            | no change                  |

#### Batch Job #2 - Montly mailout job

![Fig. 5: Monthly mailout job overview](pictures/Mailout_Fig_5.png)

![Fig. 6: Monthly mailout job overview](pictures/Mailout_Fig_6.png)

![Fig. 7: Monthly mailout job overview](pictures/Mailout_Fig_7.png)

#### CICS application to query the system of record

If your bootcamp curriculum included CICS application development, then develop a BMS mapset and COBOL program to browse the system of record back end data store (either VSAM KSDS or DB2) and display the records.

![Fig. : CICS application](pictures/Mailout_Fig_8.png)

It is not mandatory to write an update application for CICS, but feel free if you wish.


SETUP INSTRUCTIONS:

1) Go into spufi and run sql(CRTCON.sql). This will setup the contacts table and populate it with the initial seed data.
NOTE: for the first time running CRTCON the "DROP TABLE" at the top will need to be commented out or removed.

2) Use DCLGEN to generate a DCLGEN for the contacts table. Find that file and add null indicators for:
MIDDLE_NAME
ADDL_NAME
LAST_CONTACT
LAST_RESPONSE
DO_NOT_CONTACT

3) Run FEEDC to read all input sources into CAP.COMMON. Some of the normalization for data happens in this step to ensure that record lengths match. CAP.COMMON is then sorted into a GDG called CAP.SORTED

4) Run RATIOC to normalize and validate the data in CAP.SORTED. This produces another GDG and GDS called CAP.CLEAN.

5) Run UPDATEC. This populates the contacts table with all the new cleaned contacts from the CAP.CLEAN GDG.

6) Before we send mailouts we need to determine who we can still contact based on the Do not contact setting and last contact date of our clients. running SELCONC will produce CAP.SEND which contains a list of all the individuals we will reach out to.

7) Now we are ready to send email. Run SENDMC. This runs a program that will read each email in CAP.SEND and call a subprogram to send emails to each.



8) compile and bind CAPVIEW, CAPUPD, 
Compile `<userid>.CAP.SOURCE(CAPVIEW)` with `<userid>.CAP.JOBLIB(DB2CICS)` and bind it with `<userid>.CAP.JOBLIB(DB2B)`, binding program `CAPVIEW` with plan `MATEGDA'.
Compile the mapset `<userid>.CAP.MAPLIB(CAPVMSD)`. 
Define and install `<userid>.CAP.SOURCE(CAPVIEW)`and`<userid>.CAP.MAPLIB(CAPVMSD)`.
Define and install transaction `MGD1`with reference to`<userid>.CAP.SOURCE(CAPVIEW)`.
Define and install DB2entry `MGDENT1`and DB2tran`MGDTRN1`, linking the two. Make sure to connet `MGDENT1`with plan`MATEGDA`and`MGDTRN1`with transaction`MGD1`. 
Set programs `CAPVIEW`and`CAPVMSD`.
Run transaction `MGD1` to display the records in the table.


SETUP FOR CICS and DB2
