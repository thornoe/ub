/****************************************************************************************/ 
/* Based on the estimation data set and administrative registers, this SAS-program      */
/* produces the data behind Figure 1.                                                   */              
/****************************************************************************************/

dm log 'clear';
dm output 'clear';
options pageno=1 pagesize=100;
goptions reset=all;

options obs=max;

/* Relevante datasæt indlæses */
libname indk 'D:\Rawdata\702487\indk';
libname fain 'D:\Rawdata\702487\fain';
libname skat 'D:\Workdata\702487\Esben\Skatteberegning';
libname idpe 'D:\Rawdata\702487\idpe';
libname udda 'D:\Rawdata\702487\udda';
libname idas 'D:\Rawdata\702487\idas';
libname bif 'D:\Workdata\702487\Esben\Skatteberegning\NYE BEREGNINGER\';
libname lign 'D:\Rawdata\702487\indk_lign';
libname indk2 'D:\Rawdata\702487\indk_ekstra';
libname sskat 'D:\Rawdata\702487\indk_skat';

%macro in;
%do i=1980 %to 1983;

proc sort data=indk.indk&i; by pnr; run;

proc sort data=indk2.indkomst&i; by pnr; run;

proc sort data=idpe.idpe&i; by pnr; run;

data indkomst&i(keep=indkomst pnr year);
merge indk.indk&i (in=a) indk2.indkomst&i (in=b) idpe.idpe&i(keep=pnr alderp in=c);
by pnr;
year=&i;
indkomst=qlontmp2+vederlag+adagp+arblhu+bdagp+qoffpens+qovskvir-qfrdpen+qtilpens+
rentbank+rentobl+rentinde+qovskejd+aktgodt+aktudb-qkapud;
if indkomst<=0 then delete;
alder=alderp+0;
if alder>55 then delete;
if alder<25 then delete;
if a=1 and b=1 and c=1;
run;

%end;
%mend;
%in;

data samle;
set indkomst1980 indkomst1981 indkomst1982 indkomst1983; run;

proc sort data=samle; by year; run;

proc univariate data=samle noprint;
class year;
var indkomst;
output out=bif.percentiles pctlpts=90 95 99 99.5 pctlpre=broad;

run;

data ineq;
merge bif.percentiles samle;
by year;
if indkomst>=broad90 then b90=1; 
if indkomst>=broad95 then b95=1; 
if indkomst>=broad99 then b99=1; 
if indkomst>=broad99_5 then b99_5=1; 

run;

/*broad*/

/* Totalsum  */

proc means data=ineq sum noprint;
var indkomst;
by year;
output out=totalb(drop=_freq_ _type_) sum=totalb;
run;


/* Herefter beregnes for 90% percentilen */
proc sort data=ineq; by year b90; run;

data indkomst90(keep=indkomst year);
set ineq(where=(b90=1));
run;

proc means data=indkomst90 sum noprint;
var indkomst;
by year;
output out=totalb90(drop=_freq_ _type_) sum=totalb90;
run;

/* Her beregnes 90%-percentilens andel af den samlede personlige indkomst */
data bif.samleb90;
merge totalb90 totalb;
by year;
Share_90b=totalb90/totalb;
run;


/* Herefter beregnes for 95% percentilen */
proc sort data=ineq; by year b95; run;

data indkomst95(keep=indkomst year);
set ineq(where=(b95=1));
run;

proc means data=indkomst95 sum noprint;
var indkomst;
by year;
output out=totalb95(drop=_freq_ _type_) sum=totalb95;
run;

/* Her beregnes 95%-percentilens andel af den samlede personlige indkomst */
data bif.samleb95;
merge totalb95 totalb;
by year;
Share_95b=totalb95/totalb;
run;

/* Herefter beregnes for 99% percentilen */
proc sort data=ineq; by year b99; run;

data indkomst99(keep=indkomst year);
set ineq(where=(b99=1));
run;

proc means data=indkomst99 sum noprint;
var indkomst;
by year;
output out=totalb99(drop=_freq_ _type_) sum=totalb99;
run;

/* Her beregnes 99%-percentilens andel af den samlede personlige indkomst */
data bif.samleb99;
merge totalb99 totalb;
by year;
Share_99b=totalb99/totalb;
run;


/* Herefter beregnes for 99.5% percentilen */
proc sort data=ineq; by year b99_5; run;

data indkomst99_5(keep=indkomst year);
set ineq(where=(b99_5=1));
run;

proc means data=indkomst99_5 sum noprint;
var indkomst;
by year;
output out=totalb99_5(drop=_freq_ _type_) sum=totalb99_5;
run;

/* Her beregnes 99_5%-percentilens andel af den samlede personlige indkomst */
data bif.samleb99_5;
merge totalb99_5 totalb;
by year;
Share_99_5b=totalb99_5/totalb;
run;

data bif.ineq1980_1983;
merge bif.samleb90 (keep=year share_90b) 
      bif.samleb95 (keep=year share_95b)
	  bif.samleb99 (keep=year share_99b)
	  bif.samleb99_5 (keep=year share_99_5b);
by year;
run;

Proc print data=bif.ineqalle; run;

data ny;
set bif.tax84_02(keep=pnr year per_income indkomst per_incomestatus);
if per_incomestatus=0 then delete;
if alder>55 then delete;
if alder<25 then delete;
run;


proc univariate data=ny noprint;
class year;
var per_income indkomst;
output out=bif.percentiles pctlpts=90 95 99 99.5 pctlpre=person broad;

run;

