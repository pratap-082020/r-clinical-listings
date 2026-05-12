/*******************************************************************
* Client: ROSHE2                                                           
* Product:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: lis9.SAS  
*
* Program Type: Listing
*
* Purpose: To produce the 16.2.1.5 Withdrawals from the Study
* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 25 JUL 2020
*******************************************************************/	

libname adam "E:\ROSHE2\ADAM DATASETS";
libname sdtm "E:\ROSHE2\SDTM DATASETS";	



**********KEEPING THE REQUIRED VARIABLES***********************;

DATA vs;
 SET adam.advs;
  KEEP USUBJID PARAM  AVISITN AVISIT AVAL ADT TRTP
;
RUN;

PROC SORT;BY USUBJID PARAM AVISITN AVISIT;RUN;

  

DATA vs1;
SET vs;
BY USUBJID PARAM AVISITN AVISIT;

RETAIN lnt page1 0;
lnt+1;

if lnt>15 then do;
page1=page1+1;
lnt=1;
end;
run;



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


title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "16.2.1.9 Vital Signs";

footnote1 j=l "E:\ROSHE2\PROGRAMS\lis9.sas";
options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\ROSHE2\OUTPUTS\16_2_1_9.rtf" style=styles.test;



PROC REPORT DATA=vs1 NOWD SPLIT="|" MISSING

STYLE ={OUTPUTWIDTH=100%} SPACING=1 WRAP
STYLE (header)=[just=l];

COLUMN PAGE1 USUBJID PARAM  AVISITN AVISIT AVAL ADT TRTP;

DEFINE PAGE1/ORDER NOPRINT;

DEFINE USUBJID /ORDER "Subject" STYLE (COLUMN)=[JUST=LEFT CELLWIDTH=13%];
DEFINE PARAM /ORDER "Parameter (unit) "
STYLE (COLUMN)=[JUST=LEFT CELLWIDTH=20%];

DEFINE AVISITN/ORDER NOPRINT;

DEFINE AVISIT /DISPLAY "Visit" STYLE (COLUMN)=[JUST=LEFT CELLWIDTH=13%];
DEFINE AVAL /DISPLAY "Observed value " STYLE (COLUMN)=[JUST=LEFT CELLWIDTH=10%];
DEFINE ADT /DISPLAY "Date/Time of|Measurements " STYLE (COLUMN)=[JUST=LEFT CELLWIDTH=10%];

DEFINE TRTP /DISPLAY "Planned|treatment " STYLE (COLUMN)=[JUST=LEFT CELLWIDTH=10%];

compute before _page_;
line@1 "^{style [outputwidth=100% BORDERTOPCOLOR=black bordertopwidth=0.5pt]}";
endcomp;


compute after _page_;
line@1 "^{style [outputwidth=100% BORDERTOPCOLOR=black bordertopwidth=0.5pt]}";
endcomp;

BREAK AFTER PAGE1/PAGE;

COMPUTE AFTER PARAM;
LINE '';

ENDCOMP;
RUN;

ODS _all_ close;




