/*********************************************************************************************************/ 
/* Based on the final estimation data set, this STATA-program produces the estimation results in Table 4 */              
/*********************************************************************************************************/

clear
set mem 35000m
set matsize 11000
use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax1984_2002.dta", replace

set more off

gen exp2=exp*exp
gen col=0
replace col=1 if udd5==1 | udd6==1 
gen kids018=0
replace kids018=1 if anc017>0
gen kids06=0
replace kids06=1 if anc06>0
drop if arbstatus==0
drop if arb<0

log using "D:\Mail\ztk\filer\Table4.smcl", replace


* COLUMN 1 

* All

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb], cluster(pnr)


* Wage earners

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ>1, cluster(pnr)


* Self-employed

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ==1, cluster(pnr)


* COLUMN 2

* All

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if e1==5, cluster(pnr)


* Wage earners

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ>1 & e1==5, cluster(pnr)


* Self-employed

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ==1 & e1==5, cluster(pnr)


* COLUMN 3

* All

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if e1==6, cluster(pnr)


* Wage earners

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ>1 & e1==6, cluster(pnr)


* Self-employed

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ==1 & e1==6, cluster(pnr)



* COLUMN 4

* All

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if coll==1, cluster(pnr)


* Wage earners

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ>1 & coll==1, cluster(pnr)


* Self-employed

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp mand amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ==1 & coll==1, cluster(pnr)


* COLUMN 5

* All

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if mand==0, cluster(pnr)


* Wage earners

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ>1 & mand==0, cluster(pnr)


* Self-employed

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  exp exp2 anc017 alder gift unem gdp udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ==1 & mand==0, cluster(pnr)


* COLUMN 6

* All

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  mand exp exp2 alder gift unem gdp udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if kids018==1, cluster(pnr)


* Wage earners

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  mand exp exp2 alder gift unem gdp udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ>1 & kids018==1, cluster(pnr)


* Self-employed

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  mand exp exp2 alder gift unem gdp udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ==1 & kids018==1, cluster(pnr)



* COLUMN 7

* All

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  anc017 mand exp exp2 alder gift unem gdp udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if kids06==1, cluster(pnr)


* Wage earners

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  anc017 mand exp exp2 alder gift unem gdp udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ>1 & kids06==1, cluster(pnr)


* Self-employed

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb  anc017 mand exp exp2 alder gift unem gdp udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h=diffmtr_arb_h_iv) [aw=arb] if occ==1 & kids06==1, cluster(pnr)


log close
translate "D:\Mail\ztk\filer\elas1984_2002_laborincome.smcl" "D:\Mail\ztk\filer\Table4.txt"
save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Elasticity1984_2002_laborincome", replace 

clear
