************************
*** 2. Pecking order ***
************************

* Author: Glenn Magerman, email: glenn.magerman@kuleuven.be.

* First version: April 23, 2015.
* This version: June 20, 2015.

clear*
version 13.0
capture log close
set scheme lean1
set matsize 11000

***************************
*** 0. Data preparation ***
***************************
cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Raw Data//BaciHS96"
	insheet using "baci96_2005.csv", clear
	replace v=v*1000 // to values in current $
	*** calculate margins
	bysort i j: gen extmgn = _N // extensive margin as # of product lines exported from i to j
	bysort i j: egen tot = total(v)
	bysort i j: gen intmgn = tot/extmgn // intensive margin as average value per product line aggregated at the country level
	drop tot
	drop if j ==10  // Antarctica
	drop if j ==74  // Bouvet Islands
	drop if j ==80  // Britisch Antarctic Territory
	drop if j ==86  // British Indian Ocean Territory
	drop if j ==129 // Carribean NES
	drop if j ==221 // only importing?
	drop if j ==239 // South Georgia and the South Sandwich Islands
	drop if j ==260 // French Southern Antarctic Territories
	drop if j ==290 // Northern Africa NES
	drop if j ==334 // HEard Island and McDonald Islands
	drop if j ==336 // Holy See (Vatican City)
	drop if j ==471 // Centr Am. NES
	drop if j ==473 // LAIA NES
	drop if j ==492 // EU NES
	drop if j ==527 // Oceania NES
	drop if j ==568 // Europe Other NES
	drop if j ==536 // Neutral Zone
	drop if j ==577 // Africa Other NES
	drop if j ==581 // USA minor outlying islands
	drop if j ==636 // Rest of America NES
	drop if j ==637 // Rest of North America NES
	drop if j ==697 // only importing?
	drop if j ==807 // Former republic of Yugoslavia
	drop if j ==837 // Ship bunkers
	drop if j ==838	// Free Zones
	drop if j ==839 // Special categories
	drop if j ==849 // USA minor outlying islands
	drop if j ==879 // Western Asia NES
	drop if j ==899 // Areas NES
	*** attach iso codes
	merge n:1 i using codes.dta, keepusing(iso3_o)
	drop if _merge==2
	drop _merge
	merge n:1 j using codes_j.dta, keepusing(iso_j)
	drop if _merge==2
	drop _merge
	drop i j t
	ren iso3_o i
	ren iso_j j

	replace j ="GER" if j =="DEU"
	replace j ="PAL" if j =="PSE"
	replace j ="ROM" if j =="ROU" 
	replace j ="TMP" if j =="TLS" 
	replace j ="COD" if j =="ZAR" 
	drop if j=="ANT"
	drop if j=="ASM"
	drop if j=="GUM"
	drop if j=="MNE"
	drop if j=="SMR"
	drop if j=="SRB"
	drop if j=="YUG"
	order i j hs6 v q

cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data"
save "products_2005.dta", replace

*****************************************
*** 1. Pecking order inside countries ***
*****************************************
////////////////////////////////////////////////////////////////////////////////
**********************
*** Exporter - USA ***
**********************
cd "~/Dropbox/PhD HUB-KUL/Papers/Degrees and Clustering/Clean Data"
use "products_2005.dta", clear
	* distinct j // 208 countries - OK
	keep if i=="USA" // exports to 206 of these!!	
	* distinct j

*** top 10 destinations in terms of goods
preserve
distinct hs6
duplicates drop i j, force
gsort -extmgn
list in 1/10
restore

keep if j=="KOR" | j=="GBR" | j=="JPN" | j=="AUS" | j=="CHN" | j=="FRA" | j=="ITA" | j=="CRI" | j=="COL" | j=="HKG" 
* generate hierarchy from data
bys hs6: gen mark=_N // now we see to how many countries each code is sold
keep j hs6 mark 
sort mark
preserve
duplicates drop hs6, force
hist mark, freq
restore

preserve
keep if mark==1 & j=="KOR" // 11 products only sold to KOR and none other
distinct hs6
restore

preserve
keep if mark==2
gen mark2 =1 if  j=="JPN" | j=="AUS" | j=="CHN" | j=="FRA" | j=="ITA" | j=="CRI" | j=="COL" | j=="HKG" // mark products that are also sold elsewhere
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==2
distinct hs6 // 5 products only sold to both and none other
restore

preserve
keep if mark==3
gen mark2 =1 if j=="AUS" | j=="CHN" | j=="FRA" | j=="ITA" | j=="CRI" | j=="COL" | j=="HKG" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==3
distinct hs6 // 5 new products
restore

preserve
keep if mark==4
gen mark2 =1 if j=="CHN" | j=="FRA" | j=="ITA" | j=="CRI" | j=="COL" | j=="HKG" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==4
distinct hs6 // 1 product
restore

preserve
keep if mark==5
gen mark2 =1 if j=="FRA" | j=="ITA" | j=="CRI" | j=="COL" | j=="HKG" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==5
distinct hs6 // 5 product
restore

