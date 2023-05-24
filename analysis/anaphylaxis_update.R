logfilename <- "./logs/anaphylaxis_update.txt"
sink(logfilename, append = FALSE, split = FALSE)

# Clear workspace
rm(list = ls())

# Import dataset
dataset <- read.csv("./output/input_anaphylaxis_update.csv", header = TRUE)
dataset <- subset(dataset, sotrovimab_covid_therapeutics!=""|molnupiravir_covid_therapeutics!=""|paxlovid_covid_therapeutics!="")

library(lubridate)

date_vars <- c("sotrovimab_covid_therapeutics", "molnupiravir_covid_therapeutics", "paxlovid_covid_therapeutics",
               "remdesivir_covid_therapeutics", "casirivimab_covid_therapeutics", "date_treated", "start_date",
               "death_date", "dereg_date", "last_vaccination_date", 
               "death_with_anaphylaxis_date", "death_with_anaph_underly_date", "death_with_anaphylaxis_date2",
               "death_with_anaph_underly_date2", "death_with_anaphylaxis_date3", "death_with_anaphylaxis_date_pre",
               "death_with_anaph_underly_date_pre", "hospitalisation_anaph", "hosp_discharge_anaph",
               "hospitalisation_anaph_underly", "hospitalisation_anaph2", "hospitalisation_anaph_underly2",
               "hospitalisation_anaph3", "hospitalisation_anaph_pre", "hosp_anaph_underly_pre", "AE_anaph",
               "AE_anaph2", "AE_anaph3", "AE_anaph4", "AE_anaph_pre", "AE_anaph2_pre", "GP_anaph", "GP_anaph2",
               "GP_anaph_pre", "GP_anaph2_pre", "date_treated1", "sotrovimab_covid_therapeutics1",
               "molnupiravir_covid_therapeutics1", "paxlovid_covid_therapeutics1",
                "hosp_anaph_pre_1y",
               "AE_anaph_pre_1y", "AE_anaph2_pre_1y", "GP_anaph_pre_1y", "hosp_anaph_pre_1m", "AE_anaph2_pre_1m", "GP_anaph_pre_1m")

for (var in date_vars) {
  if (var %in% names(dataset)) {
    dataset[[var]] <- as.Date(dataset[[var]], format = "%Y-%m-%d")
  }
}

dataset <- subset(dataset, !is.na(date_treated)& start_date >= as.Date("2021-12-16") & start_date <= as.Date("2023-01-28"))

print("sotro")
dataset_sotro <- subset(dataset,!is.na(sotrovimab_covid_therapeutics))

print("Calculate day_hosp variable as the difference between hospitalisation_anaph and start_date")
dataset_sotro$day_hosp <- as.integer(dataset_sotro$hospitalisation_anaph - dataset_sotro$start_date)

print("Generate binary variable hosp_28d based on conditions")
dataset_sotro$hosp_28d <- as.integer(!is.na(dataset_sotro$hospitalisation_anaph) & dataset_sotro$day_hosp <= 28& dataset_sotro$day_hosp >=0)

print("Frequency table for hosp_28d variable")
table(dataset_sotro$hosp_28d)
print("Frequency table for AE_anaph variable when AE_28d is equal to 1")
table(dataset_sotro$hospitalisation_anaph[dataset_sotro$hosp_28d == 1])

print("Summarize hospitalisation_anaph_pre variable")
summary(dataset_sotro$hospitalisation_anaph_pre)

print("Summarize hosp_anaph_pre_1y variable")
summary(dataset_sotro$hosp_anaph_pre_1y)
table(dataset_sotro$registered_pre_4y)
table(dataset_sotro$registered_treated)
table(dataset_sotro$registered_treated, dataset_sotro$registered_pre_4y, useNA = "ifany")
table(dataset_sotro$hosp_anaph_pre_1y_n)
summary(dataset_sotro$hosp_anaph_pre_1m)

# Calculate day_AE variable as the difference between AE_anaph and start_date
dataset_sotro$day_AE2 <- as.integer(dataset_sotro$AE_anaph2 - dataset_sotro$start_date)

print("Summarize day_AE variable")
summary(dataset_sotro$day_AE2)

# Generate binary variable AE_28d based on conditions
dataset_sotro$AE_28d2 <- as.integer(!is.na(dataset_sotro$AE_anaph2) & dataset_sotro$day_AE2 <= 28& dataset_sotro$day_AE2 >=0)

print("Frequency table for AE_28d variable")
table(dataset_sotro$AE_28d2)

print("Frequency table for AE_anaph variable when AE_28d is equal to 1")
table(dataset_sotro$AE_anaph2[dataset_sotro$AE_28d2 == 1])

