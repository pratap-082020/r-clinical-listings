/*******************************************************************
* Client: XXXX                                                           
* Product: XXXXX                                                  
* Project: Protocol: 043-1810                                                    
* Program: ADAE.sas 
*
* Program Type: ADaM
*
* Purpose: To produce the ADAE
* Usage Notes: 
*
* SAS® Version: 9.4 [TS2M0]
* Operating System: Windows 2003 R2 Standard Edition.                   
*
* Author: shiva 
* Date Created: 21 OCT 2020
*******************************************************************/

libname adam "E:\ROSHE2\ADAM DATASETS";	
libname SDTM "E:\ROSHE2\SDTM DATASETS";	


******READING ADSL DATASET****************;

PROC SORT DATA=ADAM.ADSL OUT=ADSL ;BY USUBJID;RUN;


******************COPY ALL THE VARIABLES FROM SDTM DM***********;

DATA AE0;
SET SDTM.AE;
RUN;

PROC SORT;BY USUBJID AESEQ;RUN;



************HANDLING OF SUPP-- DATASET****************;

DATA SUPPAE0;
SET SDTM.SUPPAE;
AESEQ= INPUT (IDVARVAL,BEST.);
RUN;
PROC SORT;BY USUBJID AESEQ;RUN;

PROC TRANSPOSE DATA=SUPPAE0 OUT=T_SUPPAE0 (DROP=_NAME_ _LABEL_);
BY USUBJID AESEQ;
ID QNAM;
IDLABEL  QLABEL;
VAR QVAL;
RUN;

DATA AE1;
MERGE AE0 T_SUPPAE0;
BY USUBJID AESEQ;
RUN;


DATA AE2;
MERGE AE1 (IN=A) ADSL (IN=B);
BY USUBJID;
IF A;
RUN;


DATA ADAE0;
SET AE2;
TRTP= STRIP (TRT01P);

*IMPUTE DATES*;

/*2019-05-20*/

IF LENGTH (AESTDTC)=10 THEN DO;
AEST_YY=STRIP (SUBSTR ( AESTDTC,1,4));
AEST_MM=STRIP (SUBSTR ( AESTDTC,6,2)); 
AEST_DD=STRIP (SUBSTR ( AESTDTC,9,2));
END;
/*2019-05*/

IF LENGTH (AESTDTC)=7 THEN DO;
AEST_YY=STRIP (SUBSTR ( AESTDTC,1,4));
AEST_MM=STRIP (SUBSTR ( AESTDTC,6,2));
AEST_DD=''; 
END;
/*2019*/
IF LENGTH (AESTDTC)=4 THEN DO;
AEST_YY=STRIP (SUBSTR ( AESTDTC,1,4));
AEST_MM='';
AEST_DD=''; 
END;

*************AEENDTC********************;

IF LENGTH (AEENDTC)=10 THEN DO;
AEEN_YY=STRIP (SUBSTR ( AEENDTC,1,4));
AEEN_MM=STRIP (SUBSTR ( AEENDTC,6,2)); 
AEEN_DD=STRIP (SUBSTR ( AEENDTC,9,2));
END;
/*2019-05*/

IF LENGTH (AEENDTC)=7 THEN DO;
AEEN_YY=STRIP (SUBSTR ( AEENDTC,1,4));
AEEN_MM=STRIP (SUBSTR ( AEENDTC,6,2));
AEEN_DD=''; 
END;
/*2019*/
IF LENGTH (AEENDTC)=4 THEN DO;
AEEN_YY=STRIP (SUBSTR ( AEENDTC,1,4));
AEEN_MM='';
AEEN_DD=''; 
END;

TRTSDTC= STRIP (PUT (TRTSDT,YYMMDD10.));

IF LENGTH (TRTSDTC)=10 THEN DO;
TRST_YY=STRIP (SUBSTR ( TRTSDTC,1,4));
TRST_MM=STRIP (SUBSTR ( TRTSDTC,6,2)); 
TRST_DD=STRIP (SUBSTR ( TRTSDTC,9,2));
END;

