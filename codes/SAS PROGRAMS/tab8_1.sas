/*******************************************************************
* Client: ROSHE30730                                                           
* Product:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: Tab5_1.SAS  
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


DATA ADSL;
SET ADAM.ADSL;
IF TRT01P NE '' AND SAFFL="Y";
OUTPUT;
TRT01P="Overall";
TRT01PN=5;
OUTPUT;
KEEP USUBJID TRT01P TRT01PN SAFFL DLTEVLFL ENRLFL SEX RACE ;
RUN;

PROC SQL  NOPRINT;
CREATE TABLE TRT AS
SELECT TRT01PN,TRT01P, COUNT (DISTINCT (USUBJID)) AS DENOM FROM ADSL
GROUP BY TRT01PN,TRT01P
ORDER BY TRT01PN, TRT01P;

SELECT DENOM INTO: n1 - :n5 from trt;
QUIT;
%put &n5;

data lb1;
set adam.adlb;

if saffl="Y" and index (avisit,"UNSCH")=0 and 
parcat1 in ("CHEMISTRY" "HEMATOLOGY");

if BNRIND eq '' then BNRIND="Missing";
if ANRIND eq '' then ANRIND="Missing";

keep usubjid parcat1 paramn param BNRIND ANRIND avisitn ;
run;
proc sort; by usubjid parcat1 paramn ;run;

data lb2;
set lb1;
by usubjid parcat1 paramn ;
if last.paramn ;
run;
proc freq data=lb2 noprint;
tables parcat1*paramn*param*BNRIND*ANRIND/out=lb3 (drop=PERCENT);
where BNRIND ne '' and ANRIND ne '';
run;

data lb4;
set lb3;
length GRPA_1 $20.;

 IF count=. OR count=0 THEN GRPA_1="0";
 ELSE IF count=&n5 then GRPA_1 =compress (count)||" (100)";
 else GRPA_1 =put (count,3.)||" ("|| put (count/&n5*100,4.1)||")";
 
run;

proc transpose data=lb4 out=lb5;
by parcat1 paramn param BNRIND;
id ANRIND;
var GRPA_1;
run;
data lb6;
set lb5;
if low="" then low="  0";
if high="" then high="  0";
if normal="" then normal="  0";
run;

DATA lb7;
SET lb6;
BY parcat1;

RETAIN lnt page1 0;
lnt+1;

if lnt>17 then do;
page1=page1+1;
lnt=1;
end;
run;


title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 14.1.18 Shift Table from Baseline to End of period (Safety Population)";

footnote1 j=l "E:\ROSHE30730\PROGRAMS\tab8_1.sas";
options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\ROSHE30730\OUTPUTS\14_1_18.rtf" style=styles.test;



PROC REPORT DATA=lb7 NOWD SPLIT="|" MISSING

STYLE ={OUTPUTWIDTH=100%} SPACING=1 WRAP
STYLE (header)=[just=c];

COLUMN page1  parcat1 paramn param BNRIND
("^{style [outputwidth=100% borderbottomcolour=black borderbottomwidth=0.5pt]} 
Treatment  end|(N=&n5)" low normal high);

define page1/order noprint;
define parcat1 /order "Parameter|category"
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;
define paramn/order noprint;
define param /order "Parameter (Unit)"
style(column)=[just=left cellwidth = 20%]
style(header)=[just=left cellwidth = 20%]
;
define BNRIND/display "Baseline"
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;

define low /display "Low"
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;

define normal /display "Normal"
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;

define high /display "High"
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
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

