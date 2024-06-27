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
rename v57 haematological_malig_snomed_ever
rename v58 haematological_malig_icd10_ever




*  Convert strings to dates  *
foreach var of varlist  sotrovimab_covid_out molnupiravir_covid_out paxlovid_covid_out remdesivir_covid_out casirivimab_covid_out date_treated_out ///
        sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics paxlovid_covid_therapeutics remdesivir_covid_therapeutics	///
        casirivimab_covid_therapeutics tocilizumab_covid_therapeutics sarilumab_covid_therapeutics  baricitinib_covid_therapeutics date_treated_onset ///
		baricitinib_covid_hosp remdesivir_covid_hosp0 tocilizumab_covid_hosp0 sarilumab_covid_hosp0 tocilizumab_covid_hosp2  sarilumab_covid_hosp2  ///
        sotrovimab_covid_hosp paxlovid_covid_hosp molnupiravir_covid_hosp remdesivir_covid_hosp casirivimab_covid_hosp tocilizumab_covid_hosp sarilumab_covid_hosp ///
		date_treated_hosp start_date death_with_covid_date death_with_covid_underly_date death_date   bmi_date_measured ///
		cancer_opensafely_snomed_new cancer_opensafely_snomed_ever haematological_malignancies_snom haematological_malignancies_icd1 haematological_disease_nhsd     ///
		haematological_malig_snomed_ever haematological_malig_icd10_ever haematological_disease_nhsd_ever	 immunosuppresant_drugs_nhsd ///
		oral_steroid_drugs_nhsd immunosuppresant_drugs_nhsd_ever oral_steroid_drugs_nhsd_ever immunosupression_nhsd_new solid_organ_transplant_nhsd_new ///
		ckd_stage_5_nhsd liver_disease_nhsd last_vaccination_date covid_hosp_not_pri_admission covid_hosp_not_pri_discharge covid_hosp_not_pri_discharge_1d ///
		covid_hosp_not_pri_discharge2 covid_hosp_not_pri_admission2  covid_hosp_not_pri_discharge2_1d  all_hosp_discharge_1d all_hosp_admission2 all_hosp_discharge2_1d ///
		covid_hosp_not_pri_admission0 covid_hosp_not_pri_discharge0 covid_hosp_admission covid_hosp_discharge all_hosp_admission all_hosp_discharge ///
		all_hosp_discharge2 all_hosp_admission0 all_hosp_discharge0 covid_test_positive_date covid_test_positive_date0 covid_test_positive_date00 ///
		dereg_date	all_hosp_admission_index all_hosp_discharge_index all_hosp_admission2_index all_hosp_discharge2_index all_hosp_admission3_index all_hosp_discharge3_index {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  sum `var',f de
  }
}

*check hosp records*
keep if start_date!=.
count if  covid_hosp_not_pri_admission!=.
sum covid_hosp_not_pri_admission,f de
count if  covid_hosp_not_pri_admission2!=.
sum covid_hosp_not_pri_admission2,f de
count if  all_hosp_admission!=. 
sum all_hosp_admission,f de
count if  all_hosp_admission2!=. 
sum all_hosp_admission2,f de

gen covid_hosp_not_pri_adm_d= start_date - covid_hosp_not_pri_admission
sum covid_hosp_not_pri_adm_d,de
gen all_hosp_adm_d= start_date - all_hosp_admission
sum all_hosp_adm_d,de
gen covid_hosp_not_pri_adm2_d= start_date - covid_hosp_not_pri_admission2
sum covid_hosp_not_pri_adm2_d,de
gen all_hosp_adm2_d= start_date - all_hosp_admission2
sum all_hosp_adm2_d,de
count if (covid_hosp_not_pri_admission<=start_date&covid_hosp_not_pri_discharge>=start_date)|(covid_hosp_not_pri_admission2<=start_date&covid_hosp_not_pri_discharge2>=start_date)
count if (all_hosp_admission<=start_date&all_hosp_discharge>=start_date)|(all_hosp_admission2<=start_date&all_hosp_discharge2>=start_date)
count if (all_hosp_admission_index<=start_date&all_hosp_discharge_index>=start_date)|(all_hosp_admission2_index<=start_date&all_hosp_discharge2_index>=start_date)|(all_hosp_admission3_index<=start_date&all_hosp_discharge3_index>=start_date)


gen covid_hosp_not_pri_duration= covid_hosp_not_pri_discharge - covid_hosp_not_pri_admission
sum covid_hosp_not_pri_duration,de
gen all_hosp_duration= all_hosp_discharge - all_hosp_admission
sum all_hosp_duration,de
gen covid_hosp_not_pri2_duration= covid_hosp_not_pri_discharge2 - covid_hosp_not_pri_admission2
sum covid_hosp_not_pri2_duration,de
gen all_hosp2_duration= all_hosp_discharge2- all_hosp_admission2
sum all_hosp2_duration,de


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
sum start_date,f de

replace oral_steroid_drugs_nhsd=. if oral_steroid_drug_nhsd_3m_count < 2 & oral_steroid_drug_nhsd_12m_count < 4
gen imid_nhsd=min(oral_steroid_drugs_nhsd, immunosuppresant_drugs_nhsd)
gen solid_cancer=(cancer_opensafely_snomed_new<=start_date)
gen solid_cancer_ever=(cancer_opensafely_snomed_ever<=start_date)
gen haema_disease=( haematological_disease_nhsd <=start_date)
gen haema_disease_ever=( haematological_disease_nhsd_ever <=start_date)
gen haematological_cancer=(haematological_malignancies_snom<=start_date|haematological_malignancies_icd1<=start_date)
gen haematological_cancer_ever=(haematological_malig_snomed_ever<=start_date|haematological_malig_icd10_ever<=start_date)
gen renal_disease=( ckd_stage_5_nhsd <=start_date)
gen liver_disease=( liver_disease_nhsd <=start_date)
gen imid=( imid_nhsd <=start_date)
gen immunosupression=( immunosupression_nhsd_new <=start_date)
gen solid_organ=( solid_organ_transplant_nhsd_new<=start_date)

sum covid_test_positive_date,f de
gen covid_test_positive_date_d=start_date - covid_test_positive_date
sum covid_test_positive_date_d,de
sum covid_test_positive_date00,f de
gen covid_reinfection=(min(covid_test_positive_date,covid_test_positive_date0,covid_test_positive_date00,date_treated_hosp,date_treated_onset, ///
      date_treated_out,remdesivir_covid_hosp0, tocilizumab_covid_hosp0, sarilumab_covid_hosp0, covid_hosp_not_pri_admission, covid_hosp_not_pri_admission0)<=(start_date-90))
tab covid_reinfection,m

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
tab region_nhs,m
tab region_covid_therapeutics,m
tab region_nhs region_covid_therapeutics,m

tab rural_urban,m
replace rural_urban=. if rural_urban<1
replace rural_urban=3 if rural_urban==4
replace rural_urban=5 if rural_urban==6
replace rural_urban=7 if rural_urban==8
tab rural_urban,m
gen rural_urban_with_missing=rural_urban
replace rural_urban_with_missing=99 if rural_urban==.

*comor*
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
*vac *
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
*Time between last vaccination and treatment*
gen d_vaccinate_treat=start_date - last_vaccination_date
sum d_vaccinate_treat,de
gen month_after_vaccinate=ceil(d_vaccinate_treat/30)
tab month_after_vaccinate,m
gen month_after_vaccinate_missing=month_after_vaccinate
replace month_after_vaccinate_missing=99 if month_after_vaccinate_missing==.
*calendar time*
gen calendar_day=start_date - mdy(7,1,2021)
sum calendar_day,de
gen calendar_month=ceil((start_date-mdy(7,1,2021))/30)
tab calendar_month,m
gen omicron=(start_date>=mdy(12,6,2021))
tab omicron,m
gen previous_drug=(date_treated_hosp<start_date|date_treated_onset<start_date|date_treated_out<start_date|date_treated_onset<start_date|date_treated_onset<start_date| ///
                   remdesivir_covid_hosp0 <start_date|tocilizumab_covid_hosp0 <start_date|sarilumab_covid_hosp0 <start_date)
tab previous_drug,m

*descriptives by drug groups*
by drug,sort: sum start_date, f de
by drug,sort: sum age,de
ttest age , by( drug )
by drug,sort: sum bmi,de
ttest bmi, by( drug )
by drug,sort: sum covid_test_positive_date_d ,de
ttest covid_test_positive_date_d , by( drug )
ranksum covid_test_positive_date_d,by(drug)
by drug,sort: sum calendar_day,de
ttest calendar_day , by( drug )
ranksum calendar_day,by(drug)
by drug,sort: sum d_vaccinate_treat,de
ttest d_vaccinate_treat , by( drug )
ranksum d_vaccinate_treat,by(drug)

tab drug sex,row chi
tab drug ethnicity,row chi
tab drug imd,row chi
ranksum imd,by(drug)
tab drug rural_urban,row chi
ranksum rural_urban,by(drug)
tab drug region_nhs,row chi
tab drug region_covid_therapeutics,row chi
tab drug age_group3 ,row chi
tab drug covid_test_positive_date_d ,row chi
tab drug solid_cancer ,row chi
tab drug solid_cancer_ever ,row chi
tab drug haema_disease ,row chi
tab drug haema_disease_ever ,row chi
tab drug haematological_cancer ,row chi
tab drug haematological_cancer_ever ,row chi
tab drug renal_disease ,row chi
tab drug liver_disease ,row chi
tab drug imid ,row chi
tab drug immunosupression ,row chi
tab drug solid_organ ,row chi
tab drug bmi_group4 ,row chi
tab drug diabetes ,row chi
tab drug chronic_cardiac_disease ,row chi
tab drug hypertension ,row chi
tab drug chronic_respiratory_disease ,row chi
tab drug vaccination_status ,row chi
tab drug month_after_vaccinate,row chi
tab drug calendar_month,row chi
tab drug omicron,row chi
tab drug previous_drug,row chi
tab drug covid_reinfection,row chi



save ./output/main_feasibility2.dta, replace
log close




