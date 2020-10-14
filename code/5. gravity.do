* Author: Glenn Magerman. email: glenn.magerman@kuleuven.be
* First version: October 1, 2014.
* This version: April 20, 2016.

******************
*** 0. Prelims ***
******************
cd "~/Dropbox/Research/Papers/pecking_order/Clean Data/"
use "Total_panel1998-2011.dta", clear
	keep i j t v lndist extmgn intmgn gdp_i gdp_j wto_i wto_j rta outdeg_i ///
	indeg_j dir_clus_i dir_clus_j cp contig lang_off colony
* keep 10-year difference
	keep if t==1998 | t==2008
	replace t=1 if t==1998
	replace t=2 if t==2008
	keep if v>0 & v<. 
	xtset cp t	
* gen differences for estimation	
	foreach x in v extmgn intmgn gdp_i gdp_j outdeg_i indeg_j dir_clus_i dir_clus_j {
		gen ln`x'=ln(`x')
		gen d_ln`x'= D.ln`x'
	}
	foreach x in wto_i wto_j rta {
		gen d_`x'=D.`x'
	}	
* gen instruments
	preserve
		bys i t: keep if _n==1
		bys t: egen step1 = total(outdeg_i)
		replace step1 = step1 - outdeg_i
		gen iv_d_i = step1/207
		gen iv_lnd_i = ln(iv_d_i)
		bys i: gen d_iv_lnd_i = iv_lnd_i[_n] - iv_lnd_i[_n-1]
		bys t: egen step2 = total(dir_clus_i)
		replace step2 = step2 - dir_clus_i
		gen iv_c_i = step2/207
		gen iv_lnc_i = ln(iv_c_i)
		bys i: gen d_iv_lnc_i = iv_lnc_i[_n] - iv_lnc_i[_n-1]
		keep i t d_iv* iv*
		save temp_iv1, replace
	restore
	preserve
		bys j t: keep if _n==1
		bys t: egen step4 = total(indeg_j)
		replace step4 = step4 - indeg_j
		gen iv_d_j = step4/207
		gen iv_lnd_j = ln(iv_d_j)
		bys i: gen d_iv_lnd_j = iv_lnd_j[_n] - iv_lnd_j[_n-1]
		keep j t d_iv* iv*
		save temp_iv2, replace
	restore
	merge n:1 i t using temp_iv1, nogen
	merge n:1 j t using temp_iv2, nogen 
	keep if t==2
// many obs drop out, since not trading in 1998

***********************************
*** 1. Total trade - OLS and IV ***
***********************************
*** 1. OLS
	eststo clear 
	eststo: reg d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnoutdeg_i, robust cluster(cp)
	eststo: reg d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnindeg_j, robust cluster(cp)
	eststo: reg d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lndir_clus_i, robust cluster(cp)
	cd "~/Dropbox/Research/Papers/pecking_order/Stata/Output"
	esttab using "ols_diff.csv", r2(4) se(3) obslast nogaps replace b(3) 

*** 2. IV	
	eststo clear
	eststo: ivreg2 d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lnoutdeg_i = d_iv_lnd_i), first savesfirst robust cluster(cp)
	eststo: ivreg2 d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lnindeg_j = d_iv_lnd_j), first savesfirst	robust cluster(cp)
	eststo: ivreg2 d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lndir_clus_i = d_iv_lnc_i), first savesfirst robust cluster(cp)
	cd "~/Dropbox/Research/Papers/pecking_order/Stata/Output"
	esttab using "iv_diff.csv", r2(4) se(3) obslast nogaps replace b(3) 
		
*******************************		
*** 2. Margins - OLS and IV ***
*******************************	
*** 1. OLS	
	eststo clear
	eststo: reg d_lnext d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnoutdeg_i, robust cluster(cp)
	eststo: reg d_lnext d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnindeg_j, robust cluster(cp) 
	eststo: reg d_lnext d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lndir_clus_i,  robust cluster(cp)
	eststo: reg d_lnint d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnoutdeg_i, robust cluster(cp)
	eststo: reg d_lnint d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnindeg_j, robust cluster(cp) 
	eststo: reg d_lnint d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lndir_clus_i,  robust cluster(cp)
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Stata/Output"
	esttab using "ols_margins_diff.csv", r2(4) se(3) obslast nogaps replace b(3)

