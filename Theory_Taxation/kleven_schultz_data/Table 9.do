/*********************************************************************************************************/ 
/* Based on the final estimation data set, this STATA-program produces the estimation results in Table 9 */              
/*********************************************************************************************************/

clear
set mem 35000m
set matsize 11000
use "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\tax1984_2002.dta", replace

set more off

gen exp2=exp*exp

gen aar=0
replace aar=1 if year>1990

log using "D:\Mail\ztk\filer\Table9.smcl", replace

* PANEL A: LABOR INCOME WITH CROSS-TAX EFFECT OF CAPITAL INCOME 

* All reforms

*no income control
ivregress 2sls diffarb exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=arb] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3, cluster(pnr)
*log of current income
ivregress 2sls diffarb logarb exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=arb] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3, cluster(pnr)
*splines of log current income
ivregress 2sls diffarb sp10logarb1 sp10logarb2 sp10logarb3 sp10logarb4 sp10logarb5 sp10logarb6 sp10logarb7 sp10logarb8 sp10logarb9 sp10logarb10  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=arb] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3, cluster(pnr)
*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=arb] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3, cluster(pnr)

* 1987-reform

*no income control
ivregress 2sls diffarb exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=arb] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3 & aar==0, cluster(pnr)
*log of current income
ivregress 2sls diffarb logarb exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=arb] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3 & aar==0, cluster(pnr)
*splines of log current income
ivregress 2sls diffarb sp10logarb1 sp10logarb2 sp10logarb3 sp10logarb4 sp10logarb5 sp10logarb6 sp10logarb7 sp10logarb8 sp10logarb9 sp10logarb10  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=arb] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3 & aar==0, cluster(pnr)
*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffarb sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_arb_h diffmtr_kap_h=diffmtr_arb_h_iv diffmtr_kap_h_iv) [aw=arb] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3 & aar==0, cluster(pnr)

* PANEL B: NEGATIVE CAPITAL INCOME WITH CROSS-TAX EFFECT OF LABOR INCOME 

* All reforms

*no income control
ivregress 2sls diffkap exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_kap_h diffmtr_arb_h=diffmtr_kap_h_iv diffmtr_arb_h_iv) [aw=kap] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3, cluster(pnr)
*log of current income
ivregress 2sls diffkap logkap exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_kap_h diffmtr_arb_h=diffmtr_kap_h_iv diffmtr_arb_h_iv) [aw=kap] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3, cluster(pnr)
*splines of log current income
ivregress 2sls diffkap sp10logkap1 sp10logkap2 sp10logkap3 sp10logkap4 sp10logkap5 sp10logkap6 sp10logkap7 sp10logkap8 sp10logkap9 sp10logkap10  exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_kap_h diffmtr_arb_h=diffmtr_kap_h_iv diffmtr_arb_h_iv) [aw=kap] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3, cluster(pnr)
*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffkap sp10plogkap1 sp10plogkap2 sp10plogkap3 sp10plogkap4 sp10plogkap5 sp10plogkap6 sp10plogkap7 sp10plogkap8 sp10plogkap9 sp10plogkap10 dlogkap exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_kap_h diffmtr_arb_h=diffmtr_kap_h_iv diffmtr_arb_h_iv) [aw=kap] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3, cluster(pnr)

* 1987-reform

*no income control
ivregress 2sls diffkap exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_kap_h diffmtr_arb_h=diffmtr_kap_h_iv diffmtr_arb_h_iv) [aw=kap] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3 & aar==0, cluster(pnr)
*log of current income
ivregress 2sls diffkap logkap exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_kap_h diffmtr_arb_h=diffmtr_kap_h_iv diffmtr_arb_h_iv) [aw=kap] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3 & aar==0, cluster(pnr)
*splines of log current income
ivregress 2sls diffkap sp10logkap1 sp10logkap2 sp10logkap3 sp10logkap4 sp10logkap5 sp10logkap6 sp10logkap7 sp10logkap8 sp10logkap9 sp10logkap10 exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_kap_h diffmtr_arb_h=diffmtr_kap_h_iv diffmtr_arb_h_iv) [aw=kap] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3 & aar==0, cluster(pnr)
*splines of log lagged income and deviation of log current from log lagged income
ivregress 2sls diffkap sp10plogkap1 sp10plogkap2 sp10plogkap3 sp10plogkap4 sp10plogkap5 sp10plogkap6 sp10plogkap7 sp10plogkap8 sp10plogkap9 sp10plogkap10 dlogkap exp exp2 anc017 alder unem gdp mand udd1 udd2 udd3 udd4 udd5 udd6 amt1 amt2 amt3 amt4 amt5 amt6 amt7 amt8 amt9 amt10 amt11 amt12 amt13 amt14 amt15 ind1 ind2 ind3 ind4 ind5 ind6 ind7 ind8 ind9 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d00 d01 d02 (diffmtr_kap_h diffmtr_arb_h=diffmtr_kap_h_iv diffmtr_arb_h_iv) [aw=kap] arbstatus==1 & arb>0 & kapstatus==1 & dummycap==3 & aar==0, cluster(pnr)


log close
translate "D:\Mail\ztk\filer\elas1984_2002_laborincome.smcl" "D:\Mail\ztk\filer\Table9.txt"
save "D:\Workdata\702487\Esben\Skatteberegning\Nye beregninger\Elasticity1984_2002_laborincome", replace 

clear
