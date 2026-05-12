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
	LENGTH trgrpid  trorres trstresc  
 $200 trtestcd $8 trtest $40;
	SET raw.nl(where=(newles_dec^='No'));
	TRTESTCD='TUMSTATE';
	TRTEST='Tumor State';
	TRGRPID='NEW';
	TRORRES='PRESENT';
	TRSTRESC='PRESENT';
	run;
	
DATA NL_1;
SET nl (RENAME=( mod1_dec=TRMETHOD imgdat1=TRDTC1 lesid1_dec=TRLNKID))
 nl (RENAME=( mod2_dec=TRMETHOD imgdat2=TRDTC1 lesid2_dec=TRLNKID))
 nl (RENAME=( mod3_dec=TRMETHOD imgdat3=TRDTC1 lesid3_dec=TRLNKID))
 nl (RENAME=(mod4_dec=TRMETHOD imgdat4=TRDTC1 lesid4_dec=TRLNKID))
  nl (RENAME=( mod5_dec=TRMETHOD imgdat5=TRDTC1 lesid5_dec=TRLNKID))
 nl (RENAME=( mod6_dec=TRMETHOD imgdat6=TRDTC1 lesid6_dec=TRLNKID))
 nl (RENAME=(mod7_dec=TRMETHOD imgdat7=TRDTC1 lesid7_dec=TRLNKID))
  nl (RENAME=( mod8_dec=TRMETHOD imgdat8=TRDTC1 lesid8_dec=TRLNKID))
 nl (RENAME=( mod9_dec=TRMETHOD imgdat9=TRDTC1 lesid9_dec=TRLNKID))
 nl (RENAME=( mod10_dec=TRMETHOD imgdat10=TRDTC1 lesid10_dec=TRLNKID));
 *IF TRLOC NE '';
RUN;


DATA ntl;
	LENGTH  trtestcd $8 trtest $40 trgrpid $200;
	SET raw.ntl(where=(ntlperf_dec^=''))
		;
	TRTESTCD='TUMSTATE';
	TRTEST='Tumor State';
	TRGRPID='NON-TARGET';
	RUN;

DATA ntl_1;
SET ntl (RENAME=( mod1_dec=TRMETHOD imgdat1=TRDTC1 lesid1_dec=TRLNKID status1_dec=TRORRES))
 ntl (RENAME=( mod2_dec=TRMETHOD imgdat2=TRDTC1 lesid2_dec=TRLNKID status2_dec=TRORRES))
 ntl (RENAME=(mod3_dec=TRMETHOD imgdat3=TRDTC1 lesid3_dec=TRLNKID status3_dec=TRORRES))
 ntl (RENAME=( mod4_dec=TRMETHOD imgdat4=TRDTC1 lesid4_dec=TRLNKID status4_dec=TRORRES))
  ntl (RENAME=(mod5_dec=TRMETHOD imgdat5=TRDTC1 lesid5_dec=TRLNKID status5_dec=TRORRES))
 ntl (RENAME=( mod6_dec=TRMETHOD imgdat6=TRDTC1 lesid6_dec=TRLNKID status6_dec=TRORRES))
 ntl (RENAME=( mod7_dec=TRMETHOD imgdat7=TRDTC1 lesid7_dec=TRLNKID status7_dec=TRORRES))
  ntl (RENAME=( mod8_dec=TRMETHOD imgdat8=TRDTC1 lesid8_dec=TRLNKID status8_dec=TRORRES))
 ntl (RENAME=( mod9_dec=TRMETHOD imgdat9=TRDTC1 lesid9_dec=TRLNKID status9_dec=TRORRES))
 ntl (RENAME=( mod10_dec=TRMETHOD imgdat10=TRDTC1 lesid10_dec=TRLNKID status10_dec=TRORRES));
TRORRES=UPCASE(TRORRES);
TRSTRESC=UPCASE(TRORRES);
RUN;


DATA tl;
	LENGTH trgrpid  $200 ;
	SET 
		raw.tl(where=(tlperf_dec^=''));
	TRGRPID='TARGET';
	RUN;

	DATA Tl_1;
	SET TL;
	IF sumdia^=. THEN DO;
		TRLNKID='';
		TRMETHOD='';
		TRDTC=PUT(imgdat1,yymmdd10.);
		TRTESTCD='SUMDIAM';
		TRTEST='Sum of Diameter';
		TRORRES=sumdia;
		TRORRESU='mm';
		TRSTRESC=STRIP(sumdia);
		TRSTAT='';
		OUTPUT;
	END;
	run;
**********Longest************;

	

DATA Tl_2;
set  
Tl (RENAME=(mod1_dec=TRMETHOD imgdat1=TRDTC1 longdia1=TRORRES lesid1_dec=TRLNKID))
Tl (RENAME=(mod2_dec=TRMETHOD imgdat2=TRDTC1 longdia2=TRORRES lesid2_dec=TRLNKID))
Tl (RENAME=(mod3_dec=TRMETHOD imgdat3=TRDTC1 longdia3=TRORRES lesid3_dec=TRLNKID))
Tl (RENAME=(mod4_dec=TRMETHOD imgdat4=TRDTC1 longdia4=TRORRES lesid4_dec=TRLNKID)) 
Tl (RENAME=(mod5_dec=TRMETHOD imgdat5=TRDTC1 longdia5=TRORRES lesid5_dec=TRLNKID));
run;
data tl_3;
set tl_2;
TRDTC=PUT(TRDTC1,yymmdd10.);

			TRTESTCD='LDIAM';
			TRTEST='Longest Diameter';
			TRORRESU='mm';
			TRSTRESC=put (TRORRES,best.);
			TRSTAT='';
			run;

