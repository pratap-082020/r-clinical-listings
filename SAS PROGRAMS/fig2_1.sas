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
title 'Distribution of Blood Pressure';

data heart;
set sashelp.heart;
keep diastolic systolic ;
run;

proc sgplot data=heart;
   histogram diastolic / fillattrs=graphdata1 transparency=0.7 binstart=40 binwidth=10;
   density diastolic / lineattrs=graphdata1;
   histogram systolic / fillattrs=graphdata2 transparency=0.5 binstart=40 binwidth=10;
   density systolic / lineattrs=graphdata2;
   keylegend / location=inside position=topright noborder across=2;
   yaxis grid;
   xaxis display=(nolabel) values=(0 to 300 by 50);
run;






/*Example :01*/

data vs;
set adam.advs;
if PARAM in ("Systolic Blood Pressure (mmHg)"
"Diastolic Blood Pressure (mmHg)") and saffl="Y" ;
keep usubjid PARAM aval avisit ;
run;
proc sort nodupkey;by usubjid  avisit  PARAM ;run;

proc transpose data=vs out=vs1;
by usubjid avisit ;
id param;
var aval;
run;

data vs2;
set vs1;
diastolic=Diastolic_Blood_Pressure__mmHg_;
systolic=Systolic_Blood_Pressure__mmHg_;
keep  diastolic systolic ;
run;


title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Figre 16.2.1  Distribution of Blood Pressure (Safety Popu;ation)";

options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\ROSHE30730\OUTPUTS\16_2_1.rtf" style=styles.test;

proc sgplot data=vs2;
   histogram diastolic / fillattrs=graphdata1 transparency=0.7 binstart=40 binwidth=10;
   density diastolic / lineattrs=graphdata1;
   histogram systolic / fillattrs=graphdata2 transparency=0.5 binstart=40 binwidth=10;
   density systolic / lineattrs=graphdata2;
   keylegend / location=inside position=BOTTOMRIGHT border across=2;
   yaxis grid;
   xaxis  values=(0 to 300 by 50);
run;

ods _all_ close;

