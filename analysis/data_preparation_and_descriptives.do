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
log using ./logs/data_preparation, replace t
clear

* import dataset
import delimited ./output/input.csv, delimiter(comma) varnames(1) case(preserve) 
describe
codebook

*  Convert strings to dates  *
foreach var of varlist sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics paxlovid_covid_therapeutics remdesivir_covid_therapeutics	///
        casirivimab_covid_therapeutics sotrovimab_covid_approved sotrovimab_covid_complete sotrovimab_covid_not_start sotrovimab_covid_stopped ///
		molnupiravir_covid_approved molnupiravir_covid_complete molnupiravir_covid_not_start molnupiravir_covid_stopped ///
        covid_test_positive_date covid_test_positive_date2 covid_symptoms_snomed last_vaccination_date primary_covid_hospital_discharge ///
	   any_covid_hospital_discharge_dat preg_36wks_date death_date dereg_date downs_syndrome_nhsd_snomed downs_syndrome_nhsd_icd10 cancer_opensafely_snomed ///
	   haematopoietic_stem_cell_snomed haematopoietic_stem_cell_icd10 haematopoietic_stem_cell_opcs4 ///
	   haematological_malignancies_snom haematological_malignancies_icd1 sickle_cell_disease_nhsd_snomed sickle_cell_disease_nhsd_icd10 ///
	   ckd_stage_5_nhsd_snomed ckd_stage_5_nhsd_icd10 liver_disease_nhsd_snomed liver_disease_nhsd_icd10 immunosuppresant_drugs_nhsd ///
	   oral_steroid_drugs_nhsd immunosupression_nhsd hiv_aids_nhsd_snomed  solid_organ_transplant_nhsd_snom ///
	   solid_organ_transplant_nhsd_opcs multiple_sclerosis_nhsd_snomed multiple_sclerosis_nhsd_icd10 ///
	   motor_neurone_disease_nhsd_snome motor_neurone_disease_nhsd_icd10 myasthenia_gravis_nhsd_snomed myasthenia_gravis_nhsd_icd10 ///
	   huntingtons_disease_nhsd_snomed huntingtons_disease_nhsd_icd10 bmi_date_measured covid_positive_test_30_days_post ///
	   covid_hosp_outcome_date0 covid_hosp_outcome_date1 covid_hosp_outcome_date2 covid_hosp_discharge_date0 covid_hosp_discharge_date1 covid_hosp_discharge_date2 ///
	   covid_hosp_date_emergency0 covid_hosp_date_emergency1 covid_hosp_date_emergency2 covid_emerg_discharge_date0 covid_emerg_discharge_date1 covid_emerg_discharge_date2 ///
	   covid_hosp_date_mabs_procedure covid_hosp_date_mabs_not_pri covid_hosp_date0_not_primary covid_hosp_date1_not_primary covid_hosp_date2_not_primary ///
	   covid_discharge_date0_not_pri covid_discharge_date1_not_pri covid_discharge_date2_not_pri death_with_covid_on_the_death_ce death_with_covid_underlying_date hospitalisation_outcome_date0 ///
	   hospitalisation_outcome_date1 hospitalisation_outcome_date2 hosp_discharge_date0 hosp_discharge_date1 hosp_discharge_date2 covid_hosp_date_mabs_all_cause date_treated start_date ///
	   downs_syndrome_nhsd haematological_disease_nhsd ckd_stage_5_nhsd liver_disease_nhsd hiv_aids_nhsd solid_organ_transplant_nhsd ///
	   multiple_sclerosis_nhsd motor_neurone_disease_nhsd myasthenia_gravis_nhsd huntingtons_disease_nhsd sickle_cell_disease_nhsd covid_hosp_date_mabs_day ///
	   covid_hosp_outcome_day_date0 covid_hosp_outcome_day_date1 covid_hosp_outcome_day_date2 covid_hosp_discharge_day_date0 covid_hosp_discharge_day_date1 covid_hosp_discharge_day_date2 {
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


*exclusion criteria*
keep if sotrovimab_covid_therapeutics!=. | molnupiravir_covid_therapeutics!=.
sum age,de
keep if age>=18 & age<110
tab sex,m
keep if sex=="F"|sex=="M"
keep if has_died==0
keep if registered_treated==1
tab covid_test_positive covid_positive_previous_30_days,m
*keep if covid_test_positive==1 & covid_positive_previous_30_days==0
*restrict start_date to 2021Dec16 to 2022Feb10*
*loose this restriction to increase N?*
keep if start_date>=mdy(02,15,2022)&start_date<=mdy(04,10,2022)
drop if stp==""
*exclude those with other drugs before sotro or molnu, and those receiving sotro and molnu on the same day*
drop if sotrovimab_covid_therapeutics!=. & ( paxlovid_covid_therapeutics<=sotrovimab_covid_therapeutics| remdesivir_covid_therapeutics<=sotrovimab_covid_therapeutics| casirivimab_covid_therapeutics<=sotrovimab_covid_therapeutics)
drop if molnupiravir_covid_therapeutics!=. & ( paxlovid_covid_therapeutics<= molnupiravir_covid_therapeutics | remdesivir_covid_therapeutics<= molnupiravir_covid_therapeutics | casirivimab_covid_therapeutics<= molnupiravir_covid_therapeutics )
count if sotrovimab_covid_therapeutics!=. & molnupiravir_covid_therapeutics!=.
drop if sotrovimab_covid_therapeutics==molnupiravir_covid_therapeutics
*exclude those hospitalised after test positive and before treatment?


*define exposure*
describe
gen drug=1 if sotrovimab_covid_therapeutics==start_date
replace drug=0 if molnupiravir_covid_therapeutics ==start_date
label define drug 1 "sotrovimab" 0 "molnupiravia"
label values drug drug
tab drug,m


*correcting COVID hosp events: further ignore any day cases or sotro initiators who had COVID hosp record with mab procedure codes on Day 0 or 1 *
count if covid_hosp_outcome_date0!=start_date&covid_hosp_outcome_date0!=.
count if covid_hosp_outcome_date1!=(start_date+1)&covid_hosp_outcome_date1!=.
by drug, sort: count if covid_hosp_outcome_date0==covid_hosp_discharge_date0&covid_hosp_outcome_date0!=.
by drug, sort: count if covid_hosp_outcome_date1==covid_hosp_discharge_date1&covid_hosp_outcome_date1!=.
by drug, sort: count if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.
by drug, sort: count if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.
by drug, sort: count if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date0!=.&covid_hosp_outcome_date0==covid_hosp_discharge_date0
by drug, sort: count if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date1!=.&covid_hosp_outcome_date1==covid_hosp_discharge_date1
by drug, sort: count if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date0!=.&(covid_hosp_discharge_date0 - covid_hosp_outcome_date0)==1
by drug, sort: count if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date1!=.&(covid_hosp_discharge_date1 - covid_hosp_outcome_date1)==1
by drug, sort: count if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date0!=.&(covid_hosp_discharge_date0 - covid_hosp_outcome_date0)==2
by drug, sort: count if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date1!=.&(covid_hosp_discharge_date1 - covid_hosp_outcome_date1)==2
count if covid_hosp_outcome_date0==covid_hosp_discharge_date0&covid_hosp_outcome_date0!=.&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date1==covid_hosp_discharge_date1&covid_hosp_outcome_date1!=.&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date0!=.&covid_hosp_outcome_date0==covid_hosp_discharge_date0&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date1!=.&covid_hosp_outcome_date1==covid_hosp_discharge_date1&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
*check if any patient discharged in AM and admitted in PM*
count if covid_hosp_outcome_date0==covid_hosp_discharge_date0&covid_hosp_outcome_date0!=.&covid_hosp_outcome_date1==.&covid_hosp_outcome_date2==.&covid_hosp_discharge_date1!=.
count if covid_hosp_outcome_date1==covid_hosp_discharge_date1&covid_hosp_outcome_date1!=.&covid_hosp_outcome_date2==.&covid_hosp_discharge_date2!=.
count if covid_hosp_outcome_date2==.&covid_hosp_discharge_date2!=.
count if covid_hosp_outcome_date2!=.&covid_hosp_discharge_date2==.
count if covid_hosp_outcome_date2!=.&covid_hosp_outcome_date2>covid_hosp_discharge_date2
*ignore day cases and mab procedures in day 0/1*
replace covid_hosp_outcome_date0=. if covid_hosp_outcome_date0==covid_hosp_discharge_date0&covid_hosp_outcome_date0!=.
replace covid_hosp_outcome_date1=. if covid_hosp_outcome_date1==covid_hosp_discharge_date1&covid_hosp_outcome_date1!=.
replace covid_hosp_outcome_date0=. if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1
replace covid_hosp_outcome_date1=. if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1

gen covid_hospitalisation_outcome_da=covid_hosp_outcome_date2
replace covid_hospitalisation_outcome_da=covid_hosp_outcome_date1 if covid_hosp_outcome_date1!=.
replace covid_hospitalisation_outcome_da=covid_hosp_outcome_date0 if covid_hosp_outcome_date0!=.&drug==0
replace covid_hospitalisation_outcome_da=covid_hosp_outcome_date0 if covid_hosp_outcome_date0!=.&drug==1

gen days_to_covid_admission=covid_hospitalisation_outcome_da-start_date if covid_hospitalisation_outcome_da!=.
by drug days_to_covid_admission, sort: count if covid_hospitalisation_outcome_da!=.

by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2
by drug days_to_covid_admission, sort: count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2
by drug days_to_covid_admission, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date2!=.&covid_hosp_outcome_date2==covid_hosp_discharge_date2&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date2!=.&(covid_hosp_discharge_date2 - covid_hosp_outcome_date2)==1&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date2!=.&(covid_hosp_discharge_date2 - covid_hosp_outcome_date2)==2&days_to_covid_admission>=2
count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
by drug days_to_covid_admission, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
*ignore and censor day cases on or after day 2 from this analysis*
*ignore and censor admissions for mab procedure >= day 2 and with same-day or 1-day discharge*
gen covid_hosp_date_day_cases_mab=covid_hospitalisation_outcome_da if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2
replace covid_hosp_date_day_cases_mab=covid_hospitalisation_outcome_da if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2&(covid_hosp_discharge_date2-covid_hosp_outcome_date2)<=1&drug==1
replace covid_hospitalisation_outcome_da=. if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2
replace covid_hospitalisation_outcome_da=. if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2&(covid_hosp_discharge_date2-covid_hosp_outcome_date2)<=1&drug==1
*check hosp_admission_method*
tab covid_hosp_admission_method,m
tab drug covid_hosp_admission_method, row chi
*by drug days_to_covid_admission, sort: count if covid_hospitalisation_outcome_da!=covid_hosp_date_emergency&covid_hospitalisation_outcome_da!=.
*capture and exclude COVID-hospital admission/death on the start date
count if start_date==covid_hospitalisation_outcome_da| start_date==death_with_covid_on_the_death_ce
drop if start_date>=covid_hospitalisation_outcome_da| start_date>=death_with_covid_on_the_death_ce|start_date>=death_date|start_date>=dereg_date

*count recorded day cases or regulars*
by drug, sort: count if covid_hosp_outcome_date0==.&covid_hosp_outcome_day_date0==start_date
by drug, sort: count if covid_hosp_outcome_date1==.&covid_hosp_outcome_day_date1==start_date+1
by drug, sort: count if covid_hosp_outcome_date2>covid_hosp_outcome_day_date2
by drug, sort: count if covid_hosp_outcome_date0==.&covid_hosp_outcome_day_date0==start_date&(covid_hosp_discharge_day_date0-covid_hosp_outcome_day_date0)==0
by drug, sort: count if covid_hosp_outcome_date1==.&covid_hosp_outcome_day_date1==start_date+1&(covid_hosp_discharge_day_date1-covid_hosp_outcome_day_date1)==0
by drug, sort: count if covid_hosp_outcome_date2>covid_hosp_outcome_day_date2&(covid_hosp_discharge_day_date2-covid_hosp_outcome_day_date2)==0
by drug, sort: count if covid_hosp_outcome_date0==.&covid_hosp_outcome_day_date0==start_date&(covid_hosp_discharge_day_date0-covid_hosp_outcome_day_date0)==1
by drug, sort: count if covid_hosp_outcome_date1==.&covid_hosp_outcome_day_date1==start_date+1&(covid_hosp_discharge_day_date1-covid_hosp_outcome_day_date1)==1
by drug, sort: count if covid_hosp_outcome_date2>covid_hosp_outcome_day_date2&(covid_hosp_discharge_day_date2-covid_hosp_outcome_day_date2)==1
by drug, sort: count if covid_hosp_outcome_date0==.&covid_hosp_outcome_day_date0==start_date&covid_hosp_outcome_day_date0==covid_hosp_date_mabs_day
by drug, sort: count if covid_hosp_outcome_date1==.&covid_hosp_outcome_day_date1==start_date+1&covid_hosp_outcome_day_date1==covid_hosp_date_mabs_day
by drug, sort: count if covid_hosp_outcome_date2>covid_hosp_outcome_day_date2&covid_hosp_outcome_day_date2==covid_hosp_date_mabs_day

count if covid_hosp_outcome_date0==.&covid_hosp_outcome_day_date0==start_date&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date1==.&covid_hosp_outcome_day_date1==start_date+1&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date2>covid_hosp_outcome_day_date2&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date0==.&covid_hosp_outcome_day_date0==start_date&covid_hosp_outcome_day_date0==covid_hosp_date_mabs_day&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date1==.&covid_hosp_outcome_day_date1==start_date+1&covid_hosp_outcome_day_date1==covid_hosp_date_mabs_day&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date2>covid_hosp_outcome_day_date2&covid_hosp_outcome_day_date2==covid_hosp_date_mabs_day&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.


*define outcome and follow-up time*
gen study_end_date=mdy(06,10,2022)
gen start_date_29=start_date+28
by drug, sort: count if covid_hospitalisation_outcome_da!=.
by drug, sort: count if death_with_covid_on_the_death_ce!=.
by drug, sort: count if covid_hospitalisation_outcome_da==.&death_with_covid_on_the_death_ce!=.
by drug, sort: count if death_with_covid_on_the_death_ce==.&covid_hospitalisation_outcome_da!=.
*primary outcome*
gen event_date=min( covid_hospitalisation_outcome_da, death_with_covid_on_the_death_ce )
gen failure=(event_date!=.&event_date<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure=(event_date!=.&event_date<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure,m
gen end_date=event_date if failure==1
replace end_date=min(death_date, dereg_date, study_end_date, start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,covid_hosp_date_day_cases_mab) if failure==0&drug==1
replace end_date=min(death_date, dereg_date, study_end_date, start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,covid_hosp_date_day_cases_mab) if failure==0&drug==0
format %td event_date end_date study_end_date start_date_29

stset end_date ,  origin(start_date) failure(failure==1)
stcox drug

*secondary outcome: within 2 months*
gen start_date_2m=start_date+60
gen failure_2m=(event_date!=.&event_date<=min(study_end_date,start_date_2m,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_2m=(event_date!=.&event_date<=min(study_end_date,start_date_2m,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_2m,m
gen end_date_2m=event_date if failure_2m==1
replace end_date_2m=min(death_date, dereg_date, study_end_date, start_date_2m,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,covid_hosp_date_day_cases_mab) if failure_2m==0&drug==1
replace end_date_2m=min(death_date, dereg_date, study_end_date, start_date_2m,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,covid_hosp_date_day_cases_mab) if failure_2m==0&drug==0
format %td end_date_2m start_date_2m

stset end_date_2m ,  origin(start_date) failure(failure_2m==1)
stcox drug

*secondary outcome: within 3 months*
gen start_date_3m=start_date+90
gen failure_3m=(event_date!=.&event_date<=min(study_end_date,start_date_3m,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_3m=(event_date!=.&event_date<=min(study_end_date,start_date_3m,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_3m,m
gen end_date_3m=event_date if failure_3m==1
replace end_date_3m=min(death_date, dereg_date, study_end_date, start_date_3m,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,covid_hosp_date_day_cases_mab) if failure_3m==0&drug==1
replace end_date_3m=min(death_date, dereg_date, study_end_date, start_date_3m,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,covid_hosp_date_day_cases_mab) if failure_3m==0&drug==0
format %td end_date_3m start_date_3m

stset end_date_3m ,  origin(start_date) failure(failure_3m==1)
stcox drug

*secondary outcome: all-cause hosp/death within 29 days*
*correct all cause hosp date *
count if hospitalisation_outcome_date0!=start_date&hospitalisation_outcome_date0!=.
count if hospitalisation_outcome_date1!=(start_date+1)&hospitalisation_outcome_date1!=.
by drug, sort: count if hospitalisation_outcome_date0==hosp_discharge_date0&hospitalisation_outcome_date0!=.
by drug, sort: count if hospitalisation_outcome_date1==hosp_discharge_date1&hospitalisation_outcome_date1!=.
by drug, sort: count if hospitalisation_outcome_date0==covid_hosp_date_mabs_all_cause&covid_hosp_date_mabs_all_cause!=.
by drug, sort: count if hospitalisation_outcome_date1==covid_hosp_date_mabs_all_cause&covid_hosp_date_mabs_all_cause!=.
by drug, sort: count if hospitalisation_outcome_date0==covid_hosp_date_mabs_all_cause&hospitalisation_outcome_date0==hosp_discharge_date0&hospitalisation_outcome_date0!=.
by drug, sort: count if hospitalisation_outcome_date1==covid_hosp_date_mabs_all_cause&hospitalisation_outcome_date1==hosp_discharge_date1&hospitalisation_outcome_date1!=.
replace hospitalisation_outcome_date0=. if hospitalisation_outcome_date0==hosp_discharge_date0&hospitalisation_outcome_date0!=.
replace hospitalisation_outcome_date1=. if hospitalisation_outcome_date1==hosp_discharge_date1&hospitalisation_outcome_date1!=.
replace hospitalisation_outcome_date0=. if hospitalisation_outcome_date0==covid_hosp_date_mabs_all_cause&covid_hosp_date_mabs_all_cause!=.&drug==1
replace hospitalisation_outcome_date1=. if hospitalisation_outcome_date1==covid_hosp_date_mabs_all_cause&covid_hosp_date_mabs_all_cause!=.&drug==1

gen hospitalisation_outcome_date=hospitalisation_outcome_date2
replace hospitalisation_outcome_date=hospitalisation_outcome_date1 if hospitalisation_outcome_date1!=.
replace hospitalisation_outcome_date=hospitalisation_outcome_date0 if hospitalisation_outcome_date0!=.&drug==0
replace hospitalisation_outcome_date=hospitalisation_outcome_date0 if hospitalisation_outcome_date0!=.&drug==1

gen days_to_any_hosp_admission=hospitalisation_outcome_date-start_date if hospitalisation_outcome_date!=.
by drug days_to_any_hosp_admission, sort: count if hospitalisation_outcome_date!=.
by drug, sort: count if hospitalisation_outcome_date2==hosp_discharge_date2&hospitalisation_outcome_date2!=.&days_to_any_hosp_admission>=2
by drug days_to_any_hosp_admission, sort: count if hospitalisation_outcome_date2==hosp_discharge_date2&hospitalisation_outcome_date2!=.&days_to_any_hosp_admission>=2
by drug, sort: count if hospitalisation_outcome_date2==covid_hosp_date_mabs_all_cause&covid_hosp_date_mabs_all_cause!=.&days_to_any_hosp_admission>=2
by drug days_to_any_hosp_admission, sort: count if hospitalisation_outcome_date2==covid_hosp_date_mabs_all_cause&covid_hosp_date_mabs_all_cause!=.&days_to_any_hosp_admission>=2
by drug, sort: count if hospitalisation_outcome_date2==hosp_discharge_date2&hospitalisation_outcome_date2!=.&hospitalisation_outcome_date2==covid_hosp_date_mabs_all_cause&days_to_any_hosp_admission>=2
by drug, sort: count if hospitalisation_outcome_date2==covid_hosp_date_mabs_all_cause&hospitalisation_outcome_date2!=.&(hosp_discharge_date2 - hospitalisation_outcome_date2)==1&days_to_any_hosp_admission>=2
by drug, sort: count if hospitalisation_outcome_date2==covid_hosp_date_mabs_all_cause&hospitalisation_outcome_date2!=.&(hosp_discharge_date2 - hospitalisation_outcome_date2)==2&days_to_any_hosp_admission>=2
*ignore and censor day cases on or after day 2 from this analysis*
*ignore and censor admissions for mab procedure >= day 2 and with same-day or 1-day discharge*
gen hosp_date_day_cases_mab=hospitalisation_outcome_date if hospitalisation_outcome_date2==hosp_discharge_date2&hospitalisation_outcome_date2!=.&hospitalisation_outcome_date0==.&hospitalisation_outcome_date1==.
replace hosp_date_day_cases_mab=hospitalisation_outcome_date if hospitalisation_outcome_date2==covid_hosp_date_mabs_all_cause&covid_hosp_date_mabs_all_cause!=.&drug==1&(hosp_discharge_date2-hospitalisation_outcome_date2)<=1&hospitalisation_outcome_date0==.&hospitalisation_outcome_date1==.
replace hospitalisation_outcome_date=. if hospitalisation_outcome_date2==hosp_discharge_date2&hospitalisation_outcome_date2!=.&hospitalisation_outcome_date0==.&hospitalisation_outcome_date1==.
replace hospitalisation_outcome_date=. if hospitalisation_outcome_date2==covid_hosp_date_mabs_all_cause&covid_hosp_date_mabs_all_cause!=.&drug==1&(hosp_discharge_date2-hospitalisation_outcome_date2)<=1&hospitalisation_outcome_date0==.&hospitalisation_outcome_date1==.

gen event_date_allcause=min( death_date, hospitalisation_outcome_date,covid_hospitalisation_outcome_da )
gen failure_allcause=(event_date_allcause!=.&event_date_allcause<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_allcause=(event_date_allcause!=.&event_date_allcause<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_allcause,m
gen end_date_allcause=event_date_allcause if failure_allcause==1
replace end_date_allcause=min(death_date, dereg_date, study_end_date, start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,hosp_date_day_cases_mab) if failure_allcause==0&drug==1
replace end_date_allcause=min(death_date, dereg_date, study_end_date, start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,hosp_date_day_cases_mab) if failure_allcause==0&drug==0
format %td event_date_allcause end_date_allcause  

stset end_date_allcause ,  origin(start_date) failure(failure_allcause==1)
stcox drug

*exploratory analysis for primary outcome: only emergency admissions, ignore non-emergency admissions*
*correct hosp date*
count if covid_hosp_date_emergency0!=start_date&covid_hosp_date_emergency0!=.
count if covid_hosp_date_emergency1!=(start_date+1)&covid_hosp_date_emergency1!=.
by drug, sort: count if covid_hosp_date_emergency0==covid_emerg_discharge_date0&covid_hosp_date_emergency0!=.
by drug, sort: count if covid_hosp_date_emergency1==covid_emerg_discharge_date1&covid_hosp_date_emergency1!=.
by drug, sort: count if covid_hosp_date_emergency0==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.
by drug, sort: count if covid_hosp_date_emergency1==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.
by drug, sort: count if covid_hosp_date_emergency0==covid_hosp_date_mabs_procedure&covid_hosp_date_emergency0==covid_emerg_discharge_date0&covid_hosp_date_emergency0!=.
by drug, sort: count if covid_hosp_date_emergency1==covid_hosp_date_mabs_procedure&covid_hosp_date_emergency1==covid_emerg_discharge_date1&covid_hosp_date_emergency1!=.
replace covid_hosp_date_emergency0=. if covid_hosp_date_emergency0==covid_emerg_discharge_date0&covid_hosp_date_emergency0!=.
replace covid_hosp_date_emergency1=. if covid_hosp_date_emergency1==covid_emerg_discharge_date1&covid_hosp_date_emergency1!=.
replace covid_hosp_date_emergency0=. if covid_hosp_date_emergency0==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1
replace covid_hosp_date_emergency1=. if covid_hosp_date_emergency1==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1

gen covid_hosp_date_emergency=covid_hosp_date_emergency2
replace covid_hosp_date_emergency=covid_hosp_date_emergency1 if covid_hosp_date_emergency1!=.
replace covid_hosp_date_emergency=covid_hosp_date_emergency0 if covid_hosp_date_emergency0!=.
*ignore and censor day cases on or after day 2 from this analysis*
*ignore and censor admissions for mab procedure >= day 2 and with same-day or 1-day discharge*
gen hosp_emergency_day_cases_mab=covid_hosp_date_emergency if covid_hosp_date_emergency2==covid_emerg_discharge_date2&covid_hosp_date_emergency2!=.&covid_hosp_date_emergency0==.&covid_hosp_date_emergency1==.
replace hosp_emergency_day_cases_mab=covid_hosp_date_emergency if covid_hosp_date_emergency2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1&(covid_emerg_discharge_date2-covid_hosp_date_emergency2)<=1&covid_hosp_date_emergency0==.&covid_hosp_date_emergency1==.
replace covid_hosp_date_emergency=. if covid_hosp_date_emergency2==covid_emerg_discharge_date2&covid_hosp_date_emergency2!=.&covid_hosp_date_emergency0==.&covid_hosp_date_emergency1==.
replace covid_hosp_date_emergency=. if covid_hosp_date_emergency2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1&(covid_emerg_discharge_date2-covid_hosp_date_emergency2)<=1&covid_hosp_date_emergency0==.&covid_hosp_date_emergency1==.

gen event_date_emergency=min( covid_hosp_date_emergency, death_with_covid_on_the_death_ce )
gen failure_emergency=(event_date_emergency!=.&event_date_emergency<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_emergency=(event_date_emergency!=.&event_date_emergency<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_emergency,m
gen end_date_emergency=event_date_emergency if failure_emergency==1
replace end_date_emergency=min(death_date, dereg_date, study_end_date, start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,hosp_emergency_day_cases_mab) if failure_emergency==0&drug==1
replace end_date_emergency=min(death_date, dereg_date, study_end_date, start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,hosp_emergency_day_cases_mab) if failure_emergency==0&drug==0
format %td event_date_emergency end_date_emergency  

stset end_date_emergency ,  origin(start_date) failure(failure_emergency==1)
stcox drug

*exploratory analysis for primary outcome: not require covid as primary diagnosis*
*correct hosp date*
count if covid_hosp_date0_not_primary!=start_date&covid_hosp_date0_not_primary!=.
count if covid_hosp_date1_not_primary!=(start_date+1)&covid_hosp_date1_not_primary!=.
by drug, sort: count if covid_hosp_date0_not_primary==covid_discharge_date0_not_pri&covid_hosp_date0_not_primary!=.
by drug, sort: count if covid_hosp_date1_not_primary==covid_discharge_date1_not_pri&covid_hosp_date1_not_primary!=.
by drug, sort: count if covid_hosp_date0_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date_mabs_not_pri!=.
by drug, sort: count if covid_hosp_date1_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date_mabs_not_pri!=.
by drug, sort: count if covid_hosp_date0_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date0_not_primary==covid_discharge_date0_not_pri&covid_hosp_date0_not_primary!=.
by drug, sort: count if covid_hosp_date1_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date1_not_primary==covid_discharge_date1_not_pri&covid_hosp_date1_not_primary!=.
replace covid_hosp_date0_not_primary=. if covid_hosp_date0_not_primary==covid_discharge_date0_not_pri&covid_hosp_date0_not_primary!=.
replace covid_hosp_date1_not_primary=. if covid_hosp_date1_not_primary==covid_discharge_date1_not_pri&covid_hosp_date1_not_primary!=.
replace covid_hosp_date0_not_primary=. if covid_hosp_date0_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date_mabs_not_pri!=.&drug==1
replace covid_hosp_date1_not_primary=. if covid_hosp_date1_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date_mabs_not_pri!=.&drug==1

gen covid_hosp_date_not_primary=covid_hosp_date2_not_primary
replace covid_hosp_date_not_primary=covid_hosp_date1_not_primary if covid_hosp_date1_not_primary!=.
replace covid_hosp_date_not_primary=covid_hosp_date0_not_primary if covid_hosp_date0_not_primary!=.&drug==0
replace covid_hosp_date_not_primary=covid_hosp_date0_not_primary if covid_hosp_date0_not_primary!=.&drug==1

gen days_to_covid_adm_not_pri=covid_hosp_date_not_primary-start_date if covid_hosp_date2_not_primary!=.
by drug days_to_covid_adm_not_pri, sort: count if covid_hosp_date_not_primary!=.
by drug, sort: count if covid_hosp_date2_not_primary==covid_discharge_date2_not_pri&covid_hosp_date2_not_primary!=.&days_to_covid_adm_not_pri>=2
by drug days_to_covid_adm_not_pri, sort: count if covid_hosp_date2_not_primary==covid_discharge_date2_not_pri&covid_hosp_date2_not_primary!=.&days_to_covid_adm_not_pri>=2
by drug, sort: count if covid_hosp_date2_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date_mabs_not_pri!=.&days_to_covid_adm_not_pri>=2
by drug days_to_covid_adm_not_pri, sort: count if covid_hosp_date2_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date_mabs_not_pri!=.&days_to_covid_adm_not_pri>=2
by drug, sort: count if covid_hosp_date2_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date2_not_primary!=.&covid_hosp_date2_not_primary==covid_discharge_date2_not_pri&days_to_covid_adm_not_pri>=2
by drug, sort: count if covid_hosp_date2_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date2_not_primary!=.&(covid_discharge_date2_not_pri - covid_hosp_date2_not_primary)==1&days_to_covid_adm_not_pri>=2
by drug, sort: count if covid_hosp_date2_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date2_not_primary!=.&(covid_discharge_date2_not_pri - covid_hosp_date2_not_primary)==2&days_to_covid_adm_not_pri>=2
*ignore and censor day cases on or after day 2 from this analysis*
*ignore and censor admissions for mab procedure >= day 2 and with same-day or 1-day discharge*
gen covid_day_cases_mab_not_pri=covid_hosp_date_not_primary if covid_hosp_date2_not_primary==covid_discharge_date2_not_pri&covid_hosp_date2_not_primary!=.&covid_hosp_date0_not_primary==.&covid_hosp_date1_not_primary==.
replace covid_day_cases_mab_not_pri=covid_hosp_date_not_primary if covid_hosp_date2_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date_mabs_not_pri!=.&drug==1&covid_hosp_date0_not_primary==.&covid_hosp_date1_not_primary==.&(covid_discharge_date2_not_pri-covid_hosp_date2_not_primary)<=1
replace covid_hosp_date_not_primary=. if covid_hosp_date2_not_primary==covid_discharge_date2_not_pri&covid_hosp_date2_not_primary!=.&covid_hosp_date0_not_primary==.&covid_hosp_date1_not_primary==.
replace covid_hosp_date_not_primary=. if covid_hosp_date2_not_primary==covid_hosp_date_mabs_not_pri&covid_hosp_date_mabs_not_pri!=.&drug==1&covid_hosp_date0_not_primary==.&covid_hosp_date1_not_primary==.&(covid_discharge_date2_not_pri-covid_hosp_date2_not_primary)<=1

gen event_date_not_primary=min( covid_hosp_date_not_primary, death_with_covid_on_the_death_ce,covid_hospitalisation_outcome_da )
gen failure_not_primary=(event_date_not_primary!=.&event_date_not_primary<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_not_primary=(event_date_not_primary!=.&event_date_not_primary<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_not_primary,m
gen end_date_not_primary=event_date_not_primary if failure_not_primary==1
replace end_date_not_primary=min(death_date, dereg_date, study_end_date, start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,covid_day_cases_mab_not_pri) if failure_not_primary==0&drug==1
replace end_date_not_primary=min(death_date, dereg_date, study_end_date, start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics,covid_day_cases_mab_not_pri) if failure_not_primary==0&drug==0
format %td event_date_not_primary end_date_not_primary  

stset end_date_not_primary ,  origin(start_date) failure(failure_not_primary==1)
stcox drug

*count covid death during day1-28 and before censor*
count if failure==1&drug==1&death_with_covid_on_the_death_ce<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)
count if failure==1&drug==0&death_with_covid_on_the_death_ce<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)
count if failure==1&drug==1&death_with_covid_underlying_date<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)
count if failure==1&drug==0&death_with_covid_underlying_date<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)
*count covid hosp during day1-28 and before censor*
by drug, sort: count if failure==1&covid_hospitalisation_outcome_da==end_date
*count covid death after covid hosp during day1-28 and before censor*
count if failure==1&covid_hospitalisation_outcome_da==end_date&drug==1&death_with_covid_on_the_death_ce>=covid_hospitalisation_outcome_da&death_with_covid_on_the_death_ce<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)
count if failure==1&covid_hospitalisation_outcome_da==end_date&drug==0&death_with_covid_on_the_death_ce>=covid_hospitalisation_outcome_da&death_with_covid_on_the_death_ce<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)
count if failure==1&covid_hospitalisation_outcome_da==end_date&drug==1&death_with_covid_underlying_date>=covid_hospitalisation_outcome_da&death_with_covid_underlying_date<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)
count if failure==1&covid_hospitalisation_outcome_da==end_date&drug==0&death_with_covid_underlying_date>=covid_hospitalisation_outcome_da&death_with_covid_underlying_date<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)
*count critical care within day1-28*
tab drug covid_hospitalisation_critical_c,m row
tab drug covid_hospitalisation_critical_c if failure==1&covid_hospitalisation_outcome_da==end_date,m row




*covariates* 
*10 high risk groups: downs_syndrome, solid_cancer, haematological_disease, renal_disease, liver_disease, imid, 
*immunosupression, hiv_aids, solid_organ_transplant, rare_neurological_conditions, high_risk_group_combined	
tab high_risk_cohort_covid_therapeut,m
gen downs_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "Downs syndrome")
gen solid_cancer_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "solid cancer")
gen haema_disease_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "haematological malignancies")
replace haema_disease_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "sickle cell disease")
replace haema_disease_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "haematological diseases")
replace haema_disease_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "stem cell transplant")
gen renal_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "renal disease")
gen liver_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "liver disease")
gen imid_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "IMID")
gen immunosup_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "primary immune deficiencies")
gen hiv_aids_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "HIV or AIDS")
gen solid_organ_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "solid organ recipients")
replace solid_organ_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "solid organ transplant")
gen rare_neuro_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "rare neurological conditions")

