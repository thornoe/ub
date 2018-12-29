* install "sim_arma" from http://www.stata.com/users/jpitblado
findit sim_arma

* install "sts15_2" to perform kpss tests
findit kpss


////////////////////////////////////////////////////////////////////////////////
/////////////////////// Clear all and set up folders ////////////////////////////
////////////////////////////////////////////////////////////////////////////////
set scheme s1color
clear all
cd            	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS1\stata_code"
global figures	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS1\03_figures"
global tables	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS1\04_tables"

********************************************************************************
* Question 2.2a Gaussian stochastic process                                     *
********************************************************************************
clear
set obs 500				// create data set with 500 obs
gen t = _n				// create a time indicator
set seed 113			// set seed number
gen epsilon=rnormal()	// generate a random standard normal distribution

*** Look at the data
sum eps					// calcuated overall average
*tab eps				// show all realizations

*** Plot the time series
tsset t				// give the dataset a time series structure according to the variable t

tsline eps, title("Time series")		///
		, name(fig22a_1, replace) nodraw

** histogram
hist eps, title("Histogram and normal density") bin(20) normal ///
		name(fig22a_2, replace) nodraw

** saving combined figure
graph combine fig22a_1 fig22a_2, row(2)
	graph export "$figures/fig22a.png", replace

********************************************************************************
* Question 2.2b: Generate AR(1) processes with three different autoregressive  *
*				 coefficients φ = {0:5; 0:8; 0:95}							   *
********************************************************************************
* install "sim_arma" from http://www.stata.com/users/jpitblado
// findit sim_arma
clear
set seed 113			// set seed number
sim_arma y_a, nobs(500) ar(0.5) spin(2000)
sim_arma y_b, nobs(500) ar(0.8) spin(2000)
sim_arma y_c, nobs(500) ar(0.95) spin(2000)

rename _t t
tsset t

*** i. Plot the time series against time

/* * Individual plots
tsline y_a, title("phi = 0.5")	///
		name(fig22b_1, replace)
tsline y_b, title("phi = 0.8")	///
		name(fig22b_2, replace)
tsline y_c, title("phi = 0.95")	///
		name(fig22b_3, replace)
graph combine fig22b_1 fig22b_2 fig22b_3, saving(fig2b_, replace)
	graph export $figures/fig22b_.png, replace
*/

** Combined plot
gr two	(tsline y_a)	///
		(tsline y_b)	///
		(tsline y_c)	///
		, legend ( lab(1 "phi = 0.5") lab(2 "phi = 0.8") lab(3 "phi = 0.95") ) ///
		xtitle("period t")
	graph export $figures/fig22b.png, replace

*** ii. Plot the ACF and PACF for each time series
ac y_a, lags(25) title("ACF, phi = 0.5") ytitle("") name(ac_a, replace) nodraw
ac y_b, lags(25) title("ACF, phi = 0.8") ytitle("") name(ac_b, replace) nodraw
ac y_c, lags(25) title("ACF, phi = 0.95") ytitle("") name(ac_c, replace) nodraw

pac y_a, lags(25) title("PACF, phi = 0.5") ytitle("") name(pac_a, replace) nodraw
pac y_b, lags(25) title("PACF, phi = 0.8") ytitle("") name(pac_b, replace) nodraw
pac y_c, lags(25) title("PACF, phi = 0.95") ytitle("") name(pac_c, replace) nodraw

graph combine ac_a ac_b ac_c pac_a pac_b pac_c
	graph export $figures/fig22b_ac.png, replace

corrgram y_c
ac y_c, lags(50) title("ACF, phi = 0.95") ytitle("")

********************************************************************************
* Question 2.2c: Generate MA(1) processes with three different moving average   *
*				 coefficients θ = {0:5; 0:8; 0:95}							   *
********************************************************************************
clear
set seed 113			// set seed number
sim_arma y_a, nobs(500) ma(0.5) spin(2000)
sim_arma y_b, nobs(500) ma(0.8) spin(2000)
sim_arma y_c, nobs(500) ma(0.95) spin(2000)

rename _t t
tsset t

*** i. Plot the time series against time
gr two	(tsline y_a)	///
		(tsline y_b)	///
		(tsline y_c)	///
		, legend ( lab(1 "theta = 0.5") lab(2 "theta = 0.8") ///
		lab(3 "theta = 0.95") ) ///
		xtitle("period t")
	graph export $figures/fig22c.png, replace

*** ii. Plot the ACF and PACF for each time series
ac y_a, lags(25) title("ACF, theta = 0.5") ytitle("") name(ac_a, replace) nodraw
ac y_b, lags(25) title("ACF, theta = 0.8") ytitle("") name(ac_b, replace) nodraw
ac y_c, lags(25) title("ACF, theta = 0.95") ytitle("") name(ac_c, replace) nodraw

pac y_a, lags(25) title("PACF, theta = 0.5") ytitle("") name(pac_a, replace) nodraw
pac y_b, lags(25) title("PACF, theta = 0.8") ytitle("") name(pac_b, replace) nodraw
pac y_c, lags(25) title("PACF, theta = 0.95") ytitle("") name(pac_c, replace) nodraw