preserve
keep if mark==6
gen mark2 =1 if j=="ITA" | j=="CRI" | j=="COL" | j=="HKG" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==6
distinct hs // 4 
restore

preserve
keep if mark==7
gen mark2 =1 if j=="CRI" | j=="COL" | j=="HKG" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==7
distinct hs6 // 7
restore

preserve
keep if mark==8
gen mark2 =1 if j=="COL" | j=="HKG" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==8
distinct hs6 // 15
restore

preserve
keep if mark==9
gen mark2 =1 if j=="HKG" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==9
distinct hs6 // 204
restore

keep if mark==10
distinct hs6  // 2032

* gen # destinations by product
bys hs6: gen destinations=_N 
gsort -destinations 

**************************
*** Exporter - Tunisia ***
**************************
cd "~/Dropbox/PhD HUB-KUL/Papers/Degrees and Clustering/Clean Data"
use "products_2005.dta", clear
	* distinct j // 208 countries - OK
	keep if i=="TUN" // exports to 157 destinations 
	distinct j

*** top 10 destinations in terms of goods
preserve
distinct hs6
duplicates drop i j, force
gsort -extmgn
list in 1/10
restore

keep if j=="FRA" | j=="ITA" | j=="LBY" | j=="DZA" | j=="BLX" | j=="ESP" | j=="GBR" | j=="MAR" | j=="GER" | j=="USA"
* generate hierarchy from data
bys hs6: gen mark=_N // now we see to how many countries each code is sold
keep j hs6 mark 
sort mark
preserve
duplicates drop hs6, force
hist mark, freq
restore
preserve
keep if mark==1 & j=="FRA" // 302 products only sold to KOR and none other
distinct hs6 // 302
restore

preserve
keep if mark==2
gen mark2 =1 if  j=="LBY" | j=="DZA" | j=="BLX" | j=="ESP" | j=="GBR" | j=="MAR" | j=="GER" | j=="USA" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==2
distinct hs6 // 141
restore

preserve
keep if mark==3
gen mark2 =1 if j=="DZA" | j=="BLX" | j=="ESP" | j=="GBR" | j=="MAR" | j=="GER" | j=="USA"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==3
distinct hs6 // 30
restore

preserve
keep if mark==4
gen mark2 =1 if j=="BLX" | j=="ESP" | j=="GBR" | j=="MAR" | j=="GER" | j=="USA" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==4
distinct hs6 // 25
restore

preserve
keep if mark==5
gen mark2 =1 if j=="ESP" | j=="GBR" | j=="MAR" | j=="GER" | j=="USA" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==5
distinct hs6 // 6
restore

preserve
keep if mark==6
gen mark2 =1 if j=="GBR" | j=="MAR" | j=="GER" | j=="USA"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==6
distinct hs // 1
restore

preserve
keep if mark==7
gen mark2 =1 if j=="MAR" | j=="GER" | j=="USA"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==7
distinct hs6 // 2
restore

preserve
keep if mark==8
gen mark2 =1 if  j=="GER" | j=="USA" 
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==8
distinct hs6 // 4
restore

preserve
keep if mark==9
gen mark2 =1 if j=="USA"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==9
distinct hs6 // 2
restore

keep if mark==10
distinct hs6 //13

***********************
*** Exporter - Mali ***
***********************
cd "~/Dropbox/PhD HUB-KUL/Papers/Degrees and Clustering/Clean Data"
use "products_2005.dta", clear
keep if i=="MLI" // exports to 157 destinations 

*** top 10 destinations in terms of goods
preserve
distinct hs6
duplicates drop i j, force
gsort -extmgn
list in 1/10
restore

keep if j=="FRA" | j=="BFA" | j=="AUS" | j=="SEN" | j=="USA" | j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
* generate hierarchy from data
bys hs6: gen mark=_N // now we see to how many countries each code is sold
keep j hs6 mark 
distinct hs6
preserve
keep if mark==1 & j=="FRA" // 302 products only sold to KOR and none other
distinct hs6  // 124
restore

preserve
keep if mark==2
gen mark2 =1 if j=="AUS" | j=="SEN" | j=="USA" | j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==2
distinct hs6 // 62
restore

preserve
keep if mark==3
gen mark2 =1 if j=="SEN" | j=="USA" | j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==3
distinct hs6 // 23
restore

preserve
keep if mark==4
gen mark2 =1 if j=="USA" | j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==4
distinct hs6 // 12
restore

preserve
keep if mark==5
gen mark2 =1 if j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==5
distinct hs6 // 5
restore

preserve
keep if mark==6
gen mark2 =1 if j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==6
distinct hs // 4
restore

preserve
keep if mark==7
gen mark2 =1 if j=="NER" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==7
distinct hs6 // 4
restore

preserve
keep if mark==8
gen mark2 =1 if  j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==8
distinct hs6 // 1
restore

