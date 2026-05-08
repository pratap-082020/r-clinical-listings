/*******************************************************************
* Client: AIRIS PHARMA Private Limited                                                           
* Product:                                                   
* Project: Protocol: 043-1810                                                    
* Program: lis7.SAS  
*
* Program Type: Listing
*
* Purpose: To produce the 16.2.1.5 Withdrawals from the Study
* Usage Notes: 
*
* SAS® Version: 9.4 [TS2M0]
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: shiva
* Date Created: 16 oct 2020
*******************************************************************/				

libname adam "E:\ROSHE30730\ADAM DATASETS";
libname SDTM "E:\ROSHE30730\SDTM DATASETS";

OPTIONS MPRINT MLOGIC SYMBOLGEN;
%MACRO LAB (V1=,V2=,V3=,V4=);
DATA LB;
SET ADAM.ADLB;

IF PARCAT1 ="&V1" AND ANRIND NOT IN (" " "NORMAL");

IF ANRLO NE '' AND ANRHI NE '' THEN DO;
LH= STRIP (ANRLO) ||"-"|| STRIP (ANRHI);
END;

KEEP USUBJID PARAMN PARAM AVISITN AVISIT LH ADT AVAL ANRIND;
RUN;

PROC SORT;BY USUBJID PARAMN PARAM AVISITN AVISIT;RUN;



**********PAGE NUMBER*************************;

DATA LB1;
SET LB;
BY USUBJID PARAMN PARAM AVISITN AVISIT;
RETAIN LNT PAGE1 0;
LNT+1;

IF LNT>15  THEN DO;
PAGE1=PAGE1+1;
LNT=1;
END;
RUN;



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

TITLE1 J=L "AIRIS PHARMA Private Limited.";
TITLE2 J=L "Protocol: 043-1810";
TITLE3 J=C  "&V2";

FOOTNOTE1 J=L "E:\ROSHE\PROGRAMS\&V3.sas";
OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE="E:\ROSHE30730\OUTPUTS\&V4..RTF" STYLE=styles.test;



PROC REPORT DATA=LB1 NOWD SPLIT="|" MISSING
STYLE ={OUTPUTWIDTH=100%} SPACING=1 WRAP
STYLE (HEADER)= [JUST=LEFT];

COLUMN PAGE1 USUBJID PARAMN PARAM AVISITN AVISIT LH ADT AVAL ANRIND;
DEFINE PAGE1/ORDER NOPRINT;

DEFINE USUBJID /ORDER "Subject Number"
STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=15%] ;
DEFINE PARAMN/ORDER NOPRINT ORDER=DATA;
DEFINE PARAM /ORDER "Test"
STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=19%];
DEFINE AVISITN/ORDER NOPRINT ORDER=DATA;

DEFINE AVISIT /ORDER "Visit"
STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=16%];

DEFINE LH/DISPLAY "Normal Range"
STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=10%];



DEFINE ADT /DISPLAY "Date/Time of|Measurement"
STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=10%];
DEFINE AVAL /DISPLAY "Result"
STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=10%];


DEFINE ANRIND /DISPLAY "Flag"
STYLE (COLUMN) =[JUST=LEFT CELLWIDTH=10%];


COMPUTE BEFORE _PAGE_;
LINE@1 "^{style [outputwidth=100% bordertopcolor=black bordertopwidth=0.5pt]}";
endcomp;


COMPUTE after _PAGE_;
LINE@1 "^{style [outputwidth=100% bordertopcolor=black bordertopwidth=0.5pt]}";
endcomp;

BREAK AFTER PAGE1/PAGE;
RUN;

ODS _ALL_ CLOSE;
%MEND;

%LAB (V1=CHEMISTRY,V2=%STR (16.2.1.7 Abnormal Biochemistry Values),
V3=LIS7,V4=%STR(16_2_1_7));

%LAB (V1=HEMATOLOGY,V2=%STR (16.2.1.8 Abnormal HEMATOLOGY Values),
V3=LIS8,V4=%STR(16_2_1_8));

















