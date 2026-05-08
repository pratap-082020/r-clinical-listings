/*******************************************************************
* Client: ROSHE30730                                                           
* Product:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: Tab7_1.SAS  
*
* Program Type: Table
*
* Purpose: To produce the Table 14.1.16  Summary of Changes in Vital Signs from Baseline to Final Visit (Safety Population)
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 26 sep 2020
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



PROC SUMMARY DATA=adam.advs NWAY ;
where index (avisit, "UNSCHEDULED")=0 and saffl="Y";
CLASS PARAM TRTPN TRTP  AVISITN AVISIT ;
VAR aval;
OUTPUT OUT=ADSL2 
n=n mean=mean median=median min=min max=max std=std;
run;


data adsl3;
set ADSL2;

cn=LEFT (PUT (n,4.));
cmean=LEFT (PUT (mean,5.1));
cmedian=LEFT (PUT (median,5.1));
cstd=LEFT (PUT (std,6.2));
cmin=LEFT (PUT (min,4.));
cmax=LEFT (PUT (max,4.));


run;


PROC SUMMARY DATA=adam.advs NWAY ;
where index (avisit, "UNSCHEDULED")=0 and saffl="Y";
CLASS PARAM TRTPN TRTP  AVISITN AVISIT ;
VAR chg;
OUTPUT OUT=ADSL2_c 
n=n mean=mean median=median min=min max=max std=std;
run;


data adsl3_c;
set ADSL2_c;

cn_c=LEFT (PUT (n,4.));
cmean_c=LEFT (PUT (mean,5.1));
cmedian_c=LEFT (PUT (median,5.1));
cstd_c=LEFT (PUT (std,6.2));
cmin_c=LEFT (PUT (min,4.));
cmax_c=LEFT (PUT (max,4.));



run;

data final;
merge adsl3 adsl3_c;
by PARAM TRTPN TRTP  AVISITN AVISIT;
run;



title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 14.1.16 Summary of Changes in Vital Signs from Baseline to Final Visit (Safety Population) ";
footnote1 j=l "E:\ROSHE30730\PROGRAMS\tab7_1.sas";
options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\ROSHE30730\OUTPUTS\14_1_16.rtf" style=styles.test;


PROC REPORT DATA=final NOWD SPLIT="|" MISSING

STYLE ={OUTPUTWIDTH=100%} SPACING=1 WRAP
STYLE (header)=[just=c];

COLUMN PARAM TRTPN TRTP  AVISITN AVISIT 
( "Observed" "----------------------------------" cn cmean cmedian cstd cmin cmax)
("CFB" "-------------------------------------" cn_c cmean_c cmedian_c cstd_c cmin_c cmax_c);


define PARAM /order "Parameter (units)" noprint
style(column)=[just=left cellwidth = 15%]
style(header)=[just=left cellwidth = 15%]
;
define trtpn/order noprint;


define trtp /order "Planned Treatment"
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;
define AVISITN/order noprint;


define AVISIT /display "Visit" flow
style(column)=[just=left cellwidth = 10%]
style(header)=[just=left cellwidth = 10%]
;


define cn /display "n"style(column)=[just=left cellwidth = 03%]
style(header)=[just=left cellwidth = 03%]
;
define cmean /display "Mean"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;

define cmedian /display "Median"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;

define cstd /display "SD"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;

define cmin /display "Min"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;
define cmax /display "Max"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;



define cn_c /display "n"style(column)=[just=left cellwidth = 03%]
style(header)=[just=left cellwidth = 03%]
;
define cmean_c /display "Mean"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;

define cmedian_c /display "Median"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;

define cstd_c /display "SD"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;

define cmin_c /display "Min"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;
define cmax_c /display "Max"style(column)=[just=left cellwidth = 05%]
style(header)=[just=left cellwidth = 05%]
;

    compute before _page_;

       line @1 'Parameter:  ' PARAM $;
	   line "^{style [outputwidth=100% borderbottomcolour=black borderbottomwidth=0.5pt]}";

  endcomp;
break after param/page;


compute after _page_;
line@1 "^{style [outputwidth=100% bordertopcolour=black bordertopwidth=0.5pt]}";
endcomp;

RUN;

ODS _all_ close; 