print("Summarize AE_anaph2_pre variable")
summary(dataset_sotro$AE_anaph2_pre)

print("Summarize AE_anaph_pre_1y variable")
summary(dataset_sotro$AE_anaph_pre_1y)

print("Summarize AE_anaph2_pre_1y variable")
summary(dataset_sotro$AE_anaph2_pre_1y)
table(dataset_sotro$AE_anaph2_pre_1y_n)
summary(dataset_sotro$AE_anaph2_pre_1m)

# Calculate day_GP variable as the difference between GP_anaph and start_date
dataset_sotro$day_GP <- as.integer(dataset_sotro$GP_anaph - dataset_sotro$start_date)

print("Summarize day_GP variable")
summary(dataset_sotro$day_GP)

# Generate binary variable GP_28d based on conditions
dataset_sotro$GP_28d <- as.integer(!is.na(dataset_sotro$GP_anaph) & dataset_sotro$day_GP <= 28& dataset_sotro$day_GP >=0)

print("Frequency table for GP_28d variable")
table(dataset_sotro$GP_28d)

print("Frequency table for GP_anaph variable when GP_28d is equal to 1")
table(dataset_sotro$GP_anaph[dataset_sotro$GP_28d == 1])

print("Summarize GP_anaph_pre variable")
summary(dataset_sotro$GP_anaph_pre)

print("Summarize GP_anaph_pre_1y variable")
summary(dataset_sotro$GP_anaph_pre_1y)
table(dataset_sotro$GP_anaph_pre_1y_n)
table(dataset_sotro$GP_anaph_pre_1y_episode)
summary(dataset_sotro$GP_anaph_pre_1m)

# Generate anaph_all variable based on conditions
dataset_sotro$anaph_all2 <- as.integer((dataset_sotro$hosp_28d + dataset_sotro$AE_28d2 + dataset_sotro$GP_28d) > 0)

print("Frequency table for anaph_all2 variable")
table(dataset_sotro$anaph_all2)

# Generate anaph_ever variable based on conditions
dataset_sotro$anaph_ever2 <- as.integer((!is.na(dataset_sotro$hospitalisation_anaph_pre) | !is.na(dataset_sotro$AE_anaph2_pre) | !is.na(dataset_sotro$GP_anaph_pre) ))

print("Frequency table for anaph_ever variable")
table(dataset_sotro$anaph_ever2)


# Generate anaph_pre_1y2 variable based on conditions
dataset_sotro$anaph_pre_1y2 <- as.integer((!is.na(dataset_sotro$hosp_anaph_pre_1y) | !is.na(dataset_sotro$AE_anaph2_pre_1y) | !is.na(dataset_sotro$GP_anaph_pre_1y)))

print("Frequency table for anaph_pre_1y2 variable")
table(dataset_sotro$anaph_pre_1y2)

# Generate anaph_pre_1m2 variable based on conditions
dataset_sotro$anaph_pre_1m2 <- as.integer((!is.na(dataset_sotro$hosp_anaph_pre_1m) | !is.na(dataset_sotro$AE_anaph2_pre_1m) | !is.na(dataset_sotro$GP_anaph_pre_1m)))

print("Frequency table for anaph_pre_1m2 variable")
table(dataset_sotro$anaph_pre_1m2)



print("pax")
dataset_pax <- subset(dataset,!is.na(paxlovid_covid_therapeutics))

print("Calculate day_hosp variable as the difference between hospitalisation_anaph and start_date")
dataset_pax$day_hosp <- as.integer(dataset_pax$hospitalisation_anaph - dataset_pax$start_date)

print("Generate binary variable hosp_28d based on conditions")
dataset_pax$hosp_28d <- as.integer(!is.na(dataset_pax$hospitalisation_anaph) & dataset_pax$day_hosp <= 28& dataset_pax$day_hosp >=0)

print("Frequency table for hosp_28d variable")
table(dataset_pax$hosp_28d)
print("Frequency table for AE_anaph variable when AE_28d is equal to 1")
table(dataset_pax$hospitalisation_anaph[dataset_pax$hosp_28d == 1])

print("Summarize hospitalisation_anaph_pre variable")
summary(dataset_pax$hospitalisation_anaph_pre)

print("Summarize hosp_anaph_pre_1y variable")
summary(dataset_pax$hosp_anaph_pre_1y)
table(dataset_pax$registered_pre_4y)
table(dataset_pax$registered_treated)
table(dataset_pax$registered_treated, dataset_pax$registered_pre_4y, useNA = "ifany")
table(dataset_pax$hosp_anaph_pre_1y_n)
summary(dataset_pax$hosp_anaph_pre_1m)

