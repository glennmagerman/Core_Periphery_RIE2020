* Author: Glenn Magerman
* Version: Dec 2017

/*______________________________________________________________________________ 
This file compiles the gravity data.
______________________________________________________________________________*/

*-----------
* 0. Prelims
*-----------	
global folder "~/Dropbox/research/papers/pecking_order"
cd "$folder/data"

*--------------------------
* 1. Extract and clean data
*--------------------------
* CEPII BACI trade data (exporter, importer, value, quantities, HS6 level, 1992 version, 212 entities)
// http://www.cepii.fr/cepii/en/bdd_modele/presentation.asp?id=1
forvalues t = 1995(1)2014 {										
	insheet using "$folder/data/raw/baci92_`t'.csv", clear			
	replace v=v*1000											// rescale trade flows in current US$ 									
	fcollapse (sum) v (count) ext_mgn=hs6 (mean) int_mgn=v (first) t, by(i j) // to country level flows 
	bys i: gen d_out_i = _N
	bys j: gen d_in_j = _N
	preserve
		bys j: keep if _n==1
		keep j d_in_j
		ren (j d_in_j) (i d_in_i)
		tempfile degrees
		save "`degrees'"
	restore
	merge m:1 i using "`degrees'", nogen
	drop d_in_j
	compress													// ext_mgn: # HS6 products, int_mgn: avg value per flow
	order t i j v
save "$folder/data/tmp/trade_`t'", replace						// issue: BLX = BEL + LUX, no separate obs 
}

* GDP from World Bank WDI (current US$ 1960-2016 for 255 entities)
// https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
insheet using "$folder/data/raw/API_NY.GDP.MKTP.CD_DS2_en_csv_v2.csv", clear	
	ren countrycode iso
	reshape long y@, i(iso) j(t)
	ren y gdp
	replace iso ="BLX" if iso =="BEL" | iso =="LUX"				// Trade flows not separate for BEL and LUX, combine
	bys iso t: egen tmp = total(gdp) if iso =="BLX" 
	replace gdp = tmp if iso =="BLX" 
	drop tmp
	duplicates drop iso t, force							
	drop if gdp==.
save "$folder/data/tmp/gdp", replace		

* GDP deflator from multpl (for some measures tracked over time)
// http://www.multpl.com/gdp-deflator/table
import excel "$folder/data/raw/us_gdp_deflator.xlsx", clear firstrow
	destring us, replace force
	gen base95 = 100.17/75.86
	replace us = us*base95/100									// set 1995 base year instead of 2009
	ren year t
save "$folder/data/tmp/deflator", replace
	
* GDP per capita from World Bank WDI (current US$ 1960-2016 for 255 entities)
// https://data.worldbank.org/indicator/NY.GDP.PCAP.CD
import excel "$folder/data/raw/API_NY.GDP.PCAP.CD_DS2_en_excel_v2.xls", clear firstrow	
	ren countrycode iso
	reshape long y@, i(iso) j(t)
	ren y gdppc
	replace iso ="BLX" if iso =="BEL" | iso =="LUX"				// correct for BEL + LUX = BLX
	bys iso t: egen tmp = mean(gdppc) if iso =="BLX" 
	replace gdppc = tmp if iso =="BLX" 
	drop tmp
	duplicates drop iso t, force							
	drop if gdppc==.
save "$folder/data/tmp/gdppc", replace							
				
* CEPII geographic data	(224 entities)		
// http://www.cepii.fr/cepii/en/bdd_modele/presentation.asp?id=6								
import excel "$folder/raw/dist_cepii.xls", firstrow clear
	ren (iso_o iso_d) (iso_i iso_j)
	keep iso* contig comlang_* dist colony comcol curcol col45 
	foreach x in i j {	
		drop if iso_`x' =="LUX"									// correct for BEL + LUX = BLX
		replace iso_`x' ="BLX" if iso_`x' =="BEL" 
	}
	duplicates drop iso_i iso_j, force
save "$folder/data/tmp/dist", replace											
	
* RTA data 	(280 entities, 1950-2015)							
// http://www.ewf.uni-bayreuth.de/en/research/RTA-data/index.html
use "$folder/data/raw/rta_20170310", clear
	ren (exp imp year) (iso_i iso_j t)
	foreach x in i j {
		drop if iso_`x' =="LUX"
		replace iso_`x' ="BLX" if iso_`x' =="BEL"
	}
	duplicates drop iso_i iso_j t, force
