logfilename <- "./logs/anaphylaxis_untreated_update.txt"
sink(logfilename, append = FALSE, split = FALSE)

# Clear workspace
rm(list = ls())

# Import dataset
dataset <- read.csv("./output/input_anaphylaxis_untreated_update.csv", header = TRUE)

dataset <- dataset[!(dataset$cancer_opensafely_snomed_new == "" &
                       dataset$immunosuppresant_drugs_nhsd == "" &
                       dataset$oral_steroid_drugs_nhsd == "" &
                       dataset$immunosupression_nhsd_new == "" &
                       dataset$solid_organ_transplant_nhsd_new == "" &
                       dataset$downs_syndrome_nhsd == "" &
                       dataset$haematological_disease_nhsd == "" &
                       dataset$ckd_stage_5_nhsd == "" &
                       dataset$liver_disease_nhsd == "" &
                       dataset$hiv_aids_nhsd == "" &
                       dataset$multiple_sclerosis_nhsd == "" &
                       dataset$motor_neurone_disease_nhsd == "" &
                       dataset$myasthenia_gravis_nhsd == "" &
                       dataset$huntingtons_disease_nhsd == ""), ]

library(lubridate)

date_vars <- c("sotrovimab_covid_therapeutics", "molnupiravir_covid_therapeutics", "paxlovid_covid_therapeutics",
               "remdesivir_covid_therapeutics", "casirivimab_covid_therapeutics", "date_treated", "start_date",
               "death_date", "dereg_date", "last_vaccination_date", "cancer_opensafely_snomed_new",
               "immunosuppresant_drugs_nhsd", "oral_steroid_drugs_nhsd", "immunosupression_nhsd_new",
               "solid_organ_transplant_nhsd_new", "downs_syndrome_nhsd", "haematological_disease_nhsd",
               "ckd_stage_5_nhsd", "liver_disease_nhsd", "hiv_aids_nhsd", "multiple_sclerosis_nhsd",
               "motor_neurone_disease_nhsd", "myasthenia_gravis_nhsd", "huntingtons_disease_nhsd",
               "death_with_anaphylaxis_date", "death_with_anaph_underly_date", "death_with_anaphylaxis_date2",
               "death_with_anaph_underly_date2", "death_with_anaphylaxis_date3", "death_with_anaphylaxis_date_pre",
               "death_with_anaph_underly_date_pre", "hospitalisation_anaph", "hosp_discharge_anaph",
               "hospitalisation_anaph_underly", "hospitalisation_anaph2", "hospitalisation_anaph_underly2",
               "hospitalisation_anaph3", "hospitalisation_anaph_pre", "hosp_anaph_underly_pre", "AE_anaph",
               "AE_anaph2", "AE_anaph3", "AE_anaph4", "AE_anaph_pre", "AE_anaph2_pre", "GP_anaph", "GP_anaph2",
               "GP_anaph_pre", "GP_anaph2_pre", "date_treated1", "sotrovimab_covid_therapeutics1",
               "molnupiravir_covid_therapeutics1", "paxlovid_covid_therapeutics1",
               "primary_covid_hospital_discharge_date", "primary_covid_hospital_admission_date",
               "any_covid_hospital_discharge_date", "any_covid_hospital_admission_date", "hosp_anaph_pre_1y",
               "AE_anaph_pre_1y", "AE_anaph2_pre_1y", "GP_anaph_pre_1y", "hosp_anaph_pre_1m", "AE_anaph2_pre_1m", "GP_anaph_pre_1m")

for (var in date_vars) {
  if (var %in% names(dataset)) {
    dataset[[var]] <- as.Date(dataset[[var]], format = "%Y-%m-%d")
  }
}

dataset <- subset(dataset, registered_eligible == 1&(is.na(dataset$date_treated) | dataset$date_treated == "")
                  & start_date >= as.Date("2021-12-16") & start_date <= as.Date("2023-01-28"))

dataset$oral_steroid_drugs_nhsd[dataset$oral_steroid_drug_nhsd_3m_count < 2 & dataset$oral_steroid_drug_nhsd_12m_count < 4] <- NA

# Generate imid_nhsd variable as the minimum of oral_steroid_drugs_nhsd and immunosuppresant_drugs_nhsd
dataset$imid_nhsd <- pmin(dataset$oral_steroid_drugs_nhsd, dataset$immunosuppresant_drugs_nhsd, na.rm = T)

# Generate rare_neuro_nhsd variable as the minimum of multiple_sclerosis_nhsd, motor_neurone_disease_nhsd, myasthenia_gravis_nhsd, and huntingtons_disease_nhsd
dataset$rare_neuro_nhsd <- pmin(dataset$multiple_sclerosis_nhsd, dataset$motor_neurone_disease_nhsd, dataset$myasthenia_gravis_nhsd, dataset$huntingtons_disease_nhsd, na.rm = T)

