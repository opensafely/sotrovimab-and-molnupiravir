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
tab _t drug if failure==1&end_date==covid_hospitalisation_outcome_da&end_date!=death_with_covid_on_the_death_ce,m col
tab _t drug if failure==1&end_date==death_with_covid_on_the_death_ce,m col
tab failure drug,m col
*check censor reasons*
tab _t drug if failure==0&_t<28&end_date==death_date,m col
tab _t drug if failure==0&_t<28&end_date==dereg_date,m col
tab _t drug if failure==0&_t<28&end_date==covid_hosp_date_day_cases_mab,m col
tab _t drug if failure==0&_t<28&end_date==min(molnupiravir_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)&drug==1,m col
tab _t drug if failure==0&_t<28&end_date==min(sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)&drug==0,m col


*un-stratified Cox, with covariate adjustment, complete case*
stcox i.drug
stcox i.drug age i.sex
stcox i.drug age i.sex i.region_nhs
stcox i.drug age i.sex i.stp
*region_nhs or region_covid_therapeutics? *
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign 
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex i.region_nhs
stcox i.drug b7.age_5y_band i.sex i.stp
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex i.region_nhs
stcox i.drug age_spline* i.sex i.stp
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*PH test*
estat phtest,de
estat phtest, plot(1.drug)
graph export ./output/phtest.svg, as(svg) replace

*un-stratified Cox, missing values as a separate category*
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign
stcox i.drug age i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign
stcox i.drug b7.age_5y_band i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign 
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign 
stcox i.drug age_spline* i.sex i.region_nhs downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
estat phtest,de

*stratified Cox, complete case*
stcox i.drug age i.sex, strata(stp)
*stcox i.drug age i.sex, strata(stp week_after_campaign)
*too few events to allow two-level stratification*
stcox i.drug age i.sex i.stp, strata(week_after_campaign)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status, strata(week_after_campaign)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex, strata(stp)
stcox i.drug b7.age_5y_band i.sex i.stp, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex, strata(stp)
stcox i.drug age_spline* i.sex i.stp, strata(week_after_campaign)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
estat phtest,de
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
estat phtest,de

*stratified Cox, missing values as a separate category*
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status, strata(week_after_campaign)
stcox i.drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.stp i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.stp i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.stp i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
estat phtest,de
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
estat phtest,de



*propensity score weighted Cox*
do "analysis/ado/psmatch2.ado"
*age continuous, complete case*
psmatch2 drug age i.sex i.stp, logit
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp ) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
estat phtest,de

*age continuous, missing values as a separate categorye*
psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
estat phtest,de

*age: 5-year band, complete case*
psmatch2 drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de 
teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity b5.imd i.vaccination_status i.week_after_campaign b1.bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
estat phtest,de

*age: 5-year band, missing values as a separate categorye*
psmatch2 drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
estat phtest,de
estat phtest, plot(1.drug)
graph export ./output/phtest_psw.svg, as(svg) replace



*secondary outcomes*
*all-cause hosp/death*
*follow-up time and events*
stset end_date_allcause ,  origin(start_date) failure(failure_allcause==1)
tab _t drug,m col
by drug, sort: sum _t ,de
tab _t drug if failure_allcause==1,m col
tab _t drug if failure_allcause==1&end_date_allcause==hospitalisation_outcome_date&end_date_allcause!=death_date,m col
tab _t drug if failure_allcause==1&end_date_allcause==death_date,m col
tab failure_allcause drug if _st==1,m col
*stratified Cox, missing values as a separate category*
stcox i.drug age i.sex, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.sex, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age_spline* i.sex, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)

*2m covid hosp/death*
*follow-up time and events*
stset end_date_2m ,  origin(start_date) failure(failure_2m==1)
tab _t,m
tab _t drug,m col
by drug, sort: sum _t ,de
tab _t drug if failure_2m==1,m col
tab _t drug if failure_2m==1&end_date_2m==covid_hospitalisation_outcome_da&end_date_2m!=death_with_covid_on_the_death_ce,m col
tab _t drug if failure_2m==1&end_date_2m==death_with_covid_on_the_death_ce,m col
tab failure_2m drug if _st==1,m col
*stratified Cox, missing values as a separate category*
stcox i.drug age i.sex, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.sex, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug b7.age_5y_band i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age_spline* i.sex, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign, strata(stp)
stcox i.drug age_spline* i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)


