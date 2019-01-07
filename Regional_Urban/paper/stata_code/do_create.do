////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Global set up /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

*** RUN THE FOLLOWING FIRST (SAME GLOBALS AS WHEN RUNNING THROUGH MAIN-FILE) ***

/*

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

*/


////////////////////////////////////////////////////////////////////////////////
///////////////////////////// Load and append data /////////////////////////////
////////////////////////////////////////////////////////////////////////////////
foreach y of numlist 2003/2016 {
	use "$pitec/AÑO `y'/STATA/PITEC_`y'", clear
	tempfile PITEC_`y'_temp
	gen year = `y'
	keep ident year $x pidejc*
	save "'PITEC_`y'_temp'", replace
}

use "'PITEC_2003_temp'", clear
foreach y of numlist 2004/2016 {
	append using "'PITEC_`y'_temp'"
}

xtset ident year, yearly // unbalanced

/*
xtdescribe
*/

drop if year==2003 | year==2004

/*
xtdescribe, patterns(11)
*/


*** string variables --> integer variables ***
destring acti* clase grupo tam200 bio idin idex idintern pidtejc sede, replace


********************************************************************************
**** Time-varying variables													****
********************************************************************************

*** log total no. employees ***
gen lnemp = log(tamano)


*** squareroot of total no. employees ***
gen empsq = tamano^2


*** External research only ***
gen exter = idex==1 & idin==0
/*
su idin idintern idex exter
*/


*** R&D personnel as share of total personnel ***
gen pidp = 100 * pidt / tamano		// R&D personnel (share of total personnel)
gen invp = (invtejc/pidtejc) * pidp	// R&D researchers (share of total personnel)
gen tecp = (tectejc/pidtejc) * pidp	// R&D technicians(share of total personnel)
gen auxp = (auxtejc/pidtejc) * pidp	// R&D clerks (share of total personnel)

foreach z in pidp invp tecp auxp {
	replace `z' = . if pidp > 100
}
/*
su pidtejc pidp invp tecp auxp if idin==1, detail
*/


*** R&D expenses as share of total revenue ***
gen gtinnp 	= 100 * gtinn / cifra	// R&D expenses (share of total revenue)
gen gintidp = gintid * gtinnp/100	// Internal R&D expenses (share of total revenue)
gen gextidp = gextid * gtinnp/100	// External R&D expenses (share of total revenue)
gen recip 	= reci  * gintidp/100	// Payments to R&D researchers (share of total revenue)
gen reotp 	= reot  * gintidp/100	// Payments to R&D technicians & clerks (share of total revenue)

foreach z in gtinnp gintidp gextidp recip reotp {
	replace `z' = . if gtinnp > 200
}
/*
su pidp gtinnp gintidp gextidp recip reotp if idin==1, detail
count if gintidp > 100 & gintidp < .
*/


*** ln share R&D expenses of total revenue ***
gen lngintidp = log(1+gintidp)
gen lngextidp = log(1+gextidp)


*** Missing information per year ***
/*
gen missing_year = tamano == . 
grmeanby year, summarize(missing_year) connect(i)
	graph export $figures/missing_year.png, replace
ta year missing_year, row
*/


********************************************************************************
**** Time-invariant variables												****
********************************************************************************
reshape wide $x pidejc* lnemp empsq exter pidp invp tecp auxp gtinnp gintidp ///
	gextidp lngintidp lngextidp recip reotp, i(ident) j(year)


*** Checking the occourence of missing info for each year ***
/*
foreach y of numlist 2005/2008 {
count if acti`y'=="" 
count if tamano`y'== .
}
foreach y of numlist 2009/2016 {
count if actin`y'==""
count if tamano`y'== .
}
*/


*** Industry dummies ***
/*
ta acti2005
*/

gen ind = inrange(acti2005,2,3) // 2 <= acti2005 <= 4
	replace ind =  2 if inrange(acti2005,  4,  9)
	replace ind =  3 if inrange(acti2005, 10, 15)
	replace ind =  4 if inrange(acti2005, 16, 18)
	replace ind =  5 if inrange(acti2005, 19, 28)
	replace ind =  6 if inrange(acti2005, 29, 31)
	replace ind =  7 if inrange(acti2005, 32, 33)
	replace ind =  8 if inrange(acti2005, 34, 34)
	replace ind =  9 if inrange(acti2005, 35, 38)
	replace ind = 10 if inrange(acti2005, 39, 42)
	replace ind = 11 if inrange(acti2005, 43, 45)
	replace ind = 12 if inrange(acti2005, 46, 47)
	replace ind = 13 if inrange(acti2005, 48, 51)
	replace ind = 14 if inrange(acti2005, 52, 55)

