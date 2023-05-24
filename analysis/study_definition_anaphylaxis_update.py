## Adapted codes from https://github.com/opensafely/antibody-and-antiviral-deployment
## Import code building blocks from cohort extractor package 
from cohortextractor import (
  StudyDefinition,
  patients,
  codelist_from_csv,
  codelist,
  filter_codes_by_category,
  combine_codelists,
  Measure
)

## Import codelists from codelist.py (which pulls them from the codelist folder)
from codelists import *

# DEFINE STUDY POPULATION ----

## Define study time variables
from datetime import timedelta, date, datetime 

campaign_start = "2021-12-16"
end_date = date.today().isoformat()

## Define study population and variables
study = StudyDefinition(

  ## Configure the expectations framework
  default_expectations = {
    "date": {"earliest": "2021-11-01", "latest": "today"},
    "rate": "uniform",
    "incidence": 0.05,
  },
  
  ## Define index date
  index_date = campaign_start,
  
  # POPULATION ----
  population = patients.satisfying(
    """
    sotrovimab_covid_therapeutics OR molnupiravir_covid_therapeutics OR paxlovid_covid_therapeutics
    """,
  ),

  # TREATMENT - NEUTRALISING MONOCLONAL ANTIBODIES OR ANTIVIRALS ----
  
  ## Sotrovimab
  sotrovimab_covid_therapeutics = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Sotrovimab",
    with_these_indications = "non_hospitalised",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.4
    },
  ),
  # restrict by status
  sotrovimab_covid_approved = patients.with_covid_therapeutics(
    with_these_statuses = ["Approved"],
    with_these_therapeutics = "Sotrovimab",
    with_these_indications = "non_hospitalised",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.4
    },
  ),
  sotrovimab_covid_complete = patients.with_covid_therapeutics(
    with_these_statuses = ["Treatment Complete"],
    with_these_therapeutics = "Sotrovimab",
    with_these_indications = "non_hospitalised",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.4
    },
  ),
  sotrovimab_covid_not_start = patients.with_covid_therapeutics(
    with_these_statuses = ["Treatment Not Started"],
    with_these_therapeutics = "Sotrovimab",
    with_these_indications = "non_hospitalised",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.4
    },
  ),
  sotrovimab_covid_stopped = patients.with_covid_therapeutics(
    with_these_statuses = ["Treatment Stopped"],
    with_these_therapeutics = "Sotrovimab",
    with_these_indications = "non_hospitalised",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.4
    },
  ),
  ### Molnupiravir
  molnupiravir_covid_therapeutics = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Molnupiravir",
    with_these_indications = "non_hospitalised",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.4
    },
  ),

  ### Paxlovid
  paxlovid_covid_therapeutics = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Paxlovid",
    with_these_indications = "non_hospitalised",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-10"},
      "incidence": 0.05
    },
  ), 

  ## Remdesivir
  remdesivir_covid_therapeutics = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Remdesivir",
    with_these_indications = "non_hospitalised",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.05
    },
  ),
  
  ### Casirivimab and imdevimab
  casirivimab_covid_therapeutics = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Casirivimab and imdevimab",
    with_these_indications = "non_hospitalised",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.05
    },
  ), 
  
  
  ## Date treated
  date_treated = patients.minimum_of(
    "sotrovimab_covid_therapeutics",
    "molnupiravir_covid_therapeutics",
    "casirivimab_covid_therapeutics",
    "paxlovid_covid_therapeutics",
    "remdesivir_covid_therapeutics",
  ),
  
  registered_treated = patients.registered_as_of("date_treated"), 

  ## Study start date for extracting variables
  start_date = patients.minimum_of(
    "sotrovimab_covid_therapeutics",
    "molnupiravir_covid_therapeutics",
    "casirivimab_covid_therapeutics",
    "paxlovid_covid_therapeutics",
    "remdesivir_covid_therapeutics",
  ),
  
  

  ## Sotrovimab
  sotrovimab_covid_therapeutics1 = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Sotrovimab",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.4
    },
  ),
  ### Molnupiravir
  molnupiravir_covid_therapeutics1 = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Molnupiravir",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.4
    },
  ),

  ### Paxlovid
  paxlovid_covid_therapeutics1 = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Paxlovid",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-10"},
      "incidence": 0.05
    },
  ), 

  ## Remdesivir
  remdesivir_covid_therapeutics1 = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Remdesivir",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.05
    },
  ),
  
  ### Casirivimab and imdevimab
  casirivimab_covid_therapeutics1 = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Casirivimab and imdevimab",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    returning = "date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.05
    },
  ), 

  date_treated1 = patients.minimum_of(
    "sotrovimab_covid_therapeutics1",
    "molnupiravir_covid_therapeutics1",
    "casirivimab_covid_therapeutics1",
    "paxlovid_covid_therapeutics1",
    "remdesivir_covid_therapeutics1",
  ),



  # CENSORING ----
  
  ## Death of any cause
  death_date = patients.died_from_any_cause(
    returning = "date_of_death",
    date_format = "YYYY-MM-DD",
    on_or_after = "start_date",
    return_expectations = {
      "date": {"earliest": "2021-12-20", "latest": "index_date"},
      "incidence": 0.1
    },
  ),
  
  has_died = patients.died_from_any_cause(
    on_or_before = "start_date - 1 day",
    returning = "binary_flag",
  ),
  
  ## De-registration
  dereg_date = patients.date_deregistered_from_all_supported_practices(
    on_or_after = "start_date",
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2021-12-20", "latest": "index_date"},
      "incidence": 0.1
    },
  ),
  
  registered_campaign = patients.registered_as_of("index_date"),
 
  ## 1/2/3 months since treatment initiation
  ## AND study end date (today)
  ## end enrollment earlier to account for delay in outcome data update

  # CLINICAL/DEMOGRAPHIC COVARIATES ----
  
  ## Age
  age = patients.age_as_of(
    "start_date - 1 day",
    return_expectations = {
      "rate": "universal",
      "int": {"distribution": "population_ages"},
      "incidence" : 0.9
    },
  ),
  
  ## Sex
  sex = patients.sex(
    return_expectations = {
      "rate": "universal",
      "category": {"ratios": {"M": 0.49, "F": 0.51}},
    }
  ),
  
  ## Ethnicity
  ethnicity = patients.categorised_as(
            {"Missing": "DEFAULT",
            "White": "eth='1' OR (NOT eth AND ethnicity_sus='1')", 
            "Mixed": "eth='2' OR (NOT eth AND ethnicity_sus='2')", 
            "South Asian": "eth='3' OR (NOT eth AND ethnicity_sus='3')", 
            "Black": "eth='4' OR (NOT eth AND ethnicity_sus='4')",  
            "Other": "eth='5' OR (NOT eth AND ethnicity_sus='5')",
            }, 
            return_expectations={
            "category": {"ratios": {"White": 0.6, "Mixed": 0.1, "South Asian": 0.1, "Black": 0.1, "Other": 0.1}},
            "incidence": 0.4,
            },

            ethnicity_sus = patients.with_ethnicity_from_sus(
                returning="group_6",  
                use_most_frequent_code=True,
                return_expectations={
                    "category": {"ratios": {"1": 0.6, "2": 0.1, "3": 0.1, "4": 0.1, "5": 0.1}},
                    "incidence": 0.4,
                    },
            ),

            eth=patients.with_these_clinical_events(
                ethnicity_primis_snomed_codes,
                returning="category",
                find_last_match_in_period=True,
                on_or_before="today",
                return_expectations={
                    "category": {"ratios": {"1": 0.6, "2": 0.1, "3": 0.1, "4":0.1,"5": 0.1}},
                    "incidence": 0.75,
                },
            ),
    ),
  

  
  ## Region - NHS England 9 regions
  region_nhs = patients.registered_practice_as_of(
    "start_date",
    returning = "nuts1_region_name",
    return_expectations = {
      "rate": "universal",
      "category": {
        "ratios": {
          "North East": 0.1,
          "North West": 0.1,
          "Yorkshire and The Humber": 0.1,
          "East Midlands": 0.1,
          "West Midlands": 0.1,
          "East": 0.1,
          "London": 0.2,
          "South West": 0.1,
          "South East": 0.1,},},
    },
  ),
  
  region_covid_therapeutics = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = ["Sotrovimab", "Molnupiravir","Casirivimab and imdevimab", "Paxlovid", "Remdesivir"],
    with_these_indications = "non_hospitalised",
    on_or_after = "start_date",
    find_first_match_in_period = True,
    returning = "region",
    return_expectations = {
      "rate": "universal",
      "category": {
        "ratios": {
          "North East": 0.1,
          "North West": 0.1,
          "Yorkshire and The Humber": 0.1,
          "East Midlands": 0.1,
          "West Midlands": 0.1,
          "East": 0.1,
          "London": 0.2,
          "South West": 0.1,
          "South East": 0.1,},},
    },
  ),
  
  
  ## Vaccination status
  vaccination_status = patients.categorised_as(
    {
      "Un-vaccinated": "DEFAULT",
      "Un-vaccinated (declined)": """ covid_vax_declined AND NOT (covid_vax_1 OR covid_vax_2 OR covid_vax_3 OR covid_vax_4)""",
      "One vaccination": """ covid_vax_1 AND NOT covid_vax_2 """,
      "Two vaccinations": """ covid_vax_2 AND NOT covid_vax_3 """,
      "Three vaccinations": """ covid_vax_3 AND NOT covid_vax_4 """,
      "Four or more vaccinations": """ covid_vax_4 """
    },
    
    # first vaccine from during trials and up to treatment/test date
    covid_vax_1 = patients.with_tpp_vaccination_record(
      target_disease_matches = "SARS-2 CORONAVIRUS",
      between = ["2020-06-08", "start_date"],
      find_first_match_in_period = True,
      returning = "date",
      date_format = "YYYY-MM-DD"
    ),
    
    covid_vax_2 = patients.with_tpp_vaccination_record(
      target_disease_matches = "SARS-2 CORONAVIRUS",
      between = ["covid_vax_1 + 19 days", "start_date"],
      find_first_match_in_period = True,
      returning = "date",
      date_format = "YYYY-MM-DD"
    ),
    
    covid_vax_3 = patients.with_tpp_vaccination_record(
      target_disease_matches = "SARS-2 CORONAVIRUS",
      between = ["covid_vax_2 + 56 days", "start_date"],
      find_first_match_in_period = True,
      returning = "date",
      date_format = "YYYY-MM-DD"
    ),
    # add 4th
    covid_vax_4 = patients.with_tpp_vaccination_record(
      target_disease_matches = "SARS-2 CORONAVIRUS",
      between = ["covid_vax_3 + 56 days", "start_date"],
      find_first_match_in_period = True,
      returning = "date",
      date_format = "YYYY-MM-DD"
    ),

    covid_vax_declined = patients.with_these_clinical_events(
      covid_vaccine_declined_codes,
      returning="binary_flag",
      on_or_before = "start_date",
    ),

    return_expectations = {
      "rate": "universal",
      "category": {
        "ratios": {
          "Un-vaccinated": 0.1,
          "Un-vaccinated (declined)": 0.1,
          "One vaccination": 0.1,
          "Two vaccinations": 0.1,
          "Three vaccinations": 0.5,
          "Four or more vaccinations": 0.1,
        }
      },
    },
  ),
  # latest vaccination date
  last_vaccination_date = patients.with_tpp_vaccination_record(
      target_disease_matches = "SARS-2 CORONAVIRUS",
      on_or_before = "start_date",
      find_last_match_in_period = True,
      returning = "date",
      date_format = "YYYY-MM-DD",
      return_expectations={
            "date": {"earliest": "2020-06-08", "latest": "today"},
            "incidence": 0.95,
      }
  ),



  # OUTCOMES ----
  ## ONS death
  death_with_anaphylaxis_date = patients.with_these_codes_on_death_certificate(
    anaphylaxis_icd10_codes,
    returning = "date_of_death",
    date_format = "YYYY-MM-DD",
    on_or_after = "start_date",
    return_expectations = {
      "date": {"earliest": "2021-01-01", "latest" : "today"},
      "rate": "uniform",
      "incidence": 0.6},
  ),
  ## underlying cause
  death_with_anaph_underly_date = patients.with_these_codes_on_death_certificate(
    anaphylaxis_icd10_codes,
    returning = "date_of_death",
    date_format = "YYYY-MM-DD",
    on_or_after = "start_date",
    match_only_underlying_cause=True,
    return_expectations = {
      "date": {"earliest": "2021-01-01", "latest" : "today"},
      "rate": "uniform",
      "incidence": 0.6},
  ),  
  #return ICD-10 code of underlying_cause_of_death
  death_with_anaphylaxis_code = patients.with_these_codes_on_death_certificate(
    anaphylaxis_icd10_codes,
    returning = "underlying_cause_of_death",
    on_or_after = "start_date",
  ),
  death_code = patients.died_from_any_cause(
    returning = "underlying_cause_of_death",
    on_or_after = "start_date",
  ),


  ## ONS death-using a narrow codelist
  death_with_anaphylaxis_date2 = patients.with_these_codes_on_death_certificate(
    codelist(["T782","T886"], system="icd10"),
    returning = "date_of_death",
    date_format = "YYYY-MM-DD",
    on_or_after = "start_date",
    return_expectations = {
      "date": {"earliest": "2021-01-01", "latest" : "today"},
      "rate": "uniform",
      "incidence": 0.6},
  ),
  ## underlying cause
  death_with_anaph_underly_date2 = patients.with_these_codes_on_death_certificate(
    codelist(["T782","T886"], system="icd10"),
    returning = "date_of_death",
    date_format = "YYYY-MM-DD",
    on_or_after = "start_date",
    match_only_underlying_cause=True,
    return_expectations = {
      "date": {"earliest": "2021-01-01", "latest" : "today"},
      "rate": "uniform",
      "incidence": 0.6},
  ),  
  #return ICD-10 code of underlying_cause_of_death
  death_with_anaphylaxis_code2 = patients.with_these_codes_on_death_certificate(
    codelist(["T782","T886"], system="icd10"),
    returning = "underlying_cause_of_death",
    on_or_after = "start_date",
  ),
  death_with_anaphylaxis_date3 = patients.with_these_codes_on_death_certificate(
    codelist(["T886"], system="icd10"),
    returning = "date_of_death",
    date_format = "YYYY-MM-DD",
    on_or_after = "start_date",
    return_expectations = {
      "date": {"earliest": "2021-01-01", "latest" : "today"},
      "rate": "uniform",
      "incidence": 0.6},
  ),

  ## ONS death - check any death before recorded treatment date
  death_with_anaphylaxis_date_pre = patients.with_these_codes_on_death_certificate(
    anaphylaxis_icd10_codes,
    returning = "date_of_death",
    date_format = "YYYY-MM-DD",
    on_or_before = "start_date - 1 day",
    return_expectations = {
      "date": {"earliest": "2021-01-01", "latest" : "today"},
      "rate": "uniform",
      "incidence": 0.6},
  ),
  ## underlying cause
  death_with_anaph_underly_date_pre = patients.with_these_codes_on_death_certificate(
    anaphylaxis_icd10_codes,
    returning = "date_of_death",
    date_format = "YYYY-MM-DD",
    on_or_before = "start_date - 1 day",
    match_only_underlying_cause=True,
    return_expectations = {
      "date": {"earliest": "2021-01-01", "latest" : "today"},
      "rate": "uniform",
      "incidence": 0.6},
  ),  



