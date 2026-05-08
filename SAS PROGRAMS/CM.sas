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


DATA ac;
	LENGTH cmtrt cmcat cmscat cmdecod cmclas cmclascd 
 $200  cmstdtc cmendtc $19;
	SET raw.ac(where=(pagename='Anticancer Therapy'));
	CMCAT='ANTICANCER THERAPY';
	CMSCAT=actyp_dec;
	CMTRT=actrt;
	CMSTDTC= PUT (INPUT (acstdat,??YYMMDD10.),YYMMDD10.);
	CMENDTC= PUT (INPUT (acendat,??YYMMDD10.),YYMMDD10.);

	CMDECOD=preferred_name;
	CMCLAS=drug_name;
	CMCLASCD=code;
RUN;

DATA cm1;
	LENGTH cmtrt cmcat cmindc cmdostxt cmdosu cmdosfrq cmroute
 cmenrf cmdecod cmclas cmclascd cmrefid $200 
			 cmstdtc cmendtc $19;
	SET raw.cm(where=(pagename='Prior and/or Concomitant Medication(s)') 
rename=(cmtrt=cmtrtx cmindc=cmindcx
				cmdosu=cmdosux cmdosfrq=cmdosfrqx cmroute=cmroutex
cmseq=cmseqx));

	CMCAT='PRIOR AND/OR CONCOMITANT MEDICATION';
/*	CMREFID=STRIP(PUT(cmseqx,??best.));*/
	CMTRT=cmtrtx;
	CMINDC=cmindcx;

	CMSTDTC= PUT (INPUT (cmstdat,??YYMMDD10.),YYMMDD10.);
	CMENDTC= PUT (INPUT (cmendat,??YYMMDD10.),YYMMDD10.);

	IF cmongo_dec='Yes' THEN CMENRF='ONGOING';

                     CMDOSE=INPUT(cmdstxt,??best.);
    IF cmdose=. THEN CMDOSTXT=cmdstxt;
	CMDOSU=cmdosu_dec;


	CMDOSFRQ=cmdosfrq_dec;
	CMROUTE=cmroute_dec;

	CMDECOD=preferred_name;
	CMCLAS=drug_name;
	CMCLASCD=code;
RUN;

DATA CM2;
	LENGTH usubjid $40;
	SET ac
		CM1;
STUDYID="043-18101";
DOMAIN="CM";
USUBJID="043-18101-"||SUBNUM;
CMSTDTN = INPUT (CMstdat,??YYMMDD10.);
CMENDTN = INPUT (CMendat,??YYMMDD10.);

RUN;


DATA DM1;
SET SDTM.DM;
RFSTDTN = DATEPART (INPUT (RFSTDTC,??IS8601DT.));
FORMAT RFSTDTN DATE9.;

KEEP USUBJID RFSTDTC RFSTDTN;
RUN;

PROC SORT DATA=DM1;BY USUBJID;RUN;
PROC SORT DATA=CM2;BY USUBJID;RUN;

DATA DM_CM;
MERGE DM1 (IN=A) CM2 (IN=B);
BY USUBJID;
IF A AND B;
RUN;



DATA cm5;
SET DM_CM;

IF CMSTDTN > . AND RFSTDTN > . THEN DO;

IF CMSTDTN >= RFSTDTN THEN CMSTDY=CMSTDTN-RFSTDTN +1;
ELSE IF CMSTDTN < RFSTDTN THEN CMSTDY=CMSTDTN-RFSTDTN;
END;


IF CMENDTN > . AND RFSTDTN > . THEN DO;

IF CMENDTN >= RFSTDTN THEN CMENDY=CMENDTN-RFSTDTN +1;
ELSE IF CMENDTN < RFSTDTN THEN CMENDY=CMENDTN-RFSTDTN;
END;

CMDUR1= CMENDY-CMSTDY +1;
CMDUR =COMPRESS ( "P "||PUT (CMDUR1,BEST.)|| "D ");
IF CMDUR= "P.D " THEN CMDUR='';
RUN;



*SEQ;;
PROC SORT DATA=cm5;
	BY STUDYID USUBJID CMTRT CMSTDTC CMDOSE;
RUN;

DATA cm6;
	SET cm5;
	BY STUDYID USUBJID CMTRT CMSTDTC CMDOSE;
	IF first.usubjid THEN CMSEQ=1;
		ELSE CMSEQ+1;

	LABEL
	STUDYID	='Study Identifier'
	DOMAIN	='Domain Abbreviation'
	USUBJID	='Unique Subject Identifier'
	CMSEQ	='Sequence Number'
	CMREFID	='Reference ID'
	CMTRT	='Reported Name of Drug, Med, or Therapy'
	CMDECOD	='Standardized Medication Name'
	CMCAT	='Category for Medication'
	CMSCAT	='Subcategory for Medication'
	CMINDC	='Indication'
	CMCLAS	='Medication Class'
	CMCLASCD	='Medication Class Code'
	CMDOSE	='Dose per Administration'
	CMDOSTXT	='Dose Description'
	CMDOSU	='Dose Units'
	CMDOSFRQ	='Dosing Frequency per Interval'
	CMROUTE	='Route of Administration'
	CMSTDTC	='Start Date/Time of Medication'
	CMENDTC	='End Date/Time of Medication'
	CMSTDY	='Study Day of Start of Medication'
	CMENDY	='Study Day of End of Medication'
	CMENRF	='End Relative to Reference Period'
	;
