* install egranger from
net from http://fmwww.bc.edu/RePEc/bocode/e/
help vec
////////////////////////////////////////////////////////////////////////////////
/////////////////////// Clear all and set up folders ////////////////////////////
////////////////////////////////////////////////////////////////////////////////
set scheme s1color
clear all
cd            	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS2\stata_code"
global figures	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS2\03_figures"
global tables	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS2\04_tables"


********************************************************************************
* Question 3.1a Gaussian stochastic process                                     *
********************************************************************************
*** 3.1
use pwt90.dta, replace
keep countrycode year rgdpna
keep if inlist(countrycode,"DEU","FRA","GBR")
gen y = log(rgdpna)
drop rgdpna
* encode countrycode, gen(id)
* tsset id year
reshape wide y, i(year) j(countrycode) string
tsset year

* a)
reg yFRA yDEU					// Static equation
predict residuals, resid		// Save the residuals
dfuller residuals, lags(5)		// ADF test
eststo eg, title("1st step")
drop residuals

* b)
egranger yFRA yDEU, lags(5) regress ecm
eststo ECM
estout eg ECM using "$tables/tab31b.tex", style(tex) replace ///
	cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	mlabels(,titles numbers) /// 	// manually remove underscore from "L._egresid" & "_cons"
	/// //stats(aic bic, labels("aic" "bic") fmt(3 0) ) ///
	prehead("\begin{tabular}{lcc}\toprule") ///	// fit c's to number of columns
	posthead("\midrule") /// // prefoot("\midrule") ///   
	postfoot("\bottomrule \end{tabular} \\ \text{Standard errors are in parentheses. * p<0.10, ** p<0.05, *** p<0.01}")


*** 3.2
* a)
varsoc yFRA yDEU yGBR 			// Optimal lag of a VAR(P)
help varsoc
* b)
vecrank  yFRA yDEU yGBR, lags(2) // Number of cointegrated relationships.

* c)
vec yFRA yDEU yGBR, lags(2) rank(2) 
eststo VEC, title("Short run parameters")

estout VEC using "$tables/tab32c1.tex", style(tex) replace ///
	cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	mlabels(,titles ) /// 	// manually remove all of the underscores
	/// //stats(aic bic, labels("aic" "bic") fmt(3 0) ) ///
	prehead("\begin{tabular}{lc}\toprule") ///	// fit c's to number of columns
	posthead("\midrule") /// // prefoot("\midrule") ///   
	postfoot("\bottomrule \end{tabular} \\ \text{Standard errors are in parentheses. * p<0.10, ** p<0.05, *** p<0.01}")

* Refit the model with the Johansen normalization and the overidentifying constraint
constraint define 1 [_ce1]yFRA = 1
constraint define 2 [_ce1]yDEU = 0
constraint define 3 [_ce2]yFRA = 0
constraint define 4 [_ce2]yDEU = 1

vec yFRA yDEU yGBR, lags(2) rank(2) noetable bconstraints(1/4) idtest


*** 3.3
tsline yFRA yDEU yGBR
	

***SECOND***

tsset t

tsline austin dallas houston sa
**we want to check whether these variables are cointegrated or not.
**So we define the following vector of variables: Yt=(austin dallas houston sa)
** we want to estimate if there is a long-relationship between these variables.
*austin= b0 + b2Dallas +b3 Houston +b4 SA + ut.
**We have to check whether ut is I(1) or I(0), to see if we have cointegration or not.
*PROBLEm: If we only estimate one equation, then we are imposing only one long run
*relationship. To test it we will use Engle and Granger procedure.
*This test foccus on the disturbance term of the model especification.

*Ho: ut-i(1)
*H: ut-i()
*

help egranger
*help bayerhanck
egranger austin dallas houston sa, lags(5) regress
*we check it at the 10 percent level (lags)
*There is a cointegrating relationship linking the house prices.
*The cointegration vector is: (1, -b2, -b3, -b4), because we are isolating the disturbance term.

bayerhanck austin, rhs(dallas houston sa) lags(5)

*ECM (Error Correction Model)

egranger austin dallas houston sa, lags(1) regress ecm
*_egresid is the gamma
varsoc austin dallas houston sa //To get the optimal lag of a VAR(P)
vecrank  austin dallas houston sa, lags(2) //Testing the number of independent VEC
//using the trace statistic we can see that we have 2 cointegrated relationships (johansen procedure)
//we selcet rank=2 because of the trace test.
***ESTIMATING***

