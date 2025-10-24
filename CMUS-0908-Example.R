# Load required libraries/packages
library(tidyverse)
library(opalr)
library(panlemhelpers)

# Load Panel Lémanique data from OPAL
# for help: https://epfl-lasur.github.io/Doc-Panel-L-manique/fonction-helpers/
token = "insert your own token here"
o <- opal.login(token=token, url = "https://panel-lemanique-data.epfl.ch/")
wave2_data <- opal.table_get(o, "Panel Lemanique", "wave2")
fichier <- get_participants_wave1(wave1_data)
fichier$participants
fichier$labels

#opal.logout(o)
