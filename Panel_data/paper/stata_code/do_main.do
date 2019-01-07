////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Global set up /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
set scheme s1color

clear all


*** Global directories ***
cd 				"C:\Users\thorn\Dropbox\Public\KU Polit\Kandidat\UB_PITEC"
global code		"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Panel_Data\paper\stata_code"
global figures	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Panel_Data\paper\03_figures"
global tables	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Panel_Data\paper\04_tables"
global pitec	"C:\Users\thorn\Dropbox\Public\KU Polit\Kandidat\UB_PITEC\BE140_2018"


*** Global variable list ***
global x "acti clase grupo cifra tamano tam200 bio innprod newemp innproc idin gintid idex gextid gtinn idintern invtejc tectejc auxtejc pidt pidtejc reci reot infun inapl destec patnum actin sede"



////////////////////////////////////////////////////////////////////////////////
////////////////////////////// Create the dataset //////////////////////////////
////////////////////////////////////////////////////////////////////////////////
do $code/do_create

drop if manufact == 0 & services == 0

keep ident year clase grupo tam200 bio innprod new_0 innproc idin sede ///
	lnemp exter pidp invp tecp auxp manufact services idin_cont ///
	infun_cont inapl_cont destec_cont exter_cont ind new_1 new_2 new_3

save panel, replace

////////////////////////////////////////////////////////////////////////////////
///////////////////////////// Descriptive analysis /////////////////////////////
////////////////////////////////////////////////////////////////////////////////
use panel, clear

binscatter new_2 lnemp, nquantiles(40)

binscatter new_2 pidp, nquantiles(40)

su pidp, detail

ta ind new_0 , row


help twoway table


////////////////////////////////////////////////////////////////////////////////
///////////////////////////// Regression analysis  /////////////////////////////
////////////////////////////////////////////////////////////////////////////////
foreach 

use panel, clear

drop if services==1

eststo clear

********************************************************************************
**** Regression models													****
********************************************************************************
foreach est in fe re {
	foreach k of numlist 0/3 {
		xtreg new_`k' emp empsq pidp exter i.year, `est' vce(robust)
		est store `est'`k', title("`est', k=`k'")
	}
}

foreach k of numlist 0/3 {
	xtreg new_`k' emp empsq pidp exter i.year, be
	est store be`k', title("be, k=`k'")
}

********************************************************************************
**** RE	regression model with time-invariant controls						****
********************************************************************************
foreach k of numlist 0/3 {
	xtreg new_`k' emp empsq pidp exter i.idin_cont i.exter_cont i.ind i.year, re vce(robust)
	est store rec`k', title("rec, k=`k'")
}

foreach est in fe be re rec {
	estimates table `est'0 `est'1 `est'2 `est'3 ///
	, star(.10 .05 .01) stats(N) drop(i.year)
}

foreach est in fe be re {
	estout `est'0 `est'1 `est'2 `est'3 using $tables/reg_`est', style(tex) replace ///
	cells( b(star fmt(3)) se(par fmt(3)) ) starlevels(* .10 ** .05 *** .01) drop(*.year)
}

foreach est in fe be re {
	estout `est'0 `est'1 `est'2 `est'3 using $tables/reg_`est', style(tex) replace ///
	cells( b(star fmt(3)) se(par fmt(3)) ) starlevels(* .10 ** .05 *** .01) drop(*.year)
}