label define ind_lab ///
	0  "Agriculture \& resource extraction" ///
	1  "Foods, beverages & tobacco" ///
	2  "Textiles, footwear, lumber, cardboard, paper \& graphic arts" ///
	3  "Chemicals, pharmaceuticals, plastics, ceramics \& petrol" ///
	4  "Metallurgy \& metal manufacturing" ///
	5  "Electronics \& machinery" ///
	6  "Furniture, games, toys \& other manufacturing" ///
	7  "Recycling, energy, water \& sanitation" ///
	8  "Construction" ///
	9  "Trade \& hospitality" ///
	10 "Transport, travel, post \& tele services" ///
	11 "Finance, real estate \& leasing" ///
	12 "IT \& communications" ///
	13 "Research \& other business services" ///
	14 "Education, radio, TV, health \& social services" ///
	, replace
label values ind ind_lab


*** Sectoral dummies ***
gen manufact = inrange(ind,1,6)
gen services = ind >= 9


*** Missing information by industry and size ***
/*
gen missing_industry = tamano2005 == .
foreach y of numlist 2006/2016 {
	replace missing_industry = 1 if tamano`y' == .
}
grmeanby ind, summarize(missing_industry) connect(i)
	graph export $figures/missing_ind.png, replace
ta ind missing_industry, row

bysort missing_industry: su tamano2005, detail
*/


*** type of business ***
label define clase_lab 1 "Public" 2 "Domest. priv." 3 "MNE, priv." 4 "Research", replace

foreach y of numlist 2005/2016 {
	replace clase`y' = clase2007 if clase`y'==.
	label values clase`y' clase_lab
}

foreach y of numlist 2005/2007 {
	
}


*** location of head office ***
label define sede_lab 0 "Rest of Spain" 1 "Madrid" 2 "Cataluña" 3 "Andalucía"

foreach y of numlist 2005/2016 {
	replace sede`y' = sede2008 if sede`y'==.
	replace sede`y' = 0 if sede`y'==4
	label values sede`y' sede_lab
}


*** Frequency of research ***
label define continuity_lab 0 "Never" 1 "Occasional" 2 "Frequent" 3 "Permanent"

foreach x in idin infun inapl destec exter {
	gen `x'_freq = `x'2005 > 0
	foreach y of numlist 2006/2016 {
		replace `x'_freq = `x'_freq + 1 if `x'`y' > 0
	}
	gen `x'_cont = inrange(`x'_freq,1,6)
		replace	`x'_cont = 2 if inrange(`x'_freq,7,11)
		replace	`x'_cont = 3 if `x'_freq == 12
	label values `x'_cont continuity_lab
}
label variable idin_cont "Cont. of internal R\&D"
label variable infun_cont "Cont. of basic research"
label variable inapl_cont "Cont. of applied research"
label variable destec_cont "Cont. of tehcnological development"
label variable exter_cont "Cont. of external R\&D only"
/*
tab1 inter_freq infun_freq inapl_freq destec_freq exter_freq
tab1 inter_cont infun_cont inapl_cont destec_cont exter_cont
*/


********************************************************************************
**** Leads of sales of new products 										****
********************************************************************************

*** One lead ***
gen new_one2005 = newemp2006
gen new_one2006 = newemp2007
gen new_one2007 = newemp2008
gen new_one2008 = newemp2009
gen new_one2009 = newemp2010
gen new_one2010 = newemp2011
gen new_one2011 = newemp2012
gen new_one2012 = newemp2013
gen new_one2013 = newemp2014
gen new_one2014 = newemp2015
gen new_one2015 = newemp2016
gen new_one2016 = .

*** Two leads ***
gen new_two2005 = newemp2007
gen new_two2006 = newemp2008
gen new_two2007 = newemp2009
gen new_two2008 = newemp2010
gen new_two2009 = newemp2011
gen new_two2010 = newemp2012
gen new_two2011 = newemp2013
gen new_two2012 = newemp2014
gen new_two2013 = newemp2015
gen new_two2014 = newemp2016
gen new_two2015 = .
gen new_two2016 = .

*** Three leads ***
gen new_three2005 = newemp2008
gen new_three2006 = newemp2009
gen new_three2007 = newemp2010
gen new_three2008 = newemp2011
gen new_three2009 = newemp2012
gen new_three2010 = newemp2013
gen new_three2011 = newemp2014
gen new_three2012 = newemp2015
gen new_three2013 = newemp2016
gen new_three2014 = .
gen new_three2015 = .
gen new_three2016 = .


********************************************************************************
**** Regional variables														****
********************************************************************************
foreach t of numlist 2005/2016 {
	gen region`t' = 1 if pidejc1`t' > 75
	foreach j of numlist 2/19 {
		replace region`t' = `j' if pidejc`j'`t' > 75
	}
}

drop pidejc* 

*** Overwrite missing ***
foreach t of numlist 2005/2016 {
	foreach ti of numlist 2005/2016 {
		replace region`ti' = region`t' if region`ti'==. & region`t'!=.
	}
}

