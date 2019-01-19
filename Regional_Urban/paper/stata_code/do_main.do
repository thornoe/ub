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
////////////// 1. Create the datasets for different thresholds C  //////////////
////////////////////////////////////////////////////////////////////////////////

do $code/do_create


////////////////////////////////////////////////////////////////////////////////
////////////////////////// 2. Descriptive statistics  //////////////////////////
////////////////////////////////////////////////////////////////////////////////

use regional_400, clear

drop if year==2016

eststo clear

********************************************************************************
****	Summary table for main variables									****
********************************************************************************

estpost tabstat new_1 lngtinnpr lngtinnp lngintidp lngextidp infun_cont inapl_cont ///
		destec_cont exter_cont ///
	, by(services) statistics(count p50 mean sd min max) columns(statistics) 
esttab ., main(p50) aux(sd) nostar unstack nonote nomtitle nonumber
esttab using "$tables/descriptive.tex", style(tex) delimiter("&") replace ///
	onecell main(mean) aux(sd) unstack nostar noobs nonumbers label ///
	posthead(" &Manufacturing &Services\\\midrule") ///
	prefoot("\midrule Number of firms&1,949&1,026&2,975\\ Total observations&21,439&11,286&32,725\\") ///
	postfoot("\midrule Corr. w. log R\&D expenses at region-level &0.0216&0.0466&0.0336\\\bottomrule\end{tabular}\\\text{Mean coefficients; sd in parentheses.}")
bysort services: xtsum new_1 lngtinnpr lngintidp lngextidp infun_cont inapl_cont ///
		destec_cont exter_cont			// manually add No. firms & Total observations
xtsum new_1 lngtinnpr lngintidp lngextidp infun_cont inapl_cont destec_cont exter_cont
bysort services: corr new_1 lngtinnpr 	// manually add correlation
corr new_1 lngtinnpr					// manually add correlation

ta region if year==2005



////////////////////////////////////////////////////////////////////////////////
////////////////// 3. Regression table for preferred estimate //////////////////
////////////////////////////////////////////////////////////////////////////////

use regional_400, clear

eststo clear

********************************************************************************
**** 	Main reg. for firm sales of new products as share of total sales	****
********************************************************************************

*** With cluster-robust standard errors ***
foreach j in manufact services {
	xtreg new_1 lngtinnpr lngintidp lngextidp i.infun_cont i.inapl_cont ///
		i.destec_cont i.exter_cont i.region i.ind i.year if `j'==1 ///
		, re vce(cluster ident)
	estadd scalar cons = _b[_cons]
	est store `j', title("`j'")
	xttest0
}

*** Export regression table to LaTeX ***
/*
estimates table manufact services ///
	, star(.10 .05 .01) stats(r2 p N) drop(i.year)
*/

*** Main reg. table: Dummies for continuity of various R&D expenses ***
estout manufact services using $tables/estimates.tex, style(tex) replace ///
	label cells( b(star fmt(3)) se(par fmt(3)) ) ///
	starlevels(* .10 ** .05 *** .01) mlabels(,titles numbers) ///
	indicate("Region dummies=*.region" "Industry dummies=*.ind" "Year dummies=*.year") ///
	drop(_cons) ///
	stats(cons N, labels("Constant" "Observations") fmt(3 %9.0gc) ) ///	
	posthead("\midrule") prefoot("\midrule") postfoot("\bottomrule")


*** Reg. table for regional dummies ***
estout manufact services using $tables/reg_dummies.tex, style(tex) replace ///
	label cells( b(star fmt(3)) se(par fmt(3)) ) ///
	starlevels(* .10 ** .05 *** .01) mlabels(,titles numbers) ///
	indicate("R\&D variables = ln*" "Continuity dummies = *_cont" "Industry dummies=*.ind" "Year dummies=*.year") ///
	drop(_cons) ///
	stats(cons N, labels("Constant" "Observations") fmt(3 %9.0gc) ) ///	
	posthead("\midrule") prefoot("\midrule") postfoot("\bottomrule")


////////////////////////////////////////////////////////////////////////////////
//////// 4. Robustness check 1: for different truncations of R&D ratio  ////////
////////////////////////////////////////////////////////////////////////////////

