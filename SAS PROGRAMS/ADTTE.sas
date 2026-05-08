/*******************************************************************
* Client: ROSHE22                                                           
* Product:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: ADTTE
*
* Program Type: ADAM
*
* Purpose: ADTTE
* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 30 JUL 2020
*******************************************************************/	
libname adam "E:\ROSHE2\ADAM DATASETS";
libname sdtm "E:\ROSHE2\SDTM DATASETS";	

options missing ="";
proc format;
	value $param
		"DOR" = "Duration of Response by Investigator"
		"OS" = "Overall Survival"
	;
run;
proc sort data = adam.adrs out = adrs;
	by STUDYID USUBJID;
run;
proc sort data = adam.adsl out = adsl ;
	by STUDYID USUBJID;
run;

******** Duration of Response by Investigator *****;
data _adrs_pd      (rename = (adt = adt_pd       aseq = aseq_pd))
	 _adrs_death   (rename = (adt = adt_death    aseq = aseq_death)) 
	 _adrs_lsta    (rename = (adt = adt_lsta     aseq = aseq_lsta))
 	 _adrs_crsp    (rename = (adt = adt_crsp     aseq = aseq_crsp))
	 _adrs_ovr     (rename = (adt = adt_ovr      aseq = aseq_ovr))
	 _adrs_cncrtrp (rename = (adt = adt_cncrtrp  aseq = aseq_cncrtrp));
	set adrs;

	if ANL01FL eq "Y"  then do;
		if PARAMCD eq "PD" and AVALC eq "Y" then output _adrs_pd;
		if PARAMCD eq "DEATH" and AVALC eq "Y" then output _adrs_death;
		if PARAMCD eq "LSTA" and not missing(AVALC) then output _adrs_lsta;
		if PARAMCD eq "CRSP" and AVALC eq "Y" then output _adrs_crsp;
		if PARAMCD eq "CNCRTRP" and AVALC eq "Y" then output _adrs_cncrtrp;
	end;

	if PARAMCD eq "OVR" then output _adrs_ovr;
run;
/**/
/*"Set to PD date [ADRS.ADT] if there is an observation in ADRS,*/
/*where [ADRS.PARAMCD]='PD' and [ADRS.AVALC]='Y' and [ADRS.ANL01FL]='Y'. */
/**/
/*Else set to Death date [ADRS.ADT] if there is an observation in ADRS,*/
/*where [ADRS.PARAMCD]='DEATH' and [ADRS.AVALC]='Y' and [ADRS.ANL01FL]='Y', */
/**/
/*Else set to Last Tumor Assessment date [ADRS.ADT] */
/*where [ADRS.PARAMCD]='LSTA' and [ADRS.AVALC] ne null and [ADRS.ANL01FL]='Y',*/
/**/
/*Else set to date of response [ADTTE.STARTDT] + 1 day."*/


/*"Set to 'Disease Progression' if there is an observation in ADRS, */
/*where [ADRS.PARAMCD]='PD' and [ADRS.ANL01FL]='Y'. */

/*Else set to 'Death' if there is an observation in ADRS,*/
/*where [ADRS.PARAMCD]='DEATH' and [ADRS.ANL01FL]='Y'. */


/*Else set to 'Last Tumor Assessment'  if there is an observation in ADRS, */
/*where [ADRS.PARAMCD]='LSTA' and [ADRS.AVALC] ne null and [ADRS.ANL01FL]='Y'
.*/
/*Else set to 'Confirmed Response plus 1'."*/

data adtte_dor;
	length EVNTDESC $200 SRCDOM $10 SRCVAR $50;
	merge _adrs_crsp  (in = a)
		  _adrs_death (in = death   keep = USUBJID adt_death aseq_death)
		  _adrs_pd    (in = pd      keep = USUBJID adt_pd    ASEQ_pd)
		  _adrs_lsta  (in = lsta    keep = USUBJID adt_lsta  aseq_lsta); 
	by USUBJID;

	if a;

	PARAMCD = "DOR";
	STARTDT = ADT_CRSP;
	SRCDOM = "ADRS";
	SRCVAR = "ADT";

	if pd or death then CNSR = 0;
	else CNSR = 1;

	if pd then do;
		ADT = ADT_PD;
		EVNTDESC = "Disease Progression";
		SRCSEQ = ASEQ_pd;
	end;

	else if death then do;
		ADT = ADT_DEATH;
		EVNTDESC = "Death";
		SRCSEQ = ASEQ_death;
	end;

	else if lsta then do;
		ADT = ADT_LSTA;
		EVNTDESC = "Last Tumor Assessment";
		SRCSEQ = ASEQ_lsta;
	end;

	else do;
		ADT = STARTDT + 1;
		EVNTDESC = "Confirmed Response plus 1";
		SRCSEQ = .;
	end;
