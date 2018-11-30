/****************************************************************************************/ 
/* Based on the estimation data set, this SAS-program produces Panel D of Figure 2.     */              
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


data j(keep=pnr year);
set bif.tax84_02(where=(2000<=year<=2002));
run;

proc sort data=j; by pnr year; run;

data kurt2003(keep=pnr year top_dummy mellem_dummy bund_dummy notax_dummy);
set bif.skat2003(drop=year);
year=2000;
run;

proc sort data=kurt2003; by pnr year;

data merge2003;
merge j(in=q) kurt2003(in=u);
by pnr year;
if q=1 and u=1;
run;

proc means data=merge2003; var top_dummy mellem_dummy bund_dummy notax_dummy; class year; run;


data kurt2004(keep=pnr year top_dummy mellem_dummy bund_dummy notax_dummy);
set bif.skat2004(drop=year);
year=2001;
run;

proc sort data=kurt2004; by pnr year;

data merge2004;
merge j(in=q) kurt2004(in=u);
by pnr year;
if q=1 and u=1;
run;

proc means data=merge2004; var top_dummy mellem_dummy bund_dummy notax_dummy; class year; run;


data kurt2005(keep=pnr year top_dummy mellem_dummy bund_dummy notax_dummy);
set bif.skat2005(drop=year);
year=2002;
run;

proc sort data=kurt2005; by pnr year;

data merge2005;
merge j(in=q) kurt2005(in=u);
by pnr year;
if q=1 and u=1;
run;

proc means data=merge2005; var top_dummy mellem_dummy bund_dummy notax_dummy; class year; run;




%macro skat;
%do i=1984 %to 2005;

data j;
set bif.tax84_02(keep=year pnr tt tm tb tn mt mm mb mn bt bm bb bn nt nm nb nn);
if tt=1 or tm=1 or tb=1 or tn=1 then top=1; else top=0;
if mt=1 or mm=1 or mb=1 or mn=1 then mellem=1; else mellem=0;
if bt=1 or bm=1 or bb=1 or bn=1 then bund=1; else bund=0;
if nt=1 or nm=1 or nb=1 or nn=1 then notax=1; else notax=0;
run;

proc sort data=j; by pnr year; run;

proc means data=j; var top mellem bund notax; class year; run;


%end;
%mend skat;
%skat;




