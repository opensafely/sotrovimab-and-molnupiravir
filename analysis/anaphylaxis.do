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
import delimited ./output/ukrr/input_ukrr_update.csv, delimiter(comma) varnames(1) case(preserve) 

*codebook
keep if sotrovimab_covid_therapeutics!=""|molnupiravir_covid_therapeutics!=""|paxlovid_covid_therapeutics!=""

*  Convert strings to dates  *
foreach var of varlist sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics paxlovid_covid_therapeutics remdesivir_covid_therapeutics	///
        casirivimab_covid_therapeutics sotrovimab_covid_approved sotrovimab_covid_complete sotrovimab_covid_not_start sotrovimab_covid_stopped ///
		molnupiravir_covid_approved molnupiravir_covid_complete molnupiravir_covid_not_start molnupiravir_covid_stopped ///
        covid_test_positive_date covid_test_positive_date2 covid_symptoms_snomed last_vaccination_date primary_covid_hospital_discharge ///
	   any_covid_hospital_discharge_dat preg_36wks_date death_date dereg_date downs_syndrome_nhsd_snomed downs_syndrome_nhsd_icd10 cancer_opensafely_snomed cancer_opensafely_snomed_new ///
	   haematopoietic_stem_cell_snomed haematopoietic_stem_cell_icd10 haematopoietic_stem_cell_opcs4 ///
	   haematological_malignancies_snom haematological_malignancies_icd1 sickle_cell_disease_nhsd_snomed sickle_cell_disease_nhsd_icd10 ///
	   ckd_stage_5_nhsd_snomed ckd_stage_5_nhsd_icd10 liver_disease_nhsd_snomed liver_disease_nhsd_icd10 immunosuppresant_drugs_nhsd ///
	   oral_steroid_drugs_nhsd immunosupression_nhsd immunosupression_nhsd_new hiv_aids_nhsd_snomed  solid_organ_transplant_nhsd_snom solid_organ_nhsd_snomed_new ///
	   solid_organ_transplant_nhsd_opcs multiple_sclerosis_nhsd_snomed multiple_sclerosis_nhsd_icd10 ///
	   motor_neurone_disease_nhsd_snome motor_neurone_disease_nhsd_icd10 myasthenia_gravis_nhsd_snomed myasthenia_gravis_nhsd_icd10 ///
	   huntingtons_disease_nhsd_snomed huntingtons_disease_nhsd_icd10 bmi_date_measured covid_positive_test_30_days_post covid_test_positive_previous_dat ///
	   covid_hosp_outcome_date0 covid_hosp_outcome_date1 covid_hosp_outcome_date2 covid_hosp_discharge_date0 covid_hosp_discharge_date1 covid_hosp_discharge_date2 ///
	   covid_hosp_date_emergency0 covid_hosp_date_emergency1 covid_hosp_date_emergency2 covid_emerg_discharge_date0 covid_emerg_discharge_date1 covid_emerg_discharge_date2 ///
	   covid_hosp_date_mabs_procedure covid_hosp_date_mabs_not_pri covid_hosp_date0_not_primary covid_hosp_date1_not_primary covid_hosp_date2_not_primary ///
	   covid_discharge_date0_not_pri covid_discharge_date1_not_pri covid_discharge_date2_not_pri death_with_covid_on_the_death_ce death_with_covid_underlying_date hospitalisation_outcome_date0 ///
	   hospitalisation_outcome_date1 hospitalisation_outcome_date2 hosp_discharge_date0 hosp_discharge_date1 hosp_discharge_date2 covid_hosp_date_mabs_all_cause date_treated start_date ///
	   downs_syndrome_nhsd haematological_disease_nhsd ckd_stage_5_nhsd liver_disease_nhsd hiv_aids_nhsd solid_organ_transplant_nhsd solid_organ_transplant_nhsd_new ///
	   multiple_sclerosis_nhsd motor_neurone_disease_nhsd myasthenia_gravis_nhsd huntingtons_disease_nhsd sickle_cell_disease_nhsd covid_hosp_date_mabs_day ///
	   covid_hosp_outcome_day_date0 covid_hosp_outcome_day_date1 covid_hosp_outcome_day_date2 covid_hosp_discharge_day_date0 covid_hosp_discharge_day_date1 covid_hosp_discharge_day_date2 ///
	   covid_hosp_venti_opcs covid_hosp_venti_not_pri_opcs hosp_venti_opcs covid_hosp_crit_care_opcs covid_hosp_crit_care_not_pri_opc hosp_crit_care_opcs ///
	   ukrr_2020_startdate ukrr_2021_startdate ukrr_inc2020_date {
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
codebook  covid_hosp_outcome_date2 death_date
sum covid_hosp_outcome_date2  


*describe COVID therapy*
gen treated=(date_treated!=.)
gen sotro=(sotrovimab_covid_therapeutics== start_date)
gen mol=(molnupiravir_covid_therapeutics== start_date)
gen cas=(casirivimab_covid_therapeutics== start_date)
gen pax=(paxlovid_covid_therapeutics== start_date)
gen rem=(remdesivir_covid_therapeutics== start_date)
tab sotro ,m
tab mol ,m 
tab cas ,m
tab pax ,m
tab rem ,m
keep if treated==1

*exclusion criteria*
sum age,de
*keep if age>=18 & age<110
tab sex,m
*keep if sex=="F"|sex=="M"
tab has_died,m
*keep if has_died==0
tab registered_treated,m
*keep if registered_treated==1
keep if start_date>=mdy(12,16,2021)&start_date<=mdy(04,08,2023)

*count primary diagnosis *
tab hospitalisation_primary_code1 if sotro==1,m
tab hospitalisation_primary_code2 if sotro==1,m
tab death_code if sotro==1,m

tab hospitalisation_primary_code1 if mol==1,m
tab hospitalisation_primary_code2 if mol==1,m
tab death_code if mol==1,m

tab hospitalisation_primary_code1 if pax==1,m
tab hospitalisation_primary_code2 if pax==1,m
tab death_code if pax==1,m

log close




