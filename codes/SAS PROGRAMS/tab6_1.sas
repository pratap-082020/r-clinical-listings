/*******************************************************************
* Client: XXXX                                                           
* Product: XXXXX                                                  
* Project: Protocol: 043-1810                                                    
* Program: Tab2_1.sas 
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
if TRT01P ne '' and saffl="Y";

output;
keep usubjid trt01p trt01pn saffl DLTEVLFL ENRLFL DCSREAS SEX RACE;
run;


PROC SQL NOPRINT;
CREATE TABLE TRT AS
SELECT trt01pn,trt01p, COUNT (DISTINCT USUBJID) AS DENOM FROM ADSL
GROUP BY TRT01PN,TRT01P
ORDER BY TRT01PN,TRT01P;

SELECT DENOM INTO: n1 - :n4 from trt;
QUIT;
%put &n1 &n2 &n3 &n4 ;

data adae;
set adam.adae;
if TRTEMFL ="Y" and saffl="Y" and TRT01P ne '';
keep usubjid trt01p trt01pn AEBODSYS AEDECOD;
run;

proc sql noprint;
create table any1 as
select trt01pn,trt01p,count (distinct usubjid) as n,
" Number of Subjects with TEAEs" as AEBODSYS length=200
from adae
group by trt01pn,trt01p;



create table soc as
select trt01pn,trt01p,AEBODSYS,count (distinct usubjid) as n

from adae
group by trt01pn,trt01p,AEBODSYS;


create table pt as
select trt01pn,trt01p,AEBODSYS,AEDECOD,count (distinct usubjid) as n

from adae
group by trt01pn,trt01p,AEBODSYS,AEDECOD;
quit;

data all;
set any1 soc pt;
run;


DATA FINAL1;
SET all;
length GRPA_1 $20.;
NN=n;
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

run;



proc sort;by AEBODSYS AEDECOD;run;

proc transpose data=FINAL1 out=all_ prefix=t;
by AEBODSYS AEDECOD;
id TRT01PN;
var GRPA_1;
run;

data dummy;
set all_ (keep=AEBODSYS AEDECOD);
length t1 t2 t3 t4 $20.;
t1='';
t2='';
t3='';
t4='';
run;


data all_;
merge dummy all_;
by AEBODSYS AEDECOD;
run;

data final;
set all_;
length newv $200.;

if AEDECOD eq '' then newv=AEBODSYS;
else newv= "  "||AEDECOD;

if t1='' then t1="  0";
if t2='' then t2="  0";
if t3='' then t3="  0";
if t4='' then t4="  0";

run;


data final;
set final;
by  AEBODSYS AEDECOD ;
retain lnt page1 0;
lnt+1;

if lnt >17 then do;
page1=page1+1;
lnt=1;
end;
run;



title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 14.1.14 Table 14.1.14  Treatment Emergent Adverse Events by Treatment, System Organ Class and Preferred Term (Safety Population)";

footnote1 j=l "E:\ROSHE30730\PROGRAMS\tab6_1.sas";
options orientation=landscape;
ods escapecahr='^';

ods rtf file ="E:\ROSHE30730\OUTPUTS\14_1_14.rtf" style=styles.test;


PROC REPORT DATA=final NOWD   MISSING
STYLE = {OUTPUTWIDTH=100%} SPLIT="|" SPACING=1 WRAP
STYLE (HEADER) =[JUST=c];

COLUMN  page1 AEBODSYS lnt newv 
("^{style [outputwidth=100% borderbottomcolr=black borderbottomwidth=0.5pt]} Treatment"  t1 t2 t3 t4 );

define page1/order noprint;
define AEBODSYS/order noprint;
DEFINE lnt/ORDER noprint;

DEFINE newv/ORDER "MedDRA® System Organ Class|   MedDRA® Preferred Term"
STYLE (header) =[JUST=L CELLWIDTH=20% asis=on]
STYLE (COLUMN) =[JUST=L CELLWIDTH=20% asis=on];


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



COMPUTE BEFORE _PAGE_;
LINE @1 "^{style [outputwidth=100% bordertopcolr=black bordertopwidth=0.5pt]}";
endcomp;

COMPUTE after _PAGE_;
LINE @1 "^{style [outputwidth=100% bordertopcolr=black bordertopwidth=0.5pt]}";
endcomp;

break after page1/page;

COMPUTE BEFORE AEBODSYS;
LINE '';
ENDCOMP;

run;

ods _all_ close;