*subgroup analysis*
stset end_date ,  origin(start_date) failure(failure==1)
stcox i.drug##i.sex age downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if sex==0, strata(stp)
stcox i.drug age downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if sex==1, strata(stp)

stcox i.drug##i.age_group3 i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_group3==0, strata(stp)
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_group3==1, strata(stp)
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_group3==2, strata(stp)

stcox i.drug##i.age_50 i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_50==0, strata(stp)
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_50==1, strata(stp)

stcox i.drug##i.age_55 i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_55==0, strata(stp)
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_55==1, strata(stp)

stcox i.drug##i.age_60 i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_60==0, strata(stp)
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_60==1, strata(stp)

stcox i.drug##i.White age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if White==1, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if White==0, strata(stp)

stcox i.drug##i.downs_syndrome  solid_cancer age i.sex  haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug  solid_cancer age i.sex  haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if downs_syndrome==0, strata(stp)
stcox i.drug##i.solid_cancer age i.sex downs_syndrome  haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug age i.sex downs_syndrome  haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if solid_cancer==1, strata(stp)
stcox i.drug age i.sex downs_syndrome  haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if solid_cancer==0, strata(stp)
stcox i.drug##i.haema_disease age i.sex downs_syndrome solid_cancer  renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer  renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if haema_disease==1, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer  renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if haema_disease==0, strata(stp)
stcox i.drug##i.renal_disease age i.sex downs_syndrome solid_cancer haema_disease  liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease  liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if renal_disease==1, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease  liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if renal_disease==0, strata(stp)
stcox i.drug##i.liver_disease renal_disease age i.sex downs_syndrome solid_cancer haema_disease   imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug  renal_disease age i.sex downs_syndrome solid_cancer haema_disease   imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if liver_disease==0, strata(stp)
stcox i.drug##i.imid age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease  immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease  immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if imid==1, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease  immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if imid==0, strata(stp)
stcox i.drug##i.hiv_aids  immunosupression age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug  immunosupression age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if hiv_aids ==0, strata(stp)
stcox i.drug##i.immunosupression age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if immunosupression==1, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if immunosupression==0, strata(stp)
stcox i.drug##i.solid_organ age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids  rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids  rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if solid_organ==1, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids  rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if solid_organ==0, strata(stp)
stcox i.drug##i.rare_neuro age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ  b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ  b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if rare_neuro==0, strata(stp)

stcox i.drug##i.bmi_g3 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_g3==1, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_g3==2, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_g3==3, strata(stp)

stcox i.drug##i.bmi_25 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_25==0, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_25==1, strata(stp)

stcox i.drug##i.bmi_30 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_30==0, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_30==1, strata(stp)

stcox i.drug##i.diabetes age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing  chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing chronic_cardiac_disease hypertension chronic_respiratory_disease if diabetes ==0, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing chronic_cardiac_disease hypertension chronic_respiratory_disease if diabetes ==1, strata(stp)

stcox i.drug##i.chronic_cardiac_disease age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes  hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes  hypertension chronic_respiratory_disease if chronic_cardiac_disease==0, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes  hypertension chronic_respiratory_disease if chronic_cardiac_disease==1, strata(stp)

stcox i.drug##i.hypertension age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease  chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease  chronic_respiratory_disease if hypertension==0, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease  chronic_respiratory_disease if hypertension==1, strata(stp)

stcox i.drug##i.chronic_respiratory_disease age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension , strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension if chronic_respiratory_disease==0, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension if chronic_respiratory_disease==1, strata(stp)

