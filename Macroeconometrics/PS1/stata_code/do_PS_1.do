* install sim_arma from
net from http://www.stata.com/users/jpitblado

////////////////////////////////////////////////////////////////////////////////
/////////////////////// Clear all and set up folders ////////////////////////////
////////////////////////////////////////////////////////////////////////////////
set scheme s1color
clear all
cd            	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS1\stata_code"
global figures	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS1\03_figures"
global tables	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS1\04_tables"


********************************************************************************
* Question 2.a Gaussian stochastic process                                     *
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
		name(fig2a_1, replace)

** histogram
hist eps, title("Histogram") 		///
		name(fig2a_2, replace)

** saving combined figure
graph combine fig2a_1 fig2a_2, saving("fig2a", replace)
	graph export "$figures/fig2a.png", replace

********************************************************************************
* Question 2.b: Generate AR(1) processes with three different autoregressive   *
*				coefficients φ = {0:5; 0:8; 0:95}							   *
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
		name(fig2b_1, replace)
tsline y_b, title("phi = 0.8")	///
		name(fig2b_2, replace)
tsline y_c, title("phi = 0.95")	///
		name(fig2b_3, replace)
graph combine fig2b_1 fig2b_2 fig2b_3, saving(fig2b_, replace)
	graph export $figures/fig2b_.png, replace
*/

*** Combined plot
gr two	(tsline y_a)	///
		(tsline y_b)	///
		(tsline y_c)	///
		, legend ( lab(1 "phi = 0.5") lab(2 "phi = 0.8") lab(3 "phi = 0.95") ) ///
		xtitle(time) ///
		saving(fig2b, replace)
	graph export $figures/fig2b.png, replace

*** ii. Plot the ACF and PACF for each time series
ac y_a, lags(25) title("ACF, phi = 0.5") name(ac_a, replace) nodraw
ac y_b, lags(25) title("ACF, phi = 0.8") name(ac_b, replace) nodraw
ac y_c, lags(25) title("ACF, phi = 0.95") name(ac_c, replace) nodraw

pac y_a, lags(25) title("PACF, phi = 0.5") name(pac_a, replace) nodraw
pac y_b, lags(25) title("PACF, phi = 0.8") name(pac_b, replace) nodraw
pac y_c, lags(25) title("PACF, phi = 0.95") name(pac_c, replace) nodraw

graph combine ac_a ac_b ac_c pac_a pac_b pac_c, saving(fig2b_ac, replace)
	graph export $figures/fig2b_ac.png, replace

corrgram y_c

********************************************************************************
* Question 2.c: Generate MA(1) processes with three different moving average   *
*				coefficients θ = {0:5; 0:8; 0:95}							   *
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
		name(fig2b_1, replace)
tsline y_b, title("phi = 0.8")	///
		name(fig2b_2, replace)
tsline y_c, title("phi = 0.95")	///
		name(fig2b_3, replace)
graph combine fig2b_1 fig2b_2 fig2b_3, saving(fig2b_, replace)
	graph export $figures/fig2b_.png, replace
*/

*** Combined plot
gr two	(tsline y_a)	///
		(tsline y_b)	///
		(tsline y_c)	///
		, legend ( lab(1 "phi = 0.5") lab(2 "phi = 0.8") lab(3 "phi = 0.95") ) ///
		xtitle(time) ///
		saving(fig2b, replace)
	graph export $figures/fig2b.png, replace

*** ii. Plot the ACF and PACF for each time series
ac y_a, lags(25) title("ACF, phi = 0.5") name(ac_a, replace) nodraw
ac y_b, lags(25) title("ACF, phi = 0.8") name(ac_b, replace) nodraw
ac y_c, lags(25) title("ACF, phi = 0.95") name(ac_c, replace) nodraw

pac y_a, lags(25) title("PACF, phi = 0.5") name(pac_a, replace) nodraw
pac y_b, lags(25) title("PACF, phi = 0.8") name(pac_b, replace) nodraw
pac y_c, lags(25) title("PACF, phi = 0.95") name(pac_c, replace) nodraw

graph combine ac_a ac_b ac_c pac_a pac_b pac_c, saving(fig2b_ac, replace)
	graph export $figures/fig2b_ac.png, replace

corrgram y_c


//////////////////////////////// do_ARIMA_house prices /////////////////////////

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

///////////////////////////////// do_Practice_1 ////////////////////////////////
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
* Parsimonious principle: Estimate the simpler model.
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
estat ic // Akaike's IC and Bayesian IC

* Compare the two models based on the information criterias
* Choose the one with the lower IC: e.g. -757 < -724 --> ARMA(1,1) is preferred


*********************************************
* 				Predict outcomes 			*
*********************************************
arima ln_wpi, arima(1,1,1)

* predict 'the name of the new variable' from the last model estimated

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
	Q test: the H0 that there is autocorrelation is rejected (P>0.05)
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

dfuller D.ln_wpi, lags(3) regress // lags 1-3 are significant (P<0.05).

*** Dickey-Fuller GLS-transformed ***
help dfgls
dfgls D.ln_wpi, notrend maxlag(5) ers // Optimal lags: 5.
		