# Generate binary variables based on conditions
dataset$downs_syndrome <- as.integer(dataset$downs_syndrome_nhsd <= dataset$start_date)
dataset$solid_cancer_new <- as.integer(dataset$cancer_opensafely_snomed_new <= dataset$start_date)
dataset$haema_disease <- as.integer(dataset$haematological_disease_nhsd <= dataset$start_date)
dataset$renal_disease <- as.integer(dataset$ckd_stage_5_nhsd <= dataset$start_date)
dataset$liver_disease <- as.integer(dataset$liver_disease_nhsd <= dataset$start_date)
dataset$imid <- as.integer(dataset$imid_nhsd <= dataset$start_date)
dataset$immunosupression_new <- as.integer(dataset$immunosupression_nhsd_new <= dataset$start_date)
dataset$hiv_aids <- as.integer(dataset$hiv_aids_nhsd <= dataset$start_date)
dataset$solid_organ_new <- as.integer(dataset$solid_organ_transplant_nhsd_new <= dataset$start_date)
dataset$rare_neuro <- as.integer(dataset$rare_neuro_nhsd <= dataset$start_date)

# Generate high_risk_group_new variable based on the combination of binary variables
dataset$high_risk_group_new <- as.integer((dataset$downs_syndrome==1| dataset$solid_cancer_new==1|dataset$haema_disease==1|
                                             dataset$renal_disease==1| dataset$liver_disease==1| dataset$imid==1|
                                             dataset$immunosupression_new==1| dataset$hiv_aids==1|
                                             dataset$solid_organ_new==1| dataset$rare_neuro==1) )

print("Generate frequency table for high_risk_group_new variable")
table(dataset$high_risk_group_new)

# Keep observations where high_risk_group_new is equal to 1
dataset <- subset(dataset,high_risk_group_new == 1)

print("summary(dataset$death_with_anaphylaxis_date)")
summary(dataset$death_with_anaphylaxis_date)

print("Generate binary variable death based on death_with_anaphylaxis_date")
dataset$death <- as.integer(!is.na(dataset$death_with_anaphylaxis_date))

print("Frequency table for death variable")
table(dataset$death)

# Calculate day_death variable as the difference between death_with_anaphylaxis_date and start_date
dataset$day_death <- as.integer(dataset$death_with_anaphylaxis_date - dataset$start_date)

print("Summarize day_death variable")
summary(dataset$day_death)

# Generate binary variable death_28d based on conditions
dataset$death_28d <- as.integer(!is.na(dataset$death_with_anaphylaxis_date) & dataset$day_death <= 28)

print("Frequency table for death_28d variable")
table(dataset$death_28d)

print("Summarize death_with_anaph_underly_date variable")
summary(dataset$death_with_anaph_underly_date)

print("Summarize death_with_anaph_underly_date variable based on condition")
summary(dataset$death_with_anaph_underly_date[dataset$day_death <= 28])

print("Summarize death_with_anaphylaxis_date2 variable")
summary(dataset$death_with_anaphylaxis_date2)

print("Summarize death_with_anaph_underly_date2 variable")
summary(dataset$death_with_anaph_underly_date2)

print("Summarize death_with_anaphylaxis_date3 variable")
summary(dataset$death_with_anaphylaxis_date3)

print("Summarize death_with_anaphylaxis_date_pre variable")
summary(dataset$death_with_anaphylaxis_date_pre)

print("Summarize death_with_anaph_underly_date_pr variable")
summary(dataset$death_with_anaph_underly_date_pre)


print("Summarize hospitalisation_anaph variable")
summary(dataset$hospitalisation_anaph)

print("Generate binary variable hosp based on hospitalisation_anaph")
dataset$hosp <- as.integer(!is.na(dataset$hospitalisation_anaph))

print("Frequency table for hosp variable")
table(dataset$hosp)

print("Calculate day_hosp variable as the difference between hospitalisation_anaph and start_date")
dataset$day_hosp <- as.integer(dataset$hospitalisation_anaph - dataset$start_date)

print("Summarize day_hosp variable")
summary(dataset$day_hosp)

print("Generate binary variable hosp_28d based on conditions")
dataset$hosp_28d <- as.integer(!is.na(dataset$hospitalisation_anaph) & dataset$day_hosp <= 28)

print("Frequency table for hosp_28d variable")
table(dataset$hosp_28d)

print("Frequency table for hospitalisation_anaph variable when hosp_28d is equal to 1")
table(dataset$hospitalisation_anaph[dataset$hosp_28d == 1])

