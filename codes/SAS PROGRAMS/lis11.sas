/*******************************************************************
* Client: ROSHE2                                                           
* Product:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: lis11.SAS  
*
* Program Type: Listing
*
* Purpose: To produce the 16.2.2.3 Serious Adverse Events
* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 30 JUL 2020
*******************************************************************/	

libname adam "E:\ROSHE30730\ADAM DATASETS";
libname SDTM "E:\ROSHE30730\SDTM DATASETS";

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


DATA ADAM.ADAE_DUM;
SET ADAM.ADAE;
if AESER="Y" THEN DELETE;
RUN;


OPTIONS MPRINT MLOGIC SYMBOLGEN;
%MACRO AE (V1=,V2=,V3=,V4=);

TITLE1 J=L "AIRIS PHARMA Private Limited.";
TITLE2 J=L "Protocol: 043-1810";
TITLE3 J=C  "&V2";

FOOTNOTE1 J=L "E:\ROSHE\PROGRAMS\&V3.sas";
OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE="E:\ROSHE30730\OUTPUTS\&V4..RTF" STYLE=styles.test;


data ae1;
set adam.ADAE;
spa=strip(aeterm)||"/"||strip (aesoc)||"/"||strip (AEDECOD);

IF &V1;
X='1';
Y='2';
Z='3';
G='44';
H='55';


*if AESER="Y" AND AEOUT="FATAL";

keep usubjid  spa AESTDTC AEENDTC  AESER AEACN AEREL AEOUT X Y Z G H ;
run;
*option mprint mlogic symbolgen;

PROC SQL NOPRINT;
SELECT COUNT (*) INTO: NBR_OBS
FROM ae1;
QUIT;

%PUT &NBR_OBS;

%IF &NBR_OBS EQ 0 %THEN %DO;

DATA AE1;
TEXT="NO OBSERVTIONS";
RUN;

PROC REPORT DATA=AE1;
COLUMN TEXT;
DEFINE TEXT /'';
RUN;
%END;

%IF &NBR_OBS GT 0 %THEN %DO;



ods escapechar='^';

proc report data= ae1 split='|' headline headskip missing style(header)={just= left}  spacing=1  nowd 
													 nowindows headline headskip split='|' missing  style={outputwidth=100%};;

  Column    usubjid  spa AESTDTC AEENDTC  AESER AEACN AEREL AEOUT X Y Z G H;


  Define usubjid /order  "Subj.|No." style(column)=[just=left cellwidth = 9%] ID;;
   Define spa   /DISPLAY   "Adverse Event/Primary System Organ Class/   Preffered term"         style(column)=[just=left cellwidth = 25 %];
   Define AESTDTC    /DISPLAY   "Start Date/Time"         style(column)=[just=left cellwidth = 7%] spacing=1;
   Define AEENDTC    /DISPLAY   "End Date/Time"         style(column)=[just=left cellwidth = 7%];


   Define AEREL   /DISPLAY   "Relationship to |Study Drug"         style(column)=[just= left  cellwidth = 8%];
   Define AEOUT    /DISPLAY   "Outcome"         style(column)=[just=left cellwidth = 8.5%];
     Define AEACN    /DISPLAY   "Action taken"         style(column)=[just=left cellwidth = 9%];
	
	      Define X    /DISPLAY   "X"         style(column)=[just=left cellwidth = 9%];
     Define Y    /DISPLAY   "Y"         style(column)=[just=left cellwidth = 9%];
     Define Z    /DISPLAY   "Z"         style(column)=[just=left cellwidth = 9%];
     Define G    /DISPLAY   "G"         style(column)=[just=left cellwidth = 9%];
     Define H    /DISPLAY   "H"         style(column)=[just=left cellwidth = 9%];

compute before _page_;
line@1 "^{style [outputwidth=100% bordertopcolour=black bordertopwidth=0.5pt]}";
endcomp;


compute after _page_;
line@1 "^{style [outputwidth=100% bordertopcolour=black bordertopwidth=0.5pt]}";
endcomp;


run;

%END;
ods _all_ close;

%MEND;

%AE (V1=%STR( AESER="Y" AND AEOUT="FATAL"),
V2=%STR (16.2.2.2 Serious Adverse Events Leading to Death ),
V3=LIS11,
V4=%STR(16_2_2_2));
  


%AE (V1=%STR( AESER="Y" ),
V2=%STR (16.2.2.3 Serious Adverse Events  ),
V3=LIS11,
V4=%STR(16_2_2_3)); 


%AE (V1=%STR( USUBJID NE " " ),
V2=%STR (16.2.2.4  Adverse Events  ),
V3=LIS11,
V4=%STR(16_2_2_4)); 
