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


DATA ae1;
length usubjid $40.;
	SET raw.ae(rename=(aeseq=aeseqx aeterm=aetermx 
                        aesev=aesevx aeout=aeoutx 
                         aeser=aeserx aesdth=aesdthx) 

where=(pagename='Adverse Event(s)'));


STUDYID= "043-18101";
DOMAIN='AE';
USUBJID= "043-18101- "||SUBNUM;
USUBJID=STRIP (STUDYID)||"-"||STRIP (SUBNUM);

AEREFID=STRIP(PUT(pageseq,??best.));

IF aecmseq^='' & aecpseq^='' THEN AESPID='CM '||STRIP(aecmseq)
||'/'||'PR '||aecpseq;

ELSE IF aecmseq^='' THEN AESPID='CM '||aecmseq;
ELSE IF aecpseq^='' THEN AESPID='PR '||aecpseq;


AETERM=aetermx;

AELLT=llt_name;
AELLTCD=llt_code;
AEDECOD=pt_term;
AEPTCD=pt_code;
AEHLT=hlt_term;
AEHLTCD=hlt_code;
AEHLGT=hlgt_term;
AEHLGTCD=hlgt_code;
AEBODSYS=soc_term;
AEBDSYCD=soc_code;
AESOC=soc_term;
AESOCCD=soc_code;

*aesev=UPCASE (AESEV_DEC);*/HOLD*/;
/*HEADACHE----MILD MODERATE SEVERE*/

AESER=SUBSTR(aeserx,1,1);
/*LIFETHERETHING DEATH HOSPIT*/



AEACN=UPCASE(aeacn2_dec);

 if aeothnone ='X'  THEN AEACNOTH='NONE';
            	IF aeothcm='X' THEN AEACNOTH='CONCOMITANT MEDICATIONS';
            	IF aeothcp='X' THEN AEACNOTH='CONCURRENT PROCEDURES';
            	IF aeothdis='X' THEN AEACNOTH='DISCONTINUED STUDY';

				
AEREL=UPCASE(aerel2_dec);


IF aeout_dec='Not Recovered/Not Resolved (Continuing)'
THEN AEOUT='NOT RECOVERED/NOT RESOLVED';
ELSE AEOUT=UPCASE(aeout_dec);


	           


IF aesanom='X' THEN AESCONG='Y';
IF aesincap='X' THEN AESDISAB='Y';
IF aesdthx='X' THEN AESDTH='Y';
IF aeshos='X' THEN AESHOSP='Y';
IF aeslt='X' THEN AESLIFE='Y';
IF aesoth='X' THEN AESMIE='Y';


IF aesev_dec='Grade 1 (Mild)' THEN DO;
		AETOX='MILD';
		AETOXGR='1';
	END;
		ELSE IF aesev_dec='Grade 2 (Moderate)' THEN DO;
			AETOX='MODERATE';
			AETOXGR='2';
		END;
		ELSE IF aesev_dec='Grade 3 (Severe)' THEN DO;
			AETOX='SEVERE';
			AETOXGR='3';
		END;
		ELSE IF aesev_dec='Grade 4 (Life-threatening)' THEN DO;
			AETOX='LIFE-THREATENING';
			AETOXGR='4';
		END;
		ELSE IF aesev_dec='Grade 5 (Death)' THEN DO;
			AETOX='DEATH';
			AETOXGR='5';
		END;

IF aeongo_dec='Yes' THEN AEENRF='ONGOING';
		
AESTDTC=put (AESTDAT,yymmdd10.);

AESTDTN = AESTDAT;
FORMAT AESTDTN DATE9.;


AEENDTC=put (AEENDAT,yymmdd10.);


AEENDTN = AEENDAT;
FORMAT AEENDTN DATE9.;

	run;

DATA DM1;
SET SDTM.DM;
RFSTDTN = DATEPART (INPUT (RFSTDTC,??IS8601DT.));
FORMAT RFSTDTN DATE9.;

KEEP USUBJID RFSTDTC RFSTDTN;
RUN;

PROC SORT DATA=DM1;BY USUBJID;RUN;
PROC SORT DATA=AE1;BY USUBJID;RUN;

DATA DM_AE;
MERGE DM1 (IN=A) AE1 (IN=B);
BY USUBJID;
IF A AND B;
RUN;



DATA DM_AE2;
SET DM_AE;
/*2018-12 =aestdtc*/
/*AESTDTN=. */
/*AESTDY=.*/
/**/
/*2018-12-01=*/
/*aestdy=*/


IF AESTDTN > . AND RFSTDTN > . THEN DO;