# Calculate day_AE variable as the difference between AE_anaph and start_date
dataset_pax$day_AE2 <- as.integer(dataset_pax$AE_anaph2 - dataset_pax$start_date)

print("Summarize day_AE variable")
summary(dataset_pax$day_AE2)

# Generate binary variable AE_28d based on conditions
dataset_pax$AE_28d2 <- as.integer(!is.na(dataset_pax$AE_anaph2) & dataset_pax$day_AE2 <= 28& dataset_pax$day_AE2 >=0)

print("Frequency table for AE_28d variable")
table(dataset_pax$AE_28d2)

print("Frequency table for AE_anaph variable when AE_28d is equal to 1")
table(dataset_pax$AE_anaph2[dataset_pax$AE_28d2 == 1])

print("Summarize AE_anaph2_pre variable")
summary(dataset_pax$AE_anaph2_pre)

print("Summarize AE_anaph_pre_1y variable")
summary(dataset_pax$AE_anaph_pre_1y)

print("Summarize AE_anaph2_pre_1y variable")
summary(dataset_pax$AE_anaph2_pre_1y)
table(dataset_pax$AE_anaph2_pre_1y_n)
summary(dataset_pax$AE_anaph2_pre_1m)


# Calculate day_GP variable as the difference between GP_anaph and start_date
dataset_pax$day_GP <- as.integer(dataset_pax$GP_anaph - dataset_pax$start_date)

print("Summarize day_GP variable")
summary(dataset_pax$day_GP)

# Generate binary variable GP_28d based on conditions
dataset_pax$GP_28d <- as.integer(!is.na(dataset_pax$GP_anaph) & dataset_pax$day_GP <= 28& dataset_pax$day_GP >=0)

print("Frequency table for GP_28d variable")
table(dataset_pax$GP_28d)

print("Frequency table for GP_anaph variable when GP_28d is equal to 1")
table(dataset_pax$GP_anaph[dataset_pax$GP_28d == 1])

print("Summarize GP_anaph_pre variable")
summary(dataset_pax$GP_anaph_pre)

print("Summarize GP_anaph_pre_1y variable")
summary(dataset_pax$GP_anaph_pre_1y)
table(dataset_pax$GP_anaph_pre_1y_n)
table(dataset_pax$GP_anaph_pre_1y_episode)
summary(dataset_pax$GP_anaph_pre_1m)

# Generate anaph_all variable based on conditions
dataset_pax$anaph_all2 <- as.integer((dataset_pax$hosp_28d + dataset_pax$AE_28d2 + dataset_pax$GP_28d) > 0)

print("Frequency table for anaph_all2 variable")
table(dataset_pax$anaph_all2)

# Generate anaph_ever variable based on conditions
dataset_pax$anaph_ever2 <- as.integer((!is.na(dataset_pax$hospitalisation_anaph_pre) | !is.na(dataset_pax$AE_anaph2_pre) | !is.na(dataset_pax$GP_anaph_pre) ))

print("Frequency table for anaph_ever variable")
table(dataset_pax$anaph_ever2)


# Generate anaph_pre_1y2 variable based on conditions
dataset_pax$anaph_pre_1y2 <- as.integer((!is.na(dataset_pax$hosp_anaph_pre_1y) | !is.na(dataset_pax$AE_anaph2_pre_1y) | !is.na(dataset_pax$GP_anaph_pre_1y)))

print("Frequency table for anaph_pre_1y2 variable")
table(dataset_pax$anaph_pre_1y2)

# Generate anaph_pre_1m2 variable based on conditions
dataset_pax$anaph_pre_1m2 <- as.integer((!is.na(dataset_pax$hosp_anaph_pre_1m) | !is.na(dataset_pax$AE_anaph2_pre_1m) | !is.na(dataset_pax$GP_anaph_pre_1m)))

print("Frequency table for anaph_pre_1m2 variable")
table(dataset_pax$anaph_pre_1m2)



print("mol")
dataset_mol <- subset(dataset,!is.na(molnupiravir_covid_therapeutics))

print("Calculate day_hosp variable as the difference between hospitalisation_anaph and start_date")
dataset_mol$day_hosp <- as.integer(dataset_mol$hospitalisation_anaph - dataset_mol$start_date)

print("Generate binary variable hosp_28d based on conditions")
dataset_mol$hosp_28d <- as.integer(!is.na(dataset_mol$hospitalisation_anaph) & dataset_mol$day_hosp <= 28& dataset_mol$day_hosp >=0)

