/*******************************************************************
* Client: ROSHE2                                                           
* adamuct:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: ADSL.SAS  
*
* Program Type: ADaM
*
* Purpose: To adamuce the 
ADSL

* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 29 AUG 2020
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

DATA mh;
    FORMAT astdt aendt date9.;
	LENGTH astdtf aendtf  $200;
	SET sdtm.mh;
/*2018-04*/
	IF length(mhstdtc)=7 THEN DO;
		astdtc=STRIP(mhstdtc)||'-01';
		ASTDTF='D';
	END;
		ELSE IF LENGTH(mhstdtc)=4 THEN DO;
			astdtc=STRIP(mhstdtc)||'-01-01';
			ASTDTF='M';
		END;

/*2018-02*/
	IF length(mhendtc)=7 THEN DO;
		IF SUBSTR(mhendtc,6,2)='02' THEN aendtc=STRIP(mhendtc)||'-28';
			ELSE IF SUBSTR(mhendtc,6,2) in ('01' '03' '05' '07' '08' '10' '12') THEN aendtc=STRIP(mhendtc)||'-31';
			ELSE aendtc=STRIP(mhendtc)||'-30';
		AENDTF='D';
	END;



		ELSE IF LENGTH(mhendtc)=4 THEN DO;
			aendtc=STRIP(mhendtc)||'-12-31';
			AENDTF='M';
		END;
	IF length(mhstdtc)=10 THEN ASTDT=INPUT(mhstdtc,is8601da.);
		ELSE IF astdtc^='' THEN ASTDT=INPUT(astdtc,is8601da.);
		ELSE ASTDT=.;
	IF length(mhendtc)=10 THEN AENDT=INPUT(mhendtc,is8601da.);
		ELSE IF aendtc^='' THEN AENDT=INPUT(aendtc,is8601da.);
		ELSE AENDT=.;


	ASEQ=mhseq;

	KEEP usubjid aseq astdt astdtf aendt aendtf mhterm mhllt mhlltcd mhdecod mhptcd mhhlt mhhltcd mhhlgt mhhlgtcd 
			mhcat mhbodsys mhbdsycd mhsoc mhsoccd visitnum visit epoch mhstdtc mhendtc mhstdy mhendy mhstrf mhenrf
		 astdt aendt astdtf aendtf ;
RUN;

DATA admh1;
	MERGE adsl
		  mh(in=a);
	BY usubjid;
	IF a;
	IF ASTDT NE . THEN DO;
IF astdt>=trtsdt THEN ASTDY=astdt-trtsdt+1;
		ELSE ASTDY=astdt-trtsdt;
		END;

	IF aendt NE . THEN DO;
IF aendt>=trtsdt THEN AENDY=aendt-trtsdt+1;
		ELSE AENDY=aendt-trtsdt;
		END;
RUN;

DATA admh2;
	SET admh1;

	LABEL 
	STUDYID ='Study Identifier'
	USUBJID	='Unique Subject Identifier'
	SUBJID	='Subject Identifier for the Study'
	SITEID	='Study Site Identifier'
	SAFFL	='Safety Population Flag'
	DLTEVLFL	='DLT Evaluable Population Flag'
	PKEVLFL	='PK Evaluable Population Flag'
	ENRLFL	='Enrolled Population Flag'
	ARMCD	='Planned Arm Code'
	ARM	='Description of Planned Arm'
	ACTARMCD	='Actual Arm Code'
	ACTARM	='Description of Actual Arm'
	TRTP	='Planned Treatment'
	TRTPN	='Planned Treatment (N)'
	ASEQ	='Analysis Sequence Number'
	ASTDT	='Analysis Start Date'
	ASTDY	='Analysis Start Relative Day'
	ASTDTF	='Analysis Start Date Imputation Flag'
	AENDT	='Analysis End Date'
	AENDY	='Analysis End Relative Day'
	AENDTF	='Analysis End Date Imputation Flag'
	MHTERM	='Reported Term for the Medical History'
	MHLLT	='Lowest Level Term'
	MHLLTCD	='Lowest Level Term Code'
	MHDECOD	='Dictionary-Derived Term'
	MHPTCD	='Preferred Term Code'
	MHHLT	='High Level Term'
	MHHLTCD	='High Level Term Code'
	MHHLGT	='High Level Group Term'
	MHHLGTCD	='High Level Group Term Code'
	MHCAT	='Category for Medical History'
	MHBODSYS	='Body System or Organ Class'
	MHBDSYCD	='Body System or Organ Class Code'
	MHSOC	='Primary System Organ Class'
	MHSOCCD	='Primary System Organ Class Code'
	VISITNUM	='Visit Number'
	VISIT	='Visit Name'
	EPOCH	='Epoch'
	MHSTDTC	='Start Date/Time of Medical History Event'
	MHENDTC	='End Date/Time of Medical History Event'
	MHSTDY	='Study Day of Start of Observation'
	MHENDY	='Study Day of End of Observation'
	MHSTRF	='Start Relative to Reference Period'
	MHENRF	='End Relative to Reference Period'
	;
RUN;

PROC SQL NOPRINT;
    CREATE TABLE adam.admh_(label='Medical History Analysis Dataset') AS
        SELECT 	STUDYID, USUBJID, SUBJID, SITEID, SAFFL, DLTEVLFL, PKEVLFL, ENRLFL, ARMCD, ARM, ACTARMCD, ACTARM, TRTP, TRTPN, ASEQ, 
				ASTDT, ASTDY, ASTDTF, AENDT, AENDY, AENDTF, MHTERM, MHLLT, MHLLTCD, MHDECOD, MHPTCD, MHHLT, MHHLTCD, MHHLGT, MHHLGTCD,
				MHCAT, MHBODSYS, MHBDSYCD, MHSOC, MHSOCCD, VISITNUM, VISIT, EPOCH, MHSTDTC, MHENDTC, MHSTDY, MHENDY, MHSTRF, MHENRF
		FROM admh2
		ORDER BY STUDYID, USUBJID, ASEQ;
QUIT;
