library(shiny)
library(shinyjs)
library(shinydashboard)
library(shinyFeedback)
library(data.table)
library(countrycode)
library(markdown)
library(rmarkdown)
library(tidyverse)
library(reactable)
library(scales)
library(plotly)
library(agricolae)
library(FSA)
library(EpiEstim)


covid <- fread("https://covid.ourworldindata.org/data/owid-covid-data.csv",
               encoding = "UTF-8")

if (exists("covid") == FALSE){
  covid <- fread("www/covid-all.csv",
                 encoding = "UTF-8")
}

covid <- covid %>%
  select(c(iso_code, continent, date, total_cases, new_cases,
           new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed,
           total_cases_per_million, new_cases_per_million,
           new_cases_smoothed_per_million, total_deaths_per_million,
           new_deaths_per_million, new_deaths_smoothed_per_million,
           reproduction_rate, icu_patients, icu_patients_per_million,
           hosp_patients, hosp_patients_per_million, new_tests,
           total_tests, total_tests_per_thousand, new_tests_per_thousand,
           new_tests_smoothed, new_tests_smoothed_per_thousand,
           positive_rate, total_vaccinations, people_vaccinated,
           people_fully_vaccinated, new_vaccinations, new_vaccinations_smoothed,
           total_vaccinations_per_hundred, people_vaccinated_per_hundred,
           people_fully_vaccinated_per_hundred,
           new_vaccinations_smoothed_per_million)) %>%
  mutate(continent = as.factor(continent),
         country = countrycode(iso_code, "iso3c", "country.name"),
         date = as.Date(date)) %>%
  filter(!is.na(country)) %>%
  select(-iso_code)

# custom.dict <- data.frame(polish = codelist$cldr.name.pl,
#                           english = codelist$cldr.name.en,
#                           stringsAsFactors = FALSE)
# 
# covid$country <- countrycode(covid$country, "english", "polish",
#                              custom_dict = custom.dict)

colnames(covid)[which(names(covid) == "date")] <- "dates"
colnames(covid)[which(names(covid) == "new_cases")] <- "I"

covid <- subset(covid, select = c(1, 36, 2:35))

countries <- unique(covid$country)
covid.cols <- colnames(covid)
factors <- covid.cols[!(covid.cols %in% c("continent", "country", "dates"))]
min.date <- min(covid$dates)
max.date <- max(covid$dates)
