/*******************************************************************
* Client: ROSHE2                                                           
* adamuct:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: ADVS.SAS  
*
* Program Type: ADaM
*
* Purpose: To adamuce the 
ADVS

* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 29 OCT 2020
*******************************************************************/	
libname adam "E:\ROSHE2\ADAM DATASETS";
libname sdtm "E:\ROSHE2\SDTM DATASETS";

OPTIONS MISSING='';
PROC FORMAT;
INVALUE AVAL_RESP
'CR'=1
'PR'=2
'SD'=3
'NON-CR/NON-PD'=4
'NE'=5
'PD'=6
OTHER=-1
;

INVALUE AVAL_YN
'Y'=1
'N'=0
;

VALUE $PARAM
"LSTAC"= "Last Disease Assessment Censored at First PD by Investigator"
"BOR"=   "Best Confirmed Overall Response by Investigator"
"CRSP"=  "Confirmed Response by Investigator"
"LSTA" = "Last Disease Assessment by Investigator"
"OVR" ="Overall Response by Investigator"
"CNCRTRP"= "Cancer Therapy"
"DEATH"  = "Death"
"PD" = "Disease Progression by Investigator"
;
RUN;	
	
*******COPY ALL VARIABLES FROM SDTM RS DATASET**********;

PROC SORT DATA=SDTM.RS OUT=RS;
BY USUBJID ;
RUN;



PROC SORT DATA=ADAM.ADSL OUT=ADSL;
BY USUBJID ;
RUN;

PROC SORT DATA=SDTM.PR ( WHERE =(PRCAT EQ 'ANTICANCER RADIOTHERAPY' AND 
NOT MISSING (PRSTDTC))) OUT=PR NODUPKEY;
BY USUBJID;
RUN;
	
DATA ADRS1;
MERGE ADSL (IN=A)
      RS   (IN=B)
	  PR   (KEEP= USUBJID PRCAT PRSTDTC);
BY USUBJID;
IF A;
RUN; 


/*Overall Response by Investigator*/

data _param_adrs_ovr_ns
     _param_adrs_ovr_s;
length PARAMCD $8. param $200.;

	 set adrs1
	 ( where=(RSTESTCD eq 'OVRLRESP' and RSEVAL eq 'INVESTIGATOR'));

	 PARAMCD="OVR";
	 AVALC= STRIP (RSSTRESC);
	 AVAL= INPUT (AVALC,AVAL_RESP.);
     SRCDOM ="RS";
	 SRCVAR ="RSSTRESC";
	 SRCSEQ =RSSEQ;

/*	 ADT*/
/*     IMPUTATION OF RSDTC*/
/*2019-12*/
	 IF LENGTH (RSDTC)= 7  AND COUNTC (RSDTC,'-')=1 THEN DO;

/*	 converted to numeric date.*/
/*Missing day is imputed as the last day of the month,*/
/*if [ADRS.AVALC]='CR' or 'PR',


	 else missing day is imputed as '01'. */
/*Missing month and year are not imputed.*/

/*last day of the month,*/*/
/*/*if [ADRS.AVALC]='CR' or 'PR'*/;

IF AVALC IN ("CR" "PR") THEN
ADT= INTNX ('month',input (strip (rsdtc)||"-01",e8601da.),1)-1;

/*(2019-03-01)-1= 2019-02-28*/

else
adt= input (strip (rsdtc)||"-01",e8601da.);
end;
else adt=input (rsdtc,e8601da.);

format adt date9.;

if aval=-1 then output _param_adrs_ovr_ns;
else output _param_adrs_ovr_s;
run; 



****************03 Nov 2020***************************;


proc sort data = _param_adrs_ovr_s;
	by USUBJID ADT descending AVAL descending RSSEQ;
run;
data _param_adrs_ovr_s;
	set _param_adrs_ovr_s;
	by USUBJID ADT descending AVAL descending RSSEQ;

	if first.ADT then ANL01FL = "Y";
run;
data param_adrs_ovr;
	set _param_adrs_ovr_s
		_param_adrs_ovr_ns;
run;




***** Last Disease Assessment Censored at First PD by Investigator ****;
proc sort data = param_adrs_ovr 
		out = _param_adrs_lstac 
(where = (ANL01FL eq "Y" and ADT >= TRTSDT));
	by USUBJID ADT AVALC;
