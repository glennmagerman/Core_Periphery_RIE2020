* Author: Glenn Magerman
* Version: Dec 2017

/*______________________________________________________________________________ 
This file calculates summary statistics for the introduction
______________________________________________________________________________*/

*-----------
* 0. Prelims
*-----------	
global folder "~/Dropbox/research/papers/pecking_order"
cd "$folder/data"

*------------------------------
* Export links growth 1995-2014
*------------------------------
cd "$folder/data/clean/"
use gravity_1995_2014, clear
	keep if t==1995 | t==2014
    preserve                                                // keep only countries that exist in both 1995 and 2014
        bys i t: keep if _n==1
        bys i: keep if _N==2
        keep i t
        tempfile subsample
        save "`subsample'"
    restore
    merge m:1 i t using "`subsample'", nogen keep(match)
    ren (i j) (I i)
    merge m:1 i t using "`subsample'", nogen keep(match)
    ren (I i) (i j)



*-------------------------------
* Export values growth 1995-2014 
*-------------------------------
// direct 1995-2014 difference
cd "$folder/data/clean/"
use gravity_1995_2014, clear
	keep if t==1995 | t==2014
    merge m:1 t using "$folder/data/tmp/deflator", nogen keep(match) // deflate at 1995 US$
	replace v = v/us_gdp_deflator	
    
    fcollapse (sum) X=v, by(i t) merge
    bys i t: keep if _n==1
    keep i t X
    xtset i t, delta(19)

    sort i t
    gen pct = 100*(X - L.X)/L.X
    tab i if pct <0                                             // 23 countries decline!
    sum pct, d
    gsort -pct
    list in 1/10

// average 1995-2004, 2005-2014 difference
cd "$folder/data/clean/"
use gravity_1995_2014, clear
    merge m:1 t using "$folder/data/tmp/deflator", nogen keep(match) // deflate at 1995 US$
	replace v = v/us_gdp_deflator	
    collapse (sum) X=v, by(i t) 
    gen T = 1 if t>=1995 & t<=2004
    replace T=2 if T==.
    collapse (mean) X, by(i T)

    xtset i T, delta(1)
    sort i T
    gen pct = 100*(X - L.X)/L.X
    tab i if pct <0                                             // 23 countries decline!
    sum pct, d
    gsort -pct
    list in 1/10    

  
*--------------------------------
* Exports and GDP (growth) top 10
*--------------------------------
cd "$folder/data/clean/"
use gravity_1995_2014, clear
	keep if t==1995 | t==2014
	merge m:1 t using "$folder/data/tmp/deflator", nogen keep(match)
	replace v = v/us_gdp_deflator							// trade and GDP in 1995 constant US$
	replace gdp_i=gdp_i/us_gdp_deflator
	collapse (sum) X=v (first) gdp_i, by(i t)				// Levels 1995 and 2014
	sum X if t==1995
	sum X if t==2014
	
	preserve 
		keep if t==1995
		gsort -X
		list i X in 1/10
		gsort -gdp_i
		list i gdp_i in 1/10
	restore	
	gen gdp_growth = (gdp_i[_n]-gdp_i[_n-1])/gdp_i[_n-1]	// growth rates
	gen X_growth = (X[_n]-X[_n-1])/X[_n-1] 
	keep if t==2014
	gsort -X
	list i X X_growth in 1/10
	gsort -gdp_i
	list i gdp_i gdp_growth in 1/10
	

	
	
*---------------------------------------	
* Distribution of degrees and clustering	
*---------------------------------------
cd "$folder/data/clean/"
use gravity_1995_2014, clear
	bys i t: keep if _n==1	
	keep i t *_i
	keep if t==1995 | t==2014
	
// tables
	sum d_out d_in c_i if t==1995, d
	sum d_out d_in c_i if t==2014, d
	foreach x in d_out d_in c_i {
		gen dln_`x' = ln(`x'[_n]) - ln(`x'[_n-1])
	}	
	sum dln*, d
	
// graphs	
	kdensity d_out if t==2014, plot(kdensity d_out if t==1995) ///
		title("") note("") xtitle(Number of export destinations) ///
		legend(label(1 2014) label(2 1995) position(6))
	graph export "$folder/graphs/outdeg_1995_2014.eps", replace
		
	kdensity d_in if t==2014, plot(kdensity d_in if t==1995) ///
		title("") note("") xtitle(Number of import countries) ///
		legend(label(1 2014) label(2 1995) position(6))	
	graph export "$folder/graphs/indeg_1995_2014.eps", replace	

	kdensity c_i if t==2014, plot(kdensity c_i if t==1995) ///
		title("") note("") xtitle(Clustering coefficient) ///
		legend(label(1 2014) label(2 1995) position(6))	
	graph export "$folder/graphs/clus_1995_2014.eps", replace	

	kdensity dln_d_out, ///
		title("") note("") xtitle(Change in export destinations) ///
		xlabel(0 "10{super:0}" 2.3 "10{super:1}" -2.3 "10{super:-1}")
	graph export "$folder/graphs/dln_out_1995_2014.eps", replace	
		
	kdensity dln_d_in, ///
		title("") note("") xtitle(Change in import countries) ///
		xlabel(0 "10{super:0}" 2.3 "10{super:1}" -2.3 "10{super:-1}")
	graph export "$folder/graphs/dln_in_1995_2014.eps", replace	
	
	kdensity dln_c_i, ///
		title("") note("") xtitle(Change in clustering coefficient) ///
		xlabel(0 "10{super:0}" 2.3 "10{super:1}" -2.3 "10{super:-1}")
	graph export "$folder/graphs/dln_clus_1995_2014.eps", replace	
	
*---------------------------------------	
* Correlation with other characteristics	
*---------------------------------------
	
	
clear
exit
exit
