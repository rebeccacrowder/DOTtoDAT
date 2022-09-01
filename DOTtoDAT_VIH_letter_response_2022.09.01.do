*****************************************************************************
* DOT to DAT Trial
* Response to Value in Health Letter to the Editor
* September 1, 2022
******************************
* Model 1 and 2 below were included in Cattamanchi et. al. Plos Med 2021
* Model 3 was referenced in a response to a letter to the editor to Value in Health 2022
*****************************************************************************

use "DOTtoDAT_trialdata.dta", clear

*****************************************************************************
* Generate variables
*****************************************************************************

* include in perprotocol analysis:
gen startto99dots=enrollmentdate-txstartdate
label var startto99dots "Days from tx start to 99DOTS enrollment"

gen perprotocol=1 if eligible1==1
replace perprotocol=0 if period==0 & dat==1
replace perprotocol=0 if (period==1 | period==2) & dat==0
replace perprotocol=0 if dat==1 & startto99dots>28
replace perprotocol=0 if period==88
label define perprotocol_ 0 "No" 1 "Yes"
label values perprotocol perprotocol_
label var perprotocol "Include in perprotocol analysis?"

* time to outcome
gen timetooutcome = txout_date-txstartdate

* flag those who died/was LTFU in the first 28 days
gen earlypooroutcome=0
replace  earlypooroutcome=1 if timetooutcome>=0 & timetooutcome<=28 & inlist(outcome,4,6)
label values earlypooroutcome yesno_
* note. outcome 4 = died, outcome 6 = LTFU

*****************************************************************************
* Models
* Primary outcome: treatment success
*****************************************************************************

******************************
* Model 1: intention to treat
******************************
melogit tx_success i.period txregageyears sex txreghiv txregdisease retreatment healthcenter i.month if period!=88 & eligible1==1 || site:, or
margins i.period
margins i.period, pwcompare

******************************
* Model 2: per protocol
******************************
melogit tx_success i.period txregageyears sex txreghiv txregdisease retreatment healthcenter i.month if period!=88 & eligible1==1 & perprotocol==1 || site:, or
margins i.period
margins i.period, pwcompare

******************************
* Model 3: per protocol analysis after excluding those who died or were LTFU within day 0-28
******************************
melogit tx_success i.period txregageyears sex txreghiv txregdisease retreatment healthcenter i.month if period!=88 & eligible1==1 & perprotocol==1 & earlypooroutcome==0 || site:, or
margins i.period
margins i.period, pwcompare
