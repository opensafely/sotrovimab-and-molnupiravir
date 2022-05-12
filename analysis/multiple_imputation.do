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
log using ./logs/MI, replace t
clear

use ./output/main.dta

stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1

*MI*
do "analysis/ado/ice.ado"
set seed 1000

ice m.ethnicity m.bmi_group4  m.imd   drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro i.vaccination_status i.week_after_campaign diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease failure, m(5) saving(imputed,replace)  
clear
use imputed
mi import ice, imputed(ethnicity bmi_group4  imd)
mi stset end_date ,  origin(start_date) failure(failure==1)
mi estimate, hr: stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign,strata(stp)
mi estimate, hr: stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)


log close
