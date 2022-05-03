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
        covid_test_positive_date covid_test_positive_date2 covid_symptoms_snomed primary_covid_hospital_discharge ///
	   any_covid_hospital_discharge_dat preg_36wks_date death_date dereg_date downs_syndrome_nhsd_snomed downs_syndrome_nhsd_icd10 cancer_opensafely_snomed ///
	   haematopoietic_stem_cell_snomed haematopoietic_stem_cell_icd10 haematopoietic_stem_cell_opcs4 ///
	   haematological_malignancies_snom haematological_malignancies_icd1 sickle_cell_disease_nhsd_snomed sickle_cell_disease_nhsd_icd10 ///
	   ckd_stage_5_nhsd_snomed ckd_stage_5_nhsd_icd10 liver_disease_nhsd_snomed liver_disease_nhsd_icd10 immunosuppresant_drugs_nhsd ///
	   oral_steroid_drugs_nhsd immunosupression_nhsd hiv_aids_nhsd_snomed  solid_organ_transplant_nhsd_snom ///
	   solid_organ_transplant_nhsd_opcs multiple_sclerosis_nhsd_snomed multiple_sclerosis_nhsd_icd10 ///
	   motor_neurone_disease_nhsd_snome motor_neurone_disease_nhsd_icd10 myasthenia_gravis_nhsd_snomed myasthenia_gravis_nhsd_icd10 ///
	   huntingtons_disease_nhsd_snomed huntingtons_disease_nhsd_icd10 bmi_date_measured covid_positive_test_30_days_post ///
	   covid_hosp_outcome_date0 covid_hosp_outcome_date1 covid_hosp_outcome_date2 covid_hosp_discharge_date0 covid_hosp_discharge_date1 covid_hosp_discharge_date2 ///
	   covid_hosp_date_emergency covid_hosp_date_mabs_procedure covid_hosp_date0_not_primary covid_hosp_date1_not_primary covid_hosp_date2_not_primary ///
	   covid_discharge_date0_not_pri covid_discharge_date1_not_pri covid_discharge_date2_not_pri death_with_covid_on_the_death_ce hospitalisation_outcome_date0 ///
	   hospitalisation_outcome_date1 hospitalisation_outcome_date2 hosp_discharge_date0 hosp_discharge_date1 hosp_discharge_date2 date_treated start_date ///
	   downs_syndrome_nhsd haematological_disease_nhsd ckd_stage_5_nhsd liver_disease_nhsd hiv_aids_nhsd solid_organ_transplant_nhsd ///
	   multiple_sclerosis_nhsd motor_neurone_disease_nhsd myasthenia_gravis_nhsd huntingtons_disease_nhsd sickle_cell_disease_nhsd {
  confirm string variable `var'
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
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
*check casirivimab_covid_therapeutics*
capture confirm string variable casirivimab_covid_therapeutics
if _rc==0 {
rename casirivimab_covid_therapeutics a
gen casirivimab_covid_therapeutics = date(a, "YMD")
drop a
format %td casirivimab_covid_therapeutics
}


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
drop if stp==""
*exclude those with other drugs before sotro or molnu, and those receiving sotro and molnu on the same day*
drop if sotrovimab_covid_therapeutics!=. & ( paxlovid_covid_therapeutics<=sotrovimab_covid_therapeutics| remdesivir_covid_therapeutics<=sotrovimab_covid_therapeutics| casirivimab_covid_therapeutics<=sotrovimab_covid_therapeutics)
drop if molnupiravir_covid_therapeutics!=. & ( paxlovid_covid_therapeutics<= molnupiravir_covid_therapeutics | remdesivir_covid_therapeutics<= molnupiravir_covid_therapeutics | casirivimab_covid_therapeutics<= molnupiravir_covid_therapeutics )
count if sotrovimab_covid_therapeutics!=. & molnupiravir_covid_therapeutics!=.
drop if sotrovimab_covid_therapeutics==molnupiravir_covid_therapeutics
*restrict start_date to 2021Dec16 to 2022Feb10*
*loose this restriction to increase N?*
keep if start_date>=mdy(12,16,2021)&start_date<=mdy(02,10,2022)
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
by drug, sort: count if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date0!=.&covid_hosp_outcome_date0==covid_hosp_outcome_date0
by drug, sort: count if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date1!=.&covid_hosp_outcome_date1==covid_hosp_outcome_date1
*check if any patient discharged in AM and admitted in PM*
count if covid_hosp_outcome_date0==covid_hosp_discharge_date0&covid_hosp_outcome_date0!=.&covid_hosp_outcome_date1==.&covid_hosp_outcome_date2==.&covid_hosp_discharge_date1!=.
count if covid_hosp_outcome_date1==covid_hosp_discharge_date1&covid_hosp_outcome_date1!=.&covid_hosp_outcome_date2==.&covid_hosp_discharge_date2!=.
count if covid_hosp_outcome_date2==.&covid_hosp_discharge_date2!=.
count if covid_hosp_outcome_date2!=.&covid_hosp_discharge_date2==.
count if covid_hosp_outcome_date2!=.&covid_hosp_outcome_date2>covid_hosp_discharge_date2
*ignore day cases in day 0/1*
replace covid_hosp_outcome_date0=. if covid_hosp_outcome_date0==covid_hosp_discharge_date0&covid_hosp_outcome_date0!=.
replace covid_hosp_outcome_date1=. if covid_hosp_outcome_date1==covid_hosp_discharge_date1&covid_hosp_outcome_date1!=.
replace covid_hosp_outcome_date0=. if covid_hosp_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1
replace covid_hosp_outcome_date1=. if covid_hosp_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1

gen covid_hospitalisation_outcome_da=covid_hosp_outcome_date2
replace covid_hospitalisation_outcome_da=covid_hosp_outcome_date1 if covid_hosp_outcome_date1!=.
replace covid_hospitalisation_outcome_da=covid_hosp_outcome_date0 if covid_hosp_outcome_date0!=.
gen days_to_covid_admission=covid_hospitalisation_outcome_da-start_date if covid_hospitalisation_outcome_da!=.
by drug days_to_covid_admission, sort: count if covid_hospitalisation_outcome_da!=.

by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2
by drug days_to_covid_admission, sort: count if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2
by drug days_to_covid_admission, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&days_to_covid_admission>=2
by drug, sort: count if covid_hosp_outcome_date2==covid_hosp_date_mabs_procedure&covid_hosp_outcome_date2!=.&covid_hosp_outcome_date2==covid_hosp_discharge_date2&days_to_covid_admission>=2
drop if covid_hosp_outcome_date2==covid_hosp_discharge_date2&covid_hosp_outcome_date2!=.&days_to_covid_admission>=2
*check hosp_admission_method*
tab covid_hosp_admission_method,m
tab drug covid_hosp_admission_method, row chi
by drug days_to_covid_admission, sort: count if covid_hospitalisation_outcome_da!=covid_hosp_date_emergency&covid_hospitalisation_outcome_da!=.
*capture and exclude COVID-hospital admission/death on the start date
count if start_date==covid_hospitalisation_outcome_da| start_date==death_with_covid_on_the_death_ce
drop if start_date>=covid_hospitalisation_outcome_da| start_date>=death_with_covid_on_the_death_ce|start_date>=death_date|start_date>=dereg_date


*define outcome and follow-up time*
gen study_end_date=mdy(05,03,2022)
gen start_date_29=start_date+28
by drug, sort: count if covid_hospitalisation_outcome_da!=.
by drug, sort: count if death_with_covid_on_the_death_ce!=.
*primary outcome*
gen event_date=min( covid_hospitalisation_outcome_da, death_with_covid_on_the_death_ce )
gen failure=(event_date!=.&event_date<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure=(event_date!=.&event_date<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure,m
gen end_date=event_date if failure==1
replace end_date=min(death_date, dereg_date, study_end_date, start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure==0&drug==1
replace end_date=min(death_date, dereg_date, study_end_date, start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure==0&drug==0
format %td event_date end_date study_end_date start_date_29

stset end_date ,  origin(start_date) failure(failure==1)
stcox drug
*secondary outcome: within 2 months*
gen start_date_2m=start_date+60
gen failure_2m=(event_date!=.&event_date<=min(study_end_date,start_date_2m,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_2m=(event_date!=.&event_date<=min(study_end_date,start_date_2m,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_2m,m
gen end_date_2m=event_date if failure_2m==1
replace end_date_2m=min(death_date, dereg_date, study_end_date, start_date_2m,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_2m==0&drug==1
replace end_date_2m=min(death_date, dereg_date, study_end_date, start_date_2m,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_2m==0&drug==0
format %td end_date_2m start_date_2m

stset end_date_2m ,  origin(start_date) failure(failure_2m==1)
stcox drug
*secondary outcome: within 3 months*
gen start_date_3m=start_date+90
gen failure_3m=(event_date!=.&event_date<=min(study_end_date,start_date_3m,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_3m=(event_date!=.&event_date<=min(study_end_date,start_date_3m,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_3m,m
gen end_date_3m=event_date if failure_3m==1
replace end_date_3m=min(death_date, dereg_date, study_end_date, start_date_3m,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_3m==0&drug==1
replace end_date_3m=min(death_date, dereg_date, study_end_date, start_date_3m,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_3m==0&drug==0
format %td end_date_3m start_date_3m

stset end_date_3m ,  origin(start_date) failure(failure_3m==1)
stcox drug
*secondary outcome: all-cause hosp/death within 29 days*
*correct all cause hosp date *
count if hospitalisation_outcome_date0!=start_date&hospitalisation_outcome_date0!=.
count if hospitalisation_outcome_date1!=(start_date+1)&hospitalisation_outcome_date1!=.
replace hospitalisation_outcome_date0=. if hospitalisation_outcome_date0==hosp_discharge_date0&hospitalisation_outcome_date0!=.
replace hospitalisation_outcome_date1=. if hospitalisation_outcome_date1==hosp_discharge_date1&hospitalisation_outcome_date1!=.
replace hospitalisation_outcome_date0=. if hospitalisation_outcome_date0==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1
replace hospitalisation_outcome_date1=. if hospitalisation_outcome_date1==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1

gen hospitalisation_outcome_date=hospitalisation_outcome_date2
replace hospitalisation_outcome_date=hospitalisation_outcome_date1 if hospitalisation_outcome_date1!=.
replace hospitalisation_outcome_date=hospitalisation_outcome_date0 if hospitalisation_outcome_date0!=.
gen event_date_allcause=min( death_date, hospitalisation_outcome_date )
gen failure_allcause=(event_date_allcause!=.&event_date_allcause<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_allcause=(event_date_allcause!=.&event_date_allcause<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_allcause,m
gen end_date_allcause=event_date_allcause if failure_allcause==1
replace end_date_allcause=min(death_date, dereg_date, study_end_date, start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_allcause==0&drug==1
replace end_date_allcause=min(death_date, dereg_date, study_end_date, start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_allcause==0&drug==0
format %td event_date_allcause end_date_allcause  
*further excluding day cases on or after day 2 from this analysis*
replace end_date_allcause=. if hospitalisation_outcome_date2==hosp_discharge_date2&hospitalisation_outcome_date2!=.&hospitalisation_outcome_date0==.&hospitalisation_outcome_date1==.

stset end_date_allcause ,  origin(start_date) failure(failure_allcause==1)
stcox drug
*sensitivity analysis for primary outcome: only emergency admissions, ignore non-emergency admissions*
*exclude day cases?*
gen event_date_emergency=min( covid_hosp_date_emergency, death_with_covid_on_the_death_ce )
gen failure_emergency=(event_date_emergency!=.&event_date_emergency<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_emergency=(event_date_emergency!=.&event_date_emergency<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_emergency,m
gen end_date_emergency=event_date_emergency if failure_emergency==1
replace end_date_emergency=min(death_date, dereg_date, study_end_date, start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_emergency==0&drug==1
replace end_date_emergency=min(death_date, dereg_date, study_end_date, start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_emergency==0&drug==0
format %td event_date_emergency end_date_emergency  

stset end_date_emergency ,  origin(start_date) failure(failure_emergency==1)
stcox drug
*sensitivity analysis for primary outcome: not require covid as primary diagnosis*
*correct hosp date *
count if covid_hosp_date0_not_primary!=start_date&covid_hosp_date0_not_primary!=.
count if covid_hosp_date1_not_primary!=(start_date+1)&covid_hosp_date1_not_primary!=.
replace covid_hosp_date0_not_primary=. if covid_hosp_date0_not_primary==covid_discharge_date0_not_pri&covid_hosp_date0_not_primary!=.
replace covid_hosp_date1_not_primary=. if covid_hosp_date1_not_primary==covid_discharge_date1_not_pri&covid_hosp_date1_not_primary!=.
replace covid_hosp_date0_not_primary=. if covid_hosp_date0_not_primary==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1
replace covid_hosp_date1_not_primary=. if covid_hosp_date1_not_primary==covid_hosp_date_mabs_procedure&covid_hosp_date_mabs_procedure!=.&drug==1

gen covid_hosp_date_not_primary=covid_hosp_date2_not_primary
replace covid_hosp_date_not_primary=covid_hosp_date1_not_primary if covid_hosp_date1_not_primary!=.
replace covid_hosp_date_not_primary=covid_hosp_date0_not_primary if covid_hosp_date0_not_primary!=.
gen event_date_not_primary=min( covid_hosp_date_not_primary, death_with_covid_on_the_death_ce )
gen failure_not_primary=(event_date_not_primary!=.&event_date_not_primary<=min(study_end_date,start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==1
replace failure_not_primary=(event_date_not_primary!=.&event_date_not_primary<=min(study_end_date,start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)) if drug==0
tab failure_not_primary,m
gen end_date_not_primary=event_date_not_primary if failure_not_primary==1
replace end_date_not_primary=min(death_date, dereg_date, study_end_date, start_date_29,molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_not_primary==0&drug==1
replace end_date_not_primary=min(death_date, dereg_date, study_end_date, start_date_29,sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics) if failure_not_primary==0&drug==0
format %td event_date_not_primary end_date_not_primary  
*further excluding day cases on or after day 2 from this analysis!*
replace end_date_not_primary=. if covid_hosp_date2_not_primary==covid_discharge_date2_not_pri&covid_hosp_date2_not_primary!=.&covid_hosp_date0_not_primary==.&covid_hosp_date1_not_primary==.

stset end_date_not_primary ,  origin(start_date) failure(failure_not_primary==1)
stcox drug




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
*combine stps with low N (<50) as "Other"*
by stp, sort: gen stp_N=_N if stp!=.
replace stp=99 if stp_N<50
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
tab sgtf,m
tab sgtf_new, m
label define sgtf_new 0 "S gene detected" 1 "confirmed SGTF" 9 "NA"
label values sgtf_new sgtf_new
tab variant_recorded ,m
tab sgtf variant_recorded ,m
*calendar time*
gen month_after_campaign=ceil((start_date-mdy(12,15,2021))/30)
tab month_after_campaign,m
gen week_after_campaign=ceil((start_date-mdy(12,15,2021))/7)
tab week_after_campaign,m
*combine 8 and 9 due to small N*
replace week_after_campaign=8 if week_after_campaign==9

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
tab drug sgtf ,row chi
tab drug sgtf_new ,row chi
tab drug variant_recorded ,row chi


save ./output/main.dta, replace

log close




