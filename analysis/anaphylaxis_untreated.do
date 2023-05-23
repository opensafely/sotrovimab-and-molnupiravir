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
log using ./logs/anaphylaxis_untreated, replace t
clear

* import dataset
import delimited ./output/input_anaphylaxis_untreated.csv, delimiter(comma) varnames(1) case(preserve) 

*codebook
drop if cancer_opensafely_snomed_new==""&immunosuppresant_drugs_nhsd==""&oral_steroid_drugs_nhsd==""&immunosupression_nhsd_new==""&solid_organ_transplant_nhsd_new==""&downs_syndrome_nhsd==""&haematological_disease_nhsd==""&ckd_stage_5_nhsd==""&liver_disease_nhsd==""&hiv_aids_nhsd==""&multiple_sclerosis_nhsd==""&motor_neurone_disease_nhsd==""&myasthenia_gravis_nhsd==""&huntingtons_disease_nhsd=="" 

*  Convert strings to dates  *
foreach var of varlist  sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics paxlovid_covid_therapeutics remdesivir_covid_therapeutics	///
        casirivimab_covid_therapeutics date_treated start_date ///
		death_date dereg_date last_vaccination_date ///
	   cancer_opensafely_snomed_new   immunosuppresant_drugs_nhsd ///
	   oral_steroid_drugs_nhsd  immunosupression_nhsd_new   solid_organ_transplant_nhsd_new  ///
	   downs_syndrome_nhsd haematological_disease_nhsd ckd_stage_5_nhsd liver_disease_nhsd hiv_aids_nhsd  ///
	   multiple_sclerosis_nhsd motor_neurone_disease_nhsd myasthenia_gravis_nhsd huntingtons_disease_nhsd ///
	   death_with_anaphylaxis_date death_with_anaph_underly_date death_with_anaphylaxis_date2 ///
		death_with_anaph_underly_date2 death_with_anaphylaxis_date3 death_with_anaphylaxis_date_pre death_with_anaph_underly_date_pr hospitalisation_anaph ///
		hosp_discharge_anaph hospitalisation_anaph_underly hospitalisation_anaph2 hospitalisation_anaph_underly2 hospitalisation_anaph3 hospitalisation_anaph_pre ///
		hosp_anaph_underly_pre AE_anaph AE_anaph2 AE_anaph3 AE_anaph4 AE_anaph_pre AE_anaph2_pre GP_anaph GP_anaph2 GP_anaph_pre GP_anaph2_pre {
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
codebook  hospitalisation_anaph AE_anaph death_date last_vaccination_date 
codebook  hospitalisation_anaph AE_anaph death_date last_vaccination_date if registered_eligible==0
keep if registered_eligible==1


*describe COVID therapy*
gen treated=(date_treated!=.)
keep if treated==0

*exclusion criteria*
sum age,de
*keep if age>=18 & age<110
tab sex,m
*keep if sex=="F"|sex=="M"
tab has_died,m
*keep if has_died==0
*tab registered_eligible,m
*keep if registered_eligible==1
*tab covid_test_positive covid_positive_previous_30_days,m
*keep if covid_test_positive==1 & covid_positive_previous_30_days==0
*drop if primary_covid_hospital_discharge!=.|primary_covid_hospital_admission!=.
*drop if any_covid_hospital_admission_dat!=.|any_covid_hospital_discharge_dat!=.
keep if start_date>=mdy(12,16,2021)&start_date<=mdy(01,28,2023)


*10 high risk groups: downs_syndrome, solid_cancer, haematological_disease, renal_disease, liver_disease, imid, 
*immunosupression, hiv_aids, solid_organ_transplant, rare_neurological_conditions, high_risk_group_combined	
replace oral_steroid_drugs_nhsd=. if oral_steroid_drug_nhsd_3m_count < 2 & oral_steroid_drug_nhsd_12m_count < 4
gen imid_nhsd=min(oral_steroid_drugs_nhsd, immunosuppresant_drugs_nhsd)
gen rare_neuro_nhsd = min(multiple_sclerosis_nhsd, motor_neurone_disease_nhsd, myasthenia_gravis_nhsd, huntingtons_disease_nhsd)
*high risk group only based on codelists*
gen downs_syndrome=(downs_syndrome_nhsd<=start_date)
gen solid_cancer_new=(cancer_opensafely_snomed_new<=start_date)
gen haema_disease=( haematological_disease_nhsd <=start_date)
gen renal_disease=( ckd_stage_5_nhsd <=start_date)
gen liver_disease=( liver_disease_nhsd <=start_date)
gen imid=( imid_nhsd <=start_date)
gen immunosupression_new=( immunosupression_nhsd_new <=start_date)
gen hiv_aids=( hiv_aids_nhsd <=start_date)
gen solid_organ_new=( solid_organ_transplant_nhsd_new<=start_date)
gen rare_neuro=( rare_neuro_nhsd <=start_date)
gen high_risk_group_new=(( downs_syndrome + solid_cancer_new + haema_disease + renal_disease + liver_disease + imid + immunosupression_new + hiv_aids + solid_organ_new + rare_neuro )>0)
tab high_risk_group_new,m
keep if high_risk_group_new==1


*anaphylaxis events*
*death *
sum death_with_anaphylaxis_date,f
gen death=(death_with_anaphylaxis_date!=.) 
tab death
gen day_death=death_with_anaphylaxis_date-start_date
sum day_death, de
gen death_28d=(death_with_anaphylaxis_date!=.&day_death<=28) 
tab death_28d
sum death_with_anaph_underly_date ,f
sum death_with_anaph_underly_date if day_death<=28,f

sum death_with_anaphylaxis_date2 ,f
sum death_with_anaph_underly_date2 ,f
sum death_with_anaphylaxis_date3 ,f

sum death_with_anaphylaxis_date_pre ,f
sum death_with_anaph_underly_date_pr ,f
*hosp*
sum hospitalisation_anaph ,f
gen hosp=(hospitalisation_anaph!=.) 
tab hosp
gen day_hosp=hospitalisation_anaph-start_date  
sum day_hosp, de
gen hosp_28d=(hospitalisation_anaph!=.&day_hosp<=28) 
tab hosp_28d
tab hospitalisation_anaph if hosp_28d==1
gen day_discharge=hosp_discharge_anaph-hospitalisation_anaph 
sum day_discharge,de
sum hospitalisation_anaph_underly ,f
sum hospitalisation_anaph_underly if day_hosp<=28,f

sum hospitalisation_anaph2 ,f
sum hospitalisation_anaph2 if day_hosp<=28,f
sum hospitalisation_anaph_underly2 ,f
sum hospitalisation_anaph3 ,f
sum hospitalisation_anaph3 if day_hosp<=28,f

sum hospitalisation_anaph_pre ,f
sum hosp_anaph_underly_pre ,f
*A&E*
sum AE_anaph ,f
gen AE=(AE_anaph!=.) 
tab AE
gen day_AE=AE_anaph-start_date 
sum day_AE, de
gen AE_28d=(AE_anaph!=.&day_AE<=28) 
tab AE_28d
tab AE_anaph if AE_28d==1

sum AE_anaph2 ,f
sum AE_anaph3 ,f
sum AE_anaph4 ,f
gen AE_28d2=(AE_anaph2!=.&day_AE<=28) 
tab AE_28d2
tab AE_anaph if AE_28d2==1
sum AE_anaph2 if day_AE<=28,f
sum AE_anaph3 if day_AE<=28,f
sum AE_anaph4 if day_AE<=28,f

sum AE_anaph_pre ,f
sum AE_anaph2_pre ,f
*GP*
sum GP_anaph ,f
gen GP=(GP_anaph!=.) 
tab GP
gen day_GP=GP_anaph-start_date 
sum day_GP, de
gen GP_28d=(GP_anaph!=.&day_GP<=28) 
tab GP_28d
tab GP_anaph if GP_28d==1
tostring GP_anaph_code,replace
tab GP_anaph_code ,m
tab GP_anaph_code if day_GP<=28,m

sum GP_anaph2 ,f
sum GP_anaph2 if day_GP<=28,f
sum GP_anaph_pre ,f
sum GP_anaph2_pre ,f

*combine 4 data sources*
tab hosp_28d AE_28d,row
tab hosp_28d AE_28d2,row
tab hosp_28d GP_28d,row
tab AE_28d GP_28d,row
tab AE_28d2 GP_28d,row
gen anaph_all=(death_28d+hosp_28d+AE_28d+GP_28d)>0 
tab anaph_all
gen anaph_all2=(death_28d+hosp_28d+AE_28d2+GP_28d)>0 
tab anaph_all2

gen anaph_ever=(hospitalisation_anaph_pre!=.|AE_anaph_pre!=.|GP_anaph_pre!=.)
tab anaph_ever
gen anaph_ever2=(hospitalisation_anaph_pre!=.|AE_anaph2_pre!=.|GP_anaph_pre!=.)
tab anaph_ever2

*by age*



log close




