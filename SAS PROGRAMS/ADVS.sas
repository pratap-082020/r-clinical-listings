/*******************************************************************
* Client: ROSHE2                                                           
* adamuct:                                                   
* Project: 043-1810 /AIRIS PHARMA Private Limited                                                   
* Program: ADVS.SAS  
*
* Program Type: ADaM
*
* Purpose: To adamuce the 
ADVS

* Usage Notes: 
*
* SAS® Version: 9.4 
* Operating System: Windows 2007 R2 Standard Edition.                   
*
* Author: Shiva 
* Date Created: 29 OCT 2020
*******************************************************************/	
libname adam "E:\ROSHE2\ADAM DATASETS";
libname sdtm "E:\ROSHE2\SDTM DATASETS";

**********READING ADSL DATASET******************;

PROC SORT DATA=ADAM.ADSL OUT=ADSL;
BY USUBJID;
RUN;

************READING VS DATASET**********;

PROC SORT DATA=SDTM.VS OUT=VS;
BY USUBJID;
WHERE VSSTAT NE 'NOT DONE';
RUN;

*********MERGE ADSL AND VS INFO*****************;

DATA VS1;
MERGE VS (IN=A) ADSL (IN=B);
BY USUBJID;
IF A AND B;
RUN;

DATA VS1;
FORMAT ADT DATE9.;
SET VS1;

IF LENGTH(VSDTC)>=10 THEN ADT= INPUT (SUBSTR (VSDTC,1,10),YYMMDD10.);

IF ADT NE . AND TRTSDT NE . THEN DO;
IF ADT >= TRTSDT THEN ADY=(ADT-TRTSDT+1);
ELSE ADY=(ADT-TRTSDT);
END;

TRTP=TRT01P;
TRTPN=TRT01PN;

TRTA=TRTP;
TRTAN=TRTPN;

AVISIT=VISIT;
AVISITN=VISITNUM;

IF VSTEST NE '' THEN DO;

PARAMCD=VSTESTCD;
PARAM= STRIP (VSTEST) || " ("|| STRIP (VSSTRESU)||")";
END;

AVAL=VSSTRESN;
AVALC=VSSTRESC;

RUN;

PROC SORT DATA=VS1 OUT=VS2;
BY USUBJID PARAM AVISITN ADT;RUN;



DATA BASE POST_BASE;
SET VS2 (WHERE= (ADT NE . AND TRTSDT NE .));
BY USUBJID PARAM AVISITN ADT;

IF ADT LE TRTSDT THEN DO;
BLFL="Y";
OUTPUT BASE;
END;
ELSE DO;
OUTPUT POST_BASE;
END;
RUN;

DATA BASE1;
SET BASE;
BY USUBJID PARAM AVISITN ADT;
IF LAST.PARAM AND AVAL NE . THEN ABLFL="Y";
RUN;

DATA ALL;
SET BASE1 POST_BASE;
BY USUBJID PARAM AVISITN ADT;
RUN;

*********************30 OCT 2020********************;


/*******************************************
BASE
PCHG
*******************************************/

proc sort data = all out = all_srt;
  by usubjid param avisitn adt;
run;

data flvs;
  do until (last.param);
    set all_srt;
    by usubjid param avisitn adt;
    if ablfl = "Y"  then do;
       base = aval ;
	   basec = avalc ;
       dvseqn = avisitn;
    end;
    output;
  end;
run;

data chgvs;
   do until (last.param);
      set flvs;
      by usubjid param avisitn adt ;
      if  dvseqn ne . and avisitn gt dvseqn   then do;
        chg = (aval-base);
        if chg ne 0 and base ne 0 then pchg=(chg/base)*100;
		 else pchg=0 ;
      end;
      output;
    end;
proc sort ;by usubjid param avisitn adt ;
run;


/*No Missing aval to expalin locf assigning missing*/

data chgvs;
set chgvs;
if usubjid eq "043-18101-74001-001" and PARAMCD="BSA"
and avisit="CYCLE 1 DAY 8" then do;
aval=.;
AVALC='';
end;
if usubjid eq "043-18101-74001-001" and paramcd="BSA";
run;