preserve
keep if mark==9
gen mark2 =1 if  j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==9
distinct hs6 // 5
restore

keep if mark==10
distinct hs6 // 2 

************************
*** Exporter - Aruba ***
************************
cd "~/Dropbox/PhD HUB-KUL/Papers/Degrees and Clustering/Clean Data"
use "products_2005.dta", clear
keep if i=="ABW" 

*** top 10 destinations in terms of goods
preserve
distinct hs6
duplicates drop i j, force
gsort -extmgn
list in 1/10
restore

keep if j=="FRA" | j=="BFA" | j=="AUS" | j=="SEN" | j=="USA" | j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
* generate hierarchy from data
bys hs6: gen mark=_N // now we see to how many countries each code is sold
keep j hs6 mark 
distinct hs6
preserve
keep if mark==1 & j=="FRA" // 302 products only sold to KOR and none other
distinct hs6  // 124
restore

preserve
keep if mark==2
gen mark2 =1 if j=="AUS" | j=="SEN" | j=="USA" | j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==2
distinct hs6 // 62
restore

preserve
keep if mark==3
gen mark2 =1 if j=="SEN" | j=="USA" | j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==3
distinct hs6 // 23
restore

preserve
keep if mark==4
gen mark2 =1 if j=="USA" | j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==4
distinct hs6 // 12
restore

preserve
keep if mark==5
gen mark2 =1 if j=="CIV" | j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==5
distinct hs6 // 5
restore

preserve
keep if mark==6
gen mark2 =1 if j=="ZAF" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==6
distinct hs // 4
restore

preserve
keep if mark==7
gen mark2 =1 if j=="NER" | j=="NER" | j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==7
distinct hs6 // 4
restore

preserve
keep if mark==8
gen mark2 =1 if  j=="GER" | j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==8
distinct hs6 // 1
restore

preserve
keep if mark==9
gen mark2 =1 if  j=="GIN"
drop if mark2==1
bys hs6: gen mark3=_N
keep if mark3==9
distinct hs6 // 5
restore

keep if mark==10
distinct hs6 // 2 

*****************************************
*** 2. Pecking order across countries ***
*****************************************
////////////////////////////////////////////////////////////////////////////////
**********************
cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data"
use "Total_panel1998-2011.dta", clear
keep if t==2005
drop if lnv==.
bys j: egen tot_imports = total(v)
keep i j indeg_j extmgn gdp_j tot_imports

* Ranking 1: rank destinations by products and keep top 10
gsort i -extmgn
bys i: gen rank = _n
keep if rank<=10 // need to do this, otherwise no obs for top 10 destinations!
//!!! ranking is not unique! since ex aequo possible at rank 10 in terms of extmgn. results vary ,but all above 90%

* Ranking 2: find  top destinations (by indegree)
// correct, since want to check if ranking each country is ok with "general attractiveness"
// think of the bipartite graph
// does every country sell its most # products to the same country. 
preserve
duplicates drop j, force
gsort -indeg
list in 1/10
restore
* How many countries sell to US, GER, ...
keep if j=="USA" | j=="GER" | j=="GBR" | j=="NLD" | j=="ITA" | j=="FRA" ///
| j=="JPN" | j=="KOR" | j=="CAN" | j=="POL"

* how many countries sell to USA but not to others in top 10?
bys i: gen mark=_N // for each exporter, see to how many of top 10 it sells
preserve
keep if mark==1 & j=="USA"
sum
restore

* how many countries sell to USA and GER but not to others in top 10?
preserve
keep if mark==2
gen mark2 =1 if j=="GBR" | j=="NLD" | j=="ITA" | j=="FRA" | j=="JPN" | j=="KOR" | j=="CAN" | j=="POL"
drop if mark2==1
distinct i
restore

preserve
keep if mark==3
gen mark2 =1 if j=="NLD" | j=="ITA" | j=="FRA" | j=="JPN" | j=="KOR" | j=="CAN" | j=="POL"
drop if mark2==1
distinct i
restore

preserve
keep if mark==4
gen mark2 =1 if j=="ITA" | j=="FRA" | j=="JPN" | j=="KOR" | j=="CAN" | j=="POL"
drop if mark2==1
distinct i
restore

preserve
keep if mark==5
gen mark2 =1 if j=="FRA" | j=="JPN" | j=="KOR" | j=="CAN" | j=="POL"
drop if mark2==1
distinct i
restore

preserve
keep if mark==6
gen mark2 =1 if j=="JPN" | j=="KOR" | j=="CAN" | j=="POL"
drop if mark2==1
distinct i
restore

preserve
keep if mark==7
gen mark2 =1 if j=="KOR" | j=="CAN" | j=="POL"
drop if mark2==1
distinct i
restore

preserve
keep if mark==8
gen mark2 =1 if j=="CAN" | j=="POL"
drop if mark2==1
distinct i
restore

preserve
keep if mark==9
gen mark2 =1 if j=="POL"
drop if mark2==1
distinct i
restore

keep if mark==10

exit
end
end
