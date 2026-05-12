/*******************************************************************
* Client: ROSHE2                                                           
* adamuct:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: DM.SAS  
*
* Program Type: SDTM
*
* Purpose: To DEVLOP THE SDTM DM
* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 25 SEP 2020
*******************************************************************/	
libname adam  "E:\ROSHE2\ADAM DATASETS ";
libname sdtm  "E:\ROSHE2\SDTM DATASETS ";
OPTIONS NOFMTERR;
LIBNAME RAW  "E:\ROSHE2\RAW DATASETS ";


DATA dh;
	LENGTH mhterm mhcat   mhstdtc $19;
	SET raw.dh;
	MHCAT='DISEASE HISTORY';

MHSTDTC= PUT (INPUT (dxdat,??YYMMDD10.),YYMMDD10.);
	MHTERM=tumortyp;
RUN;


DATA mh1;
	LENGTH mhterm mhllt mhdecod mhhlt mhhlgt mhcat mhbodsys 
mhsoc  mhenrf $200  mhstdtc mhendtc $19;
	SET raw.mh(where=(pagename='Medical History')
rename=(mhterm=mhtermx));
	MHCAT='MEDICAL HISTORY';
	MHTERM=mhtermx;


	MHSTDTC= PUT (INPUT (mhstdat,??YYMMDD10.),YYMMDD10.);

	IF mhongo_dec='Yes' THEN MHENRF='ONGOING';

	MHENDTC= PUT (INPUT (mhendat,??YYMMDD10.),YYMMDD10.);

	MHLLT=llt_name;
	MHLLTCD=INPUT(llt_code,??best.);
	MHDECOD=pt_term;
	MHPTCD=INPUT(pt_code,??best.);
	MHHLT=hlt_term;
	MHHLTCD=INPUT(hlt_code,??best.);
	MHHLGT=hlgt_term;
	MHHLGTCD=INPUT(hlgt_code,??best.);
	MHBODSYS=soc_term;
	MHBDSYCD=INPUT(soc_code,??best.);
	MHSOC=soc_term;
	MHSOCCD=INPUT(soc_code,??best.);
RUN;


DATA mh2;
	LENGTH usubjid $40;
	SET 
		mh1 dh;
STUDYID="043-18101";
DOMAIN="MH";
USUBJID="043-18101-"||SUBNUM;
MHSTDTN = INPUT (mhstdat,??YYMMDD10.);
MHENDTN = INPUT (mhendat,??YYMMDD10.);

RUN;	


DATA DM1;
SET SDTM.DM;
RFSTDTN = DATEPART (INPUT (RFSTDTC,??IS8601DT.));
FORMAT RFSTDTN DATE9.;

KEEP USUBJID RFSTDTC RFSTDTN;
RUN;

PROC SORT DATA=DM1;BY USUBJID;RUN;
PROC SORT DATA=MH2;BY USUBJID;RUN;

DATA DM_MH;
MERGE DM1 (IN=A) MH2 (IN=B);
BY USUBJID;
IF A AND B;
RUN;



DATA DM_MH2;
SET DM_MH;

IF MHSTDTN > . AND RFSTDTN > . THEN DO;

IF MHSTDTN >= RFSTDTN THEN MHSTDY=MHSTDTN-RFSTDTN +1;
ELSE IF MHSTDTN < RFSTDTN THEN MHSTDY=MHSTDTN-RFSTDTN;
END;


IF MHENDTN > . AND RFSTDTN > . THEN DO;

IF MHENDTN >= RFSTDTN THEN MHENDY=MHENDTN-RFSTDTN +1;
ELSE IF MHENDTN < RFSTDTN THEN MHENDY=MHENDTN-RFSTDTN;
END;

MHDUR1= MHENDY-MHSTDY +1;
MHDUR =COMPRESS ( "P "||PUT (MHDUR1,BEST.)|| "D ");
IF MHDUR= "P.D " THEN MHDUR='';
RUN;
PROC SORT;	BY STUDYID USUBJID MHDECOD MHTERM MHSTDTC;
RUN;

DATA mh6;
	SET DM_MH2;
	BY STUDYID USUBJID MHDECOD MHTERM MHSTDTC;
	IF first.usubjid THEN mhSEQ=1;
		ELSE mhSEQ+1;

	LABEL
	STUDYID	='Study Identifier'
	DOMAIN	='Domain Abbreviation'
	USUBJID	='Unique Subject Identifier'
	MHSEQ	='Sequence Number'
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
	MHSTDTC	='Start Date/Time of Medical History Event'
	MHENDTC	='End Date/Time of Medical History Event'
	MHSTDY	='Study Day of Start of Observation'
	MHENDY	='Study Day of End of Observation'
	MHENRF	='End Relative to Reference Period'
	;
RUN;

PROC SQL NOPRINT;
	CREATE TABLE SDTM.MH_(label='Medical History') as
		SELECT STUDYID, DOMAIN, USUBJID, MHSEQ, MHTERM, MHLLT, MHLLTCD, 
MHDECOD, MHPTCD, MHHLT, MHHLTCD, MHHLGT,
				MHHLGTCD, MHCAT, MHBODSYS, MHBDSYCD, MHSOC, MHSOCCD, 
MHSTDTC, MHENDTC,
				MHSTDY, MHENDY,  MHENRF
	FROM mh6
	ORDER BY STUDYID, USUBJID, MHDECOD, MHTERM, MHSTDTC;
QUIT;

	
