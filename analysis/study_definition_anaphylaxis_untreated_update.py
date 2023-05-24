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
    covid_test_positive
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


  ## Inclusion criteria variables
  
  ### First positive SARS-CoV-2 test
  # Note patients are eligible for treatment if diagnosed <=5d ago
  covid_test_positive = patients.with_test_result_in_sgss(
    pathogen = "SARS-CoV-2",
    test_result = "positive",
    returning = "binary_flag",
    on_or_after = "index_date",
    find_first_match_in_period = True,
    restrict_to_earliest_specimen_date = False,
    return_expectations = {
      "incidence": 0.9
    },
  ),
  
  start_date = patients.with_test_result_in_sgss(
    pathogen = "SARS-CoV-2",
    test_result = "positive",
    find_first_match_in_period = True,
    restrict_to_earliest_specimen_date = False,
    returning = "date",
    date_format = "YYYY-MM-DD",
    on_or_after = "index_date",
    return_expectations = {
      "date": {"earliest": "2021-12-20", "latest": "index_date"},
      "incidence": 0.9
    },
  ),
  
  registered_eligible = patients.registered_as_of("start_date"),


  ### Require hospitalisation for COVID-19
  ## NB this data lags behind the therapeutics/testing data so may be missing
  primary_covid_hospital_discharge_date = patients.admitted_to_hospital(
    returning = "date_discharged",
    with_these_primary_diagnoses = covid_icd10_codes,
    with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    #with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    between = ["start_date - 30 days", "start_date - 1 day"],
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2021-12-20", "latest": "index_date - 1 day"},
      "rate": "uniform",
      "incidence": 0.05
    },
  ),
  primary_covid_hospital_admission_date = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_primary_diagnoses = covid_icd10_codes,
    with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    #with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    between = ["start_date - 30 days", "start_date - 1 day"],
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2021-12-20", "latest": "index_date - 1 day"},
      "rate": "uniform",
      "incidence": 0.05
    },
  ),    
  any_covid_hospital_discharge_date = patients.admitted_to_hospital(
    returning = "date_discharged",
    with_these_diagnoses = covid_icd10_codes,
    with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    #with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    between = ["start_date - 30 days", "start_date - 1 day"],
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2021-12-20", "latest": "index_date - 1 day"},
      "rate": "uniform",
      "incidence": 0.05
    },
  ),
  any_covid_hospital_admission_date = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_diagnoses = covid_icd10_codes,
    with_patient_classification = ["1"], # ordinary admissions only - exclude day cases and regular attenders
    # see https://docs.opensafely.org/study-def-variables/#sus for more info
    #with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"], # emergency admissions only to exclude incidental COVID
    between = ["start_date - 30 days", "start_date - 1 day"],
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2021-12-20", "latest": "index_date - 1 day"},
      "rate": "uniform",
      "incidence": 0.05
    },
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


  # HIGH RISK GROUPS ----
  
  ## NHSD ‘high risk’ cohort (codelist to be defined if/when data avaliable)
  # high_risk_cohort_nhsd = patients.with_these_clinical_events(
  #   high_risk_cohort_nhsd_codes,
  #   between = [campaign_start, index_date],
  #   returning = "date",
  #   date_format = "YYYY-MM-DD",
  #   find_first_match_in_period = True,
  # ),
  
  ## Down's syndrome
  downs_syndrome_nhsd_snomed = patients.with_these_clinical_events(
    downs_syndrome_nhsd_snomed_codes,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  downs_syndrome_nhsd_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_diagnoses = downs_syndrome_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  downs_syndrome_nhsd = patients.minimum_of("downs_syndrome_nhsd_snomed", "downs_syndrome_nhsd_icd10"), 
  

  ## Solid cance-updated  
  cancer_opensafely_snomed_new = patients.with_these_clinical_events(
    combine_codelists(
      non_haematological_cancer_opensafely_snomed_codes_new,
      lung_cancer_opensafely_snomed_codes,
      chemotherapy_radiotherapy_opensafely_snomed_codes
    ),
    between = ["start_date - 6 months", "start_date"],
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),    
  ## Haematological diseases
  haematopoietic_stem_cell_snomed = patients.with_these_clinical_events(
    haematopoietic_stem_cell_transplant_nhsd_snomed_codes,
    between = ["start_date - 12 months", "start_date"],
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  haematopoietic_stem_cell_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    between = ["start_date - 12 months", "start_date"],
    with_these_diagnoses = haematopoietic_stem_cell_transplant_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  haematopoietic_stem_cell_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    between = ["start_date - 12 months", "start_date"],
    with_these_procedures = haematopoietic_stem_cell_transplant_nhsd_opcs4_codes,
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  haematological_malignancies_snomed = patients.with_these_clinical_events(
    haematological_malignancies_nhsd_snomed_codes,
    between = ["start_date - 24 months", "start_date"],
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  haematological_malignancies_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    between = ["start_date - 24 months", "start_date"],
    with_these_diagnoses = haematological_malignancies_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  sickle_cell_disease_nhsd_snomed = patients.with_these_clinical_events(
    sickle_cell_disease_nhsd_snomed_codes,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  sickle_cell_disease_nhsd_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_diagnoses = sickle_cell_disease_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  haematological_disease_nhsd = patients.minimum_of("haematopoietic_stem_cell_snomed", 
                                                    "haematopoietic_stem_cell_icd10", 
                                                    "haematopoietic_stem_cell_opcs4", 
                                                    "haematological_malignancies_snomed", 
                                                    "haematological_malignancies_icd10",
                                                    "sickle_cell_disease_nhsd_snomed", 
                                                    "sickle_cell_disease_nhsd_icd10"), 
  
  
  ## Renal disease
  ckd_stage_5_nhsd_snomed = patients.with_these_clinical_events(
    ckd_stage_5_nhsd_snomed_codes,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  ckd_stage_5_nhsd_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_diagnoses = ckd_stage_5_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  ckd_stage_5_nhsd = patients.minimum_of("ckd_stage_5_nhsd_snomed", "ckd_stage_5_nhsd_icd10"), 
  
  ## Liver disease
  liver_disease_nhsd_snomed = patients.with_these_clinical_events(
    liver_disease_nhsd_snomed_codes,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  liver_disease_nhsd_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_diagnoses = liver_disease_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  liver_disease_nhsd = patients.minimum_of("liver_disease_nhsd_snomed", "liver_disease_nhsd_icd10"), 
  
  ## Immune-mediated inflammatory disorders (IMID)
  immunosuppresant_drugs_nhsd = patients.with_these_medications(
    codelist = combine_codelists(immunosuppresant_drugs_dmd_codes, immunosuppresant_drugs_snomed_codes),
    returning = "date",
    between = ["start_date - 6 months", "start_date"],
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  oral_steroid_drugs_nhsd = patients.with_these_medications(
    codelist = combine_codelists(oral_steroid_drugs_dmd_codes, oral_steroid_drugs_snomed_codes),
    returning = "date",
    between = ["start_date - 12 months", "start_date"],
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  oral_steroid_drug_nhsd_3m_count = patients.with_these_medications(
    codelist = combine_codelists(oral_steroid_drugs_dmd_codes, oral_steroid_drugs_snomed_codes),
    returning = "number_of_matches_in_period",
    between = ["start_date - 3 months", "start_date"],
    return_expectations = {"incidence": 0.1,
      "int": {"distribution": "normal", "mean": 2, "stddev": 1},
    },
  ),
  
  oral_steroid_drug_nhsd_12m_count = patients.with_these_medications(
    codelist = combine_codelists(oral_steroid_drugs_dmd_codes, oral_steroid_drugs_snomed_codes),
    returning = "number_of_matches_in_period",
    between = ["start_date - 12 months", "start_date"],
    return_expectations = {"incidence": 0.1,
      "int": {"distribution": "normal", "mean": 3, "stddev": 1},
    },
  ),
  
  # imid_nhsd = patients.minimum_of("immunosuppresant_drugs_nhsd", "oral_steroid_drugs_nhsd"), - define in processing script
  
  
  ## Primary immune deficiencies-updated
  immunosupression_nhsd_new = patients.with_these_clinical_events(
    immunosupression_nhsd_codes_new,
    on_or_before = "start_date",
    returning = "date",
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),  
  ## HIV/AIDs
  hiv_aids_nhsd_snomed = patients.with_these_clinical_events(
    hiv_aids_nhsd_snomed_codes,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  hiv_aids_nhsd_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_diagnoses = hiv_aids_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  hiv_aids_nhsd = patients.minimum_of("hiv_aids_nhsd_snomed", "hiv_aids_nhsd_icd10"),
  
  ## Solid organ transplant
  solid_organ_nhsd_snomed_new = patients.with_these_clinical_events(
    solid_organ_transplant_nhsd_snomed_codes_new,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),  
  solid_organ_transplant_nhsd_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_procedures = solid_organ_transplant_nhsd_opcs4_codes,
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  transplant_all_y_codes_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_procedures = replacement_of_organ_transplant_nhsd_opcs4_codes,
    on_or_before = "start_date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  transplant_thymus_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_procedures = thymus_gland_transplant_nhsd_opcs4_codes,
    between = ["transplant_all_y_codes_opcs4","transplant_all_y_codes_opcs4"],
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  transplant_conjunctiva_y_code_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_procedures = conjunctiva_y_codes_transplant_nhsd_opcs4_codes,
    on_or_before = "start_date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  transplant_conjunctiva_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_procedures = conjunctiva_transplant_nhsd_opcs4_codes,
    between = ["transplant_conjunctiva_y_code_opcs4","transplant_conjunctiva_y_code_opcs4"],
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  transplant_stomach_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_procedures = stomach_transplant_nhsd_opcs4_codes,
    between = ["transplant_all_y_codes_opcs4","transplant_all_y_codes_opcs4"],
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  transplant_ileum_1_Y_codes_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_procedures = ileum_1_y_codes_transplant_nhsd_opcs4_codes,
    on_or_before = "start_date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  transplant_ileum_2_Y_codes_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_procedures = ileum_2_y_codes_transplant_nhsd_opcs4_codes,
    on_or_before = "start_date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  transplant_ileum_1_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_procedures = ileum_1_transplant_nhsd_opcs4_codes,
    between = ["transplant_ileum_1_Y_codes_opcs4","transplant_ileum_1_Y_codes_opcs4"],
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  transplant_ileum_2_opcs4 = patients.admitted_to_hospital(
    returning = "date_admitted",
    with_these_procedures = ileum_2_transplant_nhsd_opcs4_codes,
    between = ["transplant_ileum_2_Y_codes_opcs4","transplant_ileum_2_Y_codes_opcs4"],
    date_format = "YYYY-MM-DD",
    find_first_match_in_period = True,
    return_expectations = {
      "date": {"earliest": "2020-02-01"},
      "rate": "exponential_increase",
      "incidence": 0.01,
    },
  ),
  
  solid_organ_transplant_nhsd_new = patients.minimum_of("solid_organ_nhsd_snomed_new", "solid_organ_transplant_nhsd_opcs4",
                                                    "transplant_thymus_opcs4", "transplant_conjunctiva_opcs4", "transplant_stomach_opcs4",
                                                    "transplant_ileum_1_opcs4","transplant_ileum_2_opcs4"), 
                                                      
  ## Rare neurological conditions
  
  ### Multiple sclerosis
  multiple_sclerosis_nhsd_snomed = patients.with_these_clinical_events(
    multiple_sclerosis_nhsd_snomed_codes,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  multiple_sclerosis_nhsd_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_diagnoses = multiple_sclerosis_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  multiple_sclerosis_nhsd = patients.minimum_of("multiple_sclerosis_nhsd_snomed", "multiple_sclerosis_nhsd_icd10"), 
  
  ### Motor neurone disease
  motor_neurone_disease_nhsd_snomed = patients.with_these_clinical_events(
    motor_neurone_disease_nhsd_snomed_codes,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  motor_neurone_disease_nhsd_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_diagnoses = motor_neurone_disease_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  motor_neurone_disease_nhsd = patients.minimum_of("motor_neurone_disease_nhsd_snomed", "motor_neurone_disease_nhsd_icd10"),
  
  ### Myasthenia gravis
  myasthenia_gravis_nhsd_snomed = patients.with_these_clinical_events(
    myasthenia_gravis_nhsd_snomed_codes,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  myasthenia_gravis_nhsd_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_diagnoses = myasthenia_gravis_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  myasthenia_gravis_nhsd = patients.minimum_of("myasthenia_gravis_nhsd_snomed", "myasthenia_gravis_nhsd_icd10"),
  
  ### Huntington’s disease
  huntingtons_disease_nhsd_snomed = patients.with_these_clinical_events(
    huntingtons_disease_nhsd_snomed_codes,
    on_or_before = "start_date",
    returning = "date",
    date_format = "YYYY-MM-DD",
    find_last_match_in_period = True,
  ),
  
  huntingtons_disease_nhsd_icd10 = patients.admitted_to_hospital(
    returning = "date_admitted",
    on_or_before = "start_date",
    with_these_diagnoses = huntingtons_disease_nhsd_icd10_codes,
    find_last_match_in_period = True,
    date_format = "YYYY-MM-DD",
  ),
  
  huntingtons_disease_nhsd = patients.minimum_of("huntingtons_disease_nhsd_snomed", "huntingtons_disease_nhsd_icd10"),
  
  
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