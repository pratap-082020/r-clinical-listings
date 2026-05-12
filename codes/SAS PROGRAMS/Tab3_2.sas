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
MODIFICATION :
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
if TRT01P ne '' and DLTEVLFL="Y";
output;
TRT01P="Overall";
trt01pn=5;
output;
keep usubjid trt01p trt01pn saffl DLTEVLFL age;
run;



PROC SQL NOPRINT;
CREATE TABLE TRT AS
SELECT trt01pn,trt01p, COUNT (DISTINCT USUBJID) AS DENOM FROM ADSL
GROUP BY TRT01PN,TRT01P
ORDER BY TRT01PN,TRT01P;


QUIT;

data dummy;
do trt01pn= 1 to 5;
output;
end;
run;
data dummy1;
set dummy;
DENOM=0;
run;

data trt1;
merge dummy1 TRT;
by trt01pn;
run;

proc sql;
SELECT DENOM INTO: n1 - :n5 from trt1;
QUIT;
%put &n1 &n2 &n3 &n4 &n5;





proc summary data=adsl nway;
class trt01pn trt01p;
var age;
output out=adsl2
n=n mean=mean median=median min=min max=max std=std;
run;
/**/
/*rule for decimals*/
/*min max=no need decimal*/
/*median mean=1*/
/*sd=2*/
/*n no decimal*/
/**/
/*var dont have decimal*/


/*AGE 40.12*/

data adsl3;
set adsl2;

cn= left (put (n,3.));
cmean=left (put(mean,4.1));
cmedian=left (put(median,4.1));
cstd=left (put(std,5.2));

cmin= left (put (min,3.));
cmax= left (put (max,3.));
run;

proc transpose data=adsl3 out= adsl4 prefix=t;
id trt01pn;
var cn cmean cmedian cstd cmin cmax;
run;

data adsl5;
set adsl4;
length stat $100.;
if _name_="cn" then do; stat="N";od=1;end;
if _name_="cmean" then do; stat="Mean";od=2;end;
if _name_="cstd" then do; stat="SD";od=3;end;
if _name_="cmedian" then do; stat="Median";od=4;end;

if _name_="cmin" then do; stat="Minimum";od=5;end;
if _name_="cmax" then do; stat="Maximum";od=6;end;

run;

data label;
length stat $100.;
stat="Age (Years)";
od=0;
run;

data adsl6;
set label adsl5;
run;
proc sort;by od;run;

data dum;
set adsl6 (keep=od);
length t1 t2 t3 t4 t5 $5.;
t1=" ";
t2=" ";t3=" ";t4=" ";t5=" ";

run;

data adsl7 ;
merge dum adsl6;
by od;
if stat="N" then do;
if t1="" then t1="  0";
if t4="" then t4="  0";
end;
run;


title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 14.1.7  Subject Demographics - Age (DLT Evaluable Population)";
footnote1 j=l "E:\ROSHE30730\PROGRAMS\tab2_1.sas";
options orientation=landscape;
ods escapecahr='^';

ods rtf file ="E:\ROSHE30730\OUTPUTS\14_1_7.rtf" style=styles.test;


PROC REPORT DATA=adsl7 NOWD   MISSING
STYLE = {OUTPUTWIDTH=100%} SPLIT="|" SPACING=1 WRAP
STYLE (HEADER) =[JUST=L];

COLUMN  od stat  t1 t2 t3 t4 t5;

define od/order noprint;
DEFINE stat/DISPLAY "CATEGORY"
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



