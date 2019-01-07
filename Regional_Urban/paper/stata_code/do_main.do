////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// 0. Global set up ///////////////////////////////
////////////////////////////////////////////////////////////////////////////////
set scheme s1color

clear all


*** Global directories ***
cd 				"C:\Users\thorn\Dropbox\Public\KU Polit\Kandidat\UB_PITEC"
global code		"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Regional_Urban\paper\stata_code"
global figures	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Regional_Urban\paper\03_figures"
global tables	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Regional_Urban\paper\04_tables"
global pitec	"C:\Users\thorn\Dropbox\Public\KU Polit\Kandidat\UB_PITEC\BE140_2018"


*** Global variable list ***
global x "acti clase grupo cifra tamano tam200 bio innprod newemp innproc idin gintid idex gextid gtinn idintern invtejc tectejc auxtejc pidt pidtejc reci reot infun inapl destec patnum actin sede"


////////////////////////////////////////////////////////////////////////////////
///////////////////////////// 1. Create the dataset /////////////////////////////
////////////////////////////////////////////////////////////////////////////////
do $code/do_create

drop if manufact == 0 & services == 0

keep ident year clase grupo tamano tam200 bio innprod new_0 innproc idin sede ///
	lnemp exter pidp invp tecp auxp gtinnp gintidp gextidp lngintidp lngextidp ///
	recip reotp ind manufact services idin_cont infun_cont inapl_cont destec_cont ///
	exter_cont new_1 new_2 new_3 region gtinnpr

gen lngtinnpr = log(gtinnpr)	

save regional, replace


////////////////////////////////////////////////////////////////////////////////
//////////////////////////// 2. Regression analysis ////////////////////////////
////////////////////////////////////////////////////////////////////////////////
use regional, clear

eststo clear

********************************************************************************
**** 	RE	regression model with time-invariant controls					****
********************************************************************************

*** With cluster-robust standard errors ***
foreach j in manufact services {
	xtreg new_1 lngtinnpr lngintidp lngextidp infun_cont inapl_cont destec_cont ///
	exter_cont i.year i.ind i.region if `j'==1, re vce(cluster ident)
	est store `j', title("`j'")
	xttest0
}

********************************************************************************
**** 	Export regression tables to LaTeX									****
********************************************************************************
estimates table manufact services ///
	, star(.10 .05 .01) stats(r2 p N) drop(i.year)

label variable lngtinnpr "log R\&D expenses in region"
label variable lngintidp "log internal R\&D expenses"	
label variable lngextidp "log external R\&D expenses"	

estout manufact services using $tables/estimates.tex, style(tex) ///
	cells( b(star fmt(3)) se(par fmt(3)) ) /// // manually remove underscore from "_cons"
	starlevels(* .10 ** .05 *** .01) mlabels(,titles numbers) ///
	stats(N, fmt(0) ) drop(*.year *.ind) label replace ///
	posthead("\midrule") prefoot("\midrule") postfoot("\bottomrule")