save "$folder/data/tmp/rta", replace									// RTA = 1 if any trade agreement							
	
* WTO membership (WTO site, self constructed, 162 entities 1948-2017)	
// www.wto.org
import excel "$folder/data/raw/WTO.xlsx", firstrow clear
    keep iso wto_start
    drop if iso==""
    expand 20
	drop if iso =="LUX"											// correct for BEL + LUX = BLX
	replace iso = "BLX" if iso == "BEL" 
    sort iso
    bys iso: gen t=1994 + [_n] 
    gen wto = 1 if t>= wto_start	
    replace wto = 0 if missing(wto)
	drop if iso==""
    keep iso t wto
	save "$folder/tmp/wto", replace
	
* Country list	(247 entities)
use "$folder/data/raw/codes", clear						
	ren iso3 iso
	keep i iso
	duplicates drop iso, force									
save "$folder/data/tmp/countries", replace		

*------------------
* 2. Merge datasets	 
*------------------
* Panel 1995-2014 with gravity variables
forvalues t = 1995(1)2014 { 
    cd "$folder/data/tmp"
    use trade_`t', clear
	fmerge m:1 i using countries, nogen keep(match)         	// exporter vars			
	merge m:1 iso t using gdp, nogen keep(match master)
	merge m:1 iso t using gdppc, nogen keep(match master)
	merge m:1 iso t using wto, nogen keep(match master)
    replace wto=0 if missing(wto)
    drop i
	ren (j iso wto gdp gdppc) (i iso_i wto_i gdp_i gdppc_i)
	fmerge m:1 i using countries, nogen keep(match)         	// importer vars
	merge m:1 iso t using gdp, nogen keep(match master)
	merge m:1 iso t using gdppc, nogen keep(match master)
	merge m:1 iso t using wto, nogen keep(match master)	
    replace wto=0 if missing(wto)
    drop i
	ren (iso wto gdp gdppc) (iso_j wto_j gdp_j gdppc_j)
	merge 1:1 iso_i iso_j t using rta, nogen keep(match master)	// bilateral vars
	merge m:1 iso_i iso_j using dist, nogen keep(match master) 
	ren (iso_i iso_j) (i j)
	order t i j v gdp_i gdp_j dist
	sort t i j 
	save "$folder/data/tmp/gravity_`t'", replace
}	

*------------------
* 3. To Gephi and R
*------------------
cd "$folder/data/tmp"
foreach t in 1995 2014 { 
use "gravity_`t'", clear
	merge m:1 t using "$folder/data/tmp/deflator", keep(match) nogen
	replace v = v/us_gdp_deflator								// set trade flows in 1995 constant US$
	keep i j v
	keep if v <. | v>0
	ren (i j v) (Source Target Weight)
export delimited using WTN_`t'.csv, replace
}

// Calculate clustering coeff in R now, before final panel
forvalues t = 1995(1)2014 { 
	insheet using "$folder/data/tmp/C_out_`t'.csv", clear 
	capture ren (v1 diagb) (i c_i)
	capture ren (v1 v2) (i c_i)
	destring c_i, replace force
	drop if i==""
	gen t = `t'
	save "$folder/data/tmp/C_out_`t'", replace
}
	
*---------------
* 4. Final panel
*---------------s
cd "$folder/data/tmp/"
forvalues t = 1995(1)2014 {
	use gravity_`t', clear
	merge m:1 i t using "$folder/data/tmp/C_out_`t'", nogen
	save "$folder/data/clean/gravity_`t'", replace
}	
use "$folder/data/clean/gravity_1995", clear
	forvalues t = 1996(1)2014 {
		append using "$folder/data/clean/gravity_`t'"
	}	
	egen cp = group(i j)
	xtset cp t
    encode i, gen(exp)
    encode j, gen(imp)
    drop i j
    ren (exp imp) (i j)
save "$folder/data/clean/gravity_1995_2014", replace									

*--------------------
* Simple gravity test
*--------------------
foreach x in v dist int_mgn ext_mgn gdp_i gdp_j {
	gen ln`x'=ln(`x')
}
reg lnv lngdp_i	lngdp_j lndist rta comlang* wto* if t==2014

clear
exit
exit
