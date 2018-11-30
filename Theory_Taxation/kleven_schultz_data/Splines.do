/****************************************************************************************/ 
/* Based on the estimation data set, this STATA-program calculates income splines for   */ 
/* labor income, positive capital income, negative capital income, taxable income and   */ 
/* broad income, and merges these splines with the estimation data set in order to      */
/* obtain the final estimation data set.                                                */        
/****************************************************************************************/

clear
set mem 65000m
set matsize 11000
use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax84_02", clear
keep pnr year arbstatus dummyear logarb2 plogarb2 dlogarb2
destring pnr, replace

keep if arbstatus==1
keep if dummyear==2

*splines of current income
mkspline sp10logarb 10=logarb2, pctile

*splines of lagged income
mkspline sp10plogarb 10=plogarb2, pctile

*Splines of deviation of current income from lagged income
mkspline sp10dlogarb 10=dlogarb2, pctile

sort pnr year

save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_labor1984_2002", replace 

clear
set mem 65000m
set matsize 11000
use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax84_02", clear
keep pnr year kapstatus dummycap logkap2 plogkap2 dlogkap2
destring pnr, replace

keep if kapstatus==1
keep if dummycap==2

*splines of current income
mkspline sp10logkap 10=logkap2, pctile

*splines of lagged income
mkspline sp10plogkap 10=plogkap2, pctile

*Splines of deviation of current income from lagged income
mkspline sp10dlogkap 10=dlogkap2, pctile

sort pnr year

save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_poscap1984_2002", replace 

clear
set mem 65000m
set matsize 11000
use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax84_02", clear
keep pnr year kapstatus dummycap logkap2 plogkap2 dlogkap2
destring pnr, replace

keep if kapstatus==1
keep if dummycap==3

*splines of current income
mkspline sp10logkap2 10=logkap2, pctile

*splines of lagged income
mkspline sp10plogkap2 10=plogkap2, pctile

*Splines of deviation of current income from lagged income
mkspline sp10dlogkap2 10=dlogkap2, pctile

sort pnr year

save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_negcap1984_2002", replace 

clear
set mem 65000m
set matsize 11000
use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax84_02", clear
keep pnr year dummybroad logbroad2 plogbroad2 dlogbroad2
destring pnr, replace

keep if dummybroad==1

*splines of current income
mkspline sp10logbroad2 10=logbroad2, pctile

*splines of lagged income
mkspline sp10plogbroad2 10=plogbroad2, pctile

*Splines of deviation of current income from lagged income
mkspline sp10dlogbroad2 10=dlogbroad2, pctile

sort pnr year

save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_broad1984_2002", replace 

clear
set mem 65000m
set matsize 11000
use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax84_02", clear
keep pnr year dummytaxable logtaxable2 plogtaxable2 dlogtaxable2
destring pnr, replace

keep if dummytaxable==1

*splines of current income
mkspline sp10logtaxable2 10=logtaxable2, pctile

*splines of lagged income
mkspline sp10plogtaxable2 10=plogtaxable2, pctile

*Splines of deviation of current income from lagged income
mkspline sp10dlogtaxable2 10=dlogtaxable2, pctile

sort pnr year

save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_taxable1984_2002", replace 


clear
set mem 65000m
set matsize 11000
use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax84_02", clear
destring pnr, replace
sort pnr year
save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam1", replace

use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_laborincome1984_2002", clear 
drop arbstatus dummyear logarb2 plogarb2 dlogarb2
sort pnr year
merge pnr year using "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam1"
drop _merge
sort pnr year
save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam2", replace 

use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_poscap1984_2002", clear 
drop kapstatus dummycap logkap2 plogkap2 dlogkap2
sort pnr year
merge pnr year using "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam2"
drop _merge
sort pnr year
save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam3", replace 


use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_broad1984_2002", clear 
drop dummybroad logbroad2 plogbroad2 dlogbroad2
sort pnr year
merge pnr year using "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam3"
drop _merge
sort pnr year
save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam4", replace 

use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_taxable1984_2002", clear 
drop dummybroad logtaxable2 plogtaxable2 dlogtaxble2
sort pnr year
merge pnr year using "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam4"
drop _merge
sort pnr year
save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam5", replace 

use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Splines_negcap1984_2002", clear 
drop kapstatus dummycap logkap2 plogkap2 dlogkap2
sort pnr year
merge pnr year using "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\sam5"
drop _merge
sort pnr year
save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax1984_2002", replace 


clear
