/*******************************************************************
* Client: ROSHE                                                           
* adamuct:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: ADCM.SAS  
*
* Program Type: ADaM
*
* Purpose: To adam 
ADCM

* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 10 SEP 2020
*******************************************************************/	
libname adam "E:\ROSHE2\ADAM DATASETS";
libname sdtm "E:\ROSHE2\SDTM DATASETS";

DATA ADSL;
	LENGTH trtp $200;
	SET adam.adsl;
	TRTP=trt01p;
	TRTPN=trt01pn;
	KEEP studyid usubjid subjid siteid saffl dltevlfl pkevlfl enrlfl armcd arm actarmcd actarm
			trtp trtpn
			trtsdt;
RUN;


DATA CM;
    FORMAT astdt aendt date9.;
	LENGTH astdtf aendtf seq $200;
	SET sdtm.CM;
/*2019-02-01*/
	IF length(CMstdtc)=7 THEN DO;
		astdtc=STRIP(CMstdtc)||'-01';
		ASTDTF='D';
	END;
/*	2019-01-01*/
		ELSE IF LENGTH(CMstdtc)=4 THEN DO;
			astdtc=STRIP(CMstdtc)||'-01-01';
			ASTDTF='M';
		END;
/*.*/

	IF length(CMendtc)=7 THEN DO;
		IF SUBSTR(CMendtc,6,2)='02' THEN aendtc=STRIP(CMendtc)||'-28';
			ELSE IF SUBSTR(CMendtc,6,2)
in ('01' '03' '05' '07' '08' '10' '12') THEN aendtc=STRIP(CMendtc)||'-31';
			ELSE aendtc=STRIP(CMendtc)||'-30';
		AENDTF='D';
	END;
		ELSE IF LENGTH(CMendtc)=4 THEN DO;
			aendtc=STRIP(CMendtc)||'-12-31';
			AENDTF='M';
		END;
/*		2019-02-15*/
	IF length(CMstdtc)=10 THEN ASTDT=INPUT(CMstdtc,is8601da.);
		ELSE IF astdtc^='' THEN ASTDT=INPUT(astdtc,is8601da.);
		ELSE ASTDT=.;
	IF length(CMendtc)=10 THEN AENDT=INPUT(CMendtc,is8601da.);
		ELSE IF aendtc^='' THEN AENDT=INPUT(aendtc,is8601da.);
		ELSE AENDT=.;


	ASEQ=CMseq;

	
RUN;




*****************CM and SUPPCM*************;

DATA CM0;
SET CM;
RUN;
PROC SORT;BY USUBJID CMSEQ;RUN;


***********HANDLING SUPP-- DATASET***********;

DATA SUPPCM0;
SET SDTM.SUPPCM;
CMSEQ = INPUT (IDVARVAL,BEST.);
RUN;
PROC SORT;BY USUBJID CMSEQ;RUN;

PROC TRANSPOSE DATA=SUPPCM0 OUT=T_SUPPCM0 (DROP=_NAME_ _LABEL_);
BY USUBJID CMSEQ;
ID QNAM;
IDLABEL QLABEL;
VAR QVAL;
RUN;

DATA CM1;
MERGE CM0 T_SUPPCM0;
BY USUBJID CMseq;
RUN;

DATA CM1;
MERGE CM1 (IN=B) ADSL (IN=A);
BY USUBJID;
IF A AND B;
RUN;

DATA CM2;
SET CM1;
ATC1=TEXT1;
ATC2=TEXT2;
ATC3=TEXT3;
ATC4=TEXT4;
RUN;


DATA CM3;
	SET CM2;
	
	IF astdt>=trtsdt THEN ASTDY=astdt-trtsdt+1;
		ELSE ASTDY=astdt-trtsdt;
	IF aendt>=trtsdt THEN AENDY=aendt-trtsdt+1;
		ELSE AENDY=aendt-trtsdt;
/*2019-02-13  2019-02-14    2019-02-28*/

IF aendt ^=. AND trtsdt ^=. AND aendt >= trtsdt
OR
CMENRF IN ('ONGOING' 'UNKNOWN') THEN ONTRTFL="Y";
ELSE ONTRTFL="N";

