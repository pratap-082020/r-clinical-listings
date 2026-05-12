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

data adlb;
set adam.adlb;
if paramcd eq "CREAT";
keep usubjid aval;
if saffl="Y";
run;

data adsl;
set adam.adsl;
keep usubjid agegr1 age;
if saffl="Y";
run;
data lb2;
merge adlb (in=a) adsl (in=b);
label cholesterol ="Creatinine (umol/L)";
by usubjid;
if a and b;
cholesterol=aval;
AgeAtStart=agegr1;
KEEP AgeAtStart cholesterol;
run;




title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Figure 16.1.1  Creatinine (umol/L) Level by Age Range (Safety Population)";

options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\ROSHE30730\OUTPUTS\16_1_1.rtf" style=styles.test;

proc sgplot data=lb2 ;
   styleattrs datacolors=(red green )
    ;
   vbox cholesterol / category=AgeAtStart group=AgeAtStart;
   *format AgeAtStart agefmt.;
run;

ODS _all_ close; 
