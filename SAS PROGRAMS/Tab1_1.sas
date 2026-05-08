/*******************************************************************
* Client: XXXX                                                           
* Product: XXXXX                                                  
* Project: Protocol: 043-1810                                                    
* Program: tab1_1.sas 
*
* Program Type: Table
*
* Purpose: To produce the Table 
Table 14.1.1 Subject Assignment to Analysis Populations
* Usage Notes: 
*
* SAS® Version: 9.4 [TS2M0]
* Operating System: Windows 2003 R2 Standard Edition.                   
*
* Author: shiva 
* Date Created: 16 sep 2020
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


data adsl;
set adam.adsl;

output;

TRT01P="Overall";
trt01pn=5;
output;
keep usubjid trt01p trt01pn saffl ;
run;

data adsl;
set adsl;
if trt01pn ne .;
run;


PROC SQL NOPRINT;
CREATE TABLE TRT AS
SELECT trt01pn,trt01p, COUNT (DISTINCT USUBJID) AS DENOM FROM ADSL
GROUP BY TRT01PN,TRT01P
ORDER BY TRT01PN,TRT01P;

SELECT DENOM INTO: n1 - :n5 from trt;
QUIT;
%put &n1 &n2 &n3 &n4 &n5;

PROC SQL NOPRINT;
CREATE TABLE SAF1 AS
SELECT trt01pn, COUNT (DISTINCT USUBJID) AS NN,
"Safety Population" AS POP LENGTH=100,1 AS SQ FROM ADSL
WHERE SAFFL ="Y"
GROUP BY TRT01PN
ORDER BY TRT01PN;
QUIT;




DATA FINAL1;
SET SAF1 ;
length GRPA_1 $20.;

IF TRT01PN=1 THEN DO;
IF NN=. OR NN=0 THEN GRPA_1="0";
ELSE IF NN=&n1 then GRPA_1=put (nn,3.)||" (100)";
else GRPA_1=put (nn,3.)||" ("||put (nn/&n1*100,4.1)||")";
end;

IF TRT01PN=2 THEN DO;
IF NN=. OR NN=0 THEN GRPA_1="0";
ELSE IF NN=&n2 then GRPA_1=put (nn,3.)||" (100)";
else GRPA_1=put (nn,3.)||" ("||put (nn/&n2*100,4.1)||")";
end;

IF TRT01PN=3 THEN DO;
IF NN=. OR NN=0 THEN GRPA_1="0";
ELSE IF NN=&n3 then GRPA_1=put (nn,3.)||" (100)";
else GRPA_1=put (nn,3.)||" ("||put (nn/&n3*100,4.1)||")";
end;

IF TRT01PN=4 THEN DO;
IF NN=. OR NN=0 THEN GRPA_1="0";
ELSE IF NN=&n4 then GRPA_1=put (nn,3.)||" (100)";
else GRPA_1=put (nn,3.)||" ("||put (nn/&n4*100,4.1)||")";
end;

IF TRT01PN=5 THEN DO;
IF NN=. OR NN=0 THEN GRPA_1="0";
ELSE IF NN=&n5 then GRPA_1=put (nn,3.)||" (100)";
else GRPA_1=put (nn,3.)||" ("||put (nn/&n5*100,4.1)||")";
end;

run;

proc sort;by sq pop;run;

proc transpose data=FINAL1 out=all_ prefix=t;
by sq pop;
id TRT01PN;
var GRPA_1;
run;

data final;
set all_;
stat="n (%)";
run;


title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 14.1.1 Subject Assignment to Analysis Populations";

footnote1 j=l "E:\ROSHE30730\PROGRAMS\tab1_1.sas";
options orientation=landscape;
ods escapecahr='^';

ods rtf file ="E:\ROSHE30730\OUTPUTS\14_1_1.rtf" style=styles.test;


PROC REPORT DATA=final NOWD   MISSING
STYLE = {OUTPUTWIDTH=100%} SPLIT="|" SPACING=1 WRAP
STYLE (HEADER) =[JUST=L];

COLUMN  sq pop stat t1 t2 t3 t4 t5;

define sq/order noprint;
DEFINE pop/DISPLAY "Population"
STYLE (header) =[JUST=L CELLWIDTH=10%]
STYLE (COLUMN) =[JUST=L CELLWIDTH=10%];

DEFINE stat/DISPLAY "Statistic"
STYLE (header) =[JUST=L CELLWIDTH=5%]
STYLE (COLUMN) =[JUST=L CELLWIDTH=5%];

DEFINE t1/DISPLAY "DRUG A|(N = &n1)"
STYLE (header) =[JUST=L CELLWIDTH=5%]
STYLE (COLUMN) =[JUST=L CELLWIDTH=5%];

DEFINE t2/DISPLAY "DRUG B|(N = &n2)"
STYLE (header) =[JUST=L CELLWIDTH=5%]
STYLE (COLUMN) =[JUST=L CELLWIDTH=5%];

DEFINE t3/DISPLAY "DRUG C|(N = &n3)"
STYLE (header) =[JUST=L CELLWIDTH=5%]
STYLE (COLUMN) =[JUST=L CELLWIDTH=5%];

DEFINE t4/DISPLAY "DRUG D|(N = &n4)"
STYLE (header) =[JUST=L CELLWIDTH=5%]
STYLE (COLUMN) =[JUST=L CELLWIDTH=5%];

DEFINE t5/DISPLAY "ALL|(N = &n5)"
STYLE (header) =[JUST=L CELLWIDTH=5%]
STYLE (COLUMN) =[JUST=L CELLWIDTH=5%];


COMPUTE BEFORE _PAGE_;
LINE @1 "^{style [outputwidth=100% bordertopcolr=black bordertopwidth=0.5pt]}";
endcomp;

COMPUTE after _PAGE_;
LINE @1 "^{style [outputwidth=100% bordertopcolr=black bordertopwidth=0.5pt]}";
endcomp;
run;

ods _all_ close;





