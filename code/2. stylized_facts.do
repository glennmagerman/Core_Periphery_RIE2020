
********************************
*** 1. Stylized facts - 2008 ***
********************************

* Author: Glenn Magerman, email: glenn.magerman@kuleuven.be.

* First version: March 15, 2015.
* This version: April 24, 2016.

clear*
version 13.0
capture log close
set scheme lean1, perm
set matsize 11000

// make nice locals for folders
// set robustness regressions etc in Appendix

**************************************
*** 0. Descriptive statistics 2005 ***
**************************************
use "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data/Total_panel1998-2011.dta", clear
keep if t == 2005
sum v extm intm rta
preserve
bys i: keep if _n==1
sum gdp_i wto_i outdeg_i dir_clus_i
restore 
bys j: keep if _n==1
sum indeg_j

********************************
*** Fact 1 - GDP and degrees ***
********************************

*** Fact 1a - Larger countries export to more destinations ***
**************************************************************	
use "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data/Total_panel1998-2011.dta", clear
keep if t == 2005
	qui tab j, gen(imp_)
	bys i: egen mediandist = median(dist)
	gen lnmediandist = ln(mediandist)
	duplicates drop i, force
	drop if lngdp_i==.
	
*** 1. Regressions
	eststo clear
	eststo: reg outdeg_i lngdp_i, robust // euro
	eststo: reg outdeg_i lngdppc_i, robust  // euro
	eststo: reg outdeg_i lngdp_i lnmediandist, robust 
	eststo: reg outdeg_i lngdppc_i lnmediandist, robust

*** 2. Graph
	replace gdp_i = gdp_i/1000000000 // GDP in billions
	drop lngdp_i 
	gen lngdp_i = ln(gdp_i) 
	reg outdeg_i lngdp_i, robust 
	local r2: display %5.4f e(r2) 
	local b: di %5.2f _b[lngdp_i]
	graph twoway (scatter outdeg_i lngdp_i)  ///
	(lfit outdeg_i lngdp_i), ylabel(0(50)200) ///
	xtitle("GDP exporter (US $, billions)") ytitle("number of destinations") ///
	xlabel( -2.3 ".1" 0 "1" 2.3 "10" 4.6 "100" 6.9 "1,000" 9.2 "10,000") ///
	legend(off) note("Linear slope: `b' (0.64)" "R-squared: `r2'", ring(0) pos(11) box) 
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Graphs"
	graph export outdeg_gdp_i.eps, replace
	
*** Fact 1b - Larger countries import from more countries ***
*************************************************************
use "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data/Total_panel1998-2011.dta", clear
keep if t == 2005
	qui tab i, gen(exp_)
	bys j: egen mediandist =median(dist)
	gen lnmediandist = ln(mediandist)
	duplicates drop j, force
	drop if lngdp_j==.

*** 1. Regressions
	eststo: reg indeg_j lngdp_j, robust
	eststo: reg indeg_j lngdppc_j, robust  
	eststo: reg indeg_j lngdp_j lnmediandist, robust
	eststo: reg indeg_j lngdppc_j lnmediandist, robust 
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Tables"
	esttab using "fact1.csv", r2 se obslast nogaps replace r2(4) se(2) b(2)

*** 2. Graph
	replace gdp_j = gdp_j/1000000000 // GDP in billions
	drop lngdp_j
	gen lngdp_j = ln(gdp_j) 
	reg indeg_j lngdp_j, robust
	local r2: display %5.4f e(r2) 
	local b: di %5.2f _b[lngdp_j]
	graph twoway (scatter indeg_j lngdp_j) ///
	(lfit indeg_j lngdp_j), ylabel(0(50)200) ///
	xlabel( -2.3 ".1" 0 "1" 2.3 "10" 4.6 "100" 6.9 "1,000" 9.2 "10,000") ///
	xtitle("GDP importer (US $, billions)") ytitle("number of sources") ///
	legend(off) note("Linear slope: `b' (0.59)" "R-squared: `r2'", ring(0) pos(11) box) 
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Graphs"
	graph export indeg_gdp_j.eps, replace

*********************************************
*** Fact 2 - Clustering and assortativity ***
********************************************* 
use "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data/Total_panel1998-2011.dta", clear
keep if t == 2005
	qui tab j, gen(imp_)
	duplicates drop i, force
*** 1. Correlations GDP, outdeg and clustering
	eststo clear
	eststo: reg dir_clus_i outdeg_i, robust 
	eststo: reg dir_clus_i lngdp_i, robust  // = -0.04
	eststo: reg dir_clus_i outdeg_i lngdp_i, robust  // = 0 -> the competition structure between me and my trading partners has no impact on my trading partners!
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Tables"
	esttab using "fact2.csv", nogaps obslast se r2(4) replace b(3)

*** 2. graph degrees vs clustering	
	reg dir_clus_i outdeg_i 
	local r2: display %5.4f e(r2) 
	local b: di %5.3f _b[outdeg_i]
	graph twoway (scatter dir_clus_i outdeg_i), ///
	xtitle("number of destinations") ytitle("clustering coefficient") ///
	legend(off) note("Linear slope: `b' (0.000)" "R-squared: `r2'", ring(0) pos(7) box)
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Graphs"
	graph export clust_degrees.eps, replace

********************************************
*** Fact 3 - Product variety and degrees ***
********************************************
cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data"
use "Total_panel1998-2011.dta", clear
	keep if t ==2005
	replace extmgn=. if extmgn==0

