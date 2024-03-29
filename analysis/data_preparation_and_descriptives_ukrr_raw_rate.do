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
log using ./logs/data_preparation_ukrr_raw_rate, replace t
clear

* import dataset
import delimited ./output/ukrr/input_ukrr.csv, delimiter(comma) varnames(1) case(preserve) 
*describe

*describe ukrr cohorts*
tab ukrr_2020,m
tab ukrr_2021,m
tab ukrr_ckd2020,m
tab ukrr_inc2020,m
tab ukrr_2021 ukrr_2020, row 
tab ukrr_2021 ukrr_ckd2020, row 
tab ukrr_2021 ukrr_inc2020, row 
tab ukrr_2020 ukrr_ckd2020,row
tab ukrr_inc2020 ukrr_ckd2020,row
tab ukrr_2020 ukrr_inc2020,row
*keep ukrr 2021 prevalent cohort*


keep if registered_eligible==1

*  Convert strings to dates  *
foreach var of varlist sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics paxlovid_covid_therapeutics remdesivir_covid_therapeutics	///
        casirivimab_covid_therapeutics sotrovimab_covid_approved sotrovimab_covid_complete sotrovimab_covid_not_start sotrovimab_covid_stopped ///
		molnupiravir_covid_approved molnupiravir_covid_complete molnupiravir_covid_not_start molnupiravir_covid_stopped ///
        covid_test_positive_date covid_test_positive_date2 covid_symptoms_snomed last_vaccination_date primary_covid_hospital_discharge ///
	   primary_covid_hospital_admission any_covid_hospital_discharge_dat preg_36wks_date death_date dereg_date downs_syndrome_nhsd_snomed downs_syndrome_nhsd_icd10 cancer_opensafely_snomed cancer_opensafely_snomed_new ///
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

*check hosp/death event date range*
codebook covid_hosp_outcome_date2 hospitalisation_outcome_date2 death_date


*describe COVID therapy*
tab covid_test_positive,m
gen treated=(date_treated!=.)
tab covid_test_positive treated,m row 
tab covid_test_positive treated if date_treated>=mdy(12,16,2021),m row 
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
*keep if treated==1

*exclusion criteria*
sum age,de
keep if age>=18 & age<110
tab sex,m
keep if sex=="F"|sex=="M"
*keep if has_died==0
*keep if registered_treated==1
tab covid_test_positive covid_positive_previous_30_days,m
keep if (covid_test_positive==1 & covid_positive_previous_30_days==0)|treated==1
*restrict start_date to 2021Dec16 to 2022Feb10*
*loose this restriction to increase N?*
replace start_date=covid_test_positive_date if start_date==.
keep if start_date>=mdy(12,16,2021)&start_date<=mdy(09,01,2022)
*drop if region_nhs==""
*exclude those with multiple therapy*
drop if sotrovimab_covid_therapeutics!=. & ( molnupiravir_covid_therapeutics!=.| remdesivir_covid_therapeutics!=.| casirivimab_covid_therapeutics!=.|paxlovid_covid_therapeutics!=.)
drop if paxlovid_covid_therapeutics!=. & (  molnupiravir_covid_therapeutics!=.| remdesivir_covid_therapeutics!=.| casirivimab_covid_therapeutics!=.|sotrovimab_covid_therapeutics!=. )
drop if molnupiravir_covid_therapeutics!=. & (  paxlovid_covid_therapeutics!=.| remdesivir_covid_therapeutics!=.| casirivimab_covid_therapeutics!=.|sotrovimab_covid_therapeutics!=. )

drop if treated==1&sotrovimab_covid_therapeutics==.&paxlovid_covid_therapeutics==.&molnupiravir_covid_therapeutics==.