TRTEDTC= STRIP (PUT (TRTEDT,YYMMDD10.));

IF LENGTH (TRTEDTC)=10 THEN DO;
TREN_YY=STRIP (SUBSTR ( TRTEDTC,1,4));
TREN_MM=STRIP (SUBSTR ( TRTEDTC,6,2)); 
TREN_DD=STRIP (SUBSTR ( TRTEDTC,9,2));
END;

/*2019-06-01*/            /*1999-05-10*/

IF MISSING (AEST_DD) AND CMISS (AEST_YY,AEST_MM)=0 THEN DO;

IF AEST_MM = TRST_MM THEN AEST_DD=TRST_DD;
ELSE IF AEST_MM ^= TRST_MM THEN AEST_DD='01';
ASTDTF='D';
END;

/*2019- */          /*2020-05-10*/
ELSE IF CMISS (AEST_DD,AEST_MM)=2 AND NOT MISSING (AEST_YY) THEN DO;
IF AEST_YY=TRST_YY THEN DO;

AEST_MM=TRST_MM;
AEST_DD=TRST_DD;
ASTDTF='M';
END;
IF AEST_YY ^=TRST_YY THEN DO;

AEST_MM='12';
AEST_DD='31';
ASTDTF='M';
END;
END;

RUN;

/*AESTDTC=.*/          
*********24 Oct 2020******************;

DATA ADAE0;
set  ADAE0;

 if cmiss(aest_yy,aest_mm,aest_dd) = 3 then do;
		aest_dd = trst_dd;
		aest_mm = trst_mm;
		aest_yy = trst_yy;
		ASTDTF = 'Y';
	end;

	astdtc = catx('-',strip(aest_yy),strip(aest_mm),strip(aest_dd));
	astdt = input(astdtc,yymmdd10.);


	if missing(aeen_dd) and cmiss(aeen_yy,aeen_mm) = 0 then do;
		aeen_tmp1 = 
input(catx('-',strip(aeen_yy),strip(aeen_mm),'01'),yymmdd10.);

		aeen_tmp2 = strip(put(intnx('month',aeen_tmp1,0,'end'),yymmdd10.));
		aeen_dd = strip(substr(aeen_tmp2,9,2));
		aendtf = 'D';
	end;

	else if cmiss(aeen_dd,aeen_mm) = 2 and not missing(aeen_yy) then do;
		aeen_dd = '31';
		aeen_mm = '12';
		aendtf = 'M';
	end;
	else if cmiss(aeen_dd,aeen_mm,aeen_yy) = 3 and aeenrf ne 'ONGOING' then do;
		aeen_dd = tren_dd;
		aeen_mm = tren_mm;
		aeen_yy = tren_yy;
		aendtf = 'Y';
	end;

	aendtc = catx('-',strip(aeen_yy),strip(aeen_mm),strip(aeen_dd));
	aendt = input(aendtc,yymmdd10.);

	if not missing(aendtf) then do;
		if aendt > trtedt then do;
			aendt = trtedt;
			
		end;
	end;
X=astdt >= trtsdt;


	if nmiss(astdt,trtsdt) = 0 then
astdy = astdt - trtsdt + (astdt >= trtsdt);


	if nmiss(aendt,trtsdt) = 0 then 
aendy = aendt - trtsdt + (aendt >= trtsdt);


    if nmiss(astdt,trtsdt,trtedt) = 0 and 
trtsdt <= astdt <= trtedt + 30 then trtemfl = 'Y';

	else if missing(trtedt) and nmiss(astdt,trtsdt) = 0 
and astdt >= trtsdt then trtemfl = 'Y';

	format astdt aendt date9.;

	if upcase(aeacn) = 'DRUG WITHDRAWN' then aedisofl = 'Y';
	if upcase(aeacnnp) = 'DRUG WITHDRAWN' then aedisnfl = 'Y';

	if nmiss(astdt,aendt) = 0 then do;	
		adurn = aendt - astdt + 1;
		aduru = 'DAYS';
	end;