vec austin dallas houston sa, lags(2) rank(2)


* PROBLEM SET 1
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

tsline eps, title("Time series")	///
		name(fig22a_1, replace)

** histogram
hist eps, title("Histogram") 		///
		name(fig22a_2, replace)

** saving combined figure
graph combine fig22a_1 fig22a_2, saving("fig22a", replace)
	graph export "$figures/fig22a.png", replace

********************************************************************************
* Question 2.2b: Generate AR(1) processes with three different autoregressive   *
*				 coefficients φ = {0:5; 0:8; 0:95}							   *
********************************************************************************
clear
set seed 113			// set seed number
sim_arma y_a, nobs(500) ar(0.5) spin(2000)
sim_arma y_b, nobs(500) ar(0.8) spin(2000)
sim_arma y_c, nobs(500) ar(0.95) spin(2000)

rename _t t
tsset t

*** i. Plot the time series against time

/* ** In individual plots
tsline y_a, title("phi = 0.5")	///
		name(fig22b_1, replace)
tsline y_b, title("phi = 0.8")	///
		name(fig22b_2, replace)
tsline y_c, title("phi = 0.95")	///
		name(fig22b_3, replace)
graph combine fig22b_1 fig22b_2 fig22b_3, saving(fig2b_, replace)
	graph export $figures/fig22b_.png, replace
*/

*** Combined plot
gr two	(tsline y_a)	///
		(tsline y_b)	///
		(tsline y_c)	///
		, legend ( lab(1 "phi = 0.5") lab(2 "phi = 0.8") lab(3 "phi = 0.95") ) ///
		xtitle("period t") ///
		saving(fig22b, replace)
	graph export $figures/fig22b.png, replace

*** ii. Plot the ACF and PACF for each time series
ac y_a, lags(25) title("ACF, phi = 0.5") ytitle("") name(ac_a, replace) nodraw
ac y_b, lags(25) title("ACF, phi = 0.8") ytitle("") name(ac_b, replace) nodraw
ac y_c, lags(25) title("ACF, phi = 0.95") ytitle("") name(ac_c, replace) nodraw

pac y_a, lags(25) title("PACF, phi = 0.5") ytitle("") name(pac_a, replace) nodraw
pac y_b, lags(25) title("PACF, phi = 0.8") ytitle("") name(pac_b, replace) nodraw
pac y_c, lags(25) title("PACF, phi = 0.95") ytitle("") name(pac_c, replace) nodraw

graph combine ac_a ac_b ac_c pac_a pac_b pac_c, saving(fig22b_ac, replace)
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
		xtitle("period t") ///
		saving(fig22c, replace)
	graph export $figures/fig22c.png, replace

*** ii. Plot the ACF and PACF for each time series
ac y_a, lags(25) title("ACF, theta = 0.5") ytitle("") name(ac_a, replace) nodraw
ac y_b, lags(25) title("ACF, theta = 0.8") ytitle("") name(ac_b, replace) nodraw
ac y_c, lags(25) title("ACF, theta = 0.95") ytitle("") name(ac_c, replace) nodraw

pac y_a, lags(25) title("PACF, theta = 0.5") ytitle("") name(pac_a, replace) nodraw
pac y_b, lags(25) title("PACF, theta = 0.8") ytitle("") name(pac_b, replace) nodraw
pac y_c, lags(25) title("PACF, theta = 0.95") ytitle("") name(pac_c, replace) nodraw

graph combine ac_a ac_b ac_c pac_a pac_b pac_c, saving(fig22c_ac, replace)
	graph export $figures/fig22c_ac.png, replace

corrgram y_a 	// 1-3 sign.
corrgram y_c 	// 1-6 + 7 sign.
su y_a y_b y_c	// slight increase in std. deviation w. theta->1

********************************************************************************
* Question 2.3 ARIMA modelling			                                       *
********************************************************************************
*** import Penn World Tables v9.0 from https://www.rug.nl/ggdc/productivity/pwt/
use pwt90.dta, replace
keep countrycode year rgdpna
keep if inlist(countrycode,"DEU","DNK","ESP")
replace rgdpna = 7.46038*rgdpna if countrycode=="DNK"
gen y = log(rgdpna)
drop rgdpna
* encode countrycode, gen(id)
* tsset id year
reshape wide y, i(year) j(countrycode) string
tsset year

*** a) Plot the time series
gr two	(tsline yDEU)	///
		(tsline yDNK)	///
		(tsline yESP)	///
		, legend ( lab(1 "Germany") lab(2 "Denmark") lab(3 "Spain") ) ///
		title("log real GDP/capita") xtitle("year") ytitle("ln(y)") ///
		name(fig23a_t, replace) nodraw
