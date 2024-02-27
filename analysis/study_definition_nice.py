## Adapted codes from https://github.com/opensafely/antibody-and-antiviral-deployment
## Import code building blocks from cohort extractor package 
from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist,
    combine_codelists,
    filter_codes_by_category,
    codelist_from_csv,
)

from codelists import *

study=StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7, 
    },
    index_date = "2023-01-01",
    population=patients.satisfying(
        """
        patient_index_date
        AND has_follow_up
        AND (age >=18 AND age < 110)
        AND (sex="M" OR sex="F")
        AND NOT stp=""
        AND NOT deceased="1"
        AND covid
        """,
    ),

patient_index_date=patients.admitted_to_hospital(
    with_these_diagnoses=covid_icd10_codes,
    returning="date_admitted",
    date_format="YYYY-MM-DD",
    find_first_match_in_period=True,
    between=["2023-01-01", "2023-12-31"],
    return_expectations={"incidence": 1.0, "date": {"earliest": "2020-02-01"}},
),
covid=patients.admitted_to_hospital(
    with_these_diagnoses=covid_icd10_codes,
    returning="binary_flag",
    find_first_match_in_period=True,
    between=["2023-01-01", "2023-12-31"],
    return_expectations={"incidence": 1.0,
    },
),
covid_primary=patients.admitted_to_hospital(
    with_these_diagnoses=covid_icd10_codes,
    returning="binary_flag",
    find_first_match_in_period=True,
    with_these_primary_diagnoses = covid_icd10_codes,
    between=["2023-01-01", "2023-12-31"],
    return_expectations={"incidence": 1.0,
    },
),
critical_care=patients.admitted_to_hospital(
    with_these_procedures=critical_care_opcs4_codes,
    returning="binary_flag",
    between=["patient_index_date", "patient_index_date + 28 days"],
    return_expectations={"incidence": 0.05,
    },
),
critical_days=patients.admitted_to_hospital(
    with_at_least_one_day_in_critical_care=True,
    between=["patient_index_date", "patient_index_date + 28 days"],
    return_expectations={"incidence": 0.05,
    },
),
has_follow_up=patients.registered_with_one_practice_between(
    "patient_index_date - 3 months", "patient_index_date + 28 days",
    return_expectations={"incidence":0.95,
    },
),
deceased=patients.with_death_recorded_in_primary_care(
    returning="binary_flag",
    between=["1970-01-01", "patient_index_date - 1 day"],
    return_expectations={"incidence": 0.01, 
    },
),
age=patients.age_as_of(
    "patient_index_date",
    return_expectations={
        "rate": "universal",
        "int": {"distribution": "population_ages"},
    },
),
sex=patients.sex(
    return_expectations={
        "rate": "universal",
        "category": {"ratios": {"M": 0.49, "F": 0.51}},
    }
),
stp=patients.registered_practice_as_of(
    "patient_index_date",
    returning="stp_code",
    return_expectations={
        "rate": "universal",
        "category": {
            "ratios": {
                "STP1": 1.0,
                }
            },
        },
    ),

## Sotrovimab
  sotrovimab_covid_therapeutics = patients.with_covid_therapeutics(
    #with_these_statuses = ["Approved", "Treatment Complete"],
    with_these_therapeutics = "Sotrovimab",
    with_these_indications = "non_hospitalised",
    between = ["patient_index_date - 60 days", "patient_index_date"],
    find_first_match_in_period = True,
    returning = "binary_flag",
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
    between = ["patient_index_date - 60 days", "patient_index_date"],
    find_first_match_in_period = True,
    returning = "binary_flag",
    return_expectations = {
      "date": {"earliest": "2021-12-16"},
      "incidence": 0.4
    },
  ),


## Death of any cause
death_date = patients.died_from_any_cause(
returning = "date_of_death",
date_format = "YYYY-MM-DD",
on_or_after = "patient_index_date",
return_expectations = {
    "date": {"earliest": "2021-12-20", "latest": "index_date"},
    "incidence": 0.1
},
),

has_died = patients.died_from_any_cause(
on_or_before = "patient_index_date - 1 day",
returning = "binary_flag",
),

## De-registration
dereg_date = patients.date_deregistered_from_all_supported_practices(
on_or_after = "patient_index_date",
date_format = "YYYY-MM-DD",
return_expectations = {
    "date": {"earliest": "2021-12-20", "latest": "index_date"},
    "incidence": 0.1
},
),

## COVID related death
death_with_covid_date = patients.with_these_codes_on_death_certificate(
covid_icd10_codes,
returning = "date_of_death",
date_format = "YYYY-MM-DD",
on_or_after = "patient_index_date",
return_expectations = {
    "date": {"earliest": "2021-01-01", "latest" : "today"},
    "rate": "uniform",
    "incidence": 0.6},
),

)
  