/*******************************************************************
* Client: ROSHE30730                                                           
* Product:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: Tab6_1.SAS  
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

data admh;
set adam.admh;
if mhcat="MEDICAL HISTORY" and saffl="Y" and trtp ne '';
 if mhbodsys = "" then mhbodsys = "UNCODED";
    if mhdecod = "" then mhdecod = "UNCODED";
keep usubjid trtp trtpn mhBODSYS mhDECOD;
run;


PROC SQL NOPRINT;
 CREATE TABLE ANY1 AS
 SELECT trtpN, trtp, COUNT ( DISTINCT USUBJID) AS n,
 "  Number of Subjects with one Medical History" as mhBODSYS length=200
 from admh
 group by trtpn,trtp;


  CREATE TABLE soc AS
 SELECT trtpN, trtp,mhBODSYS, COUNT ( DISTINCT USUBJID) AS n
 from admh
 group by trtpn,trtp,mhBODSYS;

  CREATE TABLE pt AS
 SELECT trtpN, trtp,mhBODSYS,mhDECOD, COUNT ( DISTINCT USUBJID) AS n
 from admh
 group by trtpn,trtp,mhBODSYS,mhDECOD;

 quit;
 data all;
 set any1 soc pt;
 run;

 
 DATA FINAL;
 SET all;
 NN=n;
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

 IF trtpN=3 THEN DO;
 IF NN=. OR NN=0 THEN GRPA_1="0";
 ELSE IF NN=&n3 then GRPA_1 =compress (nn)||" (100)";
 else GRPA_1 =put (nn,3.)||" ("|| put (nn/&n3*100,4.1)||")";
 end;

 IF trtpN=4 THEN DO;
 IF NN=. OR NN=0 THEN GRPA_1="0";
 ELSE IF NN=&n4 then GRPA_1 =compress (nn)||" (100)";
 else GRPA_1 =put (nn,3.)||" ("|| put (nn/&n4*100,4.1)||")";
 end;


 run;

 
proc sort;by mhBODSYS mhDECOD;run;

proc transpose data=final out=all_ prefix=t;
by mhBODSYS mhDECOD;
id trtpn;
var GRPA_1;
run;

data dummy;
set all_ (keep=mhBODSYS mhDECOD);
length t1 t2 t3 t4 $20.;
t1="";
t2="";
t3="";
t4="";
run;

data all_;
merge dummy all_;
by mhBODSYS mhDECOD;
run;

data final;
set all_;
length newv $200.;
if mhDECOD eq '' then newv=mhBODSYS;
else newv="   "||mhDECOD;

if t1="" then t1="  0";
if t2="" then t2="  0";
if t3="" then t3="  0";
if t4="" then t4="  0";
run;


DATA final;
SET final;
BY mhBODSYS mhDECOD;

RETAIN lnt page1 0;
lnt+1;

if lnt>17 then do;
page1=page1+1;
lnt=1;
end;
run;



title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 14.1.20  Medical History by Treatment, 
System Organ Class and Preferred Term (Safety Population)";

footnote1 j=l "E:\ROSHE30730\PROGRAMS\tab9_1.sas";
options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\ROSHE30730\OUTPUTS\14_1_20.rtf" style=styles.test;


PROC REPORT DATA=final NOWD SPLIT="|" MISSING

STYLE ={OUTPUTWIDTH=100%} SPACING=1 WRAP
STYLE (header)=[just=l];

COLUMN page1 lnt newv t1 t2 t3 t4 ;

define page1/order noprint;
define lnt/order noprint;

define newv /ORDER "MedDRA® System Organ Class|   MedDRA® Preferred Term"
style(column)=[just=left cellwidth = 20% asis=on]
style(header)=[just=left cellwidth = 20% asis=on]
;

define t1 /display "DRUG A|(N = &n1)"
style(column)=[just=left cellwidth = 5%]
style(header)=[just=left cellwidth = 5%]
;  

define t2 /display "DRUG B|(N = &n2)"
style(column)=[just=left cellwidth = 5%]
style(header)=[just=left cellwidth = 5%]
;    

define t3 /display "DRUG C|(N = &n3)"
style(column)=[just=left cellwidth = 5%]
style(header)=[just=left cellwidth = 5%]
;    

define t4 /display "DRUG D|(N = &n4)"
style(column)=[just=left cellwidth = 5%]
style(header)=[just=left cellwidth = 5%]
;    


compute before _page_;
line@1 "^{style [outputwidth=100% bordertopcolour=black bordertopwidth=0.5pt]}";
endcomp;


compute after _page_;
line@1 "^{style [outputwidth=100% bordertopcolour=black bordertopwidth=0.5pt]}";
endcomp;

break after page1/page;
RUN;

ODS _all_ close; 