# Calculate day_discharge variable as the difference between hosp_discharge_anaph and hospitalisation_anaph
dataset$day_discharge <- as.integer(dataset$hosp_discharge_anaph - dataset$hospitalisation_anaph)

print("Summarize day_discharge variable")
summary(dataset$day_discharge)

print("Summarize hospitalisation_anaph_underly variable")
summary(dataset$hospitalisation_anaph_underly)

print("Summarize hospitalisation_anaph_underly variable based on condition")
summary(dataset$hospitalisation_anaph_underly[dataset$day_hosp <= 28])

print("Summarize hospitalisation_anaph2 variable")
summary(dataset$hospitalisation_anaph2)

print("Summarize hospitalisation_anaph2 variable based on condition")
summary(dataset$hospitalisation_anaph2[dataset$day_hosp <= 28])

print("Summarize hospitalisation_anaph_underly2 variable")
summary(dataset$hospitalisation_anaph_underly2)

print("Summarize hospitalisation_anaph3 variable")
summary(dataset$hospitalisation_anaph3)

print("Summarize hospitalisation_anaph3 variable based on condition")
summary(dataset$hospitalisation_anaph3[dataset$day_hosp <= 28])

print("Summarize hospitalisation_anaph_pre variable")
summary(dataset$hospitalisation_anaph_pre)

print("Summarize hosp_anaph_underly_pre variable")
summary(dataset$hosp_anaph_underly_pre)

print("Summarize hosp_anaph_pre_1y variable")
summary(dataset$hosp_anaph_pre_1y)

table(dataset$registered_pre_4y)

table(dataset$hosp_anaph_pre_1y_n)
summary(dataset$hosp_anaph_pre_1m)



print("Summarize AE_anaph variable")
summary(dataset$AE_anaph)

# Generate binary variable AE based on AE_anaph
dataset$AE <- as.integer(!is.na(dataset$AE_anaph))

print("Frequency table for AE variable")
table(dataset$AE)

# Calculate day_AE variable as the difference between AE_anaph and start_date
dataset$day_AE <- as.integer(dataset$AE_anaph - dataset$start_date)

print("Summarize day_AE variable")
summary(dataset$day_AE)

# Generate binary variable AE_28d based on conditions
dataset$AE_28d <- as.integer(!is.na(dataset$AE_anaph) & dataset$day_AE <= 28)

print("Frequency table for AE_28d variable")
table(dataset$AE_28d)

print("Frequency table for AE_anaph variable when AE_28d is equal to 1")
table(dataset$AE_anaph[dataset$AE_28d == 1])

print("Summarize AE_anaph2 variable")
summary(dataset$AE_anaph2)

print("Summarize AE_anaph3 variable")
summary(dataset$AE_anaph3)

print("Summarize AE_anaph4 variable")
summary(dataset$AE_anaph4)

# Generate binary variable AE_28d2 based on conditions
dataset$AE_28d2 <- as.integer(!is.na(dataset$AE_anaph2) & dataset$day_AE <= 28)

print("Frequency table for AE_28d2 variable")
table(dataset$AE_28d2)

print("Frequency table for AE_anaph variable when AE_28d2 is equal to 1")
table(dataset$AE_anaph[dataset$AE_28d2 == 1])

print("Summarize AE_anaph2 variable based on condition")
summary(dataset$AE_anaph2[dataset$day_AE <= 28])

print("Summarize AE_anaph3 variable based on condition")
summary(dataset$AE_anaph3[dataset$day_AE <= 28])

print("Summarize AE_anaph4 variable based on condition")
summary(dataset$AE_anaph4[dataset$day_AE <= 28])

print("Summarize AE_anaph_pre variable")
summary(dataset$AE_anaph_pre)

print("Summarize AE_anaph2_pre variable")
summary(dataset$AE_anaph2_pre)

print("Summarize AE_anaph_pre_1y variable")
summary(dataset$AE_anaph_pre_1y)

print("Summarize AE_anaph2_pre_1y variable")
summary(dataset$AE_anaph2_pre_1y)

table(dataset$AE_anaph2_pre_1y_n)
print("Summarize AE_anaph2_pre_1m variable")
summary(dataset$AE_anaph2_pre_1m)

print("Summarize GP_anaph variable")
summary(dataset$GP_anaph)

# Generate binary variable GP based on GP_anaph
dataset$GP <- as.integer(!is.na(dataset$GP_anaph) )

print("Frequency table for GP variable")
table(dataset$GP)

# Calculate day_GP variable as the difference between GP_anaph and start_date
dataset$day_GP <- as.integer(dataset$GP_anaph - dataset$start_date)

