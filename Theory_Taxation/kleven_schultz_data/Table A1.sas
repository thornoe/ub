/****************************************************************************************/ 
/* Based on the estimation data set, this SAS-program produces Table A1.                */              
/****************************************************************************************/

dm log 'clear';
dm output 'clear';
options pageno=1 pagesize=100;
goptions reset=all;

options obs=max;

libname bif 'D:\Workdata\702487\Esben\Skatteberegning\NYE BEREGNINGER\';

title 'All';
proc means data=bif.tax84_02(where=(occ in (1,2))) mean median n;
var alder anc017 exp mand gift udd1 udd2 udd3 udd4 udd5 udd6 arb apers kap frad bk mk tk;
run;

title 'Wage earners';
proc means data=bif.tax84_02(where=(occ=2)) mean median n;
var alder anc017 exp mand gift udd1 udd2 udd3 udd4 udd5 udd6 arb apers kap frad bk mk tk;
run;

title 'Self-employed';
proc means data=bif.tax84_02(where=(occ=1)) mean median n;
var alder anc017 exp mand gift udd1 udd2 udd3 udd4 udd5 udd6 arb apers kap frad bk mk tk;
run;


