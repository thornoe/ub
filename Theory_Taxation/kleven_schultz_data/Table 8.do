/*********************************************************************************************************/ 
/* Based on the final estimation data set, this STATA-program produces the estimation results in Table 8 */              
/*********************************************************************************************************/

clear
set mem 35000m
set matsize 11000
use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax1984_2002.dta", replace

set more off

gen exp2=exp*exp

gen aar=0
replace aar=1 if year>1990

log using "D:\Mail\ztk\filer\Table8.smcl", replace

* PANEL A: BROAD INCOME 

* All reforms

* Column 1: All  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffbroad sp10plogbroad1 sp10plogbroad2 sp10plogbroad3 sp10plogbroad4 sp10plogbroad5 sp10plogbroad6 sp10plogbroad7 sp10plogbroad8 sp10plogbroad9 sp10plogbroad10 dlogbroad  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=broad] dummybroad==1, cluster(pnr)

* Column 2: Wage earners  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffbroad sp10plogbroad1 sp10plogbroad2 sp10plogbroad3 sp10plogbroad4 sp10plogbroad5 sp10plogbroad6 sp10plogbroad7 sp10plogbroad8 sp10plogbroad9 sp10plogbroad10 dlogbroad  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=broad] dummybroad==1 & occ>1, cluster(pnr)

* Column 3: Self-employed  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffbroad sp10plogbroad1 sp10plogbroad2 sp10plogbroad3 sp10plogbroad4 sp10plogbroad5 sp10plogbroad6 sp10plogbroad7 sp10plogbroad8 sp10plogbroad9 sp10plogbroad10 dlogbroad  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=broad] dummybroad==1 & occ==1, cluster(pnr)

* 1987-reform

* Column 1: All  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffbroad sp10plogbroad1 sp10plogbroad2 sp10plogbroad3 sp10plogbroad4 sp10plogbroad5 sp10plogbroad6 sp10plogbroad7 sp10plogbroad8 sp10plogbroad9 sp10plogbroad10 dlogbroad  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=broad] dummybroad==1 & aar==0, cluster(pnr)

* Column 2: Wage earners  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffbroad sp10plogbroad1 sp10plogbroad2 sp10plogbroad3 sp10plogbroad4 sp10plogbroad5 sp10plogbroad6 sp10plogbroad7 sp10plogbroad8 sp10plogbroad9 sp10plogbroad10 dlogbroad  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=broad] dummybroad==1 & occ>1 & aar==0, cluster(pnr)

* Column 3: Self-employed  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffbroad sp10plogbroad1 sp10plogbroad2 sp10plogbroad3 sp10plogbroad4 sp10plogbroad5 sp10plogbroad6 sp10plogbroad7 sp10plogbroad8 sp10plogbroad9 sp10plogbroad10 dlogbroad  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=broad] dummybroad==1 & occ==1 & aar==0, cluster(pnr)



* PANEL B: TAXABLE INCOME 

* All reforms

* Column 4: All  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls difftaxable sp10plogtaxable1 sp10plogtaxable2 sp10plogtaxable3 sp10plogtaxable4 sp10plogtaxable5 sp10plogtaxable6 sp10plogtaxable7 sp10plogtaxable8 sp10plogtaxable9 sp10plogtaxable10 dlogtaxable  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=taxable] dummytaxable==1, cluster(pnr)

* Column 5: Wage earners  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls difftaxable sp10plogtaxable1 sp10plogtaxable2 sp10plogtaxable3 sp10plogtaxable4 sp10plogtaxable5 sp10plogtaxable6 sp10plogtaxable7 sp10plogtaxable8 sp10plogtaxable9 sp10plogtaxable10 dlogtaxable  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=taxable] dummytaxable==1 & occ>1, cluster(pnr)

* Column 6: Self-employed  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls difftaxable sp10plogtaxable1 sp10plogtaxable2 sp10plogtaxable3 sp10plogtaxable4 sp10plogtaxable5 sp10plogtaxable6 sp10plogtaxable7 sp10plogtaxable8 sp10plogtaxable9 sp10plogtaxable10 dlogtaxable  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=taxable] dummytaxable==1 & occ==1, cluster(pnr)


* 1987-reform

* Column 4: All  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls difftaxable sp10plogtaxable1 sp10plogtaxable2 sp10plogtaxable3 sp10plogtaxable4 sp10plogtaxable5 sp10plogtaxable6 sp10plogtaxable7 sp10plogtaxable8 sp10plogtaxable9 sp10plogtaxable10 dlogtaxable  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=taxable] dummytaxable==1 & aar==0, cluster(pnr)

* Column 5: Wage earners  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls difftaxable sp10plogtaxable1 sp10plogtaxable2 sp10plogtaxable3 sp10plogtaxable4 sp10plogtaxable5 sp10plogtaxable6 sp10plogtaxable7 sp10plogtaxable8 sp10plogtaxable9 sp10plogtaxable10 dlogtaxable  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=taxable] dummytaxable==1 & occ>1 & aar==0, cluster(pnr)

* Column 6: Self-employed  

*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls difftaxable sp10plogtaxable1 sp10plogtaxable2 sp10plogtaxable3 sp10plogtaxable4 sp10plogtaxable5 sp10plogtaxable6 sp10plogtaxable7 sp10plogtaxable8 sp10plogtaxable9 sp10plogtaxable10 dlogtaxable  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=taxable] dummytaxable==1 & occ==1 & aar==0, cluster(pnr)


log close
translate "D:\Mail\ztk\filer\elas1984_2002_laborincome.smcl" "D:\Mail\ztk\filer\Table8.txt"
save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Elasticity1984_2002_laborincome", replace 

clear
