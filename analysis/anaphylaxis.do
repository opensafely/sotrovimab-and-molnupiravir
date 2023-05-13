********************************************************************************
*
*	Do-file:		data preparation and descriptives.do
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
log using ./logs/anaphylaxis, replace t
clear

* import dataset
import delimited ./output/input_anaphylaxis.csv, delimiter(comma) varnames(1) case(preserve) 

*codebook
keep if sotrovimab_covid_therapeutics!=""|molnupiravir_covid_therapeutics!=""|paxlovid_covid_therapeutics!=""
codebook

*  Convert strings to dates  *
foreach var of varlist sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics paxlovid_covid_therapeutics remdesivir_covid_therapeutics	///
        casirivimab_covid_therapeutics sotrovimab_covid_approved sotrovimab_covid_complete sotrovimab_covid_not_start sotrovimab_covid_stopped ///
        last_vaccination_date death_date dereg_date date_treated start_date death_with_anaphylaxis_date death_with_anaph_underly_date death_with_anaphylaxis_date2 ///
		death_with_anaph_underly_date2 death_with_anaphylaxis_date3 death_with_anaphylaxis_date_pre death_with_anaph_underly_date_pre hospitalisation_anaph ///
		hosp_discharge_anaph hospitalisation_anaph_underly hospitalisation_anaph2 hospitalisation_anaph_underly2 hospitalisation_anaph3 hospitalisation_anaph_pre ///
		hosp_anaph_underly_pre AE_anaph AE_anaph2 AE_anaph3 AE_anaph4 AE_anaph_pre AE_anaph2_pre GP_anaph GP_anaph2 GP_anaph_pre GP_anaph2_pre hospitalisation_allcause ///
		AE_allcause {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  }
}
*the following date variables had no observation*
*hiv_aids_nhsd_icd10
*transplant_all_y_codes_opcs4
*transplant_thymus_opcs4
*transplant_conjunctiva_y_code_op
*transplant_conjunctiva_opcs4
*transplant_stomach_opcs4
*transplant_ileum_1_Y_codes_opcs4
*transplant_ileum_2_Y_codes_opcs4
*transplant_ileum_1_opcs4
*transplant_ileum_2_opcs4

*describe
*check hosp/death event date range*
codebook  hospitalisation_allcause AE_allcause death_date last_vaccination_date 
sum hospitalisation_allcause,format


*describe COVID therapy*
gen treated=(date_treated!=.)
gen sotrovimab=(sotrovimab_covid_therapeutics== start_date)
gen molnupiravir=(molnupiravir_covid_therapeutics== start_date)
gen casirivimab=(casirivimab_covid_therapeutics== start_date)
gen paxlovid=(paxlovid_covid_therapeutics== start_date)
gen remdesivir=(remdesivir_covid_therapeutics== start_date)
tab sotrovimab ,m
tab molnupiravir ,m 
tab casirivimab ,m
tab paxlovid ,m
tab remdesivir ,m
keep if treated==1
count if sotrovimab==1&molnupiravir==1
count if paxlovid==1&molnupiravir==1
count if sotrovimab==1&paxlovid==1
count if sotrovimab_covid_therapeutics==molnupiravir_covid_therapeutics
count if molnupiravir_covid_therapeutics==paxlovid_covid_therapeutics
count if sotrovimab_covid_therapeutics==paxlovid_covid_therapeutics

*exclusion criteria*
sum age,de
*keep if age>=18 & age<110
tab sex,m
*keep if sex=="F"|sex=="M"
tab has_died,m
*keep if has_died==0
tab registered_treated,m
*keep if registered_treated==1
keep if start_date>=mdy(12,16,2021)&start_date<=mdy(05,13,2023)

*anaphylaxis events*
foreach drug of varlist sotrovimab molnupiravir paxlovid {
*death *
sum death_with_anaphylaxis_date if `drug'==1,f
gen death_`drug'=(death_with_anaphylaxis_date!=.) if `drug'==1
tab death_`drug'
gen day_death_`drug'=death_with_anaphylaxis_date-`drug'_covid_therapeutics  if `drug'==1
sum day_death_`drug', de
sum death_with_anaph_underly_date if `drug'==1,f
tab death_with_anaphylaxis_code  if `drug'==1
tab death_code if `drug'==1,m

sum death_with_anaphylaxis_date2 if `drug'==1,f
sum death_with_anaph_underly_date2 if `drug'==1,f
tab death_with_anaphylaxis_code2  if `drug'==1,m
sum death_with_anaphylaxis_date3 if `drug'==1,f

sum death_with_anaphylaxis_date_pre if `drug'==1,f
sum death_with_anaph_underly_date_pre if `drug'==1,f
*hosp*
sum hospitalisation_anaph if `drug'==1,f
gen hosp_`drug'=(hospitalisation_anaph!=.) if `drug'==1
tab hosp_`drug'
gen day_hosp_`drug'=hospitalisation_anaph-`drug'_covid_therapeutics  if `drug'==1
sum day_hosp_`drug', de
gen day_discharge_`drug'=hosp_discharge_anaph-hospitalisation_anaph  if `drug'==1
sum day_discharge_`drug',de
sum hospitalisation_anaph_underly if `drug'==1,f
tab hospitalisation_primary_code  if `drug'==1,m

sum hospitalisation_anaph2 if `drug'==1,f
sum hospitalisation_anaph_underly2 if `drug'==1,f
tab hospitalisation_primary_code2  if `drug'==1,m
sum hospitalisation_anaph3 if `drug'==1,f

sum hospitalisation_anaph_pre if `drug'==1,f
sum hosp_anaph_underly_pre if `drug'==1,f
*A&E*
sum AE_anaph if `drug'==1,f
gen AE_`drug'=(AE_anaph!=.) if `drug'==1
tab AE_`drug'
gen day_AE_`drug'=AE_anaph-`drug'_covid_therapeutics  if `drug'==1
sum day_AE_`drug', de

sum AE_anaph2 if `drug'==1,f
sum AE_anaph3 if `drug'==1,f
sum AE_anaph4 if `drug'==1,f

sum AE_anaph_pre if `drug'==1,f
sum AE_anaph2_pre if `drug'==1,f
*GP*
sum GP_anaph if `drug'==1,f
gen GP_`drug'=(GP_anaph!=.) if `drug'==1
tab GP_`drug'
gen day_GP_`drug'=GP_anaph-`drug'_covid_therapeutics  if `drug'==1
sum day_GP_`drug', de
tab GP_anaph_code  if `drug'==1,m

sum GP_anaph2 if `drug'==1,f
sum GP_anaph_pre if `drug'==1,f
sum GP_anaph2_pre if `drug'==1,f

}

log close




