/*******************************************************************
* Client: ROSHE                                                           
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
libname adam  "E:\ROSHE\ADAM DATASETS ";
libname sdtm  "E:\ROSHE\SDTM DATASETS ";
OPTIONS NOFMTERR;
LIBNAME RAW  "E:\ROSHE\RAW DATASETS ";

DATA nl;
LENGTH  tuorres $200 tutestcd $8 
			tutest $40;
	SET raw.nl(where=(newles_dec^='No'));
	TUTESTCD='TUMIDENT';
	TUTEST='Tumor Identification';
	TUORRES='NEW';
RUN;

DATA NL_1;
SET nl (RENAME=(SITE1_DEC=TULOC mod1_dec=TUMETHOD imgdat1=TUDTC1 lesid1_dec=TULNKID))
 nl (RENAME=(SITE2_DEC=TULOC mod2_dec=TUMETHOD imgdat2=TUDTC1 lesid2_dec=TULNKID))
 nl (RENAME=(SITE3_DEC=TULOC mod3_dec=TUMETHOD imgdat3=TUDTC1 lesid3_dec=TULNKID))
 nl (RENAME=(SITE4_DEC=TULOC mod4_dec=TUMETHOD imgdat4=TUDTC1 lesid4_dec=TULNKID))
  nl (RENAME=(SITE5_DEC=TULOC mod5_dec=TUMETHOD imgdat5=TUDTC1 lesid5_dec=TULNKID))
 nl (RENAME=(SITE6_DEC=TULOC mod6_dec=TUMETHOD imgdat6=TUDTC1 lesid6_dec=TULNKID))
 nl (RENAME=(SITE7_DEC=TULOC mod7_dec=TUMETHOD imgdat7=TUDTC1 lesid7_dec=TULNKID))
  nl (RENAME=(SITE8_DEC=TULOC mod8_dec=TUMETHOD imgdat8=TUDTC1 lesid8_dec=TULNKID))
 nl (RENAME=(SITE9_DEC=TULOC mod9_dec=TUMETHOD imgdat9=TUDTC1 lesid9_dec=TULNKID))
 nl (RENAME=(SITE10_DEC=TULOC mod10_dec=TUMETHOD imgdat10=TUDTC1 lesid10_dec=TULNKID));
 *IF TULOC NE '';
RUN;



DATA ntl;
LENGTH  tuorres $200 tutestcd $8 
			tutest $40;
	SET 
		raw.ntl(where=(ntlperf_dec^=''));
	TUTESTCD='TUMIDENT';
	TUTEST='Tumor Identification';
	TUORRES='NON-TARGET';
	RUN;

DATA ntl_1;
SET ntl (RENAME=(SITE1_DEC=TULOC mod1_dec=TUMETHOD imgdat1=TUDTC1 lesid1_dec=TULNKID))
 ntl (RENAME=(SITE2_DEC=TULOC mod2_dec=TUMETHOD imgdat2=TUDTC1 lesid2_dec=TULNKID))
 ntl (RENAME=(SITE3_DEC=TULOC mod3_dec=TUMETHOD imgdat3=TUDTC1 lesid3_dec=TULNKID))
 ntl (RENAME=(SITE4_DEC=TULOC mod4_dec=TUMETHOD imgdat4=TUDTC1 lesid4_dec=TULNKID))
  ntl (RENAME=(SITE5_DEC=TULOC mod5_dec=TUMETHOD imgdat5=TUDTC1 lesid5_dec=TULNKID))
 ntl (RENAME=(SITE6_DEC=TULOC mod6_dec=TUMETHOD imgdat6=TUDTC1 lesid6_dec=TULNKID))
 ntl (RENAME=(SITE7_DEC=TULOC mod7_dec=TUMETHOD imgdat7=TUDTC1 lesid7_dec=TULNKID))
  ntl (RENAME=(SITE8_DEC=TULOC mod8_dec=TUMETHOD imgdat8=TUDTC1 lesid8_dec=TULNKID))
 ntl (RENAME=(SITE9_DEC=TULOC mod9_dec=TUMETHOD imgdat9=TUDTC1 lesid9_dec=TULNKID))
 ntl (RENAME=(SITE10_DEC=TULOC mod10_dec=TUMETHOD imgdat10=TUDTC1 lesid10_dec=TULNKID));

RUN;

DATA tl;
LENGTH  tuorres $200 tutestcd $8 
			tutest $40;
	SET 
		raw.tl(where=(tlperf_dec^=''));
	TUTESTCD='TUMIDENT';
	TUTEST='Tumor Identification';
	TUORRES='TARGET';
	RUN;

	
DATA tl_1;
SET tl (RENAME=(SITE1_DEC=TULOC mod1_dec=TUMETHOD imgdat1=TUDTC1 lesid1_dec=TULNKID))
 tl (RENAME=(SITE2_DEC=TULOC mod2_dec=TUMETHOD imgdat2=TUDTC1 lesid2_dec=TULNKID))
 tl (RENAME=(SITE3_DEC=TULOC mod3_dec=TUMETHOD imgdat3=TUDTC1 lesid3_dec=TULNKID))
 tl (RENAME=(SITE4_DEC=TULOC mod4_dec=TUMETHOD imgdat4=TUDTC1 lesid4_dec=TULNKID))
  tl (RENAME=(SITE5_DEC=TULOC mod5_dec=TUMETHOD imgdat5=TUDTC1 lesid5_dec=TULNKID))
 ;

RUN;

DATA tu5;
	LENGTH usubjid visit $40 tustresc tueval $200;
	SET nl_1 (drop=lesid:)
		ntl_1 (drop=lesid:)
		tl_1 (drop=lesid:); 
		
STUDYID= "043-18101";
DOMAIN='TU';
USUBJID= "043-18101-"||SUBNUM;
	TUSTRESC=tuorres;
	TUEVAL='INVESTIGATOR';
	 IF TULOC NE '';
	 visit=VISNAME;
	 visitnum=VISITID;
	 TUDTC=PUT(TUDTC1,yymmdd10.);
	
RUN;


DATA DM1;
SET SDTM.DM;
RFSTDTN = DATEPART (INPUT (RFSTDTC,??IS8601DT.));
FORMAT RFSTDTN DATE9.;

KEEP USUBJID RFSTDTC RFSTDTN;
RUN;

PROC SORT DATA=DM1;BY USUBJID;RUN;
PROC SORT DATA=tu5;BY USUBJID;RUN;

DATA DM_TU;
MERGE DM1 (IN=A) tu5 (IN=B);
BY USUBJID;
IF A AND B;

RUN;



DATA DM_TU2;
SET DM_TU;

IF TUDTC1 > . AND RFSTDTN > . THEN DO;

IF TUDTC1 >= RFSTDTN THEN TUDY=TUDTC1-RFSTDTN +1;
ELSE IF TUDTC1 < RFSTDTN THEN TUDY=TUDTC1-RFSTDTN;
END;


RUN;

*SEQ;;
PROC SORT DATA=DM_TU2;
	BY STUDYID USUBJID TUTESTCD TULNKID TUEVAL TUDTC VISITNUM;
RUN;

DATA tu6;
	SET DM_TU2;
	BY STUDYID USUBJID TUTESTCD TULNKID TUEVAL TUDTC VISITNUM;
	IF first.usubjid THEN tuSEQ=1;
		ELSE tuSEQ+1;

	LABEL
	STUDYID	='Study Identifier'
	DOMAIN	='Domain Abbreviation'
	USUBJID	='Unique Subject Identifier'
	TUSEQ	='Sequence Number'
	TULNKID	='Link ID'
	TUTESTCD	='Tumor Identification Short Name'
	TUTEST	='Tumor Identification Test Name'
	TUORRES	='Tumor Identification Result'
	TUSTRESC	='Tumor Identification Result Std. Format'
	TULOC	='Location of the Tumor'
	TUMETHOD	='Method of Identification'
	TUEVAL	='Evaluator'
	VISITNUM	='Visit Number'
	VISIT	='Visit Name'
	TUDTC	='Date/Time of Tumor Identification'
	TUDY	='Study Day of Tumor Identification'
	;
RUN;

PROC SQL NOPRINT;
	CREATE TABLE SDTM.TU_(label='Tumor Identification') as
		SELECT STUDYID, DOMAIN, USUBJID, TUSEQ, TULNKID, TUTESTCD, 
TUTEST, TUORRES, TUSTRESC, TULOC, TUMETHOD, TUEVAL,
				VISITNUM, VISIT,  TUDTC, TUDY
	FROM TU6
	ORDER BY STUDYID, USUBJID, TUTESTCD, TULNKID, TUEVAL, TUDTC, VISITNUM;
QUIT;