*** 1. Exported products ***
****************************
*** ext margin distribution for all flows
	hist extmgn,  frac ///
	xtitle("number of products (HS6) per export flow") ytitle("% of export flows")
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Graphs"
	graph export "dist_products_flows.eps", replace
	sum extmgn, d
	list if extmgn==4731
*** ext margin distribution by exporter (max, 75, 50, 25 th percentiles)
	preserve
	keep if i=="USA"
	hist extmgn,  frac xtitle("number of products (HS6) per export flow, USA") ytitle("% of exports")
	graph export "dist_variety_usa.eps", replace
	restore

	preserve
	keep if i=="TUN"
	hist extmgn,  frac xtitle("number of products (HS6) per export flow, Tunisia") ytitle("% of exports")
	graph export "dist_variety_tun.eps", replace
	restore

	preserve
	keep if i=="MLI"
	hist extmgn,  frac xtitle("number of products (HS6) per export flow, Mali") ytitle("% of exports")
	graph export "dist_variety_mli.eps", replace
	restore

	preserve
	keep if i=="ABW"
	hist extmgn,  frac xtitle("number of products (HS6) per export flow, Aruba") ytitle("% of exports")
	graph export "dist_variety_abw.eps", replace
	restore

*** correlation outdeg and variety
cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data"
use "Total_panel1998-2011.dta", clear
	keep if t ==2005
	replace extmgn=. if extmgn==0

*** a) mean variety
	bys i: egen meanvar = mean(extmgn)
	gen lnmeanvar = ln(meanvar)
	duplicates drop i, force
	reg lnmeanvar outdeg_i 
	local r2: display %5.4f e(r2)
	local b: di %5.2f _b[outdeg_i]
	graph twoway (scatter lnmeanvar outdeg_i) ///
	(lfit lnmeanvar  outdeg_i, lcolor(gs0)), ///
	ytitle("mean number of products per export flow") xtitle("number of destinations") ///
	ylabel(0 "1" 2.3 "10" 4.6 "100" 6.9 "1,000") ///
	legend(off) note("Linear slope: `b' (0.000)" "R-squared: `r2'",ring(0) pos(11) size(small) box)
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Graphs"
	graph export "outdeg-extmgn2005.eps", replace

*** b) median variety
	bys i: egen medianvar = median(extmgn)
	gen lnmedianvar = ln(medianvar)
	reg lnmedianvar outdeg_i 
	local r2: display %5.4f e(r2)
	local b: di %5.2f _b[outdeg_i]
	graph twoway (scatter lnmedianvar outdeg_i) ///
	(lfit lnmedianvar  outdeg_i, lcolor(gs0)), ///
	ytitle("median number of products per export flow") xtitle("number of destinations") ///
	ylabel(0 "1" 2.3 "10" 4.6 "100" 6.9 "1,000") ///
	legend(off) note("Linear slope: `b' (0.000)" "R-squared: `r2'", ring(0) pos(11) size(small) box)
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Graphs"
	graph export "outdeg-extmgn_median2005.eps", replace

*** c) robustness regressions	
cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data"
use "Total_panel1998-2011.dta", clear
	keep if t ==2005
	replace extmgn=. if extmgn==0
	bys i: egen meanvar = mean(extmgn)
	gen lnmeanvar = ln(meanvar)
	bys i: egen medianvar = median(extmgn)
	gen lnmedianvar = ln(medianvar)
	qui tab j, gen(imp_)
	eststo clear	
	eststo: reg lnextmgn outdeg_i lndist imp_*, robust // bilateral version
	eststo: reg lnextmgn lngdp_i lndist imp_*, robust
	eststo: reg lnextmgn outdeg_i lngdp_i lndist imp_*, robust 
	duplicates drop i, force
	eststo: reg lnmedianvar outdeg_i, robust // exporter version
	eststo: reg lnmeanvar outdeg_i, robust 
	eststo: reg lnmeanvar lngdp_i, robust
	eststo: reg lnmeanvar outdeg_i lngdp_i, robust 
	esttab using "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Tables/fact3.csv", replace nogaps obslast drop(imp_*) r2(4) se(3) b(3)

*** correlation outdegree and variety - total
egen totvar=mean(extmgn), by(i)
gen lntotvar = ln(totvar)
reg lntotvar outdeg_i 
	local r2: display %5.4f e(r2)
	local b: di %5.2f _b[outdeg_i]
graph twoway (scatter lntotvar outdeg_i , msize(vsmall) mcolor(gs1)) ///
	(lfit lntotvar outdeg_i, lcolor(gs0)), ///
	ytitle("avg. number of products exported") xtitle("number of destinations") ///
	ylabel(0 "1" 2.3 "10" 4.6 "100" 6.9 "1,000") ///
	legend(off) note("Linear slope: `b' (0.000)" "R-squared: `r2'", ///
	ring(0) pos(11) size(small) box bcolor(white) blcolor(black))
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Output/Graphs"
	graph export "outdeg-extmgn2005_total.eps", replace

*** 2. Imported varieties ***
*****************************

*** bilateral variety imported
cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data"
use "Total_panel1998-2011.dta", clear
keep if t ==2005
replace extmgn=. if extmgn==0
reg lnextmgn indeg_j, robust cluster(j)
reg lnextmgn indeg_j lngdp_j, robust cluster(j)

*** total variety imported
cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data"
use "Total_panel1998-2011.dta", clear
keep if t ==2005
replace extmgn=. if extmgn==0
bys j: egen imported_variety = total(extmgn)

hist imported, frac
gen lnimp = ln(imported_variety)
reg lnimp indeg_j, robust cluster(j)
reg lnimp indeg_j lngdp_j, robust cluster(j)


clear
exit 
exit