run;

/**/
/*"Set to Death date [ADRS.ADT] if there is an observation in ADRS,*/
/*where [ADRS.PARAMCD]='DEATH' and [ADRS.AVALC]='Y' and [ADRS.ANL01FL]='Y', */
/*Else set to Last Known to be Alive Date [ADSL.LSTALVDT] */
/*if this date is post Time to Event Origin Date [ADTTE.STARTDT], */
/*Otherwise set to Time to Event Origin Date [ADTTE.STARTDT]."*/

********** Overall Survival *********;
data adtte_os;
	length EVNTDESC $200 CNSDTDSC $200 SRCDOM $10 SRCVAR $50;
	merge adsl        (in = a where = (not missing(TRTSDT)))
		  _adrs_death (in = death keep = USUBJID adt_death aseq_death);
	by USUBJID;

	if a;

	STARTDT = TRTSDT;
	PARAMCD = "OS";

	if death then do;
		EVNTDESC = "Death";
		CNSR = 0;
		ADT = ADT_DEATH;
		SRCDOM = "ADRS";
		SRCVAR = "ADT";
		SRCSEQ = ASEQ_DEATH;
	end;

	else do;
		EVNTDESC = "Alive";
		CNSR = 1;
		SRCDOM = "ADSL";
		if LSTALVDT > STARTDT > . then do;
			ADT = LSTALVDT;
			SRCVAR = "LSTALVDT";
			CNSDTDSC = "Last Contact";
		end;

		else do;
			ADT = STARTDT;
			SRCVAR = "TRTSDT";
			CNSDTDSC = "Treatment Start";
		end;

	end;
run;

***** Combine all parameters *****;
data param_all;
	set adtte_dor (drop = AVAL AVALC)
		adtte_os ;

run;

data param_all1;
	length PARAM $200 PARCAT1 PARCAT2 PARCAT3 $200 AVALU $40;
	set param_all;

	PARAM = strip(put(PARAMCD,$param.));
	PARCAT1 = "Time to Event";

	if PARAMCD in ("DOR") then do;
		PARCAT2 = "Investigator";
		PARCAT3 = "Recist 1.1";
	end;

	if nmiss(ADT,STARTDT) = 0 then do;
		AVALU = "MONTHS";
		AVAL = (ADT-STARTDT+1)/30.4375;
	end;

	if nmiss(TRTSDT,ADT) = 0 then ADY = ADT - TRTSDT + (ADT >= TRTSDT);


run;
%let var_adsl1 = STUDYID USUBJID SUBJID SITEID AGE AGEU SEX RACE TRT01P /*TRTSDT 
				 TRTEDT*/ SAFFL /*EFFFL */ ARMCD ARM ACTARMCD ACTARM;

proc sort data = param_all1;
	by STUDYID USUBJID PARCAT1 PARCAT2 PARCAT3 PARAMCD ADT;
run;

data param_all2;
	attrib
		ADT label = "Analysis Date" length = 8. format = date9.
		ADY label = "Analysis Relative Day" length = 8.

		PARAM label = "Parameter" length = $200
		PARAMCD label = "Parameter Code" length = $8
		PARCAT1 label = "Parameter Category 1" length = $200
		PARCAT2 label = "Parameter Category 2" length = $200
		PARCAT3 label = "Parameter Category 3" length = $200
		AVAL label = "Analysis Value" length = 8.
		AVALU label = "Analysis Value Unit" length = $40

		STARTDT label = "Time-to-Event Origin Date for Subject" length = 8.
		CNSR label = "Censor" length = 8.
		EVNTDESC label = "Event or Censoring Description" length = $200
		CNSDTDSC label = "Censor Date Description" length = $200

		SRCDOM label = "Source Data" length = $10
		SRCVAR label = "Source Variable" length = $50
		SRCSEQ label = "Source Sequence Number" length = 8. 
	;
	set param_all1;

	keep &var_adsl1 ADT ADY PARAM PARAMCD PARCAT1 PARCAT2 PARCAT3
		 AVAL AVALU STARTDT CNSR EVNTDESC CNSDTDSC SRCDOM SRCVAR SRCSEQ;

run;
data adam.adtte_ (label = "Time to Event Analyses");

	set param_all2;
run;