run;
data _param_adrs_lstac1 ;
	set _param_adrs_lstac;
	by USUBJID ADT AVALC;

	retain flag;

	if first.USUBJID and AVALC ne "PD" then flag = 0; 
	else if AVALC = "PD" and aval ne -1 then flag = 1;
run;


data _param_adrs_lstac2;
	set _param_adrs_lstac1 (where = (flag = 1));
	by USUBJID ADT SRCSEQ;

	if last.USUBJID then output;
run;
data param_adrs_lstac;
	merge adsl (in = a)
		  _param_adrs_lstac2 (in = b);
	by USUBJID;

	if a;
	  
	PARAMCD = "LSTAC";

	call missing(SRCDOM,SRCVAR,SRCSEQ);

	ANL01FL = "Y";
run;



***** Cancer Therapy / Death *****;
data _param_adrs_cncrtrp
	 _param_adrs_death;
	set adrs1;
	by USUBJID;

	if not missing(PRCAT) and not missing(TRTSDT) then do;
		if PRSTDTC >= strip(put(TRTSDT,e8601da.)) > "" 
then output _param_adrs_cncrtrp;
	end;
	if not missing(DTHDT) then output _param_adrs_death;
run;


data _param_adrs_cncrtrp1;
	set _param_adrs_cncrtrp;
	by USUBJID;

	if first.USUBJID then output;
run;
data param_adrs_cncrtrp;
	merge adsl (in = a)
		  _param_adrs_cncrtrp1 (in = b);
	by USUBJID;

	if a;

	PARAMCD = "CNCRTRP";
	ANL01FL = "Y";

	if b then do;
		AVAL = 1;
		AVALC = "Y";
		ADT = input(PRSTDTC,??e8601da.);
	end;

	if not b then do;
		AVAL = 0;
		AVALC = "N";
		ADT = .;
	end;
run;

data _param_adrs_death1;
	set _param_adrs_death;
	by USUBJID;

	if first.USUBJID then output;
run;
data param_adrs_death;
	merge adsl (in = a)
		  _param_adrs_death1 (in = b);
	by USUBJID;

	if a;

	PARAMCD = "DEATH";
	ANL01FL = "Y";

	if b then do;
		AVAL = 1;
		AVALC = "Y";
		ADT = DTHDT;
	end;

	if not b then do;
		AVAL = 0;
		AVALC = "N";
		ADT = .;
	end;
run;


***** Disease Progression by Investigator ****;
data _param_adrs_pd;
	set param_adrs_ovr (where = ((ADT >= TRTSDT or not missing(PROGDT))
and AVALC eq "PD"));

	rename ADT = _ADT;
run;
proc sort data = _param_adrs_pd;
	by USUBJID _ADT;
run;
data _param_adrs_pd1;
	set _param_adrs_pd;
	by USUBJID _ADT;

	if first.USUBJId then output;
run;
data param_adrs_pd;
	merge adsl (in = a)
		  _param_adrs_pd1  (in = b);
	by USUBJID;

	if a;

	PARAMCD = "PD";
	ANL01FL = "Y";

	if b then do;
		AVAL = 1;
		AVALC = "Y";
		ADT = min(_ADT,PROGDT);
	end;

	if not b then do;
		AVAL = 0;
		AVALC = "N";
		ADT = .;
	end;

	format ADT date9.;
run;




***** Last Disease Assessment by Investigator ****;
proc sort data =  param_adrs_ovr (where = (ADT >= TRTSDT and AVAL ne -1))
		out = _param_adrs_lsta;
	by USUBJID ADT;
run;
data _param_adrs_lsta1;
	set _param_adrs_lsta;
	by USUBJID ADT;

	if last.USUBJID then output;
run;
data param_adrs_lsta;
length PARAMCD $8. param $200.;
	merge adsl (in = a)
		  _param_adrs_lsta1 (in = b);
	by USUBJID;

	if a;

	PARAMCD = "LSTA";
	ANL01FL = "Y";
run;


******* Best Overall Response by Investigator *****;
proc sort data = param_adrs_ovr 
		out = _param_adrs_bor (where = (ANL01FL eq "Y" and ADT >= TRTSDT));
	by USUBJID ADT AVALC;
run;
data _param_adrs_bor1 (where = (flag = 1 or flag1 = 1));
	set _param_adrs_bor;
	by USUBJID ADT AVALC;

	retain flag;

	if first.USUBJID then flag = 1;

	if AVALC eq "PD" then do; flag1 = 1; flag = 0; end;
run;
data _param_adrs_bor1;
	set _param_adrs_bor1 (drop = flag flag1);
