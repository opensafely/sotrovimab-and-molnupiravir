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
describe

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
describe 

* Check exclusions
sum age 
tab sex, m 
tab has_follow_up, m 
tab deceased, m 

* has_died variable defined incorrectly
drop has_died

* death_date any time after date admitted
sum death_date death_with_covid_date

* End of study period
gen study_end = date("31Dec2023", "DMY") 
* 28 days after persons hospitalisation 
gen patient_28_days = patient_index_date + 28

gen has_died = death_date <=patient_28_days
tab has_died

* Checks
count if death_date<=patient_28_days
count if death_date<patient_28_days
count if death_date==patient_28_days
count if death_date==patient_index_date

* Find first of death or 28 days 
egen patient_end_date = rowmin(patient_28_days death_date)

count if patient_end_date!=patient_28_days 

* Flag if first 6 months of 2023
gen early_2023 = patient_index_date <= date("30Jun2023", "DMY")

* Flag if COVID primary reason 
gen primary = (covid_primary==1)

* Open file to write results to 
file open tablecontent using ./output/nice/mortality_nice.txt, write text replace
file write tablecontent ("Population") _tab ("N") _tab ("events") _tab ("Rate") _n 

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
local rate = (`died'/`denominator')
di `rate'

if `died' > 10 & `died'!=. {
  file write tablecontent ("All") _tab (`denominator') _tab (`died')  _tab (`rate') _n 
}
else { 
  file write tablecontent ("All") _tab ("redact") _n
}

* 28-day mortality for people treated with sotruvimab and molnupiravir 

tab sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics

gen covid_therapeutics = sotrovimab_covid_therapeutics 
replace covid_therapeutics = 2 if molnupiravir_covid_therapeutics==1

strate covid_therapeutics, per(100000) 

* Write to file 
safecount if covid_therapeutics==0 
local denominator_none = r(N) 
safecount if has_died==1 & covid_therapeutics==0 
local died_none = round(r(N), 5)
local rate_none = (`died_none'/`denominator_none')
di `rate_none'

safecount if covid_therapeutics==1 
local denominator_sotrov = r(N) 
safecount if has_died==1 & covid_therapeutics==1 
local died_sotrov = round(r(N), 5)
local rate_sotrov = (`died_sotrov'/`denominator_sotrov')
di `rate_sotrov'

safecount if covid_therapeutics==2 
local denominator_molnu = r(N) 
safecount if has_died==1 & covid_therapeutics==2
local died_molnu = round(r(N), 5)
local rate_molnu = (`died_molnu'/`denominator_molnu')
di `rate_molnu'

if `died_none' > 10 & `died_none'!=. {
  file write tablecontent ("No prior therapeutics") _tab (`denominator_none') _tab (`died_none') _tab (`rate_none') _n 
}
else { 
  file write tablecontent ("No prior therapeutics") _tab ("redact") _n
  }

if `died_sotrov' > 10 & `died_sotrov'!=. {
  file write tablecontent ("Sotruvimab") _tab (`denominator_sotrov') _tab (`died_sotrov') _tab (`rate_sotrov') _n 
}
else { 
  file write tablecontent ("Sotruvimab") _tab ("redact") _n
}

if `died_molnu' > 10 & `died_molnu'!=. {
  file write tablecontent ("Molnupiravir") _tab (`denominator_molnu') _tab (`died_molnu') _tab (`rate_molnu') _n 
}
else { 
  file write tablecontent ("Molnupiravir") _tab ("redact") _n
}

* 28-day mortality for people in critical care vs not 
strate critical_care, per(100000) 

* Write to file 
safecount if critical_care==0 
local denominator_hosp = r(N) 
safecount if has_died==1 & critical_care==0 
local died_hosp = round(r(N), 5)
local rate_hosp = (`died_hosp'/`denominator_hosp')
di `rate_hosp'

safecount if critical_care==1 
local denominator_crit = r(N) 
safecount if has_died==1 & critical_care==1 
local died_crit = round(r(N), 5)
local rate_crit = (`died_crit'/`denominator_crit')
di `rate_crit'

if `died_hosp' > 10 & `died_hosp'!=. {
  file write tablecontent ("Hospitalised (not critical)")  _tab (`denominator_hosp') _tab (`died_hosp') _tab (`rate_hosp') _n 
}
else { 
  file write tablecontent ("Hospitalised (not critical)") _tab ("redact") _n
}

if `died_crit' > 10 & `died_crit'!=. {
  file write tablecontent ("Hospitalised (critical)") _tab (`denominator_crit') _tab (`died_crit') _tab (`rate_crit') _n 
}
else { 
  file write tablecontent ("Hospitalised (critical)") _tab ("redact") _n
}

* First 6 months 2023 vs last 6 months 2023

strate early_2023, per(100000)

safecount if early_2023==1 
local denominator_early = r(N) 
safecount if has_died==1 & early_2023==1 
local died_early = round(r(N), 5)
di `died_early'
local rate_early = (`died_early'/`denominator_early')
di `rate_early'

safecount if early_2023==0 
local denominator_late = r(N) 
safecount if has_died==1 & early_2023==0 
local died_late = round(r(N), 5)
local rate_late = (`died_late'/`denominator_late')
di `rate_late'

if `died_early' > 10 & `died_early'!=. {
  file write tablecontent ("Jan-June 2023") _tab (`denominator_early') _tab (`died_early') _tab (`rate_early') _n 
}
else { 
  file write tablecontent ("Jan-June 2023") _tab ("redact") _n
}

if `died_late' > 10 & `died_late'!=. {
  file write tablecontent ("July-Dec 2023") _tab (`denominator_late') _tab (`died_late') _tab (`rate_late') _n 
}
else { 
  file write tablecontent ("July-Dec 2023") _tab ("redact") _n
}

* Primary reason COVID vs any position

strate primary, per(100000)

safecount if primary==1 
local denominator_primary = r(N) 
safecount if has_died==1 & primary==1 
local died_primary = round(r(N), 5)
di `died_primary'
local rate_primary = (`died_primary'/`denominator_primary')
di `rate_primary'

safecount if primary==0 
local denominator_any = r(N) 
safecount if has_died==1 & primary==0 
local died_any = round(r(N), 5)
local rate_any = (`died_any'/`denominator_any')
di `rate_any'

if `died_primary' > 10 & `died_primary'!=. {
  file write tablecontent ("Primary") _tab (`denominator_primary') _tab (`died_primary') _tab (`rate_primary') _n 
}
else { 
  file write tablecontent ("Primary") _tab ("redact") _n
}

if `died_any' > 10 & `died_any'!=. {
  file write tablecontent ("Other position") _tab (`denominator_any') _tab (`died_any') _tab (`rate_any') _n 
}
else { 
  file write tablecontent ("Other position") _tab ("redact") _n
}

file close tablecontent
