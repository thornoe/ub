////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// 0. Global set up ///////////////////////////////
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
///////////////////////////// 1. Create the dataset /////////////////////////////
////////////////////////////////////////////////////////////////////////////////
do $code/do_create

drop if manufact == 0 & services == 0

keep ident year clase grupo tamano tam200 bio innprod new_0 innproc idin sede ///
	lnemp exter pidp invp tecp auxp gtinnp gintidp gextidp recip reotp ///
	ind manufact services idin_cont infun_cont inapl_cont destec_cont exter_cont ///
	new_1 new_2 new_3

save panel, replace

////////////////////////////////////////////////////////////////////////////////
/////////////////////////// 2. Descriptive analysis  ///////////////////////////
////////////////////////////////////////////////////////////////////////////////
use panel, clear


********************************************************************************
****	Summary table for main variables									****
********************************************************************************
eststo clear
estpost tabstat new_0 pidp idin exter ///
	, by(ind) statistics(count mean sd min max) columns(statistics) 
esttab ., main(mean) aux(sd) nostar unstack nonote nomtitle nonumber
esttab using "$tables/descriptive.tex", style(tex) delimiter("&") replace ///
	onecell main(mean) aux(sd) unstack nostar noobs nonumbers label ///
	posthead(" &Foods &Textiles &Chemicals &Metal &Machinery &Furniture\\\midrule") ///
	prefoot("\midrule Obs.&5,112&3,996&10,164&4,524&11,196&1,164&36,156\\") ///
	postfoot("\midrule Corr.&0,0841&0,0997&0,0677&0,0953&0,0431&0,0985&0,0752\\\bottomrule\end{tabular}\\\text{mean coefficients; sd in parentheses}")
bysort ind: corr new_2 pidp	// manually add correlation
corr new_2 pidp
ta ind 						// manually add N
	
bysort ind: xtsum new_0 pidp idin exter


********************************************************************************
****	Boxplot of share of total revenue									****
********************************************************************************
graph box new_0, over(year, label( alternate  labsize(*0.8) )) ///
	title("Sales of new products") ytitle("% of total revenue")
	graph save Graph $figures\box1.gph, replace

graph box pidp, over(year, label( alternate  labsize(*0.8) )) ///
	title("Internal R&D personnel") ytitle("% of total personnel")
	graph save Graph $figures\box2.gph, replace

graph combine "$figures\box1.gph" "$figures\box2.gph", rows(1)
	graph export $figures\combined.png, replace


********************************************************************************
****	Binscatters for sales of new products as share of total revenue		****
********************************************************************************
binscatter new_3 pidp, nquantiles(50) ///
	xtitle("Internal R&D personnel, t") ytitle("Sales of new products, t+3")
graph export $figures/scatter.png, replace
	

*** Emp: Direction of correlation shifts around the 200-empl. discountinuity ***
/*
binscatter new_2 lnemp, nquantiles(40) linetype(qfit)
binscatter new_2 lnemp if tamano<=200, nquantiles(40)
binscatter new_2 lnemp if tamano>=200, nquantiles(40)
*/


////////////////////////////////////////////////////////////////////////////////
//////////////////////////// 3. Regression analysis ////////////////////////////
////////////////////////////////////////////////////////////////////////////////
use panel, clear

keep if manufact==1

eststo clear

********************************************************************************
****	Comparing regression methods for baseline model											****
********************************************************************************


*** FE and BE ***
foreach est in fe be {
	foreach k of numlist 0/3 {
		xtreg new_`k' pidp idin exter i.year, `est'
		est store `est'`k', title("`est', k=`k'")
		xttest0
	}
}


*** RE and Breusch-Pagan LM test for RE. H0: Var(v_i)=0 ***
foreach k of numlist 0/3 {
	xtreg new_`k' pidp idin exter i.year, re
	est store re`k', title("re, k=`k'")
	xttest0
}
// The H0 is rejected, thus the variance of the random-component v_i != 0

********************************************************************************
**** 	RE	regression model with time-invariant controls					****
********************************************************************************

*** With cluster-robust standard errors ***
foreach k of numlist 0/3 {
	xtreg new_`k' pidp idin exter i.year i.sede i.ind, re vce(cluster ident)
	est store rec`k', title("re, k=`k'")
	xttest0
}


*** Without robust standard errors (for the Hausmann test) ***
foreach k of numlist 0/3 {
	xtreg new_`k' pidp idin exter i.year i.sede i.ind, re
	est store re2`k', title("re, k=`k'")
	xttest0
}


*** With all possible controls (for the Hausmann test) ***
foreach k of numlist 0/3 {
	xtreg new_`k' pidp idin exter i.year i.clase grupo lnemp tam200 bio i.sede i.ind, re
	est store re3`k', title("re, k=`k'")
	xttest0
}


********************************************************************************
**** 	Export regression tables to LaTeX									****
********************************************************************************
foreach est in fe be re rec {
	estimates table `est'0 `est'1 `est'2 `est'3 ///
	, star(.10 .05 .01) stats(r2 p N) drop(i.year)
}

foreach est in fe be re rec {
	estout `est'0 `est'1 `est'2 `est'3 using $tables/reg_`est'.tex, style(tex) ///
	cells( b(star fmt(3)) se(par fmt(3)) ) /// // manually remove underscore from "_cons"
	starlevels(* .10 ** .05 *** .01) mlabels(,titles numbers) ///
	stats(r2 N, fmt(3 0) ) drop(*.year) label replace ///
	posthead("\midrule") prefoot("\midrule") postfoot("\bottomrule")
}


********************************************************************************
**** 	Hausman specification test											****
********************************************************************************
foreach re in re re2 re3 {
	foreach k of numlist 0/3 {
		hausman fe`k' `re'`k'
	}
}
