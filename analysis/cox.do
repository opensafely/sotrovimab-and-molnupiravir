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
log using ./logs/cox, replace t
clear

use ./output/main.dta

*follow-up time and events*
stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1
tab _t,m
tab _t drug,m col
by drug, sort: sum _t ,de
tab _t drug if failure==1,m col
tab failure drug,m col



*un-stratified Cox, with covariate adjustment, complete case*
stcox i.drug
stcox i.drug age i.sex
stcox i.drug age i.sex i.region_nhs
stcox i.drug age i.sex i.stp
*region_nhs or region_covid_therapeutics? *
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex i.region_nhs
stcox i.drug b7.age_5y_band i.sex i.stp
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex i.region_nhs
stcox i.drug age_spline* i.sex i.stp
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*PH test*
estat phtest,de
estat phtest, plot(1.drug)
graph export ./output/phtest.svg, as(svg) replace

*un-stratified Cox, missing values as a separate category*
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
estat phtest,de

*stratified Cox, complete case*
stcox i.drug age i.sex, strata(stp)
*stcox i.drug age i.sex, strata(stp week_after_campaign)
*too few events to allow two-level stratification*
stcox i.drug age i.sex i.stp, strata(week_after_campaign)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.d_postest_treat_g2, strata(week_after_campaign)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex, strata(stp)
stcox i.drug b7.age_5y_band i.sex i.stp, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.d_postest_treat_g2, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex, strata(stp)
stcox i.drug age_spline* i.sex i.stp, strata(week_after_campaign)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
estat phtest,de
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.d_postest_treat_g2, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
estat phtest,de

*stratified Cox, missing values as a separate category*
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.d_postest_treat_missing, strata(week_after_campaign)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.stp i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.stp i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.d_postest_treat_missing, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.stp i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
estat phtest,de
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.d_postest_treat_missing, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
estat phtest,de



*propensity score weighted Cox*
do "analysis/ado/psmatch2.ado"
*age continuous, complete case*
psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2, logit
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
estat phtest,de

*age continuous, missing values as a separate categorye*
psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
estat phtest,de

*age: 5-year band, complete case*
psmatch2 drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de 
teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign i.d_postest_treat_g2 b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
estat phtest,de

*age: 5-year band, missing values as a separate categorye*
psmatch2 drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
estat phtest,de
estat phtest, plot(1.drug)
graph export ./output/phtest_psw.svg, as(svg) replace


log close

*secondary outcomes*

*subgroup analysis*


