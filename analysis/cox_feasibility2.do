********************************************************************************
*
*	Do-file:		cox.do
*
*	Project:		sotrovimab-and-molnupiravir
*
*	Programmed by:	Bang Zheng
*
**
********************************************************************************
*
*	Purpose: This do-file implements stratified Cox regression, propensity score
*   weighted Cox, and subgroup analyses.
*  
********************************************************************************

* Open a log file
cap log close
log using ./logs/cox_feasibility2, replace t
clear

use ./output/main_feasibility2.dta

*follow-up time and events*
stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1
tab _t,m
tab _t drug,m col
by drug, sort: sum _t ,de
tab _t drug if failure==1,m col
tab failure drug,m col

*stratified Cox, complete case*
stcox i.drug age_spline* i.sex, strata(region_covid_therapeutics)
*stcox i.drug age i.sex, strata(stp week_after_campaign)
mkspline calendar_day_spline = calendar_day, cubic nknots(4)
stcox i.drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)
by drug, sort: stcox age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)

*stratified Cox, missing values as a separate category*
stcox i.drug age_spline* i.sex b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)
estat phtest,de
estat phtest, plot(1.drug)
graph export ./output/phtest_feasibility.svg, as(svg) replace
by drug, sort: stcox age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)



*propensity score weighted Cox*
do "analysis/ado/psmatch2.ado"
psmatch2 drug age_spline* i.sex i.region_covid_therapeutics, logit
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age_spline* i.sex i.region_covid_therapeutics ) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age_spline* i.sex i.region_covid_therapeutics b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age_spline* i.sex i.region_covid_therapeutics b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
estat phtest,de
estat phtest, plot(1.drug)
graph export ./output/phtest_psw_feasibility2.svg, as(svg) replace



*secondary outcomes*
*90 day death*
stset end_date_90d ,  origin(start_date) failure(failure_90d==1)
tab _t drug,m col
by drug, sort: sum _t ,de
tab failure_90d drug if _st==1,m col
*stratified Cox, missing values as a separate category*
stcox i.drug age_spline* i.sex, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)

*180 day death*
stset end_date_180d ,  origin(start_date) failure(failure_180d==1)
tab _t drug,m col
by drug, sort: sum _t ,de
tab failure_180d drug if _st==1,m col
*stratified Cox, missing values as a separate category*
stcox i.drug age_spline* i.sex, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)

*180 day death*
stset end_date_1y ,  origin(start_date) failure(failure_1y==1)
tab _t drug,m col
by drug, sort: sum _t ,de
tab failure_1y drug if _st==1,m col
*stratified Cox, missing values as a separate category*
stcox i.drug age_spline* i.sex, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)

*180 day death*
stset end_date_2y ,  origin(start_date) failure(failure_2y==1)
tab _t drug,m col
by drug, sort: sum _t ,de
tab failure_2y drug if _st==1,m col
*stratified Cox, missing values as a separate category*
stcox i.drug age_spline* i.sex, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)


*subgroup analysis*
stset end_date ,  origin(start_date) failure(failure==1)
stcox i.drug##i.omicron age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug if omicron==0, strata(region_covid_therapeutics)
stcox i.drug age_spline* i.sex solid_cancer_ever haema_disease_ever renal_disease liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug if omicron==1, strata(region_covid_therapeutics)



log close