replace oral_steroid_drugs_nhsd=. if oral_steroid_drug_nhsd_3m_count < 2 & oral_steroid_drug_nhsd_12m_count < 4
gen imid_nhsd=min(oral_steroid_drugs_nhsd, immunosuppresant_drugs_nhsd)
gen rare_neuro_nhsd = min(multiple_sclerosis_nhsd, motor_neurone_disease_nhsd, myasthenia_gravis_nhsd, huntingtons_disease_nhsd)

gen downs_syndrome=(downs_syndrome_nhsd<=start_date|downs_therapeutics==1)
gen solid_cancer=(cancer_opensafely_snomed<=start_date|solid_cancer_therapeutics==1)
gen haema_disease=( haematological_disease_nhsd <=start_date|haema_disease_therapeutics==1)
gen renal_disease=( ckd_stage_5_nhsd <=start_date|renal_therapeutics==1)
gen liver_disease=( liver_disease_nhsd <=start_date|liver_therapeutics==1)
gen imid=( imid_nhsd <=start_date|imid_therapeutics==1)
gen immunosupression=( immunosupression_nhsd <=start_date|immunosup_therapeutics==1)
gen hiv_aids=( hiv_aids_nhsd <=start_date|hiv_aids_therapeutics==1)
gen solid_organ=( solid_organ_transplant_nhsd<=start_date|solid_organ_therapeutics==1)
gen rare_neuro=( rare_neuro_nhsd <=start_date|rare_neuro_therapeutics==1)
gen high_risk_group=(( downs_syndrome + solid_cancer + haema_disease + renal_disease + liver_disease + imid + immunosupression + hiv_aids + solid_organ + rare_neuro )>0)
tab high_risk_group,m