**** Loop over tresholds for pct. of R&D expenses relative to total sales ****
foreach c of numlist 50 100 200 400 100000000 {

	use regional_`c', clear

	eststo clear

	****************************************************************************
	**** 	RE	regression model with time-invariant controls				****
	****************************************************************************

	*** With cluster-robust standard errors ***
	foreach j in manufact services {
		xtreg new_1 lngtinnpr lngintidp lngextidp i.infun_cont i.inapl_cont ///
			i.destec_cont i.exter_cont i.region i.ind i.year if `j'==1 ///
			, re vce(cluster ident)
		est store `j', title("`j'")
		xttest0
	}

	****************************************************************************
	**** 	Export regression tables to LaTeX								****
	****************************************************************************
	di "For C = `c'"
	estimates table manufact services ///
		, star(.10 .05 .01) stats(r2 p N) drop(i.year)

	estout manufact services using $tables/est_`c'.tex, style(tex) ///
		cells( b(star fmt(3)) se(par fmt(3)) ) ///
		starlevels(* .10 ** .05 *** .01) mlabels(,titles numbers) ///
		indicate("Dummies for continuity, region, industry \& year = *.*" "Constant = _cons") ///
		stats(N, labels("Observations") fmt(%9.0gc) ) ///
		label replace posthead("\midrule") prefoot("\midrule") postfoot("\bottomrule")
}



////////////////////////////////////////////////////////////////////////////////
//// 5. Robustness check 2: Only regions with >= 75, 90 or 100% of personnel ///
////////////////////////////////////////////////////////////////////////////////

*** Create dataset but raising the criteria for the share of regional personnel

do $code/do_create_r2

foreach cc of numlist 75 90 100 {

use regional_r1_`cc', clear

eststo clear

********************************************************************************
**** 	Main reg. for firm sales of new products as share of total sales	****
********************************************************************************

*** With cluster-robust standard errors ***
foreach j in manufact services {
	xtreg new_1 lngtinnpr lngintidp lngextidp i.infun_cont i.inapl_cont ///
		i.destec_cont i.exter_cont i.region i.ind i.year if `j'==1 ///
		, re vce(cluster ident)
	estadd scalar cons = _b[_cons]
	est store `j', title("`j'")
}

*** Export regression table to LaTeX ***
/*
estimates table manufact services ///
	, star(.10 .05 .01) stats(r2 p N) drop(i.year)
*/

*** Main reg. table: Dummies for continuity of various R&D expenses ***
estout manufact services using $tables/rob2_`cc'.tex, style(tex) replace ///
	label cells( b(star fmt(3)) se(par fmt(3)) ) ///
	starlevels(* .10 ** .05 *** .01) mlabels(,titles numbers) ///
	indicate("Dummies for continuity, region, industry \& year = *.*" "Constant = _cons") ///
	stats(N, labels("Observations") fmt(%9.0gc) ) ///
	posthead("\midrule") prefoot("\midrule") postfoot("\bottomrule")
}



////////////////////////////////////////////////////////////////////////////////
/// 6. Robustness check 3: Only regions with personnel within the same year ////
////////////////////////////////////////////////////////////////////////////////

*** Create dataset but without imputing region from other years when missing ***
do $code/do_create_r3

foreach cc of numlist 50 75 100 {

use regional_r3_`cc', clear

eststo clear

********************************************************************************
**** 	Main reg. for firm sales of new products as share of total sales	****
********************************************************************************

*** With cluster-robust standard errors ***
foreach j in manufact services {
	xtreg new_1 lngtinnpr lngintidp lngextidp i.infun_cont i.inapl_cont ///
		i.destec_cont i.exter_cont i.region i.ind i.year if `j'==1 ///
		, re vce(cluster ident)
	estadd scalar cons = _b[_cons]
	est store `j', title("`j'")
}

*** Export regression table to LaTeX ***
/*
estimates table manufact services ///
	, star(.10 .05 .01) stats(r2 p N) drop(i.year)
*/

*** Main reg. table: Dummies for continuity of various R&D expenses ***
estout manufact services using $tables/rob3_`cc'.tex, style(tex) replace ///
	label cells( b(star fmt(3)) se(par fmt(3)) ) ///
	starlevels(* .10 ** .05 *** .01) mlabels(,titles numbers) ///
	indicate("Dummies for continuity, region, industry \& year = *.*" "Constant = _cons") ///
	stats(N, labels("Observations") fmt(%9.0gc) ) ///
	posthead("\midrule") prefoot("\midrule") postfoot("\bottomrule")
}	
