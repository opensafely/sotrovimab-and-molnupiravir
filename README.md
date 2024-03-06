# sotrovimab-and-molnupiravir

This is the code and configuration for our ongoing research: "Effectiveness and safety of sotrovimab and molnupiravir for prevention of severe COVID-19 outcomes". The repository content has ONLY been made public to support the OpenSAFELY open science and transparency principles and to support the sharing of re-usable code for other subsequent users. The results have not been peer-reviewed.

You can run this project via [Gitpod](https://gitpod.io) in a web browser by clicking on this badge: [![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/lshbz1/sotrovimab-and-molnupiravir)

* Our pre-print paper can be found [here](https://doi.org/10.1101/2022.05.22.22275417)
* Our study protocol can be found [here](https://github.com/opensafely/sotrovimab-and-molnupiravir/blob/main/docs/OpenSAFELY%20Protocol_sotrovimab%20and%20molnupiravir_Git.pdf)
* Raw model outputs, including charts, crosstabs, etc, are in `released_outputs/`
* If you are interested in how we defined our variables, take a look at the [study definition](analysis/study_definition.py); this is written in `python`, but non-programmers should be able to understand what is going on there
* If you are interested in how we defined our code lists, look in the [codelists folder](./codelists/).
* Developers and epidemiologists interested in the framework should review [the OpenSAFELY documentation](https://docs.opensafely.org)
* NICE requested OpenSAFELY provide up-to-date information to inform their deliberations. Specifically, they wanted to understand the mortality rates for individuals admitted to hospital with COVID-19 and how this varies if the individual was admitted and / or needed ICU. The analysis that was possible to use to support NICE involved a study looking at how antiviral / monoclonal antibody provision to patients affected their mortality; however, due to the change in delivery of the COVID therapeutics away from Community Medicines Delivery units this additional breakdown by treatments was not available. Nevertheless, the information that could be supplied was shared with NICE to inform their wider work.


# About the OpenSAFELY framework

The OpenSAFELY framework is a Trusted Research Environment (TRE) for electronic
health records research in the NHS, with a focus on public accountability and
research quality.

Read more at [OpenSAFELY.org](https://opensafely.org).

# Licences
As standard, research projects have a MIT license. 