*Time between positive test and treatment*
gen d_postest_treat=start_date - covid_test_positive_date
tab d_postest_treat,m
replace d_postest_treat=. if d_postest_treat<0|d_postest_treat>7
gen d_postest_treat_g2=(d_postest_treat>=3) if d_postest_treat<=5
label define d_postest_treat_g2 0 "<3 days" 1 "3-5 days" 
label values d_postest_treat_g2 d_postest_treat_g2
gen d_postest_treat_missing=d_postest_treat_g2
replace d_postest_treat_missing=9 if d_postest_treat_g2==.
label define d_postest_treat_missing 0 "<3 days" 1 "3-5 days" 9 "missing" 
label values d_postest_treat_missing d_postest_treat_missing
*demo*
gen age_group3=(age>=40)+(age>=60)
label define age_group3 0 "18-39" 1 "40-59" 2 ">=60" 
label values age_group3 age_group3
tab age_group3,m
egen age_5y_band=cut(age), at(18,25,30,35,40,45,50,55,60,65,70,75,80,85,110) label
tab age_5y_band,m
mkspline age_spline = age, cubic nknots(4)
gen age_50=(age>=50)
gen age_55=(age>=55)
gen age_60=(age>=60)

tab sex,m
rename sex sex_str
gen sex=0 if sex_str=="M"
replace sex=1 if sex_str=="F"
label define sex 0 "Male" 1 "Female"
label values sex sex

