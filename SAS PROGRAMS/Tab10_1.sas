/*******************************************************************
* Client: ROSHE30730                                                           
* Product:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: Tab10_1.SAS  
*
* Program Type: Listing
*
* Purpose: To produce the 
Table 14.1.11 Subject Demographics -Sex and Race  (Safety Population)

* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 08 AUG 2020
*******************************************************************/	
libname adam "E:\ROSHE30730\ADAM DATASETS";
libname sdtm "E:\ROSHE30730\SDTM DATASETS";	
%macro _RTFSTYLE_;

proc template;
 define style styles.test;
     parent=styles.rtf;
    replace fonts /
     'BatchFixedFont' = ("Courier New",9pt)
     'TitleFont2' = ("Courier New",9pt)
     'TitleFont' = ("Courier New",9pt)
     'StrongFont' = ("Courier New",9pt)
     'EmphasisFont' = ("Courier New",9pt)
     'FixedEmphasisFont' = ("Courier New",9pt)
     'FixedStrongFont' = ("Courier New",9pt)
     'FixedHeadingFont' = ("Courier New",9pt)
     'FixedFont' = ("Courier New",9pt)
     'headingEmphasisFont' = ("Courier New",9pt)
     'headingFont' = ("Courier New",9pt)
     'docFont' = ("Courier New",9pt);
      replace table from output /
      cellpadding = 0pt
      cellspacing = 0pt
	    borderwidth = 0.50pt
      background=white
      frame=void;
	 replace color_list	/
     'link' = black
     'bgH' = white
     'fg' = black
     'bg' = white;

	 replace Body from Document /
      bottommargin = 1.00in
      topmargin = 1.00in
      rightmargin = 1.00in
      leftmargin = 1.00in; 
   end;
run;

%MEND _RTFSTYLE_;
%_RTFSTYLE_;

data adrs;
set adam.adrs;
if aval ne .;
run;

data adrs;
merge adrs  adam.adsl;
by usubjid;
run;
data adrs;
set adrs;

if trt01pn in ( 1 2) and aval ne . and aval not in ( 0 1);
run;
proc sort;by trt01pn paramcd param aval;run;

proc freq data=adrs;
by trt01pn;
tables paramcd*param*aval*avalc/out=aval_c (drop=percent);
run;


DATA ADSL;
SET ADAM.ADSL;
IF trt01p NE '' AND SAFFL="Y";
OUTPUT;
KEEP USUBJID trt01p trt01pN SAFFL DLTEVLFL ENRLFL SEX RACE ;
RUN;

PROC SQL  NOPRINT;
CREATE TABLE TRT AS
SELECT trt01pN,trt01p, COUNT (DISTINCT (USUBJID)) AS DENOM FROM ADSL
GROUP BY trt01pN,trt01p
ORDER BY trt01pN, trt01p;

SELECT DENOM INTO: n1 - :n4 from trt;
QUIT;
%put &n1,&n2;


 DATA FINAL;
 SET aval_c;
 NN=count;
 trtpN=trt01pn;
length GRPA_1 $20.;
 IF trtpN=1 THEN DO;
 IF NN=. OR NN=0 THEN GRPA_1="0";
 ELSE IF NN=&n1 then GRPA_1 =compress (nn)||" (100)";
 else GRPA_1 =put (nn,3.)||" ("|| put (nn/&n1*100,4.1)||")";
 end;

 IF trtpN=2 THEN DO;
 IF NN=. OR NN=0 THEN GRPA_1="0";
 ELSE IF NN=&n2 then GRPA_1 =compress (nn)||" (100)";
 else GRPA_1 =put (nn,3.)||" ("|| put (nn/&n2*100,4.1)||")";
 end;
 run;
 proc sort ;by paramcd param aval avalc;run;

 proc transpose data=final out=all_ prefix=t;
 by paramcd param aval avalc;
 id trtpn;
 var GRPA_1;
 run;

 data adrs;
 set adrs;
 if aval in ( 1 2) then objresfl=0;
 else if aval ne . then objresfl=1;
 run;

 proc sort ;by paramcd param trt01pn;run;
ods trace on;
 proc freq data=adrs;
 by paramcd param trt01pn;
 tables objresfl/binomial (exact);
 ods output binomialcls=rs1;
 run;
ods trace off;
 data rs1;
 set rs1;
 range='('||trim (put (LowerCL,5.2))||","||
        trim (put (UpperCL,5.2))||")";
		keep paramcd param trt01pn range;
		run;

 proc sort ;by paramcd param trt01pn;run;

 proc transpose data=rs1 out=rs1_1 prefix=tt;
 by paramcd param ;
 id trt01pn;
 var range;
 run;

ods trace on;
 proc freq data=adrs;
 by paramcd param;
 tables trt01pn*objresfl/riskdiff;
 ods output Riskdiffcol1=rs2;
 run;
ods trace off;

data rs2;
set rs2;
if row eq "Difference";
range='('||trim (put (LowerCL,5.2))||","||
        trim (put (UpperCL,5.2))||")";
		keep  paramcd param  range;
		run;

*******p-value***************;
		
ods trace on;
PROC FREQ DATA=ADRS;
BY PARAMCD PARAM;
TABLES TRT01PN*objresfl/CMH;
ODS OUTPUT cmh=cmh (where=(AltHypothesis='Row Mean Scores Differ'));
RUN;
ods trace off;

data cmh;
set cmh;
pvalue=trim (put (prob,pvalue7.3));
keep paramcd param pvalue;
run;

data final;
merge all_ rs1_1 rs2 cmh;
by paramcd;
run;



title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 14.1.22  Best overall response (Safety Population)";

footnote1 j=l "CR = complete response, PR = partial response, SD = stable disease, PD = progressive disease.";
options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\ROSHE30730\OUTPUTS\14_1_22.rtf" style=styles.test;

PROC REPORT DATA=final NOWD SPLIT="|" MISSING

STYLE ={OUTPUTWIDTH=100%} SPACING=1 WRAP
STYLE (header)=[just=l];

COLUMN  paramcd param aval avalc t1 t2 tt1 tt2 range pvalue;

define paramcd/order noprint;
define param /order "Parameter"
style(column)=[just=left cellwidth = 20%]
style(header)=[just=left cellwidth = 20%]
;  

define aval/order noprint;
define avalc /order ""
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;  


define t1 /display "DRUG A|(N = &n1)"
style(column)=[just=left cellwidth = 5%]
style(header)=[just=left cellwidth = 5%]
;  

define t2 /display "DRUG B|(N = &n2)"
style(column)=[just=left cellwidth = 5%]
style(header)=[just=left cellwidth = 5%]
;  


define tt1 /display "DRUG A|(95% CI)"
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;  

define tt2 /display "DRUG B|(95% CI)"
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;   

define range /display "95% CI|Difference"
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;  
 
define pvalue /display "P-Value"
style(column)=[just=left cellwidth = 5%]
style(header)=[just=left cellwidth = 5%]
;  

compute before _page_;
line@1 "^{style [outputwidth=100% bordertopcolour=black bordertopwidth=0.5pt]}";
endcomp;


compute after _page_;
line@1 "^{style [outputwidth=100% bordertopcolour=black bordertopwidth=0.5pt]}";
endcomp;

compute before paramcd;
line '';
endcomp;

RUN;

ODS _all_ close; 
