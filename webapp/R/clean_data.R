
## packages
library(readr)
library(dplyr)
library(lubridate)
library(stringr)
library(countrycode)
library(tidyr)
library(anytime)

## Read in eBird data

clean_data <- function (filename) {
  raw_data <- read_csv(filename)
  colnames(raw_data) <- gsub(" |/", "_", colnames(raw_data))
  raw_data %>%
    # remove hybrids and domestics, remove spuhs
    filter(!grepl("hybrid|Domestic", Common_Name),
           !grepl(" sp\\.", Common_Name),
           !grepl("\\/", Common_Name)) %>%
    mutate(sciName = stringr::word(Scientific_Name, 1, 2),
           # removing text between parenthesis in common name to compare uniques
           comName = gsub("\\s*\\([^\\)]+\\)", "", Common_Name),
           # changing state/province into a country factor
           Country = countrycode::countrycode(substr(State_Province, 1, 2), "iso2c", "country.name")) %>%
    mutate(Date = as.Date(Date, format="%m-%d-%Y"),
           Year = year(Date),
           Month = month(Date)) %>%
    unite(., Year_mon, Year, Month, sep="-") %>%
    mutate(Year_mon = anydate(Year_mon))
}


### save study site data as RData file
# save.image("data/corey_data.RData")