print("Frequency table for hosp_28d variable")
table(dataset_mol$hosp_28d)
print("Frequency table for AE_anaph variable when AE_28d is equal to 1")
table(dataset_mol$hospitalisation_anaph[dataset_mol$hosp_28d == 1])

print("Summarize hospitalisation_anaph_pre variable")
summary(dataset_mol$hospitalisation_anaph_pre)

print("Summarize hosp_anaph_pre_1y variable")
summary(dataset_mol$hosp_anaph_pre_1y)
table(dataset_mol$registered_pre_4y)
table(dataset_mol$registered_treated)
table(dataset_mol$registered_treated, dataset_mol$registered_pre_4y, useNA = "ifany")
table(dataset_mol$hosp_anaph_pre_1y_n)
summary(dataset_mol$hosp_anaph_pre_1m)

# Calculate day_AE variable as the difference between AE_anaph and start_date
dataset_mol$day_AE2 <- as.integer(dataset_mol$AE_anaph2 - dataset_mol$start_date)

print("Summarize day_AE variable")
summary(dataset_mol$day_AE2)

# Generate binary variable AE_28d based on conditions
dataset_mol$AE_28d2 <- as.integer(!is.na(dataset_mol$AE_anaph2) & dataset_mol$day_AE2 <= 28& dataset_mol$day_AE2 >=0)

print("Frequency table for AE_28d variable")
table(dataset_mol$AE_28d2)

print("Frequency table for AE_anaph variable when AE_28d is equal to 1")
table(dataset_mol$AE_anaph2[dataset_mol$AE_28d2 == 1])

print("Summarize AE_anaph2_pre variable")
summary(dataset_mol$AE_anaph2_pre)

print("Summarize AE_anaph_pre_1y variable")
summary(dataset_mol$AE_anaph_pre_1y)

print("Summarize AE_anaph2_pre_1y variable")
summary(dataset_mol$AE_anaph2_pre_1y)
table(dataset_mol$AE_anaph2_pre_1y_n)
summary(dataset_mol$AE_anaph2_pre_1m)


# Calculate day_GP variable as the difference between GP_anaph and start_date
dataset_mol$day_GP <- as.integer(dataset_mol$GP_anaph - dataset_mol$start_date)

print("Summarize day_GP variable")
summary(dataset_mol$day_GP)

# Generate binary variable GP_28d based on conditions
dataset_mol$GP_28d <- as.integer(!is.na(dataset_mol$GP_anaph) & dataset_mol$day_GP <= 28& dataset_mol$day_GP >=0)

print("Frequency table for GP_28d variable")
table(dataset_mol$GP_28d)

print("Frequency table for GP_anaph variable when GP_28d is equal to 1")
table(dataset_mol$GP_anaph[dataset_mol$GP_28d == 1])

print("Summarize GP_anaph_pre variable")
summary(dataset_mol$GP_anaph_pre)

print("Summarize GP_anaph_pre_1y variable")
summary(dataset_mol$GP_anaph_pre_1y)
table(dataset_mol$GP_anaph_pre_1y_n)
table(dataset_mol$GP_anaph_pre_1y_episode)
summary(dataset_mol$GP_anaph_pre_1m)

# Generate anaph_all variable based on conditions
dataset_mol$anaph_all2 <- as.integer((dataset_mol$hosp_28d + dataset_mol$AE_28d2 + dataset_mol$GP_28d) > 0)

print("Frequency table for anaph_all2 variable")
table(dataset_mol$anaph_all2)

# Generate anaph_ever variable based on conditions
dataset_mol$anaph_ever2 <- as.integer((!is.na(dataset_mol$hospitalisation_anaph_pre) | !is.na(dataset_mol$AE_anaph2_pre) | !is.na(dataset_mol$GP_anaph_pre) ))

print("Frequency table for anaph_ever variable")
table(dataset_mol$anaph_ever2)


# Generate anaph_pre_1y2 variable based on conditions
dataset_mol$anaph_pre_1y2 <- as.integer((!is.na(dataset_mol$hosp_anaph_pre_1y) | !is.na(dataset_mol$AE_anaph2_pre_1y) | !is.na(dataset_mol$GP_anaph_pre_1y)))

print("Frequency table for anaph_pre_1y2 variable")
table(dataset_mol$anaph_pre_1y2)

# Generate anaph_pre_1m2 variable based on conditions
dataset_mol$anaph_pre_1m2 <- as.integer((!is.na(dataset_mol$hosp_anaph_pre_1m) | !is.na(dataset_mol$AE_anaph2_pre_1m) | !is.na(dataset_mol$GP_anaph_pre_1m)))

print("Frequency table for anaph_pre_1m2 variable")
table(dataset_mol$anaph_pre_1m2)


sink()