stcox i.drug##i.vaccination_3 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing  i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing  i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if vaccination_3==1, strata(stp)
*stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing  i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if vaccination_3==0, strata(stp)
*stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing  i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if vaccination_status==0, strata(stp)

stcox i.drug##i.d_postest_treat_g2 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if d_postest_treat_g2==0, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if d_postest_treat_g2==1, strata(stp)

*use minimal-adjusted model*
stcox i.drug##i.sex age , strata(stp)
stcox i.drug age if sex==0, strata(stp)
stcox i.drug age if sex==1, strata(stp)

stcox i.drug##i.age_group3 i.sex , strata(stp)
stcox i.drug i.sex  if age_group3==0, strata(stp)
stcox i.drug i.sex if age_group3==1, strata(stp)
stcox i.drug i.sex if age_group3==2, strata(stp)

stcox i.drug##i.age_50 i.sex , strata(stp)
stcox i.drug i.sex  if age_50==0, strata(stp)
stcox i.drug i.sex  if age_50==1, strata(stp)

stcox i.drug##i.age_55 i.sex , strata(stp)
stcox i.drug i.sex  if age_55==0, strata(stp)
stcox i.drug i.sex if age_55==1, strata(stp)

stcox i.drug##i.age_60 i.sex , strata(stp)
stcox i.drug i.sex if age_60==0, strata(stp)
stcox i.drug i.sex if age_60==1, strata(stp)

stcox i.drug##i.White age i.sex , strata(stp)
stcox i.drug age i.sex if White==1, strata(stp)
stcox i.drug age i.sex if White==0, strata(stp)

stcox i.drug##i.solid_cancer age i.sex , strata(stp)
stcox i.drug age i.sex if solid_cancer==1, strata(stp)
stcox i.drug age i.sex if solid_cancer==0, strata(stp)
stcox i.drug##i.haema_disease age i.sex , strata(stp)
stcox i.drug age i.sex if haema_disease==1, strata(stp)
stcox i.drug age i.sex if haema_disease==0, strata(stp)
stcox i.drug##i.renal_disease age i.sex , strata(stp)
stcox i.drug age i.sex if renal_disease==1, strata(stp)
stcox i.drug age i.sex if renal_disease==0, strata(stp)
stcox i.drug##i.liver_disease  age i.sex, strata(stp)
stcox i.drug##i.imid age i.sex , strata(stp)
stcox i.drug age i.sex  if imid==1, strata(stp)
stcox i.drug age i.sex  if imid==0, strata(stp)
stcox i.drug##i.immunosupression age i.sex , strata(stp)
stcox i.drug##i.solid_organ age i.sex , strata(stp)
stcox i.drug##i.rare_neuro age i.sex , strata(stp)

stcox i.drug##i.bmi_g3 age i.sex , strata(stp)
stcox i.drug age i.sex  if bmi_g3==1, strata(stp)
stcox i.drug age i.sex if bmi_g3==2, strata(stp)
stcox i.drug age i.sex if bmi_g3==3, strata(stp)

stcox i.drug##i.bmi_25 age i.sex , strata(stp)
stcox i.drug age i.sex if bmi_25==0, strata(stp)
stcox i.drug age i.sex if bmi_25==1, strata(stp)

stcox i.drug##i.bmi_30 age i.sex , strata(stp)
stcox i.drug age i.sex if bmi_30==0, strata(stp)
stcox i.drug age i.sex if bmi_30==1, strata(stp)

stcox i.drug##i.diabetes age i.sex , strata(stp)
stcox i.drug age i.sex if diabetes ==0, strata(stp)
stcox i.drug age i.sex if diabetes ==1, strata(stp)

stcox i.drug##i.chronic_cardiac_disease age i.sex , strata(stp)
stcox i.drug age i.sex  if chronic_cardiac_disease==0, strata(stp)
stcox i.drug age i.sex  if chronic_cardiac_disease==1, strata(stp)

stcox i.drug##i.hypertension age i.sex , strata(stp)
stcox i.drug age i.sex if hypertension==0, strata(stp)
stcox i.drug age i.sex  if hypertension==1, strata(stp)

