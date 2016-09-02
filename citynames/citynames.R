library(readr)
library(dplyr)
library(jsonlite)

# download from geonames.org

citieszip <- tempfile()
altnameszip <- tempfile()
download.file("http://download.geonames.org/export/dump/cities1000.zip", citieszip)
download.file("http://download.geonames.org/export/dump/alternateNames.zip", altnameszip)

# load CSV data into R

citiescsv <- unzip(citieszip, exdir=tempdir())
cities <- readr::read_delim(citiescsv, delim="\t", quote="", col_names=c("geonameid","name","asciiname","alternatenames","latitude","longitude","feature_class","feature_code","country_code","cc2","admin1_code","admin2_code","admin3_code","admin4_code","population","elevation","dem","timezone","modification_date"), guess_max=10000)

altnamescsv <- unzip(altnameszip, exdir=tempdir())
altnames <- readr::read_delim(altnamescsv[grepl("alternateNames.txt", altnamescsv)], delim="\t", quote="", col_names=c("alternateNameId","geonameid","isolanguage","alternate_name","isPreferredName","isShortName","isColloquial","isHistoric"))

# filter out only dutch cities and their english/dutch names

nlcities <- cities %>% filter(country_code == "NL") %>% select(geonameid, name) 
nlandennames <- altnames %>% filter(isolanguage %in% c("nl", "en"))

namestbl <- nlcities %>% left_join(nlandennames, by="geonameid") %>% select(name, alternate_name)

# dump to JSON

nameslist <- sort(unique(c(namestbl$name, namestbl$alternate_name)))
write(toJSON(nameslist), file="citynames.json")