data ineq;
merge bif.percentiles ny;
by year;
if per_income>=person90 then p90=1; 
if per_income>=person95 then p95=1; 
if per_income>=person99 then p99=1; 
if per_income>=person99_5 then p99_5=1; 

if indkomst>=broad90 then b90=1; 
if indkomst>=broad95 then b95=1; 
if indkomst>=broad99 then b99=1; 
if indkomst>=broad99_5 then b99_5=1; 

run;


/*per_income*/

/* Totalsum  */

proc means data=ineq sum noprint;
var per_income;
by year;
output out=totalp(drop=_freq_ _type_) sum=totalp;
run;


/* Herefter beregnes for 90% percentilen */
proc sort data=ineq; by year p90; run;

data per_income90(keep=per_income year);
set ineq(where=(p90=1));
run;

proc means data=per_income90 sum noprint;
var per_income;
by year;
output out=totalp90(drop=_freq_ _type_) sum=totalp90;
run;

/* Her beregnes 90%-percentilens andel af den samlede personlige indkomst */
data bif.samlep90;
merge totalp90 totalp;
by year;
Share_90p=totalp90/totalp;
run;


/* Herefter beregnes for 95% percentilen */
proc sort data=ineq; by year p95; run;

data per_income95(keep=per_income year);
set ineq(where=(p95=1));
run;

proc means data=per_income95 sum noprint;
var per_income;
by year;
output out=totalp95(drop=_freq_ _type_) sum=totalp95;
run;

/* Her beregnes 95%-percentilens andel af den samlede personlige indkomst */
data bif.samlep95;
merge totalp95 totalp;
by year;
Share_95p=totalp95/totalp;
run;

/* Herefter beregnes for 99% percentilen */
proc sort data=ineq; by year p99; run;

data per_income99(keep=per_income year);
set ineq(where=(p99=1));
run;

proc means data=per_income99 sum noprint;
var per_income;
by year;
output out=totalp99(drop=_freq_ _type_) sum=totalp99;
run;

/* Her beregnes 99%-percentilens andel af den samlede personlige indkomst */
data bif.samlep99;
merge totalp99 totalp;
by year;
Share_99p=totalp99/totalp;
run;


/* Herefter beregnes for 99.5% percentilen */
proc sort data=ineq; by year p99_5; run;

data per_income99_5(keep=per_income year);
set ineq(where=(p99_5=1));
run;

proc means data=per_income99_5 sum noprint;
var per_income;
by year;
output out=totalp99_5(drop=_freq_ _type_) sum=totalp99_5;
run;

/* Her beregnes 99_5%-percentilens andel af den samlede personlige indkomst */
data bif.samlep99_5;
merge totalp99_5 totalp;
by year;
Share_99_5p=totalp99_5/totalp;
run;

/*broad*/

/* Totalsum  */

proc means data=ineq sum noprint;
var indkomst;
by year;
output out=totalb(drop=_freq_ _type_) sum=totalb;
run;


/* Herefter beregnes for 90% percentilen */
proc sort data=ineq; by year b90; run;

data indkomst90(keep=indkomst year);
set ineq(where=(b90=1));
run;

proc means data=indkomst90 sum noprint;
var indkomst;
by year;
output out=totalb90(drop=_freq_ _type_) sum=totalb90;
run;

/* Her beregnes 90%-percentilens andel af den samlede personlige indkomst */
data bif.samleb90;
merge totalb90 totalb;
by year;
Share_90b=totalb90/totalb;
run;


/* Herefter beregnes for 95% percentilen */
proc sort data=ineq; by year b95; run;

data indkomst95(keep=indkomst year);
set ineq(where=(b95=1));
run;

proc means data=indkomst95 sum noprint;
var indkomst;
by year;
output out=totalb95(drop=_freq_ _type_) sum=totalb95;
run;

/* Her beregnes 95%-percentilens andel af den samlede personlige indkomst */
data bif.samleb95;
merge totalb95 totalb;
by year;
Share_95b=totalb95/totalb;
run;

/* Herefter beregnes for 99% percentilen */
proc sort data=ineq; by year b99; run;

data indkomst99(keep=indkomst year);
set ineq(where=(b99=1));
run;

proc means data=indkomst99 sum noprint;
var indkomst;
by year;
output out=totalb99(drop=_freq_ _type_) sum=totalb99;
run;

/* Her beregnes 99%-percentilens andel af den samlede personlige indkomst */
data bif.samleb99;
merge totalb99 totalb;
by year;
Share_99b=totalb99/totalb;
run;


/* Herefter beregnes for 99.5% percentilen */
proc sort data=ineq; by year b99_5; run;

data indkomst99_5(keep=indkomst year);
set ineq(where=(b99_5=1));
run;

proc means data=indkomst99_5 sum noprint;
var indkomst;
by year;
output out=totalb99_5(drop=_freq_ _type_) sum=totalb99_5;
run;

/* Her beregnes 99_5%-percentilens andel af den samlede personlige indkomst */
data bif.samleb99_5;
merge totalb99_5 totalb;
by year;
Share_99_5b=totalb99_5/totalb;
run;

data bif.ineq1984_2005;
merge bif.samlep90 (keep=year share_90p) bif.samleb90 (keep=year share_90b) 
      bif.samlep95 (keep=year share_95p) bif.samleb95 (keep=year share_95b)
	  bif.samlep99 (keep=year share_99p) bif.samleb99 (keep=year share_99b)
	  bif.samlep99_5 (keep=year share_99_5p) bif.samleb99_5 (keep=year share_99_5b);
by year;
run;

proc print data=bif.ineq1980_1983; run;
proc print data=bif.ineq1984_2005; run;



