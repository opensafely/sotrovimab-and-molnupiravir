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
rename v55 haematological_malig_snomed_ever
rename v56 haematological_malig_icd10_ever


log close
exit, clear

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
gen covid_hosp_not_pri_admission_d=start_date - covid_hosp_not_pri_admission
start_date>=covid_hosp_not_pri_admission&date_treated_hosp<=covid_hosp_not_pri_discharge)|(date_treated_hosp>=covid_hosp_not_pri_admission2&date_treated_hosp<=covid_hosp_not_pri_discharge2))
count if treated_hosp==1&((date_treated_hosp>=covid_hosp_admission&date_treated_hosp<=covid_hosp_discharge)|(date_treated_hosp>=covid_hosp_admission2&date_treated_hosp<=covid_hosp_discharge2))
count if treated_hosp==1&((date_treated_hosp>=all_hosp_admission&date_treated_hosp<=all_hosp_discharge)|(date_treated_hosp>=all_hosp_admission2&date_treated_hosp<=all_hosp_discharge2))
count if treated_hosp==1&(((date_treated_hosp+1)>=covid_hosp_not_pri_admission&(date_treated_hosp-1)<=covid_hosp_not_pri_discharge)|((date_treated_hosp+1)>=covid_hosp_not_pri_admission2&(date_treated_hosp-1)<=covid_hosp_not_pri_discharge2))
count if treated_hosp==1&(((date_treated_hosp+3)>=covid_hosp_not_pri_admission&(date_treated_hosp-3)<=covid_hosp_not_pri_discharge)|((date_treated_hosp+3)>=covid_hosp_not_pri_admission2&(date_treated_hosp-3)<=covid_hosp_not_pri_discharge2))
count if treated_hosp==1&(((date_treated_hosp+1)>=covid_hosp_admission&(date_treated_hosp-1)<=covid_hosp_discharge)|((date_treated_hosp+1)>=covid_hosp_admission2&(date_treated_hosp-1)<=covid_hosp_discharge2))
count if treated_hosp==1&(((date_treated_hosp+3)>=covid_hosp_admission&(date_treated_hosp-3)<=covid_hosp_discharge)|((date_treated_hosp+3)>=covid_hosp_admission2&(date_treated_hosp-3)<=covid_hosp_discharge2))
count if treated_hosp==1&all_hosp_admission_hosp!=.
count if treated_hosp==1&covid_hosp_admission_hosp!=.
count if treated_hosp==1&covid_hosp_not_pri_hosp!=.
*check covid test*
count if treated_onset==1&covid_test_positive_onset!=.
count if treated_hosp==1&covid_test_positive_hosp!=.

*distinguish onset and hosp*
tab treated_onset if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2))
tab treated_hosp if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2))
tab treated_hosp if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge&covid_test_positive_not_pri>covid_hosp_not_pri_admission)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2&covid_test_positive_not_pri2>covid_hosp_not_pri_admission2))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge&covid_test_positive_covid_hosp>covid_hosp_admission)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2&covid_test_positive_covid_hosp2>covid_hosp_admission2))
tab treated_onset if start_date!=.&((start_date>=all_hosp_admission&start_date<=all_hosp_discharge&covid_test_positive_all_hosp>all_hosp_admission)|(start_date>=all_hosp_admission2&start_date<=all_hosp_discharge2&covid_test_positive_all_hosp2>all_hosp_admission2))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge&covid_test_positive_not_pri>covid_hosp_not_pri_admission&covid_test_positive_not_pri!=.)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2&covid_test_positive_not_pri2>covid_hosp_not_pri_admission2&covid_test_positive_not_pri2!=.))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge&covid_test_positive_covid_hosp>covid_hosp_admission&covid_test_positive_covid_hosp!=.)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2&covid_test_positive_covid_hosp2>covid_hosp_admission2&covid_test_positive_covid_hosp2!=.))
tab treated_onset if start_date!=.&((start_date>=all_hosp_admission&start_date<=all_hosp_discharge&covid_test_positive_all_hosp>all_hosp_admission&covid_test_positive_all_hosp!=.)|(start_date>=all_hosp_admission2&start_date<=all_hosp_discharge2&covid_test_positive_all_hosp2>all_hosp_admission2&covid_test_positive_all_hosp2!=.))
tab treated_hosp if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge&covid_test_positive_not_pri<=covid_hosp_not_pri_admission)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2&covid_test_positive_not_pri2<=covid_hosp_not_pri_admission2))
tab treated_hosp if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge&covid_test_positive_covid_hosp<=covid_hosp_admission)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2&covid_test_positive_covid_hosp2<=covid_hosp_admission2))
tab treated_hosp if start_date!=.&((start_date>=all_hosp_admission&start_date<=all_hosp_discharge&covid_test_positive_all_hosp<=all_hosp_admission)|(start_date>=all_hosp_admission2&start_date<=all_hosp_discharge2&covid_test_positive_all_hosp2<=all_hosp_admission2))



count  if tocilizumab_covid_hosp!=.&death_with_covid_date!=.
count  if sarilumab_covid_hosp!=.&death_with_covid_date!=.
count  if tocilizumab_covid_hosp!=.&death_date!=.
count  if sarilumab_covid_hosp!=.&death_date!=.




*check hosp/death event date range*
*codebook covid_hosp_outcome_date2 hospitalisation_outcome_date2 death_date

*exclusion criteria*

log close