print("Summarize day_GP variable")
summary(dataset$day_GP)

# Generate binary variable GP_28d based on conditions
dataset$GP_28d <- as.integer(!is.na(dataset$GP_anaph) & dataset$day_GP <= 28)

print("Frequency table for GP_28d variable")
table(dataset$GP_28d)

print("Frequency table for GP_anaph variable when GP_28d is equal to 1")
table(dataset$GP_anaph[dataset$GP_28d == 1])

# Convert GP_anaph_code variable to string type
dataset$GP_anaph_code <- as.character(dataset$GP_anaph_code)

print("Frequency table for GP_anaph_code variable")
table(dataset$GP_anaph_code)

print("Frequency table for GP_anaph_code variable when day_GP is less than or equal to 28")
table(dataset$GP_anaph_code[dataset$day_GP <= 28])

print("Summarize GP_anaph2 variable")
summary(dataset$GP_anaph2)

print("Summarize GP_anaph2 variable based on condition")
summary(dataset$GP_anaph2[dataset$day_GP <= 28])

print("Summarize GP_anaph_pre variable")
summary(dataset$GP_anaph_pre)

print("Summarize GP_anaph2_pre variable")
summary(dataset$GP_anaph2_pre)

print("Summarize GP_anaph_pre_1y variable")
summary(dataset$GP_anaph_pre_1y)

table(dataset$GP_anaph_pre_1y_n)
table(dataset$GP_anaph_pre_1y_episode)
summary(dataset$GP_anaph_pre_1m)

# Combine data from four sources and generate frequency tables
table(dataset$hosp_28d, dataset$AE_28d, useNA = "ifany", dnn = c("hosp_28d", "AE_28d"))
table(dataset$hosp_28d, dataset$AE_28d2, useNA = "ifany", dnn = c("hosp_28d", "AE_28d2"))
table(dataset$hosp_28d, dataset$GP_28d, useNA = "ifany", dnn = c("hosp_28d", "GP_28d"))
table(dataset$AE_28d, dataset$GP_28d, useNA = "ifany", dnn = c("AE_28d", "GP_28d"))
table(dataset$AE_28d2, dataset$GP_28d, useNA = "ifany", dnn = c("AE_28d2", "GP_28d"))

# Generate anaph_all variable based on conditions
dataset$anaph_all <- as.integer((dataset$death_28d + dataset$hosp_28d + dataset$AE_28d + dataset$GP_28d) > 0)

print("Frequency table for anaph_all variable")
table(dataset$anaph_all)

print("Generate anaph_all2 variable based on conditions")
dataset$anaph_all2 <- as.integer((dataset$death_28d + dataset$hosp_28d + dataset$AE_28d2 + dataset$GP_28d) > 0)

print("Frequency table for anaph_all2 variable")
table(dataset$anaph_all2)

# Generate anaph_ever variable based on conditions
dataset$anaph_ever <- as.integer((!is.na(dataset$hospitalisation_anaph_pre) | !is.na(dataset$AE_anaph_pre) | !is.na(dataset$GP_anaph_pre) ))

print("Frequency table for anaph_ever variable")
table(dataset$anaph_ever)

# Generate anaph_ever2 variable based on conditions
dataset$anaph_ever2 <- as.integer((!is.na(dataset$hospitalisation_anaph_pre) | !is.na(dataset$AE_anaph2_pre) | !is.na(dataset$GP_anaph_pre) ))

print("Frequency table for anaph_ever2 variable")
table(dataset$anaph_ever2)

# Generate anaph_pre_1y variable based on conditions
dataset$anaph_pre_1y <- as.integer((!is.na(dataset$hosp_anaph_pre_1y) | !is.na(dataset$AE_anaph_pre_1y) | !is.na(dataset$GP_anaph_pre_1y)))

print("Frequency table for anaph_pre_1y variable")
table(dataset$anaph_pre_1y)

# Generate anaph_pre_1y2 variable based on conditions
dataset$anaph_pre_1y2 <- as.integer((!is.na(dataset$hosp_anaph_pre_1y) | !is.na(dataset$AE_anaph2_pre_1y) | !is.na(dataset$GP_anaph_pre_1y)))

print("Frequency table for anaph_pre_1y2 variable")
table(dataset$anaph_pre_1y2)

# Generate anaph_pre_1m2 variable based on conditions
dataset$anaph_pre_1m2 <- as.integer((!is.na(dataset$hosp_anaph_pre_1m) | !is.na(dataset$AE_anaph2_pre_1m) | !is.na(dataset$GP_anaph_pre_1m)))

print("Frequency table for anaph_pre_1m2 variable")
table(dataset$anaph_pre_1m2)




sink()


