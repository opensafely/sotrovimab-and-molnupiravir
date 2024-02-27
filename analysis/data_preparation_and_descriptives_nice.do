********************************************************************************
*
*	Do-file:		data preparation and descriptives.do
*
*	Project:		sotrovimab-and-molnupiravir
*
*	Programmed by:	Ruth Costello (based on code from Bang Zheng)
*
*	Data used:		output/input_nice.csv
*
*	Data created:	output/main.dta  (main analysis dataset)
*
*	Other output:	logs/data_preparation_nice.log
*
********************************************************************************
*
*	Purpose: This do-file creates the variables required for the 
*			 main analysis and saves into Stata dataset, and describes 
*            variables by drug groups.
*  
********************************************************************************
cap mkdir ./output/nice 

* Open a log file
cap log close
log using ./logs/data_preparation_nice, replace t
clear

* import dataset
import delimited ./output/input_nice.csv, delimiter(comma) varnames(1) case(preserve) 
*describe

*  Convert strings to dates  *
foreach var of varlist patient_index_date death_date death_with_covid_date dereg_date {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  }
}

* Check exclusions
sum age 
tab sex, m 
tab has_follow_up, m 
tab deceased, m 

* End of study period
gen study_end = date("31Dec2023", "DMY") 
* 28 days after persons hospitalisation 
gen patient_28_days = patient_index_date + 28

* Find first of death or 28 days 
egen patient_end_date = rowmin(patient_28_days death_date)

* Flag if first 6 months of 2023
gen early_2023 = patient_index_date <= date("30Jun2023", "DMY")

* Flag if COVID primary reason 
gen primary = (covid_primary==1)

* Open file to write results to 
file open tablecontent using ./output/nice/mortality_nice.txt, write text replace
file write tablecontent ("Population") _tab ("events") _tab ("total_person_mths") _tab ("Rate") _n 

* stset data
stset patient_end_date, fail(has_died) id(patient_id) enter(patient_index_date) origin(patient_index_date)

* 28-day mortality rate 
strate, per(100000) 

* Write to file 
safecount if covid==1 
local denominator = r(N) 
safecount if has_died==1 
local died = round(r(N), 5)
di `died'
sum _t
egen total_follow_up = total(_t)
sum total_follow_up
local person_mth = round(r(mean), 5)/30 
di `person_mth'
local rate = 100000*(`died'/`person_mth')
di `rate'

if `died' > 10 & `died'!=. {
  file write tablecontent ("All") _tab (`died') _tab (`person_mth') _tab (`rate') _n 
}
else { 
    file write tablecontent ("All") _tab ("redact") _n
    continue
}

* 28-day mortality for people treated with sotruvimab and molnupiravir 

tab sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics

gen covid_therapeutics = sotrovimab_covid_therapeutics 
replace covid_therapeutics = 2 if molnupiravir_covid_therapeutics==1

strate covid_therapeutics, per(100000) 

* Write to file 
safecount if covid_therapeutics==0 
local denominator = r(N) 
safecount if has_died==1 & covid_therapeutics==0 
local died_none = round(r(N), 5)
egen total_follow_up_none = total(_t) if covid_therapeutics==0
sum total_follow_up_none if covid_therapeutics==0
local person_mth_none = round(r(mean), 5)/30 
di `person_mth_none'
local rate_none = 100000*(`died_none'/`person_mth_none')
di `rate_none'

safecount if covid_therapeutics==1 
local denominator = r(N) 
safecount if has_died==1 & covid_therapeutics==1 
local died_sotrov = round(r(N), 5)
egen total_follow_up_sotrov = total(_t) if covid_therapeutics==1
sum total_follow_up_sotrov if covid_therapeutics==1
local person_mth_sotrov = round(r(mean), 5)/30 
di `person_mth_sotrov'
local rate_sotrov = 100000*(`died_sotrov'/`person_mth_sotrov')
di `rate_sotrov'

safecount if covid_therapeutics==2 
local denominator = r(N) 
safecount if has_died==1 & covid_therapeutics==2
local died_molnu = round(r(N), 5)
egen total_follow_up_molnu = total(_t) if covid_therapeutics==2
sum total_follow_up_molnu if covid_therapeutics==2
local person_mth_molnu = round(r(mean), 5)/30 
di `person_mth_molnu'
local rate_molnu = 100000*(`died_molnu'/`person_mth_molnu')
di `rate_molnu'

if `died_none' > 10 & `died_none'!=. {
  file write tablecontent ("No prior therapeutics") _tab (`died_none') _tab (`person_mth_none') _tab (`rate_none') _n 
}
else { 
    file write tablecontent ("No prior therapeutics") _tab ("redact") _n
    continue
}

if `died_sotrov' > 10 & `died_sotrov'!=. {
  file write tablecontent ("Sotruvimab") _tab (`died_sotrov') _tab (`person_mth_sotrov') _tab (`rate_sotrov') _n 
}
else { 
    file write tablecontent ("Sotruvimab") _tab ("redact") _n
    continue
}

if `died_molnu' > 10 & `died_molnu'!=. {
  file write tablecontent ("Molnupiravir") _tab (`died_molnu') _tab (`person_mth_molnu') _tab (`rate_molnu') _n 
}
else { 
    file write tablecontent ("Molnupiravir") _tab ("redact") _n
    continue
}