stcox i.drug##i.chronic_respiratory_disease age i.sex  , strata(stp)
stcox i.drug age i.sex  if chronic_respiratory_disease==0, strata(stp)
stcox i.drug age i.sex  if chronic_respiratory_disease==1, strata(stp)

stcox i.drug##i.vaccination_3 age i.sex , strata(stp)
stcox i.drug age i.sex  if vaccination_3==1, strata(stp)
*stcox i.drug age i.sex  if vaccination_3==0, strata(stp)
*stcox i.drug age i.sex if vaccination_status==0, strata(stp)

stcox i.drug##i.d_postest_treat_g2 age i.sex , strata(stp)
stcox i.drug age i.sex if d_postest_treat_g2==0, strata(stp)
stcox i.drug age i.sex if d_postest_treat_g2==1, strata(stp)

*use un-stratified minimal-adjusted model*
stcox i.drug##i.sex age  i.stp
stcox i.drug age  i.stp if sex==0 
stcox i.drug age  i.stp if sex==1 

stcox i.drug##i.age_group3 i.sex   i.stp
stcox i.drug i.sex  i.stp if age_group3==0 
stcox i.drug i.sex  i.stp if age_group3==1 
stcox i.drug i.sex  i.stp if age_group3==2 

stcox i.drug##i.age_50 i.sex  i.stp
stcox i.drug i.sex  i.stp if age_50==0 
stcox i.drug i.sex  i.stp if age_50==1 

stcox i.drug##i.age_55 i.sex  i.stp
stcox i.drug i.sex  i.stp if age_55==0 
stcox i.drug i.sex  i.stp if age_55==1 

stcox i.drug##i.age_60 i.sex  i.stp
stcox i.drug i.sex  i.stp if age_60==0 
stcox i.drug i.sex  i.stp if age_60==1 

stcox i.drug##i.White age i.sex  i.stp
stcox i.drug age i.sex i.stp if White==1 
stcox i.drug age i.sex i.stp if White==0 

stcox i.drug##i.solid_cancer age i.sex i.stp
stcox i.drug age i.sex  i.stp if solid_cancer==1
stcox i.drug age i.sex  i.stp if solid_cancer==0
stcox i.drug##i.haema_disease age i.sex i.stp
stcox i.drug age i.sex  i.stp if haema_disease==1 
stcox i.drug age i.sex  i.stp if haema_disease==0 
stcox i.drug##i.renal_disease age i.sex  i.stp
stcox i.drug age i.sex i.stp if renal_disease==1 
stcox i.drug age i.sex i.stp if renal_disease==0 
stcox i.drug##i.liver_disease  age i.sex i.stp
stcox i.drug  age i.sex i.stp if liver_disease==1
stcox i.drug  age i.sex i.stp if liver_disease==0
stcox i.drug##i.imid age i.sex  i.stp
stcox i.drug age i.sex i.stp  if imid==1 
stcox i.drug age i.sex i.stp  if imid==0 
stcox i.drug##i.immunosupression age i.sex i.stp
stcox i.drug age i.sex i.stp if immunosupression==1 
stcox i.drug age i.sex i.stp if immunosupression==0 
stcox i.drug##i.solid_organ age i.sex  i.stp
stcox i.drug age i.sex i.stp if solid_organ==1 
stcox i.drug age i.sex i.stp if solid_organ==0 
stcox i.drug##i.rare_neuro age i.sex  i.stp
stcox i.drug age i.sex i.stp if rare_neuro==1 
stcox i.drug age i.sex i.stp if rare_neuro==0

stcox i.drug##i.bmi_g3 age i.sex  i.stp
stcox i.drug age i.sex  i.stp if bmi_g3==1 
stcox i.drug age i.sex  i.stp if bmi_g3==2 
stcox i.drug age i.sex  i.stp if bmi_g3==3 

stcox i.drug##i.bmi_25 age i.sex  i.stp
stcox i.drug age i.sex i.stp if bmi_25==0 
stcox i.drug age i.sex i.stp if bmi_25==1 