graph combine ac_a ac_b ac_c pac_a pac_b pac_c
	graph export $figures/fig22c_ac.png, replace

corrgram y_a 	// 1-3 sign.
corrgram y_c 	// 1-6 + 7 sign.
su y_a y_b y_c	// slight increase in std. deviation w. theta->1


********************************************************************************
////////////////////////////////////////////////////////////////////////////////
///////////////////////// Question 2.3 ARIMA modelling /////////////////////////
////////////////////////////////////////////////////////////////////////////////
********************************************************************************
*** import Penn World Tables v9.0 from https://www.rug.nl/ggdc/productivity/pwt/
use pwt90.dta, replace
keep countrycode year rgdpna
keep if inlist(countrycode,"DEU","DNK","ESP")
replace rgdpna = 7.46038*rgdpna if countrycode=="DNK"
gen y = log(rgdpna)
drop rgdpna
// encode countrycode, gen(id)
// tsset id year
reshape wide y, i(year) j(countrycode) string
tsset year

* 1st differences
foreach y of varlist yDEU-yESP {
gen D`y' = 100*(`y' - `y'[_n-1])
}

********************************************************************************
* a) Plot the time series													   *
********************************************************************************
gr two	(tsline yDEU)	///
		(tsline yDNK)	///
		(tsline yESP)	///
		, legend ( lab(1 "Germany") lab(2 "Denmark") lab(3 "Spain") ) ///
		title("log real GDP per capita") xtitle("year") ytitle("ln(y)") ///
		name(fig23a_t, replace) nodraw
gr two	(tsline DyDEU)	///
		(tsline DyDNK)	///
		(tsline DyESP)	///
		, legend ( lab(1 "Germany") lab(2 "Denmark") lab(3 "Spain") ) ///
		title("growth in real GDP per capita") xtitle("year") ytitle("%") ///
		name(fig23a_D, replace) yla(-5 (5) 15, ang(h) grid) nodraw
graph combine fig23a_t fig23a_D, rows(2)
	graph export $figures/fig23a.png, replace

* Extremes in GDP growth -> looking at negative growth rates:
extremes DyDEU, n(10) // negative 	 75,      82,	  93, 03,   09
ta year if inlist(_n,18,26,33,44,54,60) // zero growth in 67 - unusual for the time
extremes DyDNK, n(15) // 51, 55,  74,75, 80,81,   88, 93,	 08,09,    12,13
ta year if inlist(_n,2,6,25,26,31,32,39,44,59,60,63,64)
extremes DyESP, n(10) //   53, 59,			81,		  93,		09, 11,12,13
ta year if inlist(_n,4,10,32,44,60,62,63,64)
extremes DyDEU DyDNK DyESP // all negative	 	      93,		09,	

********************************************************************************
* (b) Identification: using autocorrelation and partial autocorrelation		   *
*		functions, identify the orders of the ARIMA model. Compute both the	   *
*		numerical  and graphical ACFs(including confidence bands)			   *
********************************************************************************
foreach y of varlist yDEU-yESP {
	ac D.`y', lags(30) title("ACF, D.`y'") ytitle("") name(ac_`y', replace) nodraw
	pac D.`y', lags(30) title("PACF, D.`y'") ytitle("") name(pac_`y', replace) nodraw
}
graph combine ac_yDEU ac_yDNK ac_yESP pac_yDEU pac_yDNK pac_yESP
	graph export $figures/fig23b.png, replace
/*	Germany:
	PA is significant for lag 16 and 28-30
	can't model an ARMA(p,q) model where only q=1,3-4,16,28-30 are significant.
	i.e. they're 'false signals', can be due to model shifting
	due to structural breaks, e.g. the oil crisis in 1973 --> dummies! */

corrgram D.yDEU
corrgram D.yDNK
corrgram D.yESP	
/*  Correlogram:
	Computes the two functions together.
	Giving us the actual values of the coefficients.
	Portmanteau's Q test for white noise
	Testing the H_0: variable follows a white noise process ("no autocorrelation")
	e.g. rho_1 = rho_2 = rho_3 = 0
	Reject H0 if P<0.05 -> we might have autocorrelation. */

********************************************************************************
* (c) Estimation: fit the identified ARIMA specification,					   *
*		using MLE estimation procedures										   *
********************************************************************************
* Germany
eststo clear
arima yDEU, arima(4,1,4)
eststo
arima yDEU, arima(4,1,1)
eststo
arima yDEU, arima(1,1,4)	// lowest AIC, lag 3-4 not significant at 5% level
eststo
/*arima yDEU, arima(2,1,2)	// doesn't converge!
eststo
arima yDEU, arima(1,1,2) 	// doesn't converge!
eststo	*/
arima yDEU, arima(2,1,1)	// 
eststo
arima yDEU, arima(1,1,1)	// lowest BIC, lowest AIC where all lags significant
eststo
arima yDEU, arima(1,1,0)	// worse IC than ARMA(1,1)
eststo
arima yDEU, arima(0,1,1)	// worse IC than AR(1)
eststo
estout, cells(b(star fmt(3)) se(par fmt(3))) /// 
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	stats(aic bic, labels( "aic" "bic") fmt(1 1) )