IF AESTDTN >= RFSTDTN THEN AESTDY=AESTDTN-RFSTDTN +1;
ELSE IF AESTDTN < RFSTDTN THEN AESTDY=AESTDTN-RFSTDTN;
END;


IF AEENDTN > . AND RFSTDTN > . THEN DO;

IF AEENDTN >= RFSTDTN THEN AEENDY=AEENDTN-RFSTDTN +1;
ELSE IF AEENDTN < RFSTDTN THEN AEENDY=AEENDTN-RFSTDTN;
END;

AEDUR1= AEENDY-AESTDY +1; 
AEDUR =COMPRESS ( "P "||PUT (AEDUR1,BEST.)|| "D ");
IF AEDUR= "P.D " THEN AEDUR='';
RUN;

*SEQ;;
PROC SORT DATA=DM_AE2 out=AE4;
	BY STUDYID USUBJID AEDECOD AESTDTC AETERM;
RUN;

DATA AE5;
retain
STUDYID
DOMAIN
USUBJID
AESEQ
AEREFID
AESPID
AETERM
AELLT
AELLTCD
AEDECOD
AEPTCD
AEHLT
AEHLTCD
AEHLGT
AEHLGTCD
AEBODSYS
AEBDSYCD
AESOC
AESOCCD
AESEV
AESER
AEACN
AEACNOTH
AEREL
AEOUT
AESCONG
AESDISAB
AESDTH
AESHOSP
AESLIFE
AESMIE
AETOXGR
AESTDTC
AEENDTC
AESTDY
AEENDY
AEDUR
AEENRF
;
	SET AE4;
	BY studyid usubjid aedecod aestdtc aeterm;
	IF first.usubjid THEN AESEQ=1;
		ELSE AESEQ+1;
		keep
		STUDYID
DOMAIN
USUBJID
AESEQ
AEREFID
AESPID
AETERM
AELLT
AELLTCD
AEDECOD
AEPTCD
AEHLT
AEHLTCD
AEHLGT
AEHLGTCD
AEBODSYS
AEBDSYCD
AESOC
AESOCCD
AESEV
AESER
AEACN
AEACNOTH
AEREL
AEOUT
AESCONG
AESDISAB
AESDTH
AESHOSP
AESLIFE
AESMIE
AETOXGR
AESTDTC
AEENDTC
AESTDY
AEENDY
AEDUR
AEENRF
;
run;

PROC SQL;
CREATE TABLE FINAL AS 
SELECT
STUDYID "Study Identifier " length=	8	,
DOMAIN "Domain Abbreviation " length=	2	,
USUBJID "Unique Subject Identifier " length=	50	,
AESEQ "Sequence Number " length=	8	,
AESPID "Sponsor-Defined Identifier " length=	200	,
AETERM "Reported Term for the Adverse Event " length=	200	,
AELLT "Lowest Level Term " length=	100	,
AELLTCD "Lowest Level Term Code " length=	8	,
AEDECOD "Dictionary-Derived Term " length=	200	,
AEPTCD "Preferred Term Code " length=	8	,
AEHLT "High Level Term " length=	100	,
AEHLTCD "High Level Term Code " length=	8	,
AEHLGT "High Level Group Term " length=	100	,
AEHLGTCD "High Level Group Term Code " length=	8	,
AEBODSYS "Body System or Organ Class " length=	200	,
AEBDSYCD "Body System or Organ Class Code " length=	8	,
AESOC "Primary System Organ Class " length=	200	,
AESOCCD "Primary System Organ Class Code " length=	8	,
AESER "Serious Event " length=	2	,
AEACN "Action Taken with Study Treatment " length=	16	,
AEACNOTH "Other Action Taken " length=	200	,
AEREL "Causality " length=	20	,
AEOUT "Outcome of Adverse Event " length=	40	,
AESCONG "Congenital Anomaly or Birth Defect " length=	2	,
AESDISAB "Persist or Signif Disability/Incapacity " length=	2	,
AESDTH "Results in Death " length=	2	,
AESHOSP "Requires or Prolongs Hospitalization " length=	2	,
AESLIFE "Is Life Threatening " length=	2	,
AESMIE "Other Medically Important Serious Event " length=	2	,
AETOXGR "Standard Toxicity Grade " length=	1	,
AESTDTC "Start Date/Time of Adverse Event " length=	25	,
AEENDTC "End Date/Time of Adverse Event " length=	25	,
AESTDY "Study Day of Start of Adverse Event " length=	8	,
AEENDY "Study Day of End of Adverse Event " length=	8	,
AEDUR "Duration of Adverse Event " length=	25	,
AEENRF "End Relative to Reference Period " length=	20	
FROM ae5;
QUIT;
RUN;

data sdtm.ae_ (label="Adverse Events");
set final;
run;