*define exposure*
describe
gen drug=1 if sotrovimab_covid_therapeutics==start_date
replace drug=0 if paxlovid_covid_therapeutics ==start_date
replace drug=2 if molnupiravir_covid_therapeutics ==start_date
label define drug_Paxlovid 1 "sotrovimab" 0 "Paxlovid" 2 "molnupiravir"
label values drug drug_Paxlovid
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
count if primary_covid_hospital_admission!=.&primary_covid_hospital_discharge==.
count if primary_covid_hospital_admission==.&primary_covid_hospital_discharge!=.
count if primary_covid_hospital_admission!=.&primary_covid_hospital_discharge!=.&primary_covid_hospital_admission==primary_covid_hospital_discharge
count if primary_covid_hospital_admission!=.&primary_covid_hospital_discharge!=.&primary_covid_hospital_admission<primary_covid_hospital_discharge
count if primary_covid_hospital_admission!=.&primary_covid_hospital_discharge!=.&primary_covid_hospital_admission>primary_covid_hospital_discharge
*ignore day cases and mab procedures in day 0/1*
replace covid_hosp_outcome_date0=. if covid_hosp_outcome_date0==covid_hosp_discharge_date0&covid_hosp_outcome_date0!=.
replace covid_hosp_outcome_date1=. if covid_hosp_outcome_date1==covid_hosp_discharge_date1&covid_hosp_outcome_date1!=.
*replace covid_hosp_outcome_date0=. if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1
*replace covid_hosp_outcome_date1=. if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1

gen covid_hospitalisation_outcome_da=covid_hosp_outcome_date2
replace covid_hospitalisation_outcome_da=covid_hosp_outcome_date1 if covid_hosp_outcome_date1!=.
replace covid_hospitalisation_outcome_da=covid_hosp_outcome_date0 if covid_hosp_outcome_date0!=.&drug==0
replace covid_hospitalisation_outcome_da=covid_hosp_outcome_date0 if covid_hosp_outcome_date0!=.&drug==1

gen days_to_covid_admission=covid_hospitalisation_outcome_da-start_date if covid_hospitalisation_outcome_da!=.
by drug days_to_covid_admission, sort: count if covid_hospitalisation_outcome_da!=.

by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2<=(start_date+28)&days_to_covid_admission>=2
by drug days_to_covid_admission, sort: count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2<=(start_date+28)&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure<=(start_date+28)&days_to_covid_admission>=2
by drug days_to_covid_admission, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure<=(start_date+28)&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date2<=(start_date+28)&covid_hosp_outcome_date2==covid_hosp_discharge_date2&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date2<=(start_date+28)&(covid_hosp_discharge_date2 - covid_hosp_outcome_date2)==1&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date2<=(start_date+28)&(covid_hosp_discharge_date2 - covid_hosp_outcome_date2)==2&days_to_covid_admission>=2
count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2<=(start_date+28)&days_to_covid_admission>=2&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2<=(start_date+28)&days_to_covid_admission>=2&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure<=(start_date+28)&days_to_covid_admission>=2&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
by drug days_to_covid_admission, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure<=(start_date+28)&days_to_covid_admission>=2&sotrovimab_covid_therapeutics==.&casirivimab_covid_therapeutics==.
*ignore and censor day cases on or after day 2 from this analysis*
*ignore and censor admissions for mab procedure >= day 2 and with same-day or 1-day discharge*
*gen covid_hosp_date_day_cases_mab=covid_hospitalisation_outcome_da if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2
*replace covid_hosp_date_day_cases_mab=covid_hospitalisation_outcome_da if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2&(covid_hosp_discharge_date2-covid_hosp_outcome_date2)<=1&drug==1
drop if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2
*replace covid_hospitalisation_outcome_da=. if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2&(covid_hosp_discharge_date2-covid_hosp_outcome_date2)<=1&drug==1
*check hosp_admission_method*
tab covid_hosp_admission_method,m
tab drug covid_hosp_admission_method, row chi
*by drug days_to_covid_admission, sort: count if covid_hospitalisation_outcome_da!=covid_hosp_date_emergency&covid_hospitalisation_outcome_da!=.
*capture and exclude COVID-hospital admission/death on the start date
count if start_date==covid_hospitalisation_outcome_da| start_date==death_with_covid_on_the_death_ce
drop if start_date>=covid_hospitalisation_outcome_da| start_date>=death_with_covid_on_the_death_ce|start_date>=death_date|start_date>=dereg_date