stcox i.drug##i.bmi_30 age i.sex  i.stp
stcox i.drug age i.sex i.stp if bmi_30==0 
stcox i.drug age i.sex i.stp if bmi_30==1 

stcox i.drug##i.diabetes age i.sex  i.stp
stcox i.drug age i.sex i.stp if diabetes ==0 
stcox i.drug age i.sex i.stp if diabetes ==1 

stcox i.drug##i.chronic_cardiac_disease age i.sex  i.stp
stcox i.drug age i.sex  i.stp if chronic_cardiac_disease==0 
stcox i.drug age i.sex  i.stp if chronic_cardiac_disease==1 

stcox i.drug##i.hypertension age i.sex  i.stp
stcox i.drug age i.sex  i.stp if hypertension==0 
stcox i.drug age i.sex  i.stp if hypertension==1 

stcox i.drug##i.chronic_respiratory_disease age i.sex  i.stp
stcox i.drug age i.sex  i.stp if chronic_respiratory_disease==0 
stcox i.drug age i.sex  i.stp if chronic_respiratory_disease==1 

stcox i.drug##i.vaccination_3 age i.sex  i.stp
stcox i.drug age i.sex  i.stp if vaccination_3==1 
stcox i.drug age i.sex  i.stp if vaccination_3==0 
*stcox i.drug age i.sex if vaccination_status==0, strata(stp)

stcox i.drug##i.d_postest_treat_g2 age i.sex  i.stp
stcox i.drug age i.sex  i.stp if d_postest_treat_g2==0 
stcox i.drug age i.sex  i.stp if d_postest_treat_g2==1 

*use un-stratified fully-adjusted model*
stcox i.drug##i.sex age downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if sex==0 
stcox i.drug age downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if sex==1 

stcox i.drug##i.age_group3 i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
*stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if age_group3==0 
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if age_group3==1 
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if age_group3==2 

stcox i.drug##i.age_50 i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if age_50==0 
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if age_50==1 

stcox i.drug##i.age_55 i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if age_55==0 
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if age_55==1 

stcox i.drug##i.age_60 i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if age_60==0 
stcox i.drug i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if age_60==1 

stcox i.drug##i.White age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if White==1 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if White==0 

stcox i.drug##i.solid_cancer age i.sex downs_syndrome  haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp 
stcox i.drug age i.sex downs_syndrome  haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp  if solid_cancer==1 
stcox i.drug age i.sex downs_syndrome  haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp  if solid_cancer==0 
stcox i.drug##i.haema_disease age i.sex downs_syndrome solid_cancer  renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer  renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if haema_disease==1 
stcox i.drug age i.sex downs_syndrome solid_cancer  renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if haema_disease==0 
stcox i.drug##i.renal_disease age i.sex downs_syndrome solid_cancer haema_disease  liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease  liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if renal_disease==1 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease  liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if renal_disease==0 
stcox i.drug##i.liver_disease renal_disease age i.sex downs_syndrome solid_cancer haema_disease   imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp 
stcox i.drug  renal_disease age i.sex downs_syndrome solid_cancer haema_disease   imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if liver_disease==1
stcox i.drug  renal_disease age i.sex downs_syndrome solid_cancer haema_disease   imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if liver_disease==0
stcox i.drug##i.imid age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease  immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease  immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if imid==1 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease  immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if imid==0 
stcox i.drug##i.immunosupression age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if immunosupression==1 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if immunosupression==0 
stcox i.drug##i.solid_organ age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids  rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp 
*stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids  rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if solid_organ==1 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids  rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if solid_organ==0
stcox i.drug##i.rare_neuro age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ  b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ  b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if rare_neuro==1 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ  b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if rare_neuro==0 

stcox i.drug##i.bmi_g3 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if bmi_g3==1 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if bmi_g3==2 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if bmi_g3==3 

stcox i.drug##i.bmi_25 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp  if bmi_25==0 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp  if bmi_25==1 

stcox i.drug##i.bmi_30 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if bmi_30==0 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if bmi_30==1 