# hosp
  hospitalisation_allcause = patients.admitted_to_hospital(
    returning = "date_admitted",
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_after = "start_date",
    find_first_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),
  hospitalisation_anaph = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_diagnoses = anaphylaxis_icd10_codes,
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_after = "start_date",
    find_first_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),
  hosp_discharge_anaph = patients.admitted_to_hospital(
    returning = "date_discharged",
    with_these_diagnoses = anaphylaxis_icd10_codes,
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_after = "hospitalisation_anaph",
    find_first_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),
  hospitalisation_anaph_underly = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_primary_diagnoses = anaphylaxis_icd10_codes,
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_after = "start_date",
    find_first_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),  
  #return primary diagnosis code
  hospitalisation_primary_code = patients.admitted_to_hospital(
    returning = "primary_diagnosis",
    with_these_diagnoses = anaphylaxis_icd10_codes,
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_after = "start_date",
    find_first_match_in_period = True,
  ),


# hosp - using a narrow codelist
  hospitalisation_anaph2 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_diagnoses = codelist(["T782","T886"], system="icd10"),
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_after = "start_date",
    find_first_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),
  hospitalisation_anaph_underly2 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_primary_diagnoses = codelist(["T782","T886"], system="icd10"),
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_after = "start_date",
    find_first_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),  
  #return primary diagnosis code
  hospitalisation_primary_code2 = patients.admitted_to_hospital(
    returning = "primary_diagnosis",
    with_these_diagnoses = codelist(["T782","T886"], system="icd10"),
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_after = "start_date",
    find_first_match_in_period = True,
  ),
  hospitalisation_anaph3 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_diagnoses = codelist(["T886"], system="icd10"),
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_after = "start_date",
    find_first_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),

  ## hosp - check any hosp before recorded treatment date
  hospitalisation_anaph_pre = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_diagnoses = anaphylaxis_icd10_codes,
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_before = "start_date - 1 day",
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),
  hosp_anaph_underly_pre = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_primary_diagnoses = anaphylaxis_icd10_codes,
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    on_or_before = "start_date - 1 day",
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),  
  hosp_anaph_pre_1y = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_diagnoses = anaphylaxis_icd10_codes,
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    between = ["start_date - 1459 days", "start_date - 1095 days"],
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),
  hosp_anaph_pre_1y_n = patients.admitted_to_hospital(
    returning = "number_of_matches_in_period",
    with_these_diagnoses = anaphylaxis_icd10_codes,
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    between = ["start_date - 1459 days", "start_date - 1095 days"],
  ),
  registered_pre_4y = patients.registered_as_of("start_date - 1459 days"), 
  hosp_anaph_pre_1m = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_diagnoses = anaphylaxis_icd10_codes,
    # with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    # with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    between = ["start_date - 1095 days", "start_date - 1067 days"],
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {"earliest": "2022-02-18"},
      "rate": "uniform",
      "incidence": 0.6
    },
  ),
  registered_pre_3y = patients.registered_as_of("start_date - 1095 days"), 

  ## A&E
  AE_allcause = patients.attended_emergency_care(
          returning="date_arrived",
          on_or_after = "start_date",
          date_format="YYYY-MM-DD",
          find_first_match_in_period = True,
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  
  AE_anaph = patients.attended_emergency_care(
          returning="date_arrived",
          on_or_after = "start_date",
          date_format="YYYY-MM-DD",
          find_first_match_in_period = True,
          with_these_diagnoses = codelist(["39579001","62014003","609328004"], system="snomed"),
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  
  AE_anaph2 = patients.attended_emergency_care(
          returning="date_arrived",
          on_or_after = "start_date",
          date_format="YYYY-MM-DD",
          find_first_match_in_period = True,
          with_these_diagnoses = codelist(["39579001"], system="snomed"),
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  
  AE_anaph3 = patients.attended_emergency_care(
          returning="date_arrived",
          on_or_after = "start_date",
          date_format="YYYY-MM-DD",
          find_first_match_in_period = True,
          with_these_diagnoses = codelist(["62014003"], system="snomed"),
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  
  AE_anaph4 = patients.attended_emergency_care(
          returning="date_arrived",
          on_or_after = "start_date",
          date_format="YYYY-MM-DD",
          find_first_match_in_period = True,
          with_these_diagnoses = codelist(["609328004"], system="snomed"),
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  

  ## check any A&E before
  AE_anaph_pre = patients.attended_emergency_care(
          returning="date_arrived",
          on_or_before = "start_date - 1 day",
          date_format="YYYY-MM-DD",
          find_last_match_in_period = True,
          with_these_diagnoses = codelist(["39579001","62014003","609328004"], system="snomed"),
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  
  AE_anaph2_pre = patients.attended_emergency_care(
          returning="date_arrived",
          on_or_before = "start_date - 1 day",
          date_format="YYYY-MM-DD",
          find_last_match_in_period = True,
          with_these_diagnoses = codelist(["39579001"], system="snomed"),
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  
  AE_anaph_pre_1y = patients.attended_emergency_care(
          returning="date_arrived",
          between = ["start_date - 1459 days", "start_date - 1095 days"],
          date_format="YYYY-MM-DD",
          find_last_match_in_period = True,
          with_these_diagnoses = codelist(["39579001","62014003","609328004"], system="snomed"),
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  
  AE_anaph2_pre_1y = patients.attended_emergency_care(
          returning="date_arrived",
          between = ["start_date - 1459 days", "start_date - 1095 days"],
          date_format="YYYY-MM-DD",
          find_last_match_in_period = True,
          with_these_diagnoses = codelist(["39579001"], system="snomed"),
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  
  AE_anaph2_pre_1y_n = patients.attended_emergency_care(
          returning="number_of_matches_in_period",
          between = ["start_date - 1459 days", "start_date - 1095 days"],
          with_these_diagnoses = codelist(["39579001"], system="snomed"),
  ),  
  AE_anaph2_pre_1m = patients.attended_emergency_care(
          returning="date_arrived",
          between = ["start_date - 1095 days", "start_date - 1067 days"],
          date_format="YYYY-MM-DD",
          find_last_match_in_period = True,
          with_these_diagnoses = codelist(["39579001"], system="snomed"),
          return_expectations={
            "date": {"earliest": "2022-02-18"},
            "rate": "uniform",
            "incidence": 0.05,
          },
  ),  

  ## GP records
  GP_anaph = patients.with_these_clinical_events(
    anaphylaxis_snomed_codes,
    on_or_after = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_first_match_in_period = True,
  ),
  GP_anaph2 = patients.with_these_clinical_events(
    codelist(["39579001"], system="snomed"),
    on_or_after = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_first_match_in_period = True,
  ),
  GP_anaph_code = patients.with_these_clinical_events(
    anaphylaxis_snomed_codes,
    on_or_after = "start_date",
    returning = "code",
    find_first_match_in_period = True,
  ),

  ## check any GP before
  GP_anaph_pre = patients.with_these_clinical_events(
    anaphylaxis_snomed_codes,
    on_or_before = "start_date - 1 day",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  GP_anaph2_pre = patients.with_these_clinical_events(
    codelist(["39579001"], system="snomed"),
    on_or_before = "start_date - 1 day",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  GP_anaph_pre_1y = patients.with_these_clinical_events(
    anaphylaxis_snomed_codes,
    between = ["start_date - 1459 days", "start_date - 1095 days"],
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  GP_anaph_pre_1y_n = patients.with_these_clinical_events(
    anaphylaxis_snomed_codes,
    between = ["start_date - 1459 days", "start_date - 1095 days"],
    returning = "number_of_matches_in_period",
  ),
  GP_anaph_pre_1y_episode = patients.with_these_clinical_events(
    anaphylaxis_snomed_codes,
    between = ["start_date - 1459 days", "start_date - 1095 days"],
    returning = "number_of_episodes",
  ),
  GP_anaph_pre_1m = patients.with_these_clinical_events(
    anaphylaxis_snomed_codes,
    between = ["start_date - 1095 days", "start_date - 1067 days"],
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
)