* 28-day mortality for people in critical care vs not 
strate critical_care, per(100000) 

* Write to file 
safecount if critical_care==0 
local denominator = r(N) 
safecount if has_died==1 & critical_care==0 
local died_hosp = round(r(N), 5)
egen total_follow_up_hosp = total(_t) if critical_care==0
sum total_follow_up_hosp if critical_care==0
local person_mth_hosp = round(r(mean), 5)/30 
di `person_mth_hosp'
local rate_hosp = 100000*(`died_hosp'/`person_mth_hosp')
di `rate_hosp'

safecount if critical_care==1 
local denominator = r(N) 
safecount if has_died==1 & critical_care==1 
local died_crit = round(r(N), 5)
egen total_follow_up_crit = total(_t) if critical_care==1
sum total_follow_up_crit if critical_care==1
local person_mth_crit = round(r(mean), 5)/30 
di `person_mth_crit'
local rate_crit = 100000*(`died_crit'/`person_mth_crit')
di `rate_crit'

if `died_hosp' > 10 & `died_hosp'!=. {
  file write tablecontent ("Hospitalised (not critical)") _tab (`died_hosp') _tab (`person_mth_hosp') _tab (`rate_hosp') _n 
}
else { 
    file write tablecontent ("Hospitalised (not critical)") _tab ("redact") _n
    continue
}

if `died_crit' > 10 & `died_crit'!=. {
  file write tablecontent ("Hospitalised (critical)") _tab (`died_crit') _tab (`person_mth_crit') _tab (`rate_crit') _n 
}
else { 
    file write tablecontent ("Hospitalised (critical)") _tab ("redact") _n
    continue
}

* First 6 months 2023 vs last 6 months 2023

strate early_2023, per(100000)

safecount if early_2023==1 
local denominator = r(N) 
safecount if has_died==1 & early_2023==1 
local died_early = round(r(N), 5)
di `died_early'
egen total_follow_up_early = total(_t) if early_2023==1
sum total_follow_up_early if early_2023==1
local person_mth_early = round(r(mean), 5)/30 
di `person_mth_early'
local rate_early = 100000*(`died_early'/`person_mth_early')
di `rate_early'

safecount if early_2023==0 
local denominator = r(N) 
safecount if has_died==1 & early_2023==0 
local died_late = round(r(N), 5)
egen total_follow_up_late = total(_t) if early_2023==0
sum total_follow_up_late if early_2023==0
local person_mth_late = round(r(mean), 5)/30 
di `person_mth_late'
local rate_late = 100000*(`died_late'/`person_mth_late')
di `rate_late'

if `died_early' > 10 & `died_early'!=. {
  file write tablecontent ("Jan-June 2023") _tab (`died_early') _tab (`person_mth_early') _tab (`rate_early') _n 
}
else { 
    file write tablecontent ("Jan-June 2023") _tab ("redact") _n
    continue
}

if `died_late' > 10 & `died_late'!=. {
  file write tablecontent ("July-Dec 2023") _tab (`died_late') _tab (`person_mth_late') _tab (`rate_late') _n 
}
else { 
    file write tablecontent ("July-Dec 2023") _tab ("redact") _n
    continue
}

* Primary reason COVID vs any position

strate primary, per(100000)

safecount if primary==1 
local denominator = r(N) 
safecount if has_died==1 & primary==1 
local died_primary = round(r(N), 5)
di `died_primary'
egen total_follow_up_primary = total(_t) if primary==1
sum total_follow_up_primary if primary==1
local person_mth_primary = round(r(mean), 5)/30 
di `person_mth_primary'
local rate_primary = 100000*(`died_primary'/`person_mth_primary')
di `rate_primary'

safecount if primary==0 
local denominator = r(N) 
safecount if has_died==1 & primary==0 
local died_any = round(r(N), 5)
egen total_follow_up_any = total(_t) if primary==0
sum total_follow_up_any if primary==0
local person_mth_any = round(r(mean), 5)/30 
di `person_mth_any'
local rate_any = 100000*(`died_any'/`person_mth_any')
di `rate_any'

if `died_primary' > 10 & `died_primary'!=. {
  file write tablecontent ("Primary") _tab (`died_primary') _tab (`person_mth_primary') _tab (`rate_primary') _n 
}
else { 
    file write tablecontent ("Primary") _tab ("redact") _n
    continue
}

if `died_any' > 10 & `died_any'!=. {
  file write tablecontent ("Other position") _tab (`died_any') _tab (`person_mth_any') _tab (`rate_any') _n 
}
else { 
    file write tablecontent ("Other position") _tab ("redact") _n
}

file close tablecontent