tab ethnicity,m
rename ethnicity ethnicity_with_missing_str
encode  ethnicity_with_missing_str ,gen(ethnicity_with_missing)
label list ethnicity_with_missing
gen ethnicity=ethnicity_with_missing
replace ethnicity=. if ethnicity_with_missing_str=="Missing"
label values ethnicity ethnicity_with_missing
gen White=1 if ethnicity==6
replace White=0 if ethnicity!=6&ethnicity!=.

tab imd,m
replace imd=. if imd==0
label define imd 1 "most deprived" 5 "least deprived"
label values imd imd
gen imd_with_missing=imd
replace imd_with_missing=9 if imd==.

tab region_nhs,m
rename region_nhs region_nhs_str 
encode  region_nhs_str ,gen(region_nhs)
label list region_nhs

tab region_covid_therapeutics ,m
rename region_covid_therapeutics region_covid_therapeutics_str
encode  region_covid_therapeutics_str ,gen( region_covid_therapeutics )
label list region_covid_therapeutics

tab stp ,m
rename stp stp_str
encode  stp_str ,gen(stp)
label list stp
*combine stps with low N (<100) as "Other"*
by stp, sort: gen stp_N=_N if stp!=.
replace stp=99 if stp_N<100
tab stp ,m

tab rural_urban,m
*comor*
tab autism_nhsd,m
tab care_home_primis,m
tab dementia_nhsd,m
tab housebound_opensafely,m
tab learning_disability_primis,m
tab serious_mental_illness_nhsd,m
sum bmi,de
replace bmi=. if bmi<10|bmi>60
rename bmi bmi_all
*latest BMI within recent 10 years*
gen bmi=bmi_all if bmi_date_measured!=.&bmi_date_measured>=start_date-365*10&(age+((bmi_date_measured-start_date)/365)>=18)
gen bmi_5y=bmi_all if bmi_date_measured!=.&bmi_date_measured>=start_date-365*5&(age+((bmi_date_measured-start_date)/365)>=18)
gen bmi_2y=bmi_all if bmi_date_measured!=.&bmi_date_measured>=start_date-365*2&(age+((bmi_date_measured-start_date)/365)>=18)
gen bmi_group4=(bmi>=18.5)+(bmi>=25.0)+(bmi>=30.0) if bmi!=.
label define bmi 0 "underweight" 1 "normal" 2 "overweight" 3 "obese"
label values bmi_group4 bmi
gen bmi_g4_with_missing=bmi_group4
replace bmi_g4_with_missing=9 if bmi_group4==.
gen bmi_g3=bmi_group4
replace bmi_g3=1 if bmi_g3==0
label values bmi_g3 bmi
gen bmi_25=(bmi>=25) if bmi!=.
gen bmi_30=(bmi>=30) if bmi!=.