run;


data adae1;
	set adae0;

	keep studyid usubjid subjid siteid aeseq saffl dltevlfl pkevlfl enrlfl trt01p trt01pn
	armcd arm actarmcd actarm trtsdt trtedt trtp 
	aeterm aedecod aebodsys aebdsycd aellt aelltcd aeptcd aehlt aehltcd aehlgt aehlgtcd
	aesoc aesoccd aestdtc astdt aeendtc aendt aestdy astdy astdtf aeendy aendy aendtf adurn aduru
	trtemfl aeser aerel aerelnp aeacn aeacnoth aeacnnp aeout 
	aeenrf aetox aetoxgr aedisofl aedisnfl aesdth ;

	attrib
		TRTP		label='Planned Treatment'
		AETERM		label='Reported Term for the Adverse Event'
		AEDECOD		label='Dictionary-Derived Term'
		AEBODSYS	label='Body System or Organ Class'
		AEBDSYCD	label='Body System or Organ Class Code'
		AELLT		label='Lowest Level Term'
		AELLTCD		label='Lowest Level Term Code'
		AEPTCD		label='Preferred Term Code'
		AEHLT		label='High Level Term'
		AEHLTCD		label='High Level Term Code'
		AEHLGT		label='High Level Group Term'
		AEHLGTCD	label='High Level Group Term Code'
		AESOC		label='Primary System Organ Class'
		AESOCCD		label='Primary System Organ Class Code'
		AESTDTC		label='Start Date/Time of Adverse Event'
		ASTDT		label='Analysis Start Date'
		AEENDTC		label='End Date/Time of Adverse Event'
		AENDT		label='Analysis End Date'
		AESTDY		label='Study Day of Start of Adverse Event'
		ASTDY		label='Analysis Start Relative Day'
		ASTDTF		label='Analysis Start Date Imputation Flag'
		AEENDY		label='Study Day of End of Adverse Event'
		AENDY		label='Analysis End Relative Day'
		AENDTF		label='Analysis End Date Imputation Flag'
		ADURN		label='AE Duration (N)'
		ADURU		label='AE Duration Units'
		TRTEMFL		label='Treatment Emergent Analysis Flag'
		AESER		label='Serious Event'
		AEREL		label='Causality'
		AERELNP		label='Relationship to Nab-Paclitaxel'
		AEACN		label='Action Taken with Study Treatment'
		AEACNOTH	label='Other Action Taken'
		AEACNNP		label='Action Taken with Nab-Paclitaxel'
		AEOUT		label='Outcome of Adverse Event'
		AEENRF		label='End Relative to Reference Period'
		AETOX		label='Toxicity'
		AETOXGR		label='Standard Toxicity Grade'
		AEDISOFL	label='Oric Discontinuation due to AE'
		AEDISNFL	label='Nab-Pac Discontinuation due to AE'
		AESDTH		label='Results in Death'
		
	;
run;

proc sql noprint;
	create table ADAM.ADAE_(label='Adverse Event Analysis Dataset') as
	select studyid, usubjid, subjid, siteid, aeseq, saffl, dltevlfl, pkevlfl, enrlfl, trt01p, trt01pn,
	armcd, arm, actarmcd, actarm, trtsdt, trtedt, trtp, 
	aeterm, aedecod, aebodsys, aebdsycd, aellt, aelltcd, aeptcd, aehlt, aehltcd, aehlgt, aehlgtcd,
	aesoc, aesoccd, aestdtc, astdt, astdtf, aeendtc, aendt, aendtf, adurn, aduru, astdy, aestdy, aendy, aeendy,
	trtemfl, aeser, aerel, aerelnp, aetox, aetoxgr, aeacn, aeacnoth, aeacnnp, aeout, 
	aeenrf, aedisofl, aedisnfl, aesdth
	from adae1
	order by studyid, usubjid, aeseq;
quit;

