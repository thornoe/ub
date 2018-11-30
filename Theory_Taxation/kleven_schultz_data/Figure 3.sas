/****************************************************************************************/ 
/* Based on the estimation data set, this SAS-program produces the data behind Figure 3 */              
/****************************************************************************************/

dm log 'clear';
dm output 'clear';
options pageno=1 pagesize=100;
goptions reset=all;
options obs=max;

/* Relevante datasæt indlæses */
libname bif 'D:\Workdata\702487\Esben\Skatteberegning\NYE BEREGNINGER\';

data v;
set bif.tax84_02(keep=pnr year arbstatus kapstatus dummyear dummycap
                 tt tm tb tn mt mm mb mn bt bm bb bn nt nm nb nn  
                 diffmtr_arb_h_iv diffmtr_kap_h_iv);
if bb=1 then group=1;
if mb=1 then group=2;
if bm=1 then group=3;
if mm=1 then group=4;
if tm=1 then group=5;
if mt=1 then group=6;
if tt=1 then group=7;
run; 

/* Panel A: Labor income */

/* 1986-1989 */

proc means data=v(where=(group ne . and arbstatus=1 and dummyear=1 and year=1986)) n mean;
class group;
var diffmtr_arb_h_iv;
run;


/* 1993-1996 */

proc means data=v(where=(group ne . and arbstatus=1 and dummyear=1 and year=1993)) n mean;
class group;
var diffmtr_arb_h_iv;
run;


/* Panel B: Positive capital income */

/* 1986-1989 */

proc means data=v(where=(group ne . and kapstatus=1 and dummycap=2 and year=1986)) n mean;
class group;
var diffmtr_kap_h_iv;
run;


/* 1993-1996 */

proc means data=v(where=(group ne . and kapstatus=1 and dummycap=2 and year=1993)) n mean;
class group;
var diffmtr_kap_h_iv;
run;


/* Panel B: Negative capital income */

/* 1986-1989 */

proc means data=v(where=(group ne . and kapstatus=1 and dummycap=3 and year=1986)) n mean;
class group;
var diffmtr_kap_h_iv;
run;


/* 1993-1996 */

proc means data=v(where=(group ne . and kapstatus=1 and dummycap=3 and year=1993)) n mean;
class group;
var diffmtr_kap_h_iv;
run;