tab diabetes,m
tab chronic_cardiac_disease,m
tab hypertension,m
tab chronic_respiratory_disease,m
*vac and variant*
tab vaccination_status,m
rename vaccination_status vaccination_status_g5
gen vaccination_status=0 if vaccination_status_g5=="Un-vaccinated"|vaccination_status_g5=="Un-vaccinated (declined)"
replace vaccination_status=1 if vaccination_status_g5=="One vaccination"
replace vaccination_status=2 if vaccination_status_g5=="Two vaccinations"
replace vaccination_status=3 if vaccination_status_g5=="Three or more vaccinations"
label define vac 0 "Un-vaccinated" 1 "One vaccination" 2 "Two vaccinations" 3 "Three or more vaccinations"
label values vaccination_status vac
gen vaccination_3=1 if vaccination_status==3
replace vaccination_3=0 if vaccination_status<3
tab sgtf,m
tab sgtf_new, m
label define sgtf_new 0 "S gene detected" 1 "confirmed SGTF" 9 "NA"
label values sgtf_new sgtf_new
tab variant_recorded ,m
*tab sgtf variant_recorded ,m
by sgtf, sort: tab variant_recorded ,m
*Time between last vaccination and treatment*
gen d_vaccinate_treat=start_date - last_vaccination_date
sum d_vaccinate_treat,de
gen month_after_vaccinate=ceil(d_vaccinate_treat/30)
tab month_after_vaccinate,m
gen week_after_vaccinate=ceil(d_vaccinate_treat/7)
tab week_after_vaccinate,m
*combine month5-13 due to small N*
replace month_after_vaccinate=5 if month_after_vaccinate>=5&month_after_vaccinate!=.
gen month_after_vaccinate_missing=month_after_vaccinate
replace month_after_vaccinate_missing=99 if month_after_vaccinate_missing==.
*calendar time*
gen month_after_campaign=ceil((start_date-mdy(12,15,2021))/30)
tab month_after_campaign,m
gen week_after_campaign=ceil((start_date-mdy(12,15,2021))/7)
tab week_after_campaign,m
*combine 8 and 9 due to small N*
*replace week_after_campaign=8 if week_after_campaign==9