*define outcome and follow-up time*
gen study_end_date=mdy(10,1,2022)
gen start_date_30=start_date+30
by drug, sort: count if covid_hospitalisation_outcome_da!=.
by drug, sort: count if death_with_covid_on_the_death_ce!=.
by drug, sort: count if covid_hospitalisation_outcome_da==.&death_with_covid_on_the_death_ce!=.
by drug, sort: count if death_with_covid_on_the_death_ce==.&covid_hospitalisation_outcome_da!=.
*30-day COVID hosp*
gen covid_hospitalisation_30day=(covid_hospitalisation_outcome_da!=.&covid_hospitalisation_outcome_da<=start_date_30)
tab covid_hospitalisation_30day,m
tab drug covid_hospitalisation_30day,row m
tab drug covid_hospitalisation_30day if start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug covid_hospitalisation_30day if start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug covid_hospitalisation_30day if start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m
*30-day COVID death*
gen covid_death_30day=(death_with_covid_on_the_death_ce!=.&death_with_covid_on_the_death_ce<=start_date_30)
tab covid_death_30day,m
tab drug covid_death_30day,row m
tab drug covid_death_30day if start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug covid_death_30day if start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug covid_death_30day if start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m
*30-day all-cause death*
gen death_30day=(death_date!=.&death_date<=start_date_30)
tab death_30day,m
tab drug death_30day,row m
tab drug death_30day if start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug death_30day if start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug death_30day if start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m




*covariates* 
*ukrr variables*
tab ukrr_2021_mod,m
gen rrt_mod_Tx=(ukrr_2021_mod=="Tx")
tab rrt_mod_Tx,m
*ukrr_2021_startdate all missing, so use ukrr_2020_startdate*
tab ukrr_2020,m
tab ukrr_inc2020,m
gen days_since_rrt=start_date-ukrr_2020_startdate
sum days_since_rrt,de
tab ukrr_inc2020 if days_since_rrt==.,m
gen months_since_rrt=ceil(days_since_rrt/30)
tab months_since_rrt,m
gen years_since_rrt=ceil(days_since_rrt/365.25)
tab years_since_rrt,m
replace years_since_rrt=8 if years_since_rrt>=9&years_since_rrt!=.
tab years_since_rrt,m
gen years_since_rrt_missing=years_since_rrt
replace years_since_rrt_missing=99 if years_since_rrt==.

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
gen solid_cancer_new=(cancer_opensafely_snomed_new<=start_date|solid_cancer_therapeutics==1)
gen haema_disease=( haematological_disease_nhsd <=start_date|haema_disease_therapeutics==1)
gen renal_disease=( ckd_stage_5_nhsd <=start_date|renal_therapeutics==1)
gen liver_disease=( liver_disease_nhsd <=start_date|liver_therapeutics==1)
gen imid=( imid_nhsd <=start_date|imid_therapeutics==1)
gen immunosupression=( immunosupression_nhsd <=start_date|immunosup_therapeutics==1)
gen immunosupression_new=( immunosupression_nhsd_new <=start_date|immunosup_therapeutics==1)
gen hiv_aids=( hiv_aids_nhsd <=start_date|hiv_aids_therapeutics==1)
gen solid_organ=( solid_organ_transplant_nhsd<=start_date|solid_organ_therapeutics==1)
gen solid_organ_new=( solid_organ_transplant_nhsd_new<=start_date|solid_organ_therapeutics==1)
gen rare_neuro=( rare_neuro_nhsd <=start_date|rare_neuro_therapeutics==1)
gen high_risk_group=(( downs_syndrome + solid_cancer + haema_disease + renal_disease + liver_disease + imid + immunosupression + hiv_aids + solid_organ + rare_neuro )>0)
tab high_risk_group,m
gen high_risk_group_new=(( downs_syndrome + solid_cancer_new + haema_disease + renal_disease + liver_disease + imid + immunosupression_new + hiv_aids + solid_organ_new + rare_neuro )>0)
tab high_risk_group_new,m

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
gen White_with_missing=White
replace White_with_missing=9 if White==.

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
replace rural_urban=. if rural_urban<1
replace rural_urban=3 if rural_urban==4
replace rural_urban=5 if rural_urban==6
replace rural_urban=7 if rural_urban==8
tab rural_urban,m
gen rural_urban_with_missing=rural_urban
replace rural_urban_with_missing=99 if rural_urban==.

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
gen bmi_g3_with_missing=bmi_g3
replace bmi_g3_with_missing=9 if bmi_g3==.
gen bmi_25=(bmi>=25) if bmi!=.
gen bmi_30=(bmi>=30) if bmi!=.