*********locf*******************;

data val1;
set chgvs;

*keep usubjid paramcd avisitn avisit aval;
run;
PROC SORT;BY avisitn;RUN;

proc sort data=val1 out=vis1 /*(keep=avisit avisitn USUBJID PARAMCD)*/
nodupkey;
by avisitn;
where index (avisit,"UNSC")=0;
run;

PROC SORT DATA=VIS1;BY USUBJID PARAMCD AVISITN;RUN;
PROC SORT DATA=VAL1;BY USUBJID PARAMCD AVISITN;RUN;

data final1;
 retain tempvar 0;
 merge vis1 val1;
 by  USUBJID PARAMCD AVISITN;


 IF FIRST.PARAMCD AND AVAL EQ . THEN AVAL=9999;


 if AVAL=. then DO;AVAL=tempvar;DTYPE="LOCF";END;
 else tempvar=AVAL;


 IF AVAL EQ 9999 THEN DO;AVAL=.;END;
run; 


/*WOCF*/
data final11;
 retain tempvar 0;
 merge vis1 val1;
 by  USUBJID PARAMCD AVISITN;
 IF FIRST.PARAMCD AND AVAL EQ . THEN AVAL=9999;


 if AVAL=. then DO;AVAL=tempvar;DTYPE="WOCF";END;
 else tempvar=AVAL;

 IF AVAL EQ 9999 THEN DO;AVAL=.;END;
 IF USUBJID EQ "043-18101-74001-001";
run; 
PROC SQL;
CREATE TABLE FINAL2 AS
SELECT *, MIN (AVAL) AS AVAL2 FROM final11
GROUP BY USUBJID, PARAMCD
ORDER BY USUBJID, PARAMCD;
QUIT;

DATA FINAL3;
SET FINAL2;
IF DTYPE="WOCF" THEN AVAL=AVAL2;
RUN;
PROC SORT;BY USUBJID AVISITN;RUN;


**********AVERAGE OR INSERT A ROW*****************;

PROC SORT DATA=val1 OUT=VS4_;
BY USUBJID  PARAM AVISITN AVISIT  VSDTC;
*WHERE USUBJID EQ "043-18101-74001-002" AND VSTESTCD EQ "TEMP";
RUN;

DATA VS5;
SET VS4_ (drop=avalc);
BY USUBJID  PARAM AVISITN AVISIT  VSDTC;

FORMAT ASUM ACOUNT 8.2;
RETAIN ASUM ACOUNT;

IF FIRST.PARAM THEN DO;
ACOUNT=1;

IF AVAL NE . THEN ASUM=AVAL;
ELSE ASUM=.;
END;
ELSE DO;
IF AVAL NE . THEN DO;
ASUM=ASUM+AVAL;
ACOUNT=ACOUNT+1;
END;
END;
OUTPUT;


IF LAST.PARAM THEN DO;
IF PARAM NE '' AND NOT (FIRST.PARAM) AND ASUM NE . THEN DO;
AVAL=ASUM/ACOUNT;
DTYPE="AVERAGE";
OUTPUT;
END;
END;
run;

data vs6;
set vs5;
AVALC=PUT (AVAL,BEST.);
RUN;

    data vs7; 
	SET vs6;
	BY studyid usubjid param avisitn adt;
	IF first.usubjid THEN ASEQ=1;
		ELSE ASEQ+1;

		if index (avisit,"UNSC")=0 then  ANL01FL="Y";
		
		run;

data final;
set vs7;
keep
STUDYID
USUBJID
SUBJID
SITEID
SAFFL
ARMCD
ARM
ACTARMCD
ACTARM
TRTP
TRTA
ASEQ
ADT
ADY
AVISIT
AVISITN
PARAM
PARAMCD
AVAL
AVALC
BASE
BASEC
CHG
PCHG
ABLFL
ANL01FL
VSSEQ
VSTESTCD
VSTEST
VSPOS
VSORRES
VSORRESU
VSSTRESC
VSSTRESN
VSSTRESU
VSSTAT
VSREASND
VSBLFL
VISITNUM
VISIT
EPOCH
VSDTC
VSDY
;
run;