run;

data param_adrs_bor;
	merge adsl (in = a)
		  _param_adrs_bor1 (in = b);
	by USUBJID;

	if a;

	PARAMCD = "BOR";
	if not missing(AVALC) then AVAL = input(AVALC,aval_resp.);
	ANL01FL = "Y";
run;


******* Confirmed Response by Investigator *******;
data param_adrs_crsp;
	set param_adrs_bor (rename = (AVAL = _AVAL AVALC = _AVALC));

	PARAMCD = "CRSP";

	if _AVALC in ("CR","PR") then do;
		AVALC = "Y"; AVAL = 1;
	end;

	else do;
		AVALC = "N"; AVAL = 0; ADT = .;
	end;
run;

***** Combine all parameters together ******;
data param_all;
	set param_adrs_ovr
		param_adrs_lstac
		param_adrs_bor
		param_adrs_crsp
		param_adrs_lsta
		param_adrs_cncrtrp
		param_adrs_death
		param_adrs_pd
	;
run;


data param_all1;
	set param_all;

	PARAM = strip(put(PARAMCD,$param.));

	if PARAMCD in ("DEATH","CNCRTRP") then PARCAT1 = "Reference Event";

	else do;
		PARCAT1 = "Tonse";
		PARCAT2 = "Investigatorumor Resp";
		PARCAT3 = "Recist 1.1";
	end;


	if nmiss(TRTSDT,ADT) = 0 then ADY = ADT - TRTSDT + (ADT >= TRTSDT);

	if nmiss(ADT,TRTSDT,TRTEDT) = 0  and TRTSDT <= ADT <= TRTEDT then do;
		TRTP = strip(TRT01P);
		
	end;
run;
%let var_adsl1 = STUDYID USUBJID SUBJID SITEID AGE AGEU SEX RACE TRT01P /*TRTSDT 
				 TRTEDT */ SAFFL /*EFFFL */ ARMCD ARM ACTARMCD ACTARM;

proc sort data = param_all1;
	by STUDYID USUBJID PARAMCD PARCAT1 PARCAT2 PARCAT3 ADT;
run;
data param_all1_seq;
	set param_all1;
	by STUDYID USUBJID;

	retain ASEQ;

	if first.USUBJID then ASEQ = 1;
	else ASEQ = ASEQ + 1;
run;

data param_all2;
	attrib
		TRTP label = "Planned Treatment" length = $200
		ADT label = "Analysis Date" length = 8. format = date9.
		ADY label = "Analysis Relative Day" length = 8.

		VISITNUM label = "Visit Number" length = 8.
		VISIT label = "Visit Name" length = $200

		ASEQ label = "Analysis Sequence Number" length = 8.
		PARAM label = "Parameter" length = $200
		PARAMCD label = "Parameter Code" length = $8
		PARCAT1 label = "Parameter Category 1" length = $200
		PARCAT2 label = "Parameter Category 2" length = $200
		PARCAT3 label = "Parameter Category 3" length = $200
		AVAL label = "Analysis Value" length = 8.
		AVALC label = "Analysis Value (C)" length = $200
		ANL01FL label = "Analysis Flag 01" length = $1 

		RSDTC label = "Date/Time of Response Assessment" length = $25
/*		RSTESTCD label = "Response Assessment Short Name" length = $8*/
/*		RSTEST label = "Response Assessment Name" length = $40*/
/*		RSCAT label = "Category for Response Assessment" length = $200*/
/*		RSORRES label = "Response Assessment Original Result" length = $200*/
		RSSTRESC label = "Response Assessment Result in Std Format" length = $200
		RSEVAL label = "Evaluator" length = $200

		SRCDOM label = "Source Data" length = $10
		SRCVAR label = "Source Variable" length = $8
		SRCSEQ label = "Source Sequence Number" length = 8. 
	;
	set param_all1_seq;

	keep &var_adsl1 /*RSTESTCD RSTEST RSCAT RSORRES*/ RSSTRESC
		 RSEVAL VISITNUM VISIT ASEQ RSDTC PARAM PARAMCD PARCAT1 PARCAT2 PARCAT3
		 AVAL AVALC ADT ADY TRTP /*TRTA*/ ANL01FL SRCDOM SRCVAR SRCSEQ;

run;
data adam.adrs_ (label = "Data for the Response Analyses ");
	retain &var_adsl1;
	set param_all2;
run;















	
	
	





