tab diabetes,m
tab chronic_cardiac_disease,m
tab hypertension,m
tab chronic_respiratory_disease,m
*vac and variant*
tab vaccination_status,m
rename vaccination_status vaccination_status_str
gen vaccination_status_g5=0 if vaccination_status_str=="Un-vaccinated"|vaccination_status_str=="Un-vaccinated (declined)"
replace vaccination_status_g5=1 if vaccination_status_str=="One vaccination"
replace vaccination_status_g5=2 if vaccination_status_str=="Two vaccinations"
replace vaccination_status_g5=3 if vaccination_status_str=="Three vaccinations"
replace vaccination_status_g5=4 if vaccination_status_str=="Four or more vaccinations"
label define vac_g5 0 "Un-vaccinated" 1 "One vaccination" 2 "Two vaccinations" 3 "Three vaccinations" 4 "Four or more vaccinations"
label values vaccination_status_g5 vac_g5
gen vaccination_3=1 if vaccination_status_g5==3|vaccination_status_g5==4
replace vaccination_3=0 if vaccination_status_g5<3
gen vaccination_status=vaccination_status_g5 
replace vaccination_status=3 if vaccination_status_g5==4
label define vac 0 "Un-vaccinated" 1 "One vaccination" 2 "Two vaccinations" 3 "Three or more vaccinations"
label values vaccination_status vac
gen pre_infection=(covid_test_positive_previous_dat<=(covid_test_positive_date - 30)&covid_test_positive_previous_dat>mdy(1,1,2020)&covid_test_positive_previous_dat!=.)
tab pre_infection,m

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
*combine month5-15 due to small N*
replace month_after_vaccinate=5 if month_after_vaccinate>=5&month_after_vaccinate!=.
gen month_after_vaccinate_missing=month_after_vaccinate
replace month_after_vaccinate_missing=99 if month_after_vaccinate_missing==.
*calendar time*
gen month_after_campaign=ceil((start_date-mdy(12,15,2021))/30)
tab month_after_campaign,m
gen week_after_campaign=ceil((start_date-mdy(12,15,2021))/7)
tab week_after_campaign,m
*combine 6 and 7 due to small N*
*replace month_after_campaign=6 if month_after_campaign==7
gen day_after_campaign=start_date-mdy(12,15,2021)
sum day_after_campaign,de
mkspline calendar_day_spline = day_after_campaign, cubic nknots(4)

*descriptives by drug groups*
by drug,sort: sum days_since_rrt,de
sum months_since_rrt,de
by drug,sort: sum months_since_rrt,de
sum years_since_rrt,de
by drug,sort: sum years_since_rrt,de
by drug,sort: sum age,de
by drug,sort: sum bmi,de
sum d_postest_treat ,de
by drug,sort: sum d_postest_treat ,de
sum week_after_campaign,de
by drug,sort: sum week_after_campaign,de
sum week_after_vaccinate,de
by drug,sort: sum week_after_vaccinate,de
sum d_vaccinate_treat,de
by drug,sort: sum d_vaccinate_treat,de