/*
foreach t of numlist 2005/2016 {
	count if inrange(region`t',1,19)
}
ta region2005
*/


*** Drop Maroccan province and missing ***
foreach t of numlist 2005/2016 {
	drop if region`t' == 18
	drop if region`t' == .
}


*** Label regions ***
label define reg_lab ///
	1 "Andalucía" ///
	2 "Aragón" ///
	3 "Asturias (Principado de)" ///
	4 "Balears (Illes)" ///
	5 "Canarias" ///
	6 "Cantabria" ///
	7 "Castilla y León" ///
	8 "Castilla-La Mancha" ///
	9 "Cataluña" ///
	10 "Comunidad Valenciana" ///
	11 "Extremadura" ///
	12 "Galicia" ///
	13 "Madrid (Comunidad de)" ///
	14 "Murcia (Región de)" ///
	15 "Navarra (Com. Foral de)" ///
	16 "País Vasco" ///
	17 "Rioja (La)" ///
	18 "Ceuta" ///
	19 "Melilla" ///
	, replace
label values region* reg_lab


*** Collapse and sum ***
pause on
preserve
tempfile PITEC_region_temp
collapse (sum) gtinn* cifra*, by(region2010)
drop gtinnp*
foreach z in gtinn cifra {
	foreach t of numlist 2005/2016 {
		rename `z'`t' `z'r`t'
	}
}
save "'PITEC_region_temp'", replace
restore

merge m:1 region2010 using "'PITEC_region_temp'"
drop _merge


*** Regional R&D expenses as share of total revenue ***
foreach t of numlist 2005/2016 {
	gen gtinnpr`t' = 100 * (gtinnr`t'-gtinn`t') / (cifrar`t'-cifra`t')
}
drop gtinnr* cifrar*

********************************************************************************
**** Drop firms if missing information for one or more year												****
********************************************************************************
foreach y of numlist 2005/2016 {
	drop if tamano`y' == .
}
// 200-500 observations droped per year, but 2,000 for 2014 & 700 for 2016

/*
ta ind
count if manufact == 0 & services == 0
count if manufact == 1 | services == 1
count if manufact == 1
count if services == 1
*/


********************************************************************************
**** Reshape back to long form												****
********************************************************************************
reshape long $x lnemp empsq exter pidp invp tecp auxp gtinnp gintidp gextidp ///
	lngintidp lngextidp recip reotp new_one new_two new_three region gtinnpr ///
	, i(ident) j(year)

sort ident year

rename newemp new_0
rename new_one new_1
rename new_two new_2
rename new_three new_3


********************************************************************************
**** Prices indices and real sales											****
********************************************************************************
// A possible alternative to the no. employees as a proxy for firm size.

/*

tempfile PITEC_short_temp
save "'PITEC_short_temp'", replace

foreach i in inpp sepp {
	clear 
	import delimited "$prices/sts_`i'_a_1_Data"
	rename value `i'
	rename time year
	keep year `i'
	tempfile `i'_temp
	save "'`i'_temp'", replace
}

use "'PITEC_short_temp'", clear
foreach i in inpp sepp {
	merge m:1 year using "'`i'_temp'"
	drop _merge
}

gen real_t = cifra * (100/inpp) if service==0
replace real_t = cifra * (100/sepp) if service==1

gen lreal_new = log( 1 + (newemp/100) * real_t )
gen lreal_old = log( 1 + (1-newemp/100) * real_t )

*/

////////////////////////////////////////////////////////////////////////////////
/////////////////////////// Delete 'temporary' files ///////////////////////////
////////////////////////////////////////////////////////////////////////////////
foreach y of numlist 2003/2016 {
	erase "'PITEC_`y'_temp'.dta"
}
erase "'PITEC_region_temp'.dta"
