////////////////////////////////////////////////////////////////////////////////
///////////////////////// Clear all and set up folders /////////////////////////
////////////////////////////////////////////////////////////////////////////////
set scheme s1color
clear all
cd            	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS2\stata_code"
global figures	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS2\03_figures"
global tables	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS2\04_tables"


////////////////////////////////////////////////////////////////////////////////
///////////////////////////// Load and set up data /////////////////////////////
////////////////////////////////////////////////////////////////////////////////
use pwt90.dta, replace
keep countrycode year rgdpna
keep if inlist(countrycode,"DEU","FRA","GBR")
gen y = log(rgdpna)
drop rgdpna
* encode countrycode, gen(id)
* tsset id year
reshape wide y, i(year) j(countrycode) string
tsset year


********************************************************************************
* Question 3.1 Cointegration analysis. Single-equation-based methods		   *
********************************************************************************
*** a) Augmented Dickey–Fuller test
reg yFRA yDEU					// Static equation
predict residuals, resid		// Save the residuals
dfuller residuals, lags(5)		// ADF test
eststo eg, title("1st step")
drop residuals


*** b) Engle-Granger ECM
* 	install egranger from
* 	net from http://fmwww.bc.edu/RePEc/bocode/e/
egranger yFRA yDEU, lags(5) regress ecm
eststo ECM
estout eg ECM using "$tables/tab31b.tex", style(tex) replace ///
	cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	mlabels(,titles numbers) /// 	// manually remove underscore from "L._egresid" & "_cons"
	/// //stats(aic bic, labels("aic" "bic") fmt(3 0) ) ///
	prehead("\begin{tabular}{lcc}\toprule") ///	// fit c's to number of columns
	posthead("\midrule") /// // prefoot("\midrule") ///   
	postfoot("\bottomrule \end{tabular} \\ \text{Standard errors are in parentheses. * p<0.10, ** p<0.05, *** p<0.01}")


********************************************************************************
* Question 3.1 Cointegration analysis. System-based methods					   *
********************************************************************************
*** a) Optimal number of lags of the VAR(P)
varsoc yFRA yDEU yGBR


*** b) Number of cointegrated relationships (rank)
vecrank  yFRA yDEU yGBR, lags(2)


*** c) Estimation of the VECM model with the found number of lags and rank
vec yFRA yDEU yGBR, lags(2) rank(2) noetable
predict ce, ce
tsline D.ce
	graph export $figures/fig32.png, replace

vec yFRA yDEU yGBR, lags(2) rank(2) nobtable
eststo VEC, title("Short run parameters")
estout VEC using "$tables/tab32c1.tex", style(tex) replace ///
	cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	mlabels(,titles ) /// 	// manually remove all of the underscores
	/// //stats(aic bic, labels("aic" "bic") fmt(3 0) ) ///
	prehead("\begin{tabular}{lc}\toprule") ///	// fit c's to number of columns
	posthead("\midrule") /// // prefoot("\midrule") ///   
	postfoot("\bottomrule \end{tabular} \\ \text{Standard errors are in parentheses. * p<0.10, ** p<0.05, *** p<0.01}")


*** 3.3
gr two	(tsline yFRA yDEU yGBR) 	///
		(tsline ce, yaxis(2) )		///
		, ytitle("log real GDP")
	graph export $figures/fig33.png, replace

* Average growth rates 1950-1974
di 	" DEU:" (1+(14.352 - 13.001))^(1/(1974-1950))-1 ///
	" FRA:" (1+(13.938 - 12.769))^(1/(1974-1950))-1 ///
	" GBR:" (1+(13.806 - 13.166))^(1/(1974-1950))-1
