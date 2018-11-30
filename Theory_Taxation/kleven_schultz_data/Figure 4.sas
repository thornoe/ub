/****************************************************************************************/ 
/* Based on the estimation data set, this SAS-program produces the data behind Figure 4 */              
/****************************************************************************************/

dm log 'clear';
dm output 'clear';
options pageno=1 pagesize=100;
goptions reset=all;
options obs=max;

/* Relevante datasæt indlæses */
libname bif 'D:\Workdata\702487\Esben\Skatteberegning\NYE BEREGNINGER\';

%macro skat;
%do aar=1982 %to 1993;

data samle&aar(where=(year=&aar));
set bif.tax84_02(keep=pnr year arb kap);
run; 

proc sort data=samle&aar; by pnr; run;

%end;
%mend skat;
%skat;

/* Defining treatment and control groups */
data treat(keep=pnr panela panelb panelc);
set bif.tax1984_02(where=(year=1986));
kn=bb+bm+mb+tm+mm+mt+tt;
if kn ne 1 then delete;
panela=2;
if bb=1 or bm=1 or mt=1 then panela=1;
panelb=3; 
if bb=1 or bm=1 or mt=1 then panelb=1; 
if mb=1 or tm=1 or tt=1 then panelb=2;
panelc=2;
if bb=1 or bm=1 then panelc=1;
run;

proc sort data=treat; by pnr; run;

%macro skat;
%do aar=1982 %to 1993;

data v&aar;
merge samle&aar (in=a) treat (in=b);
by pnr;
run;

proc sort data=v&aar; by pnr; run;

%end;
%mend skat;
%skat;


data samle(keep=pnr);
merge v1982 (in=a) v1983 (in=b) v1984 (in=c) v1985 (in=d) v1986 (in=e) v1987 (in=f)
v1988 (in=g) v1989 (in=h) v1990 (in=i) v1991 (in=j) v1992 (in=k) v1993 (in=l);
by pnr;
if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1 and j=1 and k=1 and l=1;
run;

%macro skat;
%do aar=1982 %to 1993;

data tv&aar;
merge v (in=a) samle (in=b);
by pnr;
run;

proc sort data=tv&aar; by pnr; run;

%end;
%mend skat;
%skat;

data samlet(keep=pnr);
set tv1982 tv1983 tv1984 tv1985 tv1986 tv1987 tv1988 tv1989 tv1990 tv1991 tv1992 tv1993;
run;

proc sort data=samle; by pnr year; run;

proc means data=samle; class panela year; var arb; run;
proc means data=samle; class panelb year; var arb; run;
proc means data=samle; class panelc year; var kap; run;