stcox i.drug##i.diabetes age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing  chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if diabetes ==0 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if diabetes ==1 

stcox i.drug##i.chronic_cardiac_disease age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes  hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes  hypertension chronic_respiratory_disease i.stp  if chronic_cardiac_disease==0 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes  hypertension chronic_respiratory_disease i.stp  if chronic_cardiac_disease==1 

stcox i.drug##i.hypertension age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease  chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease  chronic_respiratory_disease  i.stp if hypertension==0
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease  chronic_respiratory_disease  i.stp if hypertension==1 

stcox i.drug##i.chronic_respiratory_disease age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension  i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension  i.stp if chronic_respiratory_disease==0 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension  i.stp if chronic_respiratory_disease==1 

stcox i.drug##i.vaccination_3 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing  i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing  i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if vaccination_3==1 
*stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing  i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if vaccination_3==0 
*stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing  i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if vaccination_status==0 

stcox i.drug##i.d_postest_treat_g2 age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.stp 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if d_postest_treat_g2==0 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  i.stp if d_postest_treat_g2==1 



*sensitivity analysis*
stset end_date ,  origin(start_date) failure(failure==1)
*additionally adjusting for days between test positive and treatment initiation, and days/months between last vaccination date and treatment initiation; *
stcox i.drug age i.sex i.d_postest_treat_missing i.month_after_vaccinate_missing, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro i.d_postest_treat_missing i.month_after_vaccinate_missing, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign i.d_postest_treat_missing i.month_after_vaccinate_missing, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.d_postest_treat_missing i.month_after_vaccinate_missing, strata(stp)
*excluding patients with treatment records of both sotrovimab and molnupiravir, or with treatment records of any other therapies*
stcox i.drug age i.sex if (sotrovimab_covid_therapeutics==.|molnupiravir_covid_therapeutics==.)&paxlovid_covid_therapeutics==.&remdesivir_covid_therapeutics==.&casirivimab_covid_therapeutics==., strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro if (sotrovimab_covid_therapeutics==.|molnupiravir_covid_therapeutics==.)&paxlovid_covid_therapeutics==.&remdesivir_covid_therapeutics==.&casirivimab_covid_therapeutics==., strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign if (sotrovimab_covid_therapeutics==.|molnupiravir_covid_therapeutics==.)&paxlovid_covid_therapeutics==.&remdesivir_covid_therapeutics==.&casirivimab_covid_therapeutics==., strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (sotrovimab_covid_therapeutics==.|molnupiravir_covid_therapeutics==.)&paxlovid_covid_therapeutics==.&remdesivir_covid_therapeutics==.&casirivimab_covid_therapeutics==., strata(stp)
*excluding patients who were identified to be pregnant at treatment initiation*
*stcox i.drug age i.sex if pregnancy!=1, strata(stp)
*stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro if pregnancy!=1, strata(stp)
*stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign if pregnancy!=1, strata(stp)
*stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if pregnancy!=1, strata(stp)
*excluding patients who did not have a positive SARS-CoV-2 test record before treatment or initiated treatment after 5 days since positive SARS-CoV-2 test*
stcox i.drug age i.sex if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
*create a 1-day lag in the follow-up start date *
stcox i.drug age i.sex if _t>=2, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro if _t>=2, strata(stp) 
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign if _t>=2, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _t>=2, strata(stp)
*create a 2-day lag in the follow-up start date *
stcox i.drug age i.sex if _t>=3, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro if _t>=3, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign if _t>=3, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer haema_disease renal_disease liver_disease imid immunosupression hiv_aids solid_organ rare_neuro b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status i.week_after_campaign b1.bmi_g4_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _t>=3, strata(stp)


*safety outcome*
*death not due to covid*
by drug, sort: count if death_date!=.
by drug, sort: count if death_with_covid_on_the_death_ce!=.
by drug, sort: count if death_with_covid_on_the_death_ce==.&death_date!=.
gen death_without_covid=death_date if death_with_covid_on_the_death_ce==.&death_date!=.

log close
