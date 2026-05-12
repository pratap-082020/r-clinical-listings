/*******************************************************************
* Client: ROSHE30730                                                           
* Product:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: Tab11_1.SAS  
*
* Program Type: Listing
*
* Purpose: To produce the 
Table 14.1.24  Survival Estimates (Safety Population)

* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 11 NOV 2020
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

DATA ADTTE;
SET adam.adtte;
IF SAFFL="Y" ;
RUN;


ODS TRACE ON;

ODS OUTPUT CensoredSummary =_censorsum
 Means =_mean
 Quartiles =_quartiles
  HomTests =_HomTests;

proc lifetest data=adtte plots=(s);

   time aval * CNSR (0);

   strata trt01p;

   

run;

ODS TRACE OFF; 


proc sort data=_censorsum;by STRATUM;run;

data final;
merge _censorsum _mean ;
by STRATUM;
run;

data final1;
set final;
if control_var ne '-';


MEANST= STRIP(PUT (MEAN,6.3)) || " ("|| STRIP (PUT(StdErr,6.3))||")";
run;


 proc transpose data=final1 out=all_ prefix=tt;

 id STRATUM;
var Total MEANST ;
 run;
 data all_;
 set all_;
t1=put (tt1,6.3);
t2= put (tt2,6.3);
t3=put (tt3,6.3);
run;



 data _quartiles;
 set _quartiles;
if Estimate ne .;
range=trim (put (Estimate,6.3))||'('||trim (put (LowerLimit,6.3))||","||
        trim (put (UpperLimit,6.3))||")";
		run;
proc sort;by Percent;run;

 proc transpose data=_quartiles out=all_2 prefix=t;

 id STRATUM ;
by Percent ;
var range;
 run;

 data all_3;
 set _HomTests;
 pvalue=trim (put (ProbChiSq,pvalue7.3));
 if Test ="Log-Rank";
 run;

 data f;
 set  all_2 all_3 all_;
 run;

 data final_f;
 set f;
 if _name_="Total" then do;od=1;var="Number of Subjects";end;
 if _name_="Mean" then do;od=2;var="Mean";end;
 if _name_="StdErr" then do;od=3;var="STD ERROR";end;

 if Percent=25 then do;od=4;var="25 Percentile";end;
 if Percent=50 then do;od=5;var="50 Percentile";end;
 if Percent=75 then do;od=6;var="75 Percentile";end;

 if pvalue ne . then do;od=7;var="pvalue";end;
 keep od var t1 t2 t3 pvalue;
 run;
proc sort;by od;run;

title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 14.1.24  Survival Estimates";

options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\ROSHE30730\OUTPUTS\14_1_24.rtf" style=styles.test;

PROC REPORT DATA=final_f NOWD SPLIT="|" MISSING

STYLE ={OUTPUTWIDTH=100%} SPACING=1 WRAP
STYLE (header)=[just=l];

COLUMN   od var t1 t2 t3  pvalue;

define od/order noprint;
define var /order "Parameter"
style(column)=[just=left cellwidth = 20%]
style(header)=[just=left cellwidth = 20%]
;  



define t1 /display "DRUG A"
style(column)=[just=left cellwidth = 15%]
style(header)=[just=left cellwidth = 15%]
;  

define t2 /display "DRUG B"
style(column)=[just=left cellwidth = 15%]
style(header)=[just=left cellwidth = 15%]
;  

define t3/display "DRUG C"
style(column)=[just=left cellwidth = 15%]
style(header)=[just=left cellwidth = 15%]
; 


 
define pvalue /display "P-Value"
style(column)=[just=left cellwidth = 15%]
style(header)=[just=left cellwidth = 15%]
;  

compute before _page_;
line@1 "^{style [outputwidth=100% bordertopcolour=black bordertopwidth=0.5pt]}";
endcomp;


compute after _page_;
line@1 "^{style [outputwidth=100% bordertopcolour=black bordertopwidth=0.5pt]}";
endcomp;

RUN;

ODS _all_ close; 