IF aendt ^=. AND trtsdt ^=. AND aendt < trtsdt THEN PREFL="Y";
ELSE PREFL="N";




KEEP STUDYID
USUBJID
SUBJID
SITEID
SAFFL
DLTEVLFL
PKEVLFL
ENRLFL
ARMCD
ARM
ACTARMCD
ACTARM
TRTP
TRTPN
ASTDT
ASTDY
ASTDTF
AENDT
AENDY
AENDTF
ONTRTFL
PREFL
CMSEQ
CMTRT
CMDECOD
ATC1
ATC2
ATC3
ATC4
CMCAT
CMSCAT
CMINDC
CMCLAS
CMCLASCD
CMDOSE
CMDOSTXT
CMDOSU
CMDOSFRQ
CMROUTE
EPOCH
CMSTDTC
CMENDTC
CMSTDY
CMENDY
CMSTRF
CMENRF
LINETHPY

;
RUN;


proc sql noprint;
create table final as
select
STUDYID	label= "Study Identifier" length=	200	,
USUBJID	label="Unique Subject Identifier" length=	200	,
SUBJID	label="Subject Identifier for the Study" length=	200	,
SITEID	label="Study Site Identifier" length=	200	,
SAFFL	label="Safety Population Flag" length=	200	,
DLTEVLFL	label="DLT Evaluable Population Flag" length=	200	,
PKEVLFL	label="PK Evaluable Population Flag" length=	200	,
ENRLFL	label="Enrolled Population Flag" length=	200	,
ARMCD	label="Planned Arm Code" length=	200	,
ARM	    label="Description of Planned Arm" length=	200	,
ACTARMCD	label="Actual Arm Code" length=	200	,
ACTARM	label="Description of Actual Arm" length=	200	,
TRTP	label="Planned Treatment " length=	200	,
TRTPN	label="Planned Treatment (N) " length=	8	,
ASTDT	label="Analysis Start Date" length=	8	,
ASTDY	label="Analysis Start Relative Day" length=	8	,
ASTDTF	label="Analysis Start Date Imputation Flag" length=	8	,
AENDT	label="Analysis End Date" length=	8	,
AENDY	label="Analysis End Relative Day" length=	8	,
AENDTF	label="Analysis End Date Imputation Flag" ,
ONTRTFL	label="On Treatment Record Flag" length=	200	,
PREFL	label="Pre-Treatment Flag" length=	200	,
CMSEQ	label="Sequence Number" ,
CMTRT	label="Reported Name of Drug, Med, or Therapy" length=	200	,
CMDECOD	label="Standardized Medication Name" length=	200	,
ATC1	label="ATC Level 1" length=	200	,
ATC2	label="ATC Level 2" length=	200	,
ATC3	label="ATC Level 3" length=	200	,
ATC4	label="ATC Level 4" length=	200	,
CMCAT	label="Category for Medication" length=	200	,
CMSCAT	label="Subcategory for Medication" length=	200	,
CMINDC	label="Indication" length=	200	,
CMCLAS	label="Medication Class" length=	200	,
CMCLASCD	label="Medication Class Code" length=	200	,
CMDOSE	label="Dose per Administration" ,
CMDOSTXT	label="Dose Description" length=	200	,
CMDOSU	label="Dose Units" length=	200	,
CMDOSFRQ	label="Dosing Frequency per Interval" length=	200	,
CMROUTE	label="Route of Administration" length=	200	,
EPOCH	label="Epoch" length=	40	,
CMSTDTC	label="Start Date/Time of Medication" length=	19	,
CMENDTC	label="End Date/Time of Medication" length=	19	,
CMSTDY	label="Study Day of Start of Medication" ,
CMENDY	label="Study Day of End of Medication" ,
CMSTRF	label="Start Relative to Reference Period" length=	200	,
CMENRF	label="End Relative to Reference Period" length=	200	,
LINETHPY	label="Line of Therapy" length=	200	
from cm3;
quit;


data adam.adcm_ (label="Concomitant Medication Analysis Dataset");
set final;
run;