gr two	(tsline D.yDEU)	///
		(tsline D.yDNK)	///
		(tsline D.yESP)	///
		, legend ( lab(1 "Germany") lab(2 "Denmark") lab(3 "Spain") ) ///
		title("real GDP growth") xtitle("year") ytitle("%") ///
		name(fig23a_D, replace) nodraw
graph combine fig23a_t fig23a_D, saving(fig23a, replace)
	graph export $figures/fig23a.png, replace

* Extremes in GDP growth
gen DyDEU = 100*(yDEU - yDEU[_n-1])
gen DyDNK = 100*(yDNK - yDNK[_n-1])
gen DyESP = 100*(yESP - yESP[_n-1])
extremes DyDEU, n(10) // negative 	 75,       82, 93, 03,    09
extremes DyDNK, n(15) // negative 74,75, 80,81,            08,09
extremes DyESP, n(10) // negative 				   93,		  09, 11,12,13
extremes DyDEU DyDNK DyESP // all negative	 	   93,		  09,	

*** (b) Identification: using autocorrelation and partial autocorrelation
***		functions, identify the orders of the ARIMA model. Compute both the numerical 
***		and graphical autocorrelation functions (including confidence bands)
foreach y of varlist yDEU-yESP {
	ac D.`y', lags(15) title("ACF, D.`y'") ytitle("") name(ac_`y', replace) nodraw
	pac D.`y', lags(15) title("PACF, D.`y'") ytitle("") name(pac_`y', replace) nodraw
}
graph combine ac_yDEU ac_yDNK ac_yESP pac_yDEU pac_yDNK pac_yESP ///
		, saving(fig23b, replace)
	graph export $figures/fig23b.png, replace

corrgram D.yDEU
corrgram D.yDNK
corrgram D.yESP	/*  Table: Computes the two functions together.
					Giving us the actual values of the coefficients.
					Q: The Box-Pierce Qtest (Ljung-Box)
					   Testing the H_0 = "no autocorrelation",
					   e.g. rho_1 = rho_2 = rho_3 = 0*/

*** (d) Validation: check the estimated residuals for misspecification errors
***********
* Germany *
***********
* d
arima yDEU, arima(1,1,4)
predict res_estimated, residuals // are the residuals white noise or not?
tsline res_estimated
ac res_estimated
pac res_estimated 	// only 15, 22, 25 are significant
					// can't model an AR(p) model where only lag 15, 22, 25 are significant.
					// i.e. they're 'false signals', can be due to model shifting
					// due to structural breaks, e.g. the oil crisis in 1973 --> dummies!
corrgram res_estimated
/* 	The correlation of all lags are close to zero
	Q test: the H0 that there is no-autocorrelation is rejected (P<0.05)
	--> There is nothing left to be explained
	--> Our model is well-specified */
extremes res_estimated, n(10) // 09>74-75,93

* Denmark
arima yDNK, arima(1,1,1)
predict res_estimated2, residuals
tsline res_estimated2
ac res_estimated2
pac res_estimated2
corrgram res_estimated2

* Spain
arima yDNK, arima(1,1,1)
predict res_estimated3, residuals
tsline res_estimated3
ac res_estimated3
pac res_estimated3
corrgram res_estimated3


*** (c) Estimation: fit the identified ARIMA specification, using MLE estimation procedures
gen y74 = year == 1974
gen y75 = year == 1975
gen y93 = year == 1993
gen y09 = year == 2009

eststo clear
arima yDEU, arima(1,1,1)
eststo, title("Germany")
/*
arima yDEU, arima(1,1,2) // doesn't converge!
eststo, title("Germany")
*/
arima yDEU, arima(1,1,4)
eststo, title("Germany")

arima yDEU y74 y75 y93 y09, arima(1,1,1)
eststo, title("Germany")

arima yDEU y74 y75 y93 y09, arima(1,1,4)
eststo, title("Germany")

arima yDEU y74 y75 y93 y09, arima(1,1,0)
eststo, title("Germany")

arima yDNK, arima(1,1,1)
eststo, title("Denmark")

arima yESP, arima(1,1,1)
eststo, title("Spain")