* Denmark
eststo clear
arima yDNK, arima(1,1,1)
eststo
arima yDNK, arima(1,1,0)	// both lowest AIC and BIC, preferred
eststo
arima yDNK, arima(0,1,1)
eststo
estout, cells(b(star fmt(3)) se(par fmt(3))) /// 
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	stats(aic bic, labels( "aic" "bic") fmt(1 1) )

* Spain
eststo clear
arima yESP, arima(1,1,1)	// lowest AIC
eststo
arima yESP, arima(3,1,3)
eststo
arima yESP, arima(3,1,1)
eststo
arima yESP, arima(3,1,0)
eststo
arima yESP, arima(1,1,3)
eststo
arima yESP, arima(0,1,3)
eststo
arima yESP, arima(1,1,0)	// lowest BIC
eststo
estout, cells(b(star fmt(3)) se(par fmt(3))) /// 
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	stats(aic bic, labels( "aic" "bic") fmt(1 1) )

* Table 1 (for Denmark and Spain only)
eststo clear
arima yDNK, arima(1,1,0)	// both lowest AIC and BIC, preferred
eststo, title("Denmark, AR(1)")
arima yESP, arima(1,1,1)	// lowest AIC
eststo, title("Spain, ARMA(1,1)")
arima yESP, arima(1,1,0)	// lowest BIC
eststo, title("Spain, AR(1)")

estout using  "$tables/tab23c.tex", style(tex) replace ///
	cells(b(star fmt(3)) se(par fmt(3))) ///
	mlabels(,titles numbers) /// 	// manually remove underscore from "_cons"
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	stats(aic bic, labels( "aic" "bic") fmt(1 1) ) ///
	prehead("\begin{tabular}{lccc}\toprule") ///	// fit c's to number of columns
	posthead("\midrule") prefoot("\midrule") ///   
	postfoot("\bottomrule \end{tabular} \\ \text{Standard errors are in parentheses. * p<0.10, ** p<0.05, *** p<0.01}")


********************************************************************************
* (d) Validation: check the estimated residuals for misspecification errors	   *
********************************************************************************

*********************************** Germany ************************************
eststo clear
arima yDEU, arima(1,1,4)
eststo, title("ARMA(1,4)")
predict res_estimated1, residuals // are the residuals white noise or not?
tsline res_estimated1, title("Germany, ARMA(1,4) res.") ytitle("") name(res1, replace) ///
		yla(-0.05 (0.05) 0.05, ang(h) grid) xtitle("")
