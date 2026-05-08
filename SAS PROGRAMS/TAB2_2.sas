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
IF DLTEVLFL="Y";
output;

TRT01P="Overall";
trt01pn=5;
output;
keep usubjid trt01p trt01pn saffl DLTEVLFL ENRLFL DCSREAS;
run;

DATA DUMMY;
DO trt01pn=1 TO 5;
OUTPUT;
END;
RUN;

PROC SORT DATA=ADSL;BY trt01pn;RUN;
PROC SORT DATA=DUMMY;BY trt01pn;RUN;

DATA ADSL_DUMM;
MERGE DUMMY adsl;
BY trt01pn;
RUN;


PROC SQL NOPRINT;
CREATE TABLE TRT AS
SELECT trt01pn,trt01p, COUNT (DISTINCT USUBJID) AS DENOM FROM ADSL_DUMM
GROUP BY TRT01PN,TRT01P
ORDER BY TRT01PN,TRT01P;

SELECT DENOM INTO: n1 - :n5 from trt;
QUIT;
%put &n1 &n2 &n3 &n4 &n5;



PROC SQL NOPRINT;
CREATE TABLE PLAN AS
SELECT trt01pn, COUNT (DISTINCT USUBJID) AS NN,
"Subjects Planned" AS POP LENGTH=100,1 AS NUMB FROM ADSL_DUMM
WHERE TRT01P ^=" "
GROUP BY TRT01PN
ORDER BY TRT01PN;


CREATE TABLE ENRL AS
SELECT trt01pn, COUNT (DISTINCT USUBJID) AS NN,
"Subjects Enrolled" AS POP LENGTH=100,2 AS NUMB FROM ADSL_DUMM
WHERE ENRLFL ="Y"
GROUP BY TRT01PN
ORDER BY TRT01PN;



CREATE TABLE WTH AS
SELECT trt01pn, COUNT (DISTINCT USUBJID) AS NN,
"Subjects Withdrawn" AS POP LENGTH=100,3 AS NUMB FROM ADSL_DUMM
WHERE DCSREAS ^=" "
GROUP BY TRT01PN
ORDER BY TRT01PN;

QUIT;

PROC SQL;
 CREATE TABLE ANY4 AS
SELECT trt01pn,DCSREAS AS POP LENGTH=100 ,COUNT (DISTINCT USUBJID) AS NN,
4 AS NUMB FROM ADSL_DUMM
WHERE DCSREAS ^=''
GROUP BY TRT01PN,DCSREAS
ORDER BY TRT01PN,DCSREAS;

QUIT;


DATA FINAL;
SET PLAN ENRL WTH ANY4;
RUN;

PROC SORT;BY POP TRT01PN;RUN;



DATA FINAL1;
SET FINAL ;
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

proc sort;by NUMB pop;run;

proc transpose data=FINAL1 out=all_ prefix=t;
by NUMB pop;
id TRT01PN;
var GRPA_1;
run;
PROC SORT DATA=all_ OUT=ALL_2 (KEEP=NUMB) NODUPKEY;BY NUMB;RUN;

DATA DUMMY2;
SET ALL_2 (KEEP=NUMB);
LENGTH T1 T2 T3 T4 T5 $20.;
T1='  0';
T2='  0';
T3='  0';
T4='  0';
T5='  0';
RUN;

DATA FIN;
MERGE DUMMY2 ALL_;
BY NUMB;
RUN;

DATA FIN;
SET FIN;
IF T1='' THEN T1='  0';
IF T2='' THEN T2='  0';
IF T3='' THEN T3='  0';
IF T4='' THEN T4='  0';
IF T5='' THEN T5='  0';
RUN;


title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 14.1.4  Subject Disposition by Treatment (DLT Evaluable Population)";

footnote1 j=l "E:\ROSHE30730\PROGRAMS\tab2_2.sas";
options orientation=landscape;
ods escapecahr='^';

ods rtf file ="E:\ROSHE30730\OUTPUTS\14_1_4.rtf" style=styles.test;


PROC REPORT DATA=fin NOWD   MISSING
STYLE = {OUTPUTWIDTH=100%} SPLIT="|" SPACING=1 WRAP
STYLE (HEADER) =[JUST=L];

COLUMN  NUMB POP t1 t2 t3 t4 t5;

define NUMB/order noprint;
DEFINE pop/DISPLAY "CATEGORY"
STYLE (header) =[JUST=L CELLWIDTH=10%]
STYLE (COLUMN) =[JUST=L CELLWIDTH=10%];


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






