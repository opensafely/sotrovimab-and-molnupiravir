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
log using ./logs/data_preparation_feasibility2, replace t
clear

* import dataset
import delimited ./output/input_feasibility2.csv, delimiter(comma) varnames(1) case(preserve) 
keep if date_treated_out!=""|date_treated_hosp!=""|date_treated_onset!=""
*describe
codebook

log close
exit, clear

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


*covariates* 
replace oral_steroid_drugs_nhsd=. if oral_steroid_drug_nhsd_3m_count < 2 & oral_steroid_drug_nhsd_12m_count < 4
gen imid_nhsd=min(oral_steroid_drugs_nhsd, immunosuppresant_drugs_nhsd)
gen solid_cancer=(cancer_opensafely_snomed<=start_date)
gen haema_disease=( haematological_disease_nhsd <=start_date|haema_disease_therapeutics==1)
gen renal_disease=( ckd_stage_5_nhsd <=start_date|renal_therapeutics==1)
gen liver_disease=( liver_disease_nhsd <=start_date|liver_therapeutics==1)
gen imid=( imid_nhsd <=start_date)
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
*combine month6-14 due to small N*
replace month_after_vaccinate=6 if month_after_vaccinate>6&month_after_vaccinate!=.
gen month_after_vaccinate_missing=month_after_vaccinate
replace month_after_vaccinate_missing=99 if month_after_vaccinate_missing==.
*calendar time*
gen month_after_campaign=ceil((start_date-mdy(12,15,2021))/30)
tab month_after_campaign,m
gen week_after_campaign=ceil((start_date-mdy(12,15,2021))/7)
tab week_after_campaign,m
*combine 9 and 10 due to small N*
*replace week_after_campaign=9 if week_after_campaign==10




save ./output/main_feasibility.dta, replace
log close




