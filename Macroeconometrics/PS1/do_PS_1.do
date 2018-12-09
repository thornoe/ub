clear
cd            	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS1"
global figures	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS1\03_figures"
global tables	"C:\Users\thorn\OneDrive\Dokumenter\GitHub\ub\Macroeconometrics\PS1\04_tables"









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
		