*descriptives by drug groups*
by drug,sort: sum age,de
ttest age , by( drug )
by drug,sort: sum bmi,de
ttest bmi, by( drug )
sum d_postest_treat ,de
by drug,sort: sum d_postest_treat ,de
ttest d_postest_treat , by( drug )
ranksum d_postest_treat,by(drug)
sum week_after_campaign,de
by drug,sort: sum week_after_campaign,de
ttest week_after_campaign , by( drug )
ranksum week_after_campaign,by(drug)
sum week_after_vaccinate,de
by drug,sort: sum week_after_vaccinate,de
ttest week_after_vaccinate , by( drug )
ranksum week_after_vaccinate,by(drug)
sum d_vaccinate_treat,de
by drug,sort: sum d_vaccinate_treat,de
ttest d_vaccinate_treat , by( drug )
ranksum d_vaccinate_treat,by(drug)

tab drug sex,row chi
tab drug ethnicity,row chi
tab drug imd,row chi
ranksum imd,by(drug)
tab drug region_nhs,row chi
tab drug region_covid_therapeutics,row chi
*need to address the error of "too many values"*
tab stp if drug==0
tab stp if drug==1
tab drug age_group3 ,row chi
tab drug d_postest_treat_g2 ,row chi
tab drug d_postest_treat ,row
tab drug downs_syndrome ,row chi
tab drug solid_cancer ,row chi
tab drug haema_disease ,row chi
tab drug renal_disease ,row chi
tab drug liver_disease ,row chi
tab drug imid ,row chi
tab drug immunosupression ,row chi
tab drug hiv_aids ,row chi
tab drug solid_organ ,row chi
tab drug rare_neuro ,row chi
tab drug high_risk_group ,row chi
tab drug autism_nhsd ,row chi
tab drug care_home_primis ,row chi
tab drug dementia_nhsd ,row chi
tab drug housebound_opensafely ,row chi
tab drug learning_disability_primis ,row chi
tab drug serious_mental_illness_nhsd ,row chi
tab drug bmi_group4 ,row chi
tab drug diabetes ,row chi
tab drug chronic_cardiac_disease ,row chi
tab drug hypertension ,row chi
tab drug chronic_respiratory_disease ,row chi
tab drug vaccination_status ,row chi
tab drug month_after_vaccinate,row chi
tab drug sgtf ,row chi
tab drug sgtf_new ,row chi
*tab drug variant_recorded ,row chi
by drug, sort: tab variant_recorded

*check treatment status*
count if drug==0&molnupiravir_covid_therapeutics==molnupiravir_covid_approved
count if drug==0&molnupiravir_covid_therapeutics==molnupiravir_covid_complete
count if drug==0&molnupiravir_covid_therapeutics==molnupiravir_covid_not_start
count if drug==0&molnupiravir_covid_therapeutics==molnupiravir_covid_stopped
count if drug==0&molnupiravir_covid_approved!=.
count if drug==0&molnupiravir_covid_complete!=.
count if drug==0&molnupiravir_covid_not_start!=.
count if drug==0&molnupiravir_covid_stopped!=.
count if drug==1&sotrovimab_covid_therapeutics==sotrovimab_covid_approved
count if drug==1&sotrovimab_covid_therapeutics==sotrovimab_covid_complete
count if drug==1&sotrovimab_covid_therapeutics==sotrovimab_covid_not_start
count if drug==1&sotrovimab_covid_therapeutics==sotrovimab_covid_stopped
count if drug==1&sotrovimab_covid_approved!=.
count if drug==1&sotrovimab_covid_complete!=.
count if drug==1&sotrovimab_covid_not_start!=.
count if drug==1&sotrovimab_covid_stopped!=.


save ./output/main.dta, replace

log close