ac res_estimated1, title("ACF res.") ytitle("") name(acf1, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("") // all close to 0 
pac res_estimated1, title("PACF res.") ytitle("") name(pacf1, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("") // lag 15, 22, 25 and 30 are significant
corrgram res_estimated1
/* 	The correlation of all lags are close to zero
	Q test: the H0 that there is no-autocorrelation is not rejected at a 5% level
	--> There is nothing left to be explained
	--> The model seem well-specified according to the Q-test */
* Finding relevant structural breaks (outliers)
	di 1.5*.0201708 // criteria: 1.5 times bigger than std. dev. of err. term
	extremes res_estimated1, n(10) // 5 first are over the 'critical value'
	ta year if inlist(_n,60,26,44,25,14) // relevant negative 'outliers'
	ta year if inlist(_n,2,61,6) // relevant positive 'outliers'

graph close _all

arima yDEU, arima(1,1,1)
eststo, title("ARMA(1,1)")
predict res_estimated2, residuals // are the residuals white noise or not?
tsline res_estimated2, title("Germany, ARMA(1,1) res.") ytitle("") name(res2, replace) ///
		yla(-0.05 (0.05) 0.05, ang(h) grid) xtitle("")
ac res_estimated2, title("ACF res.") ytitle("") name(acf2, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 2 significant
pac res_estimated2, title("PACF res.") ytitle("") name(pacf2, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 2 significant
corrgram res_estimated2
/* 	The ac and pac of lag 2 > 0.3
	Q test: the H0 that there is no-autocorrelation is rejected for lags 2-6
	--> There is SOMETHING left to be explained
	--> The model is misspecified */
* Finding relevant structural breaks (outliers)
	di 1.5* .0220769 // criteria: 1.5 times bigger than std. dev. of err. term
	extremes res_estimated2, n(10) // 6 first are over the 'critical value'
	ta year if inlist(_n,60,18,26,44,25) // 6 negative 'outliers'
	ta year if inlist(_n,2,61,6) // 3 positive 'outliers'

graph close _all	

arima yDEU, arima(1,1,0)
eststo, title("AR(1)")
predict res_estimated3, residuals // are the residuals white noise or not?
tsline res_estimated3, title("Germany, AR(1) res.") ytitle("") name(res3, replace) ///
		yla(-0.05 (0.05) 0.05, ang(h) grid) xtitle("")
ac res_estimated3, title("ACF res.") ytitle("") name(acf3, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 4 significant, lag 2 close
pac res_estimated3, title("PACF res.") ytitle("") name(pacf3, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 4 significant, lag 2 close
corrgram res_estimated3
/*	The ac and pac of lag 4 are around 0.3
	Q test: the H0 that there is no-autocorrelation is rejected for lag 4
	--> There is SOMETHING left to be explained
	--> The model is misspecified */
* Finding relevant structural breaks (outliers)
	di 1.5* .0232647 // criteria: 1.5 times bigger than std. dev. of err. term
	extremes res_estimated3, n(10) // only 2009 is a negative 'outlier' >1.5 std. dev.
	ta year if inlist(_n,60,44,25,63,18) // 5 highest negative 'outliers'
	ta year if inlist(_n,61,2,6,27,19,10) // 6 positive 'outliers'
/*	--> instead the same outliers are applied as for the ARMA(1,1) model
			in fact, using these outliers yields better IC than all the tested
			versions with the outliers for the AR(1) model itself as dummies
			--> referring to the out-commented section below */

graph close _all

* Graphs for Germany without dummies 
graph combine res1 res2 res3 acf1 acf2 acf3 pacf1 pacf2 pacf3
	graph export $figures/fig23d_A1.png, replace

***  Testing if autocorrelation in models are due to structural breaks only  ***
* Generate year dummies
foreach n in 51 55 63 67 74 75 93 {
gen a`n' = year == 19`n'
}
foreach n in 09 10 {
gen a`n' = year == 20`n'
}

arima yDEU a51 a55 a63 a74 a75 a93 a09 a10, arima(1,1,4)
eststo, title("ARMA(1,4)")
predict res_estimated4, residuals // are the residuals white noise or not?
tsline res_estimated4, title("Germany, ARMA(1,4) res.") ytitle("") name(res4, replace) ///
		yla(-0.05 (0.05) 0.05, ang(h) grid) xtitle("")
ac res_estimated4, title("ACF res.") ytitle("") name(acf4, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 7 close to significant
pac res_estimated4, title("PACF res.") ytitle("") name(pacf4, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 24,25,30 are significant
corrgram res_estimated4
/* 	The correlation of lags are close to zero
	Q test: the H0 that there is no-autocorrelation is not rejected for any lags
	--> There is nothing left to be explained (except for the shocks!)
	--> The model specification is acceptable, but doesn't predict (negative) shocks */

graph close _all

arima yDEU a51 a55 a63 a67 a74 a75 a93 a09 a10, arima(1,1,1)
eststo, title("ARMA(1,1)")
predict res_estimated5, residuals // are the residuals white noise or not?
tsline res_estimated5, title("Germany, ARMA(1,1) res.") ytitle("") name(res5, replace) ///
		yla(-0.05 (0.05) 0.05, ang(h) grid) xtitle("")
ac res_estimated5, title("ACF res.") ytitle("") name(acf5, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 4 significant
pac res_estimated5, title("PACF res.") ytitle("") name(pacf5, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 4,9,21 borderline significant
corrgram res_estimated5
/* 	The correlation of most lags are close to zero, but for lag 4
	Q test: the H0 that there is no-autocorrelation is not rejected for any lags
	--> There isn't much left to be explained (except for the shocks!)
	--> The model specification is acceptable, but doesn't predict (negative) shocks */

graph close _all

arima yDEU a51 a55 a63 a67 a74 a75 a93 a09 a10, arima(1,1,0)
eststo, title("AR(1)")
predict res_estimated6, residuals // are the residuals white noise or not?
tsline res_estimated6, title("Germany, AR(1) res.") ytitle("") name(res6, replace) ///
		yla(-0.05 (0.05) 0.05, ang(h) grid) xtitle("")
ac res_estimated6, title("ACF res.") ytitle("") name(acf6, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 2 significant, 4 close
pac res_estimated6, title("PACF res.") ytitle("") name(pacf6, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 2,21 significant
corrgram res_estimated6
/*	The ac and pac are close to 0.3 for lag 2
	Q test: the H0 that there is no-autocorrelation is rejected for lags 5-7 (P<0,5)
	--> There is still something left to be explained
	--> The model might still be misspecified */

graph close _all

estout using  "$tables/tab23d.tex", style(tex) replace ///
	cells(b(star fmt(3)) se(par fmt(3))) ///
	mlabels(,titles numbers) /// 	// manually remove underscore from "_cons"
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	stats(aic bic, labels( "aic" "bic") fmt(1 1) ) ///
	prehead("\begin{tabular}{lcccccc}\toprule") ///	// fit c's to number of columns
	posthead("\midrule") prefoot("\midrule") ///   
	postfoot("\bottomrule \end{tabular} \\ \text{Standard errors are in parentheses. * p<0.10, ** p<0.05, *** p<0.01}")
/* 	Controlling for big shocks, no MA-terms are significant! 
	I.e. only severe shocks have persistence >1 period. 
	Thus, the AR(1) model would be preferred */

* Graphs for Germany with dummies 
graph combine res4 res5 res6 acf4 acf5 acf6 pacf4 pacf5 pacf6
	graph export $figures/fig23d_A2.png, replace
	
/*
	*** Testing alternative dummy specifications for the AR(1) model ***
	drop a*
	foreach n in 51 55 59 63 64 66 67 68 69 74 75 76 80 92 93 {
	gen a`n' = year == 19`n'
	}
	foreach n in 09 10 12 {
	gen a`n' = year == 20`n'
	}

	arima yDEU a51 a55 a59 a68 a76 a09 a10, arima(1,1,0)
	eststo, title("alt1") // >1.5 std. dev.

	arima yDEU a51 a55 a59 a67 a68 a74 a76 a93 a09 a10 a12, arima(1,1,0)
	eststo, title("alt2") // +5 most neg. outliers

	arima yDEU a51 a55 a67 a74 a93 a09 a10 a12, arima(1,1,0)
	eststo, title("alt3") // 5 most neg. and 3 most pos.

	arima yDEU a51 a55 a59 a64 a66 a67 a68 a69 a74 a75 a76 a80 a92 a93 a09 a10 a12, arima(1,1,0)
	eststo, title("alt4") // >1.0 std. dev.

	arima yDEU a66 a67 a74 a75 a80 a92 a93 a09 a12, arima(1,1,0)
	eststo, title("alt5") // only negative >1.0 std. dev.

	arima yDEU a51 a55 a59 a64 a68 a69 a76 a10, arima(1,1,0)
	eststo, title("alt6") // only positive >1.0 std. dev.

	estout est3 est6 est7 est8 est9 est10 est11 est12, cells(b(star fmt(3)) se(par fmt(3))) /// 
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		stats(aic bic, labels( "aic" "bic") fmt(1 1) )
	/*	Curiously, the AR(1) model performs better in terms of IC by applying
		the same outliers  as for the ARMA(1,1) model than for any of the tested
		versions with the outliers for the AR(1) model itself as dummies */
*/
	
/*
	*** Testing the ARMA(1,3) model with dummies ***
	arima yDEU a51 a55 a63 a74 a75 a93 a09 a10, arima(1,1,3)
	eststo alt_ARMA, title("ARMA(1,4)")
	estout est1 est4 alt_ARMA, cells(b(star fmt(3)) se(par fmt(3))) /// 
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		stats(aic bic, labels( "aic" "bic") fmt(1 1) )
	/* --> not quite an improvement... */
*/

****************************** Denmark and Spain *******************************
*** Denmark ***
arima yDNK, arima(1,1,0)
predict res_estimated7, residuals
tsline res_estimated2, title("Denmark, AR(1) res.") ytitle("") name(res7, replace) ///
		yla(-0.1 (0.1) 0.1, ang(h) grid) xtitle("")
ac res_estimated7, title("Denmark, ACF res.") ytitle("") name(acf7, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("") // no lags are significant
pac res_estimated7, title("Denmark, PACF res.") ytitle("") name(pacf7, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("") // only lag 13 is significant
corrgram res_estimated7
/*	All lags are close to 0, except for 13 (false signal due to structural break)
	Q test: the H0 that there is no-autocorrelation is not rejected for any lags
	--> There is nothing left to be explained
	--> The model is well-specified */

graph close _all

*** Spain ***
arima yESP, arima(1,1,1)
predict res_estimated8, residuals
tsline res_estimated8, title("Spain, ARMA(1,1) res.") ytitle("") name(res8, replace) ///
		yla(-0.1 (0.1) 0.1, ang(h) grid) xtitle("")
ac res_estimated8, title("Spain, ARMA(1,1), ACF res.") ytitle("") name(acf8, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// no lags significant
pac res_estimated8, title("Spain, ARMA(1,1), PACF res.") ytitle("") name(pacf8, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// only lag 29 is significant
corrgram res_estimated8	// correlations of lag 2 just < 0.2.
/*	All lags are close to 0, except for 29 (false signal due to structural break)
	Q test: the H0 that there is no-autocorrelation is not rejected for any lags
	--> There is nothing left to be explained
	--> The model is well-specified */

graph close _all

arima yESP, arima(1,1,0)
predict res_estimated9, residuals
tsline res_estimated9, title("Spain, AR(1) res.") ytitle("") name(res9, replace) ///
		yla(-0.1 (0.1) 0.1, ang(h) grid) xtitle("")
ac res_estimated9, title("Spain, AR(1), ACF res.") ytitle("") name(acf9, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 3,6 close to significant
pac res_estimated9, title("Spain, AR(1), PACF res.") ytitle("") name(pacf9, replace) ///
		yla(-0.4 (0.4) 0.4, ang(h) grid) xtitle("")	// lag 3,6 borderline significant
corrgram res_estimated9	// correlations of lag 3 > 0.2
/*	All lags are close to 0
	Q test: the H0 that there is no-autocorrelation is not rejected for any lags
	--> There is not really anything left to be explained (but lag 3 is interesting)
	--> The model is well-specified */

graph close _all

* Graph for Denmark and Spain
graph combine res7 res8 res9 acf7 acf8 acf9 pacf7 pacf8 pacf9
	graph export $figures/fig23d.png, replace

graph close _all

********************************************************************************
* (e) Forecasting: compute the one-step ahead forecast of the log of real	   *
********************************************************************************
***	 	GDP per capita time series
set obs `=_N+10'
replace year = 1+year[_n-1] if missing(year)
sort year

*********************************** Germany ************************************
* Germany, models estimated without use of dummies
arima yDEU, arima(1,1,4)
predict DyDEU_pred1, xb 				// in first differences
predict yDEU_pred1, y 					// in levels

arima yDEU, arima(1,1,1)
predict DyDEU_pred2, xb 				// in first differences
predict yDEU_pred2, y 					// in levels

* Germany, models estimated using dummies
arima yDEU a51 a55 a63 a74 a75 a93 a09 a10, arima(1,1,4) // estimate using dummies
foreach var of varlist a51 a55 a63 a74 a75 a93 a09 a10 {
	replace `var' = 0
}										// Exclude dummies to predict 'out of sample'
predict DyDEU_pred3, xb 				// in first differences
predict yDEU_pred3, y 					// in levels

foreach n in 51 55 63 67 74 75 93 {
replace a`n' = 1 if year == 19`n'
}
foreach n in 09 10 {
replace a`n' = 1 if year == 20`n'
}

arima yDEU a51 a55 a63 a67 a74 a75 a93 a09 a10, arima(1,1,1) // estimate using dummies
foreach var of varlist a51 a55 a63 a67 a74 a75 a93 a09 a10 {
	replace `var' = 0
}										// Exclude dummies to predict 'out of sample'
predict DyDEU_pred4, xb 				// in first differences
predict yDEU_pred4, y 					// in levels

****************************** Denmark and Spain *******************************
* Denmark, Spain, AR(1)
foreach y of varlist yDNK-yESP {
	arima `y', arima(1,1,0)
	predict D`y'_pred, xb 					// in first differences
	predict `y'_pred, y 					// in levels
}

* Spain, ARMA(1,1)
arima yESP, arima(1,1,1)
predict DyESP_pred1, xb 				// in first differences
predict yESP_pred1, y 					// in levels

************************** Out of sample predictions ***************************
foreach y_p of varlist yDEU_pred1 yDEU_pred2 yDEU_pred3 yDEU_pred4 ///
	yDNK_pred yESP_pred yESP_pred1 {
replace `y_p' = `y_p'[_n-1]+D`y_p' if missing(`y_p')	// Out of sample levels
replace D`y_p' = 100*D`y_p' 							// FD in percentage
}
label variable DyDEU_pred1 "AR, no dummies"

estpost tabstat DyDEU_pred1 DyDEU_pred2 DyDEU_pred3 DyDEU_pred4 ///
	DyDNK_pred DyESP_pred DyESP_pred1 if year==2015

esttab . using "$tables/tab23e1.tex" ///
	, style(tex) replace nonumbers noobs ///
	cells("DyDEU_pred1(fmt(2)) DyDEU_pred2(fmt(2)) DyDEU_pred3(fmt(2)) DyDEU_pred4(fmt(2))") ///
	prehead("\begin{tabular}{lcccc}\toprule") ///	// fit c's to number of columns
	posthead("\midrule\\ Model&ARMA(1,4)&ARMA(1,1)&ARMA(1,4)&ARMA(1,1)\\ Time dummies&no&no&yes&yes\\ \midrule") ///
	postfoot("\bottomrule \end{tabular}")

esttab . using "$tables/tab23e2.tex" ///
	, style(tex) replace nonumbers noobs ///
	cells("DyDNK_pred(fmt(2)) DyESP_pred1(fmt(2)) DyESP_pred(fmt(2))") ///
	prehead("\begin{tabular}{lccc}\toprule") ///	// fit c's to number of columns
	posthead("\midrule\\ Country&Denmark&Spain&Spain\\ Model&AR(1)&ARMA(1,1)&AR(1)\\ Time dummies&no&no&no\\ \midrule") ///
	postfoot("\bottomrule \end{tabular}")

********************************************************************************
* (f) Plot both the actual and predicted time series for each country		   *
********************************************************************************
label variable yDEU "Actual"
label variable yDNK "Actual"
label variable yESP "Actual"
label variable DyDEU "Actual"
label variable DyDNK "Actual"
label variable DyESP "Actual"

* Germany, ARMA(1,4)
label variable DyDEU_pred1 "ARMA(1,4) without dummies"
label variable DyDEU_pred3 "ARMA(1,4) with dummies"
	tsline DyDEU_pred1 DyDEU_pred3 DyDEU, title("Germany, ARMA(1,4)") ///
		ytitle("growth in %") name("DEU1", replace) nodraw

/* Germany, GDP level
label variable yDEU_pred1 "ARIMA(1,1,4) without dummies"
label variable yDEU_pred3 "ARIMA(1,1,4) with dummies"
	tsline yDEU_pred1 yDEU_pred3 yDEU, title("GDP level, ARIMA(1,1,4)") ///
		ytitle("log real GDP") name("DEU2", replace) nodraw
graph combine DEU1 DEU2, row(2)
	graph export $figures/fig23fDEU1.png, replace
*/

* Germany, ARMA(1,1)
label variable DyDEU_pred2 "ARMA(1,1) without dummies"
label variable DyDEU_pred4 "ARMA(1,1) with dummies"
	tsline DyDEU_pred2 DyDEU_pred4 DyDEU, title("Germany, ARMA(1,1)") ///
		ytitle("growth in %") name("DEU3", replace) nodraw

graph combine DEU1 DEU3, row(2)

/* * Germany, GDP level
label variable yDEU_pred2 "ARIMA(1,1,1) without dummies"
label variable yDEU_pred4 "ARIMA(1,1,1) with dummies"
	tsline yDEU_pred2 yDEU_pred4 yDEU, title("GDP level") ///
		ytitle("log real GDP") name("DEU4", replace) nodraw
graph combine DEU3 DEU4, row(2)
	graph export $figures/fig23fDEU2.png, replace
*/

* Germany, no dummies
label variable DyDEU_pred1 "ARMA(1,4)"
label variable DyDEU_pred2 "ARMA(1,1)"
	tsline DyDEU_pred1 DyDEU_pred2 DyDEU, ///
		title("Germany, estimations without dummies") ytitle("growth in %")
	graph export $figures/fig23f2.png, replace

* Denmark, AR(1)
label variable DyDNK_pred "AR(1)"
	tsline DyDNK_pred DyDNK, title("Denmark") ///
		ytitle("growth in %") name("DNK1", replace) nodraw

/* Denmark, GDP level
label variable yDNK_pred "ARIMA(1,1,0) without dummies"
	tsline yDNK_pred yDNK, title("GDP level") ///
		ytitle("log real GDP") name("DNK2", replace) nodraw
graph combine DNK1 DNK2, row(2)
	graph export $figures/fig23fDNK.png, replace
*/

* Spain, AR(1) + ARMA(1,1)
label variable DyESP_pred "AR(1)"
label variable DyESP_pred1 "ARMA(1,1)"
	tsline DyESP_pred DyESP_pred1 DyESP, title("Spain") ///
		ytitle("growth in %") name("ESP1", replace) nodraw

graph combine DNK1 ESP1, row(2)
	graph export $figures/fig23f3.png, replace

/* Spain, GDP level
label variable yESP_pred "ARIMA(1,1,0) without dummies"
label variable yESP_pred1 "ARIMA(1,1,1) without dummies"
	tsline yESP_pred yESP_pred1 yESP, title("GDP level") ///
		ytitle("log real GDP") name("ESP2", replace) nodraw
graph combine ESP1 ESP2, row(2)
	graph export $figures/fig23fESP.png, replace
*/

********************************************************************************
////////////////////////////////////////////////////////////////////////////////
////////////////// Question 2.4 Order of integration analysis //////////////////
////////////////////////////////////////////////////////////////////////////////
********************************************************************************
/*	Following the Dickey-Pantula strategy, determine the order of integration of
	the real per capita GDP time series that you have selected */

********************************************************************************
* (a) With a constant term								   					   *
********************************************************************************
/*	Following the Dickey-Pantula strategy:
	H0: ln_yDEU_t \sim I(2)
	H1: ln_yDEU_t \sim I(1) or I(0)
	equivalent to:
	H0: D.ln_yDEU_t \sim I(1)
	H1: D.ln_yDEU_t \sim I(0)

	if D.ln_yDEU_t \sim I(0), then test
	H0: ln_yDEU_t \sim I(1)
	H1: ln_yDEU_t \sim I(0)													  */

/////////////////// Testing the 1st order transformed series ///////////////////

*** ADF ***
foreach lag of numlist 1/10 {
	di "Running ADF test for " `lag' " lagged differences of the FD of German GDP pc:"
	dfuller D.yDEU, lags(`lag') noconstant //regress
}
/*	for all lags the ADF test statistic is below the 5% critical value (neg. sign),
	i.e. we clearly reject the H0 that the FD of the time series contain a unit root */
foreach lag of numlist 1/10 {
	di "Running ADF test for " `lag' " lagged differences of the FD of Danish GDP pc:"
	dfuller D.yDNK, lags(`lag') noconstant
}
/* 	for lags 2-10 the ADF test statistic is above the 5% critical value (neg. sign),
	i.e. we can't reject the H0 that the FD of the time series contain a unit root */
foreach lag of numlist 1/10 {
	di "Running ADF test for " `lag' " lagged differences of the FD of Spanish GDP pc:"
	dfuller D.yESP, lags(`lag') noconstant
}
/*	for lags 2-9 the ADF test statistic is above the 5% critical value (neg. sign),
	i.e. we can't reject the H0 that the FD of the time series contain a unit root */

*** PP ***
foreach lag of numlist 1/10 {
	di "Running PP test for " `lag' " lagged differences of the FD of German GDP pc:"
	pperron D.yDEU, lags(`lag') noconstant
}
foreach lag of numlist 1/10 {
	di "Running PP test for " `lag' " lagged differences of the FD of Danish GDP pc:"
	pperron D.yDNK, lags(`lag') noconstant
}
foreach lag of numlist 1/10 {
	di "Running PP test for " `lag' " lagged differences of the FD of Spanish GDP pc:"
	pperron D.yESP, lags(`lag') noconstant
}
/* 	for all lags the PP test statistic is below the 5% critical value (neg. sign),
	i.e. we clearly reject the H0 that the FD of the time series contain a unit root */

*** ADF-GLS ***
foreach gdp of varlist yDEU-yESP {
	dfgls D.`gdp', notrend
}
/* 	the ADF-GLS test statistic is above the 5% critical value for all lags, 
	except for Denmark for lags 1-2
	i.e. for Germany and Spain we can't reject the H0
	that the FD of the time series contain a unit root */

*** KPSS ***
* install "sts15_2" to perform kpss tests
// findit kpss
foreach gdp of varlist yDEU-yESP {
	kpss D.`gdp', notrend
	kpss D.`gdp', notrend auto
}
/* 	the KPSS test statistic is above the 5% critical value for all lags, 
	except for Denmark for lags 9-10
	i.e. for Germany and Spain we clearly reject the H0,
	that the FD of the time series is level stationary */

//////////////// Testing the non-transformed series for Denmark ////////////////

*** ADF ***
foreach lag of numlist 1/10 {
	di "Running ADF test for " `lag' " lagged differences of Danish GDP pc:"
	dfuller yDNK, lags(`lag')
}

*** PP ***
foreach lag of numlist 1/10 {
	di "Running PP test for " `lag' " lagged differences of Danish GDP pc:"
	pperron yDNK, lags(`lag')
}

*** ADF-GLS ***
dfgls yDNK, notrend

*** KPSS ***
kpss yDNK, notrend
kpss yDNK, notrend auto


********************************************************************************
* (b) With a linear time trend								   					   *
********************************************************************************

/////////////////// Testing the 1st order transformed series ///////////////////

*** ADF ***
foreach lag of numlist 1/10 {
	di "Running ADF test for " `lag' " lagged differences of the FD of German GDP pc:"
	dfuller D.yDEU, lags(`lag') //regress
}
/*	for lags 2,3,5-8,10 the ADF test statistic is above the 5% critical value (neg. sign),
	i.e. we can't reject the H0 that the FD of the time series contain a unit root */
foreach lag of numlist 1/10 {
	di "Running ADF test for " `lag' " lagged differences of the FD of Danish GDP pc:"
	dfuller D.yDNK, lags(`lag')
}
/* 	for lags 3-10 the ADF test statistic is above the 5% critical value (neg. sign),
	i.e. we can't reject the H0 that the FD of the time series contain a unit root */
foreach lag of numlist 1/10 {
	di "Running ADF test for " `lag' " lagged differences of the FD of Spanish GDP pc:"
	dfuller D.yESP, lags(`lag')
}
/*	for lags 2-10 the ADF test statistic is above the 5% critical value (neg. sign),
	i.e. we can't reject the H0 that the FD of the time series contain a unit root */

*** PP ***
foreach lag of numlist 1/10 {
	di "Running PP test for " `lag' " lagged differences of the FD of German GDP pc:"
	pperron D.yDEU, lags(`lag')
}
foreach lag of numlist 1/10 {
	di "Running PP test for " `lag' " lagged differences of the FD of Danish GDP pc:"
	pperron D.yDNK, lags(`lag')
}
foreach lag of numlist 1/10 {
	di "Running PP test for " `lag' " lagged differences of the FD of Spanish GDP pc:"
	pperron D.yESP, lags(`lag')
}
/* 	for all lags the PP test statistic is well below the 5% critical value (neg. sign),
	i.e. we clearly reject the H0 that the FD of the time series contain a unit root */

//////////////// Testing the non-transformed series for Denmark ////////////////

*** ADF ***
foreach lag of numlist 1/10 {
	di "Running ADF test for " `lag' " lagged differences of Danish GDP pc:"
	dfuller yDNK, lags(`lag') trend
}

*** PP ***
foreach lag of numlist 1/10 {
	di "Running PP test for " `lag' " lagged differences of Danish GDP pc:"
	pperron yDNK, lags(`lag') trend
}

*** ADF-GLS ***
dfgls yDNK

*** KPSS ***
kpss yDNK
kpss yDNK, auto