*** 2. IV
	eststo clear
	eststo: ivreg2 d_lnext d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lnoutdeg_i = d_iv_lnd_i), first savesfirst robust cluster(cp)
	eststo: ivreg2 d_lnext d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lnindeg_j = d_iv_lnd_j), first savesfirst	robust cluster(cp) 
	eststo: ivreg2 d_lnext d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lndir_clus_i = d_iv_lnc_i), first savesfirst robust cluster(cp)
	eststo: ivreg2 d_lnint d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lnoutdeg_i = d_iv_lnd_i), first savesfirst robust cluster(cp)
	eststo: ivreg2 d_lnint d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lnindeg_j = d_iv_lnd_j), first savesfirst	robust cluster(cp) 
	eststo: ivreg2 d_lnint d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lndir_clus_i = d_iv_lnc_i), first savesfirst robust cluster(cp)
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Stata/Output"
	esttab using "iv_margins_diff.csv", r2(4) se(3) obslast nogaps replace b(3)
	
	

************************************************************
*** 1. Multicollinearity of netstats with baseregression ***
************************************************************
// use pooled model to get VIF. The logic is that since multicollinearity is only about independent variable there is no need to control for individual effects using panel methods.
reg d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnoutdeg_i, robust cluster(cp)
vif
reg d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnindeg_j, robust cluster(cp)
vif
reg d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lndir_clus_i, robust cluster(cp)
vif
// VIF increases to 4 for netstats, but still ok.

***********************************************
*** 2. Automatic variable selection - LASSO ***
***********************************************

* Lasso
lars d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnoutdeg_i d_lnindeg_j d_lndir_clus_i, a(lasso) g

* Least angle regression
lars d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta d_lnoutdeg_i d_lnindeg_j d_lndir_clus_i
// both give same outcome
	
	
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


* IV estimations in levels, not D
eststo clear
eststo: ivreg2 lnv lngdp_i lngdp_j lndist contig lang_off colony rta wto_i wto_j rta (lnoutdeg_i = iv_lnd_i), first savesfirst
eststo: ivreg2 lnv lngdp_i lngdp_j lndist contig lang_off colony rta wto_i wto_j rta (lnindeg_j = iv_lnd_j), first savesfirst	
eststo: ivreg2 lnv lngdp_i lngdp_j lndist contig lang_off colony rta wto_i wto_j rta (lndir_clus_i = iv_lnc_i), first savesfirst
cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Stata/Output"
esttab using "iv_regs2.csv", r2(4) se(3) obslast nogaps replace b(3) 

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

*********************
*** IV Approach 2 ***
*********************
// Use indegree as IV for outdegree
// indeg and outdeg are correlated, but indeg_i should not affect x_ij
// at least in this model where only final goods are sold. Things change when we 
// allow for global value chains, but then the theoretical model is also misspecified
// Holds for both degrees (outward pointing, while we only look at i and j)
// What is good instrument for exporter out-clustering??

cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Clean Data/"
use "Total_panel1998-2011.dta", clear
keep i j t v lndist extmgn intmgn gdp_i gdp_j wto_i wto_j rta outdeg_i indeg_i ///
	outdeg_j indeg_j dir_clus_i dir_clus_j cp contig lang_off colony
* keep 10-year difference
	keep if t==1998 | t==2008
	replace t=1 if t==1998
	replace t=2 if t==2008
	keep if v>0 & v<. 
	xtset cp t	
* gen differences for estimation	
	foreach x in v extmgn intmgn gdp_i gdp_j outdeg_i indeg_i outdeg_j indeg_j ///
	dir_clus_i dir_clus_j {
		gen ln`x'=ln(`x')
		gen d_ln`x'= D.ln`x'
	}
	foreach x in wto_i wto_j rta {
		gen d_`x'=D.`x'
	}	
	keep if t==2
* IV estimations
	eststo clear
	eststo iv_1: ivreg d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lnoutdeg_i = d_lnindeg_i), first
	eststo iv_2: ivreg d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lnindeg_j = d_lnindeg_i), first	
	eststo iv_3: ivreg d_lnv d_lngdp_i d_lngdp_j d_wto_i d_wto_j d_rta (d_lndir_clus_i = d_lndir_clus_j), first
	cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Stata/Output"
	esttab iv* using "iv_regs1.csv", r2(4) se(3) obslast nogaps replace b(3) 

* IV estimations in levels, not D
eststo clear
eststo iv_1: ivregress 2sls lnv lngdp_i lngdp_j lndist contig lang_off colony wto_i wto_j rta (lnoutdeg_i = lnindeg_i), first
eststo iv_2: ivregress 2sls lnv lngdp_i lngdp_j lndist contig lang_off colony wto_i wto_j rta (lnindeg_j = lnindeg_i), first	
eststo iv_3: ivregress 2sls lnv lngdp_i lngdp_j lndist contig lang_off colony wto_i wto_j rta (lndir_clus_i = lndir_clus_j), first
cd "~/Dropbox/PhD HUB-KUL/Papers/pecking_order/Stata/Output"
esttab iv* using "iv_regs2.csv", r2(4) se(3) obslast nogaps replace b(3) 


clear
exit
exit