RUN;

PROC SQL NOPRINT;
	CREATE TABLE sdtm.CM_(label='Concomitant Medications') as
		SELECT STUDYID, DOMAIN, USUBJID, CMSEQ, CMREFID, CMTRT, CMDECOD, CMCAT, CMSCAT, CMINDC, CMCLAS, CMCLASCD, 
				CMDOSE, CMDOSTXT, CMDOSU, CMDOSFRQ, CMROUTE,  CMSTDTC, CMENDTC, CMSTDY, CMENDY, 
				 CMENRF
	FROM CM6
	ORDER BY STUDYID, USUBJID, CMTRT, CMSTDTC, CMDOSE;
QUIT;

%macro suppvar(nam, label, val, orig);
	IF STRIP(&val.) ^in ('' '.') THEN DO;
		QNAM=&nam.;
		QLABEL=&label.;
		QVAL=&val.;
		QORIG=&orig.;

		OUTPUT;

	END;
%mend suppvar;
*SUPPCM;;
DATA suppCM1;
	LENGTH IDVAR QORIG QNAM $8 QLABEL QEVAL $40 IDVARVAL QVAL $200;
	SET cm6;
	RDOMAIN='CM';
	IDVAR='CMSEQ';
	IDVARVAL=STRIP(cmseq);
	QEVAL='INVESTIGATOR';

	%suppvar('TYPEOSP', 'Therapy Type, Other Specify', actypoth, 'CRF');
	%suppvar('TRGTTYPE', 'Targeted Therapy, Other Specify', actgtoth, 'CRF');
	%suppvar('LINETHPY', 'Line of Therapy', acline_dec, 'CRF');
	%suppvar('EXTENT', 'Extent of Disease at Time of Therapy', acextnt_dec, 'CRF');
	%suppvar('CYCLE', 'Cycles', accycle, 'CRF');
	%suppvar('CYCLE', 'Cycles', accycna_dec, 'CRF');
	%suppvar('BEST', 'Best Overall Response', acbest_dec, 'CRF');
	%suppvar('REASONTD', 'Reason Therapy Discontinued', acdisc_dec, 'CRF');
	%suppvar('DISCOSP', 'Reason Therapy Discontinued, Other Spec', acdiscoth, 'CRF');
	%suppvar('CMDOSUO', 'Dose Units, Specify', cmdosusp, 'CRF');
	%suppvar('CMDOSFRO', 'Frequency, Specify', cmdosfrqsp, 'CRF');
	%suppvar('CMROUTEO', 'Route, Specify', cmroutesp, 'CRF');
	%suppvar('PTCD', 'Preferred Term Code', preferred_code, 'CRF');
	%suppvar('CODE4', 'ATC Code 4', code4, 'CRF');
	%suppvar('TEXT4', 'ATC 4', text4, 'CRF');
	%suppvar('CODE3', 'ATC Code 3', code3, 'CRF');
	%suppvar('TEXT3', 'ATC 3', text3, 'CRF');
	%suppvar('CODE2', 'ATC Code 2', code2, 'CRF');
	%suppvar('TEXT2', 'ATC 2', text2, 'CRF');
	%suppvar('CODE1', 'ATC Code 1', code1, 'CRF');
	%suppvar('TEXT1', 'ATC 1', text1, 'CRF');
RUN;
PROC SORT DATA = SUPPCM1; 
	BY STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM;
RUN;

DATA SUPPCM2;
    SET SUPPCM1;

	LABEL STUDYID = 'Study Identifier'
	      RDOMAIN = 'Related Domain Abbreviation'
		  USUBJID = 'Unique Subject Identifier'
		  IDVAR = 'Identifying Variable'
		  IDVARVAL = 'Identifying Variable Value'
		  QNAM = 'Qualifier Variable Name'
		  QLABEL = 'Qualifier Variable Label'
		  QVAL = 'Data Value'
		  QORIG = 'Origin'
		  QEVAL = 'Evaluator'
	;
RUN;

PROC SQL;
	CREATE TABLE sdtm.SUPPCM_ (label = 'Supplemental Qualifiers for CM') AS
	SELECT STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM, QLABEL, QVAL, QORIG, QEVAL
	       FROM SUPPCM2;
QUIT;
 
