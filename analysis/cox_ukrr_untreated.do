********************************************************************************
*
*	Do-file:		cox.do
*
*	Project:		sotrovimab-and-molnupiravir
*
*	Programmed by:	Bang Zheng
*
*	Data used:		output/main.dta
*
*	Output:	        logs/cox.log  output/phtest.svg  output/phtest_psw.svg
*
********************************************************************************
*
*	Purpose: This do-file implements stratified Cox regression, propensity score
*   weighted Cox, and subgroup analyses.
*  
********************************************************************************

* Open a log file
cap log close
log using ./logs/cox_ukrr_untreated, replace t
clear

use ./output/ukrr/main_ukrr_untreated.dta

*follow-up time and events*
stset end_date ,  origin(covid_test_positive_date) failure(failure==1) id(patient_id)
keep if _st==1
tab _t drug if failure==1,m col
tab failure drug,m col
*time-varying Cox*
stsplit timeband, at(0) after(time=start_date)
replace drug=-1 if _t0==0&covid_test_positive_date<start_date
replace drug=2 if drug==-1
tab drug,m

drop age_spline* calendar_day_spline*
mkspline age_spline = age, cubic nknots(4)
mkspline calendar_day_spline = day_after_campaign, cubic nknots(4)
*un-stratified Cox, missing values as a separate category*
stcox b2.drug age i.sex i.region_nhs  
stcox b2.drug age i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new 
stcox b2.drug age i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline*
stcox b2.drug age i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: 5-year band*
stcox b2.drug b7.age_5y_band i.sex i.region_nhs  
stcox b2.drug b7.age_5y_band i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new 
stcox b2.drug b7.age_5y_band i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline*
stcox b2.drug b7.age_5y_band i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: Restricted cubic spline*
stcox b2.drug age_spline* i.sex i.region_nhs  
stcox b2.drug age_spline* i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new 
stcox b2.drug age_spline* i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* 
stcox b2.drug age_spline* i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease


*stratified Cox, missing values as a separate category*
stcox b2.drug age i.sex   , strata(region_nhs)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new , strata(region_nhs)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline*, strata(region_nhs)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs) vce(r)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs) vce(cluster(patient_id))

*age: 5-year band*
stcox b2.drug b7.age_5y_band i.sex   , strata(region_nhs)
stcox b2.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new , strata(region_nhs)
stcox b2.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline*, strata(region_nhs)
stcox b2.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs)
*age: Restricted cubic spline*
stcox b2.drug age_spline* i.sex   , strata(region_nhs)
stcox b2.drug age_spline* i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new , strata(region_nhs)
stcox b2.drug age_spline* i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline*, strata(region_nhs)
stcox b2.drug age_spline* i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* i.b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs)
estat phtest,de
*by rrt_mod_Tx*
by rrt_mod_Tx, sort: stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs)


clear
use ./output/ukrr/main_ukrr_untreated.dta
*secondary outcomes*
*all-cause hosp/death*
*follow-up time and events*
stset end_date_allcause ,  origin(covid_test_positive_date) failure(failure_allcause==1) id(patient_id)
keep if _st==1
tab _t drug if failure_allcause==1,m col
tab failure_allcause drug,m col
*time-varying Cox*
stsplit timeband, at(0) after(time=start_date)
replace drug=-1 if _t0==0&covid_test_positive_date<start_date
replace drug=2 if drug==-1
tab drug,m

drop age_spline* calendar_day_spline*
mkspline age_spline = age, cubic nknots(4)
mkspline calendar_day_spline = day_after_campaign, cubic nknots(4)
*stratified Cox, missing values as a separate category*
stcox b2.drug age i.sex, strata(region_nhs)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new , strata(region_nhs)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline*, strata(region_nhs)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs) vce(r)
stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs) vce(cluster(patient_id))
stcox b2.drug b7.age_5y_band i.sex, strata(region_nhs)
stcox b2.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new , strata(region_nhs)
stcox b2.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline*, strata(region_nhs)
stcox b2.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs)
stcox b2.drug age_spline* i.sex, strata(region_nhs)
stcox b2.drug age_spline* i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new , strata(region_nhs)
stcox b2.drug age_spline* i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline*, strata(region_nhs)
stcox b2.drug age_spline* i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs)
*by rrt_mod_Tx*
by rrt_mod_Tx, sort: stcox b2.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt_missing  imid immunosupression_new  solid_organ_new  b1.White_with_missing b5.imd_with_missing i.vaccination_3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs)




log close