estout using  "$tables/tab23.tex", replace cells(b(star fmt(3)) se(par fmt(3))) ///
	style(tex) mlabels(,titles numbers) /// 	// manually remove underscore from "_cons"
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	stats(aic bic, labels( "aic" "bic") fmt(3 0) ) ///
	prehead("\begin{tabular}{lccccccc}\toprule") ///	// fit c's to number of columns
	posthead("\midrule") prefoot("\midrule") ///   
	postfoot("\bottomrule \end{tabular} \text{Standard errors are in parentheses. * p<0.10, ** p<0.05, *** p<0.01}")

*** (e) Forecasting: compute the one-step ahead forecast of the log of real
***	 	GDP per capita time series
set obs `=_N+10'
replace year = 1+year[_n-1] if missing(year)
sort year

* Germany, y ARIMA(1,1,4)
arima yDEU, arima(1,1,4)
predict DyDEU_pred1, xb 				// in first differences
replace DyDEU_pred1 = 100*DyDEU_pred1	// in percentage
predict yDEU_pred1, y 					// in levels

* Germany, D.y AR(1)
arima yDEU y74 y75 y93 y09, arima(1,1,0)
predict DyDEU_pred2, xb 				// in first differences
replace DyDEU_pred2 = 100*DyDEU_pred2	// in percentage
predict yDEU_pred2, y 					// in levels 

* Denmark & Spain, y ARIMA(1,1,1)
foreach y of varlist yDNK-yESP {
arima `y', arima(1,1,1)
predict D`y'_pred, xb 					// in first differences
replace D`y'_pred = 100*D`y'_pred		// in percentage
predict `y'_pred, y 					// in levels
}

*** (f) Plot both the actual and predicted time series for each country
label variable DyDEU "Actual"
label variable DyDNK "Actual"
label variable DyESP "Actual"

label variable DyDEU_pred1 "ARMA(1,4)"
	tsline DyDEU DyDEU_pred1, title("Germany (no dummies)") ///
		ytitle("growth in %") name("DEU1", replace) nodraw
label variable DyDEU_pred2 "AR(1)"
	tsline DyDEU DyDEU_pred2, title("Germany (with dummies)") ///
		ytitle("growth in %") name("DEU2", replace) nodraw
label variable DyDNK_pred "ARMA(1,1)"
	tsline DyDEU DyDNK_pred, title("Denmark (no dummies)") ///
		ytitle("growth in %") name("DNK", replace) nodraw
label variable DyESP_pred "ARMA(1,1)"
	tsline DyDEU DyESP_pred, title("Spain (no dummies)") ///
		ytitle("growth in %") name("ESP", replace) nodraw

graph combine DEU1 DEU2 DNK ESP ///
		, saving(fig23f, replace)
	graph export $figures/fig23f.png, replace
		


////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// do_Practice_1 /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
tsline ln_wpi // Graph

*Arima modelling: Compute and decide how the time series can be modelled
corrgram ln_wpi // AC and PAC close to 1
ac ln_wpi // slowly becomes insignificant
pac ln_wpi // quickly become insignificant, sign shifts a lot
// -> ln_wpi is non stationary, a unit root.

*First difference:
corrgram D.ln_wpi
ac D.ln_wpi // Autocorrelation is far away from one and becomes insignificant after 6 lags
pac D.ln_wpi // Partial autocorrelation: far away from one and only 1,2,4 are significant
// -> D.ln_wpi is stationary

*********************************************
* 				Suggest a model 			*
*********************************************
* Similar number of lags (ACF+PACF)? --> D.ln_wpi_t \sim ARMA(p,q)
* I.e. decide 3rd lag almost is significant --> lots of lags in both
* Parsimonious principle: Estimate the more simple model.
* ARMA(1,1) only requires estimation of two coefficients as opposed to AR(4)

* ACF's number of lags clearly dominates PACF? --> D.ln_wpi_t \sim AR(p)
* --> AR(4) to capture the significant effect of lag 4, though lag 3 isn't significant.

* PACF's number of lags clearly dominates ACF --> D.ln_wpi_t \sim MA(p)
* --> AR(4) requires specification of four coefficients.

*********************************************
* 				Estimate a model 			*
*********************************************
help arima
help arima_postestimation

*ARMA(1,1):
arima ln_wpi, arima(1,1,1)
estat aroots // Conditions for a well-specified model: AR roots < 1. |MA roots| < 1.
estat ic // Akaike's IC and Bayesian IC

*AR(4)
arima D.ln_wpi, ar(4)
estat aroots // Conditions for a well-specified model: All AR roots < 1.
estat ic // Akaike's IC (AIK) and Bayesian IC (BIC)

* Compare the two models based on the information criterias
* Choose the one with the lower IC: e.g. -757 < -724 --> ARIMA(1,1,1) is preferred


*********************************************
* 				Predict outcomes 			*
*********************************************
arima ln_wpi, arima(1,1,1)

* predict 'the name of the new variable' from the last model estimated
help predict
predict dif_ln_wpi_pred, xb 	 // in first differences (for dif_ln_wpi_t)
tsline D.ln_wpi dif_ln_wpi_pred  // actual time series more volatile than estimated

predict ln_wpi_pred, y      	 // in levels (for ln_wpi_t) 
tsline ln_wpi ln_wpi_pred

predict res_estimated, residuals // are the residuals white noise or not?
tsline res_estimated
ac res_estimated  // four is a 'false signal'
pac res_estimated // can't model an AR model where only lag 4, 26 and 37 is significant.
				  // i.e. they're 'false signals', can be due to model shifting
				  // due to structural breaks, e.g. the oil crisis in 1973 --> dummies!
corrgram res_estimated
/* 	The correlation of all lags are close to zero
	Q test: the H0 that there is no-autocorrelation is rejected (P>Q is less than 0.05)
	--> There is nothing left to be explained
	--> Our model is well-specified */

*********************************************
* 		Order of Integration Analysis		*
*********************************************
* H0: ln_wpi_t \sim I(2)
* H1: ln_wpi_t \sim I(1) or I(0)
* equivalent to:
* H0: D.ln_wpi_t \sim I(1)
* H1: D.ln_wpi_t \sim I(0)

*** Dickey-Fuller test ***
dfuller D.ln_wpi, lags(5) regress // 5 lags just to test the next lag...
* test statistic is above the 5% critical value, i.e. we can't reject the H0 
* --> Conclude that the FD of times series is I(1)

dfuller D.ln_wpi, lags(4) regress // fourth lag is insignificant

dfuller D.ln_wpi, lags(3) regress // lags 1-3 are significant (P>Q is less than 0.05).

*** Dickey-Fuller GLS-transformed ***
help dfgls
dfgls D.ln_wpi, notrend maxlag(5) ers // Optimal lags: 5.

////////////////////////////////////////////////////////////////////////////////
///////////////////////////// do_ARIMA_house prices ////////////////////////////
////////////////////////////////////////////////////////////////////////////////
* simulate random walk, AR(1)
sim_arma yran, nobs(1000) ar(1.0) spin(2000)

* simulate AR(2)
sim_arma y, nobs(1000) ar(1.5 -0.5) spin(2000)
drop y

tsset t // give the dataset a time series structure according to the variable t

tsline y // show the time line

ac y	 /* Graph: show the Simple Autocorrelation Function (ACF) for different k,
			i.e. the correlation between the prices today and each of the prior periods
			e.g.  up to e.g. 40 periods ago -> there is memory, but the memory decreases
			The grey shape: The 95% confidence interval (degrees of freedom corrected*/

ac D.y	 /* The autocorrelation function for the 1st difference of the time series.
			D.y generating a temporary variable (the differences between each periode).*/
			
pac y	 /* The partial autocorrelation function of y.
			Graph: shows how many lags matters. */

pac D.y	//  The partial autocorrelation function for the 1st difference of the time series.

corrgram y		/*  Table: Computes the two functions together.
					Giving us the actual values of the coefficients.
					Q: The Box-Pierce Qtest (Ljung-Box)
					   Testing the H_0 = "no autocorrelation",
					   e.g. rho_1 = rho_2 = rho_3 = 0*/

 * MA(1) process
sim_arma yma, nobs(1000) ma(0.5) spin(2000)

ac yma

tsline yma

* ARMA(1,1)
sim_arma yarma, nobs(1000) ar(0.8) ma(0.5) spin(2000)

tsline yarma

ac yarma	//	10 coef. significant
pac yarma	//	 3 coef. significant
/* 	i.e. AC has a huge predominance over the PAC -> it looks like an AR(3) process.
	Even though the true model is an ARMA(1,1) model
*/

* ARMA(1,1)
sim_arma yarma2, nobs(1000) ar(0.8) ma(0.9) spin(2000)
tsline yarma2
ac yarma2	//	 6 coef. significant
pac yarma2	//	10 coef. significant
/* 	i.e. as both AC and PAC has a high number of coefficients,
	it looks like both an AR and MA process -> an ARMA process.
	-> Not clear cut, but pretty subjective analysis.
	-> Validate! R^2? t, F?
*/

		