tab drug ukrr_2021_mod,row chi
tab drug rrt_mod_Tx,row chi
tab drug years_since_rrt,row chi
tab drug years_since_rrt_missing,row chi
tab drug sex,row chi
tab drug ethnicity,row chi
tab drug White,row chi
tab drug imd,row chi
tab drug rural_urban,row chi
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
tab drug solid_cancer_new ,row chi
tab drug haema_disease ,row chi
tab drug renal_disease ,row chi
tab drug liver_disease ,row chi
tab drug imid ,row chi
tab drug immunosupression ,row chi
tab drug immunosupression_new ,row chi
tab drug hiv_aids ,row chi
tab drug solid_organ ,row chi
tab drug solid_organ_new ,row chi
tab drug rare_neuro ,row chi
tab drug high_risk_group ,row chi
tab drug autism_nhsd ,row chi
tab drug care_home_primis ,row chi
tab drug dementia_nhsd ,row chi
tab drug housebound_opensafely ,row chi
tab drug learning_disability_primis ,row chi
tab drug serious_mental_illness_nhsd ,row chi
tab drug bmi_group4 ,row chi
tab drug bmi_g3 ,row chi
tab drug diabetes ,row chi
tab drug chronic_cardiac_disease ,row chi
tab drug hypertension ,row chi
tab drug chronic_respiratory_disease ,row chi
tab drug vaccination_status ,row chi
tab drug vaccination_status_g5 ,row chi
tab drug month_after_vaccinate,row chi
tab drug month_after_campaign,row chi
tab drug sgtf ,row chi
tab drug sgtf_new ,row chi
*tab drug variant_recorded ,row chi
by drug, sort: tab variant_recorded
tab drug pre_infection,row chi

*30-day COVID hosp*
tab drug covid_hospitalisation_30day if high_risk_group_new==1,row m
tab drug covid_hospitalisation_30day if high_risk_group_new==1&start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug covid_hospitalisation_30day if high_risk_group_new==1&start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug covid_hospitalisation_30day if high_risk_group_new==1&start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m
*30-day COVID death*
tab drug covid_death_30day if high_risk_group_new==1,row m
tab drug covid_death_30day if high_risk_group_new==1&start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug covid_death_30day if high_risk_group_new==1&start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug covid_death_30day if high_risk_group_new==1&start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m
*30-day all-cause death*
tab drug death_30day if high_risk_group_new==1,row m
tab drug death_30day if high_risk_group_new==1&start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug death_30day if high_risk_group_new==1&start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug death_30day if high_risk_group_new==1&start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m


*UKRR cohort*
keep if ukrr_2021==1
tab drug,m
*30-day COVID hosp*
tab drug covid_hospitalisation_30day,row m
tab drug covid_hospitalisation_30day if start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug covid_hospitalisation_30day if start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug covid_hospitalisation_30day if start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m
*30-day COVID death*
tab drug covid_death_30day,row m
tab drug covid_death_30day if start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug covid_death_30day if start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug covid_death_30day if start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m
*30-day all-cause death*
tab drug death_30day,row m
tab drug death_30day if start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug death_30day if start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug death_30day if start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m
*30-day COVID hosp*
tab drug covid_hospitalisation_30day if high_risk_group_new==1,row m
tab drug covid_hospitalisation_30day if high_risk_group_new==1&start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug covid_hospitalisation_30day if high_risk_group_new==1&start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug covid_hospitalisation_30day if high_risk_group_new==1&start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m
*30-day COVID death*
tab drug covid_death_30day if high_risk_group_new==1,row m
tab drug covid_death_30day if high_risk_group_new==1&start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug covid_death_30day if high_risk_group_new==1&start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug covid_death_30day if high_risk_group_new==1&start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m
*30-day all-cause death*
tab drug death_30day if high_risk_group_new==1,row m
tab drug death_30day if high_risk_group_new==1&start_date>=mdy(12,16,2021)&start_date<=mdy(2,10,2022),row m
tab drug death_30day if high_risk_group_new==1&start_date>=mdy(2,11,2022)&start_date<=mdy(5,31,2022),row m
tab drug death_30day if high_risk_group_new==1&start_date>=mdy(6,1,2022)&start_date<=mdy(10,1,2022),row m




log close