/*Short Axis*/

			

DATA T_short;
set  
Tl (RENAME=(mod1_dec=TRMETHOD imgdat1=TRDTC1 shortax1=TRORRES lesid1_dec=TRLNKID))
Tl (RENAME=(mod2_dec=TRMETHOD imgdat2=TRDTC1 shortax2=TRORRES lesid2_dec=TRLNKID))
Tl (RENAME=(mod3_dec=TRMETHOD imgdat3=TRDTC1 shortax3=TRORRES lesid3_dec=TRLNKID))
Tl (RENAME=(mod4_dec=TRMETHOD imgdat4=TRDTC1 shortax4=TRORRES lesid4_dec=TRLNKID)) 
Tl (RENAME=(mod5_dec=TRMETHOD imgdat5=TRDTC1 shortax5=TRORRES lesid5_dec=TRLNKID));
run;


data T_short2;
set T_short;
TRDTC=PUT(TRDTC1,yymmdd10.);


			TRTESTCD='LPERP';
			TRTEST='Short Axis';
			TRORRESU='mm';
			
			TRSTRESC=put (TRORRES,best.);
			TRSTAT='';
			run;

			data f3;
			set Tl_1 tl_3 T_short2;
			TRORRES1=TRORRES;
			DROP TRORRES;

			run;

			DATA F4;
			SET F3;
TRORRES=put (TRORRES1,best.);
RUN;


DATA final;
	LENGTH usubjid visit $40 TRstresc TReval $200;
	SET NL_1 (drop=lesid:)
		ntl_1 (drop=lesid:)
		f4 (drop=lesid:); 
		
STUDYID= "043-18101";
DOMAIN='TR';
USUBJID= "043-18101-"||SUBNUM;
	TRSTRESC=TRorres;
	TREVAL='INVESTIGATOR';
	 visit=VISNAME;
	 visitnum=VISITID;
	 TRDTC=PUT(TRDTC1,yymmdd10.);
	
RUN;



DATA DM1;
SET SDTM.DM;
RFSTDTN = DATEPART (INPUT (RFSTDTC,??IS8601DT.));
FORMAT RFSTDTN DATE9.;

KEEP USUBJID RFSTDTC RFSTDTN;
RUN;

PROC SORT DATA=DM1;BY USUBJID;RUN;
PROC SORT DATA=final;BY USUBJID;RUN;

DATA DM_TR;
MERGE DM1 (IN=A) final (IN=B);
BY USUBJID;
IF A AND B;

RUN;



DATA DM_TR2;
SET DM_TR;

IF TRDTC1 > . AND RFSTDTN > . THEN DO;

IF TRDTC1 >= RFSTDTN THEN TRDY=TRDTC1-RFSTDTN +1;
ELSE IF TRDTC1 < RFSTDTN THEN TRDY=TRDTC1-RFSTDTN;
END;


RUN;

*SEQ;;
PROC SORT DATA=DM_TR2;
	BY STRDYID USUBJID TRTESTCD TRLNKID TREVAL TRDTC VISITNUM;
RUN;

DATA TR6;
	SET DM_TR2;
	BY STRDYID USUBJID TRTESTCD TRLNKID TREVAL TRDTC VISITNUM;
	IF first.usubjid THEN TRSEQ=1;
		ELSE TRSEQ+1;

	LABEL
	STRDYID	='STRdy Identifier'
	DOMAIN	='Domain Abbreviation'
	USUBJID	='Unique Subject Identifier'
	TRSEQ	='Sequence Number'
	TRLNKID	='Link ID'
	TRTESTCD	='TRmor Identification Short Name'
	TRTEST	='TUmor Identification Test Name'
	TRORRES	='TUmor Identification Result'
	TRSTRESC	='TUmor Identification Result Std. Format'
	TRMETHOD	='Method of Identification'
	TREVAL	='Evaluator'
	VISITNUM	='Visit Number'
	VISIT	='Visit Name'
	TRDTC	='Date/Time of TUmor Identification'
	TRDY	='STRdy Day of TUmor Identification'
	;
RUN;

PROC SQL NOPRINT;
	CREATE TABLE SDTM.TR_(label='Tumor Result') as
		SELECT STUDYID, DOMAIN, USUBJID, TRSEQ, TRLNKID, TRTESTCD, 
TRTEST, TRORRES, TRSTRESC,  TRMETHOD, TREVAL,
				VISITNUM, VISIT,  TRDTC, TRDY
	FROM TR6
	ORDER BY STUDYID, USUBJID, TRTESTCD, TRLNKID, TREVAL, TRDTC, VISITNUM;
QUIT;
