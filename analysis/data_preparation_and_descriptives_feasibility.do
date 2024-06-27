********************************************************************************
*
*	Do-file:		data_preparation_and_descriptives.do
*
*	Project:		sotrovimab-and-molnupiravir
*
*	Programmed by:	Bang Zheng
*
*	Data used:		output/input.csv
*
*	Data created:	output/main.dta  (main analysis dataset)
*
*	Other output:	logs/data_preparation.log
*
********************************************************************************
*
*	Purpose: This do-file creates the variables required for the 
*			 main analysis and saves into Stata dataset, and describes 
*            variables by drug groups.
*  
********************************************************************************

* Open a log file
cap log close
log using ./logs/data_preparation_feasibility, replace t
clear

* import dataset
import delimited ./output/input_feasibility.csv, delimiter(comma) varnames(1) case(preserve) 
keep if date_treated_out!=""|date_treated_hosp!=""|date_treated_onset!=""
*describe
codebook
rename v57 haematological_malig_snomed_ever
rename v58 haematological_malig_icd10_ever




*  Convert strings to dates  *
foreach var of varlist  sotrovimab_covid_out molnupiravir_covid_out paxlovid_covid_out remdesivir_covid_out casirivimab_covid_out date_treated_out ///
        sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics paxlovid_covid_therapeutics remdesivir_covid_therapeutics	///
        casirivimab_covid_therapeutics tocilizumab_covid_therapeutics sarilumab_covid_therapeutics  baricitinib_covid_therapeutics date_treated_onset ///
		baricitinib_covid_hosp remdesivir_covid_hosp0 tocilizumab_covid_hosp0 sarilumab_covid_hosp0 tocilizumab_covid_hosp2  sarilumab_covid_hosp2  ///
        sotrovimab_covid_hosp paxlovid_covid_hosp molnupiravir_covid_hosp remdesivir_covid_hosp casirivimab_covid_hosp tocilizumab_covid_hosp sarilumab_covid_hosp ///
		date_treated_hosp start_date death_with_covid_date death_with_covid_underly_date death_date   ///
		cancer_opensafely_snomed_new cancer_opensafely_snomed_ever haematological_malignancies_snom haematological_malignancies_icd1 haematological_disease_nhsd     ///
		haematological_malig_snomed_ever haematological_malig_icd10_ever haematological_disease_nhsd_ever	 immunosuppresant_drugs_nhsd ///
		oral_steroid_drugs_nhsd immunosuppresant_drugs_nhsd_ever oral_steroid_drugs_nhsd_ever immunosupression_nhsd_new solid_organ_transplant_nhsd_new ///
		ckd_stage_5_nhsd liver_disease_nhsd last_vaccination_date covid_hosp_not_pri_admission covid_hosp_not_pri_discharge covid_hosp_not_pri_discharge_1d ///
		covid_hosp_not_pri_discharge2 covid_hosp_not_pri_admission2  covid_hosp_not_pri_discharge2_1d  all_hosp_discharge_1d all_hosp_admission2 all_hosp_discharge2_1d ///
		covid_hosp_not_pri_admission0 covid_hosp_not_pri_discharge0 covid_hosp_admission covid_hosp_discharge all_hosp_admission all_hosp_discharge ///
		all_hosp_discharge2 all_hosp_admission0 all_hosp_discharge0 covid_test_positive_date covid_test_positive_date0 covid_test_positive_date00 ///
		dereg_date	{
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  sum `var',f
  }
}

*check hosp records*
keep if start_date!=.
count if  covid_hosp_not_pri_admission!=.
sum covid_hosp_not_pri_admission,f
count if covid_hosp_not_pri_admission==covid_hosp_not_pri_discharge
sum covid_hosp_not_pri_admission if covid_hosp_not_pri_admission==covid_hosp_not_pri_discharge,f
count if  all_hosp_admission!=.
sum all_hosp_admission,f
count if all_hosp_admission==all_hosp_discharge
sum all_hosp_admission if all_hosp_admission==all_hosp_discharge, f
gen covid_hosp_not_pri_adm_d= start_date - covid_hosp_not_pri_admission
sum covid_hosp_not_pri_adm_d,de
gen all_hosp_adm_d= start_date - all_hosp_admission
sum all_hosp_adm_d,de
gen covid_hosp_not_pri_duration= covid_hosp_not_pri_discharge - covid_hosp_not_pri_admission
sum covid_hosp_not_pri_duration,de
gen all_hosp_duration= all_hosp_discharge - all_hosp_admission
sum all_hosp_duration,de


count  if tocilizumab_covid_hosp!=.&death_with_covid_date!=.
count  if sarilumab_covid_hosp!=.&death_with_covid_date!=.
count  if tocilizumab_covid_hosp!=.&death_date!=.
count  if sarilumab_covid_hosp!=.&death_date!=.

*exclusion*
sum age,de
keep if age>=18 & age<110
tab sex,m
keep if sex=="F"|sex=="M"
keep if has_died==0
drop if start_date==death_date
*keep if registered_treated_hosp==1
keep if region_nhs!=""|region_covid_therapeutics!=""
keep if start_date>=mdy(07,01,2021)&start_date<=mdy(02,28,2022)
drop if tocilizumab_covid_hosp==sarilumab_covid_hosp
gen drug1=1 if sotrovimab_covid_out!=.
replace drug1=2 if molnupiravir_covid_out!=.
replace drug1=0 if molnupiravir_covid_out==.&sotrovimab_covid_out==.
label define drug1 1 "sotrovimab" 2 "molnupiravia" 0 "neither" 
label values drug1 drug1
tab drug1,m
gen drug=1 if sarilumab_covid_hosp==start_date
replace drug=0 if tocilizumab_covid_hosp ==start_date
label define drug 1 "sarilumab" 0 "tocilizumab"
label values drug drug
tab drug,m

*define outcome and follow-up time*
gen study_end_date=mdy(03,01,2024)
gen start_date_29=start_date+28
*primary outcome*
gen failure=(death_date!=.&death_date<=min(study_end_date,start_date_29,tocilizumab_covid_hosp)) if drug==1
replace failure=(death_date!=.&death_date<=min(study_end_date,start_date_29,sarilumab_covid_hosp)) if drug==0
tab drug failure,m
gen end_date=death_date if failure==1
replace end_date=min(study_end_date, start_date_29,tocilizumab_covid_hosp) if failure==0&drug==1
replace end_date=min(study_end_date, start_date_29,sarilumab_covid_hosp) if failure==0&drug==0
format %td  end_date study_end_date start_date_29

stset end_date ,  origin(start_date) failure(failure==1)
stcox drug
stcox i.drug##i.drug1

*secondary outcome: within 90 day*
gen start_date_90d=start_date+90
gen failure_90d=(death_date!=.&death_date<=min(study_end_date,start_date_90d,tocilizumab_covid_hosp)) if drug==1
replace failure_90d=(death_date!=.&death_date<=min(study_end_date,start_date_90d,sarilumab_covid_hosp)) if drug==0
tab drug failure_90d,m
gen end_date_90d=death_date if failure_90d==1
replace end_date_90d=min(study_end_date, start_date_90d,tocilizumab_covid_hosp) if failure_90d==0&drug==1
replace end_date_90d=min(study_end_date, start_date_90d,sarilumab_covid_hosp) if failure_90d==0&drug==0
format %td  end_date_90d  start_date_90d

stset end_date_90d ,  origin(start_date) failure(failure_90d==1)
stcox drug
stcox i.drug##i.drug1

*secondary outcome: within 180 day*
gen start_date_180d=start_date+180
gen failure_180d=(death_date!=.&death_date<=min(study_end_date,start_date_180d,tocilizumab_covid_hosp)) if drug==1
replace failure_180d=(death_date!=.&death_date<=min(study_end_date,start_date_180d,sarilumab_covid_hosp)) if drug==0
tab drug failure_180d,m
gen end_date_180d=death_date if failure_180d==1
replace end_date_180d=min(study_end_date, start_date_180d,tocilizumab_covid_hosp) if failure_180d==0&drug==1
replace end_date_180d=min(study_end_date, start_date_180d,sarilumab_covid_hosp) if failure_180d==0&drug==0
format %td  end_date_180d  start_date_180d

stset end_date_180d ,  origin(start_date) failure(failure_180d==1)
stcox drug
stcox i.drug##i.drug1

*secondary outcome: within 1 year*
gen start_date_1y=start_date+365
gen failure_1y=(death_date!=.&death_date<=min(study_end_date,start_date_1y,tocilizumab_covid_hosp)) if drug==1
replace failure_1y=(death_date!=.&death_date<=min(study_end_date,start_date_1y,sarilumab_covid_hosp)) if drug==0
tab drug failure_1y,m
gen end_date_1y=death_date if failure_1y==1
replace end_date_1y=min(study_end_date, start_date_1y,tocilizumab_covid_hosp) if failure_1y==0&drug==1
replace end_date_1y=min(study_end_date, start_date_1y,sarilumab_covid_hosp) if failure_1y==0&drug==0
format %td  end_date_1y  start_date_1y

stset end_date_1y ,  origin(start_date) failure(failure_1y==1)
stcox drug
stcox i.drug##i.drug1

*secondary outcome: within 2 year*
gen start_date_2y=start_date+365*2
gen failure_2y=(death_date!=.&death_date<=min(study_end_date,start_date_2y,tocilizumab_covid_hosp)) if drug==1
replace failure_2y=(death_date!=.&death_date<=min(study_end_date,start_date_2y,sarilumab_covid_hosp)) if drug==0
tab drug failure_2y,m
gen end_date_2y=death_date if failure_2y==1
replace end_date_2y=min(study_end_date, start_date_2y,tocilizumab_covid_hosp) if failure_2y==0&drug==1
replace end_date_2y=min(study_end_date, start_date_2y,sarilumab_covid_hosp) if failure_2y==0&drug==0
format %td  end_date_2y  start_date_2y

stset end_date_1y ,  origin(start_date) failure(failure_1y==1)
stcox drug
stcox i.drug##i.drug1


log close




