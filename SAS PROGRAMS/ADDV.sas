/*******************************************************************
* Client: XXXX                                                           
* Product: XXXXX                                                  
* Project: Protocol: 043-1810                                                    
* Program: ADDV.sas 
*
* Program Type: ADaM
*
* Purpose: To produce the ADDV
* Usage Notes: 
*
* SAS® Version: 9.4 [TS2M0]
* Operating System: Windows 2003 R2 Standard Edition.                   
*
* Author: shiva 
* Date Created: 13 OCT 2020
*******************************************************************/

libname adam "E:\ROSHE2\ADAM DATASETS";	
libname SDTM "E:\ROSHE2\SDTM DATASETS";	

******READING ADSL DATASET****************;

PROC SORT DATA=ADAM.ADSL OUT=ADSL ;BY USUBJID;RUN;


******************COPY ALL THE VARIABLES FROM SDTM DM***********;

DATA DV0;
SET SDTM.DV;
RUN;

PROC SORT;BY USUBJID DVSEQ;RUN;



************HANDLING OF SUPP-- DATASET****************;

DATA SUPPDV0;
SET SDTM.SUPPDV;
DVSEQ= INPUT (IDVARVAL,BEST.);
RUN;
PROC SORT;BY USUBJID DVSEQ;RUN;

PROC TRANSPOSE DATA=SUPPDV0 OUT=T_SUPPDV0 (DROP=_NAME_ _LABEL_);
BY USUBJID DVSEQ;
ID QNAM;
IDLABEL  QLABEL;
VAR QVAL;
RUN;

DATA DV1;
MERGE DV0 T_SUPPDV0;
BY USUBJID DVSEQ;
RUN;


DATA DV2;
MERGE DV1 (IN=A) ADSL (IN=B);
BY USUBJID;
IF A;
/*2019-05-16*/
IF LENGTH (DVSTDTC) >=10 THEN
ASTDT= INPUT (SUBSTR (DVSTDTC,1,10),YYMMDD10.);

IF ASTDT NE . AND TRTSDT NE . THEN DO;
/*ASTDT=11APR1989*/
/*TRTSDT=10APR1989*/

IF ASTDT >= TRTSDT THEN ASTDY=(ASTDT-TRTSDT+1);
ELSE ASTDY=(ASTDT-TRTSDT);
END;

IF DVSEQ NE . THEN ASEQ = DVSEQ;

TRTP=TRT01P;
TRTPN=TRT01PN;
TRTA=ACTARMCD;

AVISIT=VISIT;
AVISITN=VISITNUM;
RUN;

data dv3;
 attrib
STUDYID  length= $200 label="Study Identifier"
USUBJID  length= $200  label="Unique Subject Identifier"
SUBJID   length= $200 label="Subject Identifier for the Study"
SITEID   length= $200 label="Study Site Identifier"
DLTEVLFL length= $200 label="DLT Evaluation Population Flag"
PKEVLFL  length= $200 label="PK Evaluable Population Flag"
ENRLFL   length= $200 label="Enrolled Population Flag"
ARMCD    length= $200 label="Planned Arm Code"
ARM      length= $200 label="Description of Planned Arm"
ACTARMCD length= $200 label="Actual Arm Code"
ACTARM   length= $200 label="Description of Actual Arm"
TRTP     length= $200 label="Planned Treatment" 
TRTPN    length= 8 label="Planned Treatment (N)" 
/*TRTA     length= $200 label="Actual Treatment"*/
ASEQ     length= 8 label="Analysis Sequence Number"
ASTDT       label="Analysis Start Date"
ASTDY    length= 8   label="Analysis Start Relative Day"
AVISITN length= 8   label="Analysis Visit Number"
AVISIT    length= $40  label="Analysis Visit Name"
DVSEQ    length= 8   label="Sequence Number"
DVTERM    label="Protocol Deviation Term"
DVTERM1   label="Protocol Deviation Term 01"
DVCAT    length= $200 label="Category for Protocol Deviation"
VISITNUM length= 8   label="Visit Number"
VISIT    length= $40  label="Visit Name"
EPOCH    length= $40  label="Epoch"
DVSTDTC    label="Start Date/Time of Deviation"
DVSTDY   length= 8   label="Study Day of Start of Deviation"
;

set dv2;

keep STUDYID USUBJID SUBJID SITEID SAFFL DLTEVLFL PKEVLFL ENRLFL ARMCD ARM ACTARMCD
     ACTARM TRTP TRTPN ASEQ ASTDT ASTDY AVISIT AVISITN DVSEQ DVTERM DVTERM1 DVCAT VISITNUM VISIT 
     EPOCH DVSTDTC DVSTDY;

run;

proc sort data=dv3 out=ADAM.ADDV_(label="Protocol Deviation Dataset") ;
 by usubjid aseq;
run;












