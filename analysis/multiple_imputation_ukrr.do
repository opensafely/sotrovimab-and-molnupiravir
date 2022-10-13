********************************************************************************
*
*	Do-file:		multiple_imputation.do
*
*	Project:		sotrovimab-and-molnupiravir
*
*	Programmed by:	Bang Zheng
*
*	Data used:		output/main.dta
*
*	Output:	        logs/MI.log  
*
********************************************************************************
*
*	Purpose: This do-file implements stratified Cox regression after multiple imputation for covariates.
*  
********************************************************************************

* Open a log file
cap log close
log using ./logs/MI_ukrr, replace t
clear

use ./output/ukrr/main_ukrr.dta

stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1

*MI*
*install ice package by changing ado filepath*
sysdir
sysdir set PLUS "analysis/ado"
sysdir set PERSONAL "analysis/ado"

set seed 1000

ice m.White m.bmi_g3  m.imd m.years_since_rrt  drug age i.sex i.region_nhs  i.rrt_mod_Tx imid immunosupression_new  solid_organ_new i.vaccination_3 calendar_day_spline* diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease failure, m(5) saving(imputed,replace)  
clear
use imputed
mi import ice, imputed(White bmi_g3  imd years_since_rrt)
mi stset end_date ,  origin(start_date) failure(failure==1)
*MI with stratified Cox*
mi estimate, hr: stcox i.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White b5.imd i.vaccination_3 calendar_day_spline*, strata(region_nhs)
mi estimate, hr: stcox i.drug age i.sex  solid_cancer_new haema_disease i.years_since_rrt i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White b5.imd i.vaccination_3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(region_nhs)
*MI with PSW*
mi estimate, saving(miest):   logit  drug age i.sex i.region_nhs  solid_cancer_new haema_disease i.years_since_rrt i.rrt_mod_Tx  imid immunosupression_new  solid_organ_new  b1.White b5.imd i.vaccination_3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
mi predict xb_mi using miest
mi xeq: generate _pscore = invlogit(xb_mi)
sort patid
by patid: egen _pscore1=min(_pscore)
gen psweight=cond( drug ==1,1/_pscore1,1/(1-_pscore1)) if _pscore1!=.
sum psweight,de
by drug, sort: sum _pscore1 ,de
mi stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
mi estimate, hr: stcox i.drug
erase miest.ster

log close
