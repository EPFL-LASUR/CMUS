
# //////////////////////////////////////////////////////////////////////////////
# CMUS EXAMPLE 1 - SPACE OF (UN)SUSTAINABLE PRACTICES
# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


# 1 : Libraries and data -------------------------------------------------------


## ... 1 : Load libraries ------------------------------------------------------

install.packages("dplyr")
install.packages("tidyr")
install.packages("opalr")
install.packages("summarytools")
install.packages("haven")
install.packages("forcats")
install.packages("labelled")
install.packages("stringr")
install.packages("GDAtools")
install.packages("ggplot2")
install.packages("ggrepel")
install.packages("cluster")
install.packages("janitor")
install.packages("rgl")

library(dplyr)                                                   # Base R.
library(tidyr)                                                   # Base R.
library(opalr)                                                   # Get access to the data.
library(summarytools)                                            # Function : dfSummary
library(haven)                                                   # Function : as_factor
library(forcats)                                                 # Function : fct_collapse
library(labelled)                                                # Function : to_factor
library(stringr)                                                 # Function : str_sub
library(GDAtools)                                                # Package for Multiple Correspondance Analysis
library(ggplot2)                                                 # Package for plots
library(ggrepel)                                                 # For labels in graphs.
library(cluster)                                                 # For cluster analysis (diana).
library(janitor)                                                 # For cross-tables
library(rgl)                                                     # For 3D graphs.

setwd("WORKING DIRECTORY HERE")                                  # Set a working directory.

## ... 2 : Import the data -----------------------------------------------------

o <- opal.login(token = "TOKEN HERE",                            # Paste your token here.
                url = "https://panel-lemanique-data.epfl.ch/")   # Where the data is hosted.

# Load the required data for this exercise - we will use
# ... two waves from the PaLem.

palem_w1 <- opal.table_get(o, "Panel_Lemanique", "wave1")        # Wave 1 is about mobility.

dico_w1 <- as_tibble((                                           # The tibble format is the best for tables.
  opal.table_dictionary_get(o, "Panel_Lemanique",                # Get the dictionnary of variables.
                            "wave1"))$variables) %>% 
  select(name, `label:en`)                                       # "select" lets us pick columns.

palem_w2 <- opal.table_get(o, "Panel_Lemanique", "wave2")        # Wave 2 is about housing.

dico_w2 <- as_tibble((
  opal.table_dictionary_get(o, "Panel_Lemanique", 
                            "wave2"))$variables) %>% 
  select(name, `label:en`)

# >>>>>>>>>> Please do not forget to disconnect your session after <<<<<<<<<<<<<
# >>>>>>>>>>                  loading data !                       <<<<<<<<<<<<<
opal.logout(o)

palem_typo <- as_tibble(                                         # Complementary house spatial typology.
  read.csv2("EPFL_vague1_typo-territoire.csv")) %>%              # The path to the file (from your wd)
  rename(id = IDNO, typo = dom_Typo_panel)                       # "rename" help us change names of columns.


## 2 : Data handling -----------------------------------------------------------


### ... 1 : Creating new variables ---------------------------------------------

# Let's create a new object to merge all the data into one 
# ... single database. 

palem <- select(palem_w2, id) %>%                                # The pipe operator "%>%" is fundamental and lets us chain operations. We start by only keeping the id column from the 2nd (smallest) dataset.
  left_join(palem_w1, by = "id") %>%                             # "left_join" help merge two datasets that share one common variable - here id.
  left_join(palem_w2, by = "id", 
            suffix = c("_w1", "_w2")) %>%                        # "suffix" makes sure that identical column names in both databases will be differentiated after merging.
  ### >>> Assignment 1 : ADD A LINE TO JOIN panel_typo ----
  # HERE 
  left_join("ADD CODE HERE") %>%
  select(id,                                                     # From here we start picking relevant columns.
         Q4a_1, Q4_1_1_R, Q4_1_2_R, Q10_9_R, Q10_1_R:Q10_8_R,    # 1) Mobility equipment.
         Q33_1, Q33_3:Q33_5,                                     # 2) Mobility practices.
         Q78_1:Q78_4,                                            # 3) Trips frequency.
         Q82_1:Q82_5,                                            # 4) Journeys frequency.
         Q101_1:Q104_5,                                          # 5) Transport mode convenience.
         temp_q1, temp_q1_text, temp_q3, temp_q3_text,           # 6) Heating practices.
         equ_q1_1:equ_q1_16, con_q1_1:con_q1_14,                 # 7) Number of home devices.
         con_q6_neuf_1:con_q6_neuf_11,                           # 8) Comsumption practices.
         con_q8_neuf_1:con_q8_neuf_8, con_q10_fr:con_q13,
         ali_q1_1, ali_q1_4:ali_q1_9, ali_q4_1:ali_q4_10,        # 9) Eating/drinking practices.
         ali_q5:ali_q7,                                          # 10) Grocery shopping practices.
         genre, Q109, Q110, Q120, Q121, typo)                    # 11) Additional sociological and spatial information.

# Let's create some new variables we will include in our 
# ... analysis - we are aiming at categorical variables.

palem_mca <- palem %>%
  mutate(                                                        # "mutate" either transform existing / create new variables based on the name.
    mob_equip_car =                                              # How many cars ppl have in their household ?
      case_when(                                                 # "case_when" is a convenient tool for conditional imputation.
        Q4a_1 == 0 ~ 1,                                          # This reads "when Q4a_1 is 0 then my new variable should be 1.
        Q4_1_1_R == 1 & (Q4_1_2_R == 0 | is.na(Q4_1_2_R)) |      # "&" stands for "and" and "|" for "or" - with "is.na()" we make sure the information is available.
          (Q4_1_1_R == 0 | is.na(Q4_1_1_R)) & 
          Q4_1_2_R == 1 ~ 2,
        Q4_1_1_R == 2 & (Q4_1_2_R == 0 | is.na(Q4_1_2_R)) |
          (Q4_1_1_R == 0 | is.na(Q4_1_1_R)) & Q4_1_2_R == 2 |
          Q4_1_1_R == 1 & Q4_1_2_R == 1 ~ 3,
        Q4_1_1_R > 2 | Q4_1_2_R > 2 | 
          Q4_1_1_R == 2 & Q4_1_2_R >= 1 | Q4_1_1_R >= 1 & 
          Q4_1_2_R == 2 ~ 4,
        T ~ NA),                                                 # This is for safety - it means "when none of the above conditions are matched, impute NA".
    mob_equip_car = labelled(                                    # "labelled" is the format used for the databases - it helps us have numerical factors with information about the factors and the variables.
      mob_equip_car,                                             # We change the existing "mob_equip_car" variable we have just created.
      labels = c("none" = 1, "one" = 2,                          # We provide the labels for each category.
                 "two" = 3, "three or more" = 4), 
      label = "Number of cars"),                                 # We name our new variable.
    mob_equip_pt =                                               # Do individuals have public transport cards ?
      case_when(Q10_9_R == 1 ~ 1,
                rowSums(select(., Q10_1_R:Q10_8_R)) == 1 ~ 2,    # "rowSums" calculates the sum of values in columns "Q10_1_R" to "Q10_8_R" for each individual.
                rowSums(select(., Q10_1_R:Q10_8_R)) > 1 ~ 3,
                T ~ NA),
    mob_equip_pt = labelled(mob_equip_pt, 
                            labels = c("none" = 1, "one" = 2, 
                                       "two or more" = 3), 
                            label = "Number of PT cards"),
    mob_conv_pt =                                                # In general (all trip purposes), what transport modes are considered convenient ? For public transport.
      case_when(rowMeans(select(., Q101_1:Q101_5)) < 1.5 ~ 1,    # "rowMeans" works the same as "rowSums" for means.
                rowMeans(select(., Q101_1:Q101_5)) < 2.5 ~ 2, 
                rowMeans(select(., Q101_1:Q101_5)) < 3.5 ~ 3, 
                rowMeans(select(., Q101_1:Q101_5)) < 4.5 ~ 4,
                rowMeans(select(., Q101_1:Q101_5)) <= 5 ~ 5, 
                T ~ NA),
    mob_conv_pt = labelled(
      mob_conv_pt, 
      labels = c("inconvenient" = 1, "rather inconvenient" = 2,
                 "neutral" = 3, "rather convenient" = 4, 
                 "convenient" = 5), 
      label = "Convenience of PT"),
    mob_conv_car =                                               # For cars.
      case_when(rowMeans(select(., Q102_1:Q102_5)) < 1.5 ~ 1, 
                rowMeans(select(., Q102_1:Q102_5)) < 2.5 ~ 2, 
                rowMeans(select(., Q102_1:Q102_5)) < 3.5 ~ 3, 
                rowMeans(select(., Q102_1:Q102_5)) < 4.5 ~ 4,
                rowMeans(select(., Q102_1:Q102_5)) <= 5 ~ 5, 
                T ~ NA),
    mob_conv_car = labelled(
      mob_conv_car, 
      labels = c("inconvenient" = 1, "rather inconvenient" = 2, 
                 "neutral" = 3, "rather convenient" = 4,
                 "convenient" = 5), 
      label = "Convenience of car"),
    mob_conv_bike =                                               # For bikes.
      case_when(rowMeans(select(., Q103_1:Q103_5)) < 1.5 ~ 1, 
                rowMeans(select(., Q103_1:Q103_5)) < 2.5 ~ 2, 
                rowMeans(select(., Q103_1:Q103_5)) < 3.5 ~ 3, 
                rowMeans(select(., Q103_1:Q103_5)) < 4.5 ~ 4,
                rowMeans(select(., Q103_1:Q103_5)) <= 5 ~ 5, 
                T ~ NA),
    mob_conv_bike = labelled(
      mob_conv_bike, 
      labels = c("inconvenient" = 1, "rather inconvenient" = 2, 
                 "neutral" = 3, "rather convenient" = 4, 
                 "convenient" = 5), 
      label = "Convenience of bike"),
    mob_conv_walk =                                               # For walking.
      case_when(rowMeans(select(., Q104_1:Q104_5)) < 1.5 ~ 1, 
                rowMeans(select(., Q104_1:Q104_5)) < 2.5 ~ 2, 
                rowMeans(select(., Q104_1:Q104_5)) < 3.5 ~ 3, 
                rowMeans(select(., Q104_1:Q104_5)) < 4.5 ~ 4,
                rowMeans(select(., Q104_1:Q104_5)) <= 5 ~ 5, 
                T ~ NA),
    mob_conv_walk = labelled(
      mob_conv_walk, 
      labels = c("inconvenient" = 1, "rather inconvenient" = 2, 
                 "neutral" = 3, "rather convenient" = 4,
                 "convenient" = 5), 
      label = "Convenience of walking"),
    log_temp_lr =                                                 # What temperature individuals set in their living room ?
      case_when(temp_q1 == 2 ~ 1, temp_q1 == 3 ~ 2,
                temp_q1 == 1 & temp_q1_text < 20 ~ 3,
                temp_q1 == 1 & temp_q1_text == 20 ~ 4,
                temp_q1 == 1 & temp_q1_text > 20 ~ 5, T ~ NA),
    log_temp_lr = labelled(
      log_temp_lr, labels = c("no choice" = 1, "no heat" = 2, 
                              "< 20" = 3, "20" = 4, "> 20" = 5), 
      label = "Living room temperature"),
    log_temp_br =                                                 # What temperature individuals set in their bedroom ?
      case_when(temp_q3 == 2 ~ 1, temp_q3 == 3 ~ 2,
                temp_q3 == 1 & temp_q3_text < 20 ~ 3,
                temp_q3 == 1 & temp_q3_text == 20 ~ 4,
                temp_q3 == 1 & temp_q3_text > 20 ~ 5, T ~ NA),
    log_temp_br = labelled(
      log_temp_br, labels = c("no choice" = 1, "no heat" = 2, 
                              "< 20" = 3, "20" = 4, "> 20" = 5), 
      label = "Bedroom temperature"),
    con_equ_em =                                                  # How many household appliances individuals have in their home ?
      case_when(rowSums(select(., equ_q1_1:equ_q1_16)) < 10 ~ 1,
                rowSums(select(., equ_q1_1:equ_q1_16)) < 15 ~ 2,
                is.na(rowSums(select(., 
                                     equ_q1_1:equ_q1_16))) ~ NA,
                T ~ 3),
    con_equ_em = labelled(
      con_equ_em, 
      labels = c("9 or less" = 1, "10 to 14" = 2, 
                 "15 or more" = 3), 
      label = "Number of EM devices"),
    # How many hifi devices individuals have in their home.
    con_equ_hifi =                                                # How many hifi devices individuals have in their home ?
      case_when(rowSums(select(., con_q1_1:con_q1_13)) < 1 ~ 1,
                rowSums(select(., con_q1_1:con_q1_13)) < 2 ~ 2,
                is.na(rowSums(select(., 
                                     con_q1_1:con_q1_13))) ~ NA,
                T ~ 3),
    con_equ_hifi = labelled(
      con_equ_hifi, 
      labels = c("none" = 1, "one" = 2, "2 or more" = 3), 
      label = "Number of hi-fi devices"),
    con_equ_clo =                                                 # How many pieces of clothing individuals bought in the last 12 months.
      case_when(rowSums(
        select(., con_q6_neuf_1:con_q6_neuf_11)) < 10 ~ 1,
        rowSums(select(., 
                       con_q6_neuf_1:con_q6_neuf_11)) < 20 ~ 2,
        is.na(rowSums(
          select(., con_q6_neuf_1:con_q6_neuf_11))) ~ NA,
        T ~ 3),
    con_equ_clo = labelled(
      con_equ_clo, 
      labels = c("9 or less" = 1, "10 to 19" = 2, 
                 "20 or more" = 3), 
      label = "Number of clothes"),
    con_equ_fur =                                                 # How many pieces of furniture individuals  bought in the last 12 months.
      case_when(rowSums(
        select(., con_q8_neuf_1:con_q8_neuf_8)) < 1 ~ 1,
        rowSums(select(., con_q8_neuf_1:con_q8_neuf_8)) < 5 ~ 2,
        is.na(rowSums(
          select(., con_q8_neuf_1:con_q8_neuf_8))) ~ NA,
        T ~ 3),
    con_equ_fur = labelled(
      con_equ_fur, 
      labels = c("none" = 1, "1 to 4" = 2, "5 or more" = 3), 
      label = "Number of furnitures"),
    con_buy_hyg =                                                 # This is just for the sake of homogenization between EUR and CHF.
      case_when(con_q10_fr == 1 | con_q10_ch == 1 ~ 1,
                con_q10_fr == 2 | con_q10_ch == 2 ~ 2,
                con_q10_fr == 3 | con_q10_ch == 3 ~ 3,
                con_q10_fr == 4 | con_q10_ch == 4 ~ 4,
                con_q10_fr == 5 | con_q10_ch == 5 ~ 5,
                con_q10_fr == 6 | con_q10_ch == 6 ~ 6,
                con_q10_fr == 7 | con_q10_ch == 7 ~ 7),
    con_buy_hyg = labelled(
      con_buy_hyg, 
      labels = c("20€ or less" = 1, "21€ to 50€" = 2, 
                 "51€ to 100€" = 3, "101€ to 200€" = 4,
                 "201€ to 300€" = 5, "301€ to 400€" = 6, 
                 "400€ or more" = 7), 
      label = "Price of hygiene products"),
    con_buy_new =                                                 # This is just for the sake of homogenization between EUR and CHF.
      case_when(con_q11_fr == 1 | con_q11_ch == 1 ~ 1,
                con_q11_fr == 2 | con_q11_ch == 2 ~ 2,
                con_q11_fr == 3 | con_q11_ch == 3 ~ 3,
                con_q11_fr == 4 | con_q11_ch == 4 ~ 4,
                con_q11_fr == 5 | con_q11_ch == 5 ~ 5,
                con_q11_fr == 6 | con_q11_ch == 6 ~ 6,
                con_q11_fr == 7 | con_q11_ch == 7 ~ 7),
    con_buy_new = labelled(
      con_buy_new, 
      labels = c("20€ or less" = 1, "21€ to 50€" = 2, 
                 "51€ to 100€" = 3, "101€ to 200€" = 4,
                 "201€ to 300€" = 5, "301€ to 400€" = 6, 
                 "400€ or more" = 7), 
      label = "Price of new products"),
    ### >>> Assignment 2 : ADD A FEW LINES HERE TO CREATE A ----
    # CATEGORICAL VARIABLE ABOUT THE NUMBER OF COFFEES 
    # INDIVIDUALS DRINK EACH WEEK. WE WANT THE FOLLOWING 
    # CATEGORIES : "none", "1 to 5", "6 to 10", "11 to 20", 
    # "21 or more".
    alim_dri_cof = case_when("ADD CODE HERE"),                    # How many coffees individuals drink each week ?
    alim_dri_cof = labelled("ADD CODE HERE"),
    alim_dri_alt =                                                # How many drinks with alternative milks individuals drink each week ?
      case_when((ali_q1_4 + ali_q1_5) < 1 ~ 1, 
                (ali_q1_4 + ali_q1_5) < 2 ~ 2,
                (ali_q1_4 + ali_q1_5) < 5 ~ 3, 
                (ali_q1_4 + ali_q1_5) < 10 ~ 4,
                is.na((ali_q1_4 + ali_q1_5)) ~ NA, T ~ 5),
    alim_dri_alt = labelled(
      alim_dri_alt, 
      labels = c("none" = 1, "1" = 2, "2 to 4" = 3, 
                 "5 to 9" = 4, "10 or more" = 5), 
      label = "Number of alternative milk"),
    # How many sodas individuals drink each week.
    alim_dri_soda =                                               # How many sodas individuals drink each week ?
      case_when(ali_q1_6 < 1 ~ 1, ali_q1_6 < 3 ~ 2,
                ali_q1_6 < 6 ~ 3, ali_q1_6 < 11 ~ 4,
                is.na(ali_q1_6) ~ NA, T ~ 5),
    alim_dri_soda = labelled(
      alim_dri_soda, 
      labels = c("none" = 1, "1 or 2" = 2, "3 to 5" = 3, 
                 "6 to 10" = 4, "11 or more" = 5), 
      label = "Number of sodas"),
    # How many glasses of alcohol individuals drink each week.
    alim_dri_alc =                                                # How many glasses of alcohol individuals drink each week ?
      case_when((ali_q1_7 + ali_q1_8 + ali_q1_9) < 1 ~ 1, 
                (ali_q1_7 + ali_q1_8 + ali_q1_9) < 4 ~ 2,
                (ali_q1_7 + ali_q1_8 + ali_q1_9) < 8 ~ 3, 
                (ali_q1_7 + ali_q1_8 + ali_q1_9) < 11 ~ 4,
                is.na((ali_q1_7 + ali_q1_8 + ali_q1_9)) ~ NA, 
                T ~ 5),
    alim_dri_alc = labelled(
      alim_dri_alc, 
      labels = c("none" = 1, "1 to 2" = 2, "4 to 7" = 3, 
                 "7 to 10" = 4, "11 or more" = 5), 
      label = "Number of alcohol")) %>%
  select(id, mob_equip_car:alim_dri_alc,                          # Keep only the necessary variables.
         Q33_1:Q33_5, Q78_1:Q78_4, Q82_1:Q82_5, con_q13,
         ali_q4_1:ali_q4_10, ali_q5:ali_q7, genre:typo)

dfSummary(palem_mca)                                              # "dfSummary" provides a quick assessment of the data.


### ... 2 : Transforming existing variables ------------------------------------

# Let's prepare the final dataset before the analysis.

palem_act <- palem_mca %>%
  mutate(Q78_1 = recode(Q78_1, `1` = 1L, `2` = 2L, `3` = 3L,      # "recode" helps merging two or more categories together.
                        `4` = 4L, `5` = 5L, `6` = 5L, `7` = 5L,   # Here we state that categories 5, 6 and 7 should be merged together.
                        `8` = 5L, .combine_value_labels = T),     # "combine_value_labels" automatically set up a new label.
         Q78_2 = recode(Q78_2, `1` = 1L, `2` = 2L, `3` = 3L, 
                        `4` = 4L, `5` = 5L, `6` = 5L, `7` = 5L, 
                        `8` = 5L, .combine_value_labels = T),
         Q78_3 = recode(Q78_3, `1` = 1L, `2` = 1L, `3` = 3L, 
                        `4` = 4L, `5` = 5L, `6` = 6L, `7` = 6L, 
                        `8` = 6L, .combine_value_labels = T),
         Q82_2 = recode(Q82_2, `1` = 1L, `2` = 1L, `3` = 3L, 
                        `4` = 4L, `5` = 5L, `6` = 6L, 
                        .combine_value_labels = T),
         Q82_4 = recode(Q82_4, `1` = 1L, `2` = 1L, `3` = 3L, 
                        `4` = 4L, `5` = 5L, `6` = 6L, 
                        .combine_value_labels = T),
         Q82_5 = recode(Q82_5, `1` = 1L, `2` = 1L, `3` = 3L, 
                        `4` = 4L, `5` = 5L, `6` = 6L, 
                        .combine_value_labels = T),
         con_q13 = recode(con_q13, `1` = 1L, `2` = 1L, `3` = 3L, 
                          `4` = 4L, `5` = 5L, `6` = 6L, 
                          .combine_value_labels = T),
         ali_q4_2 = recode(ali_q4_2, `1` = 1L, `2` = 1L, 
                           `3` = 3L, `4` = 4L, `5` = 5L, 
                           .combine_value_labels = T),
         ali_q4_3 = recode(ali_q4_3, `1` = 1L, `2` = 2L, 
                           `3` = 3L, `4` = 3L, `5` = 3L, 
                           .combine_value_labels = T),
         ali_q4_4 = recode(ali_q4_4, `1` = 1L, `2` = 2L, 
                           `3` = 3L, `4` = 4L, `5` = 4L, 
                           .combine_value_labels = T),
         ali_q4_5 = recode(ali_q4_5, `1` = 1L, `2` = 1L, 
                           `3` = 3L, `4` = 4L, `5` = 5L, 
                           .combine_value_labels = T),
         ali_q4_6 = recode(ali_q4_6, `1` = 1L, `2` = 1L, 
                           `3` = 3L, `4` = 4L, `5` = 5L, 
                           .combine_value_labels = T),
         ali_q4_7 = recode(ali_q4_7, `1` = 1L, `2` = 1L, 
                           `3` = 1L, `4` = 4L, `5` = 5L, 
                           .combine_value_labels = T),
         ali_q4_8 = recode(ali_q4_8, `1` = 1L, `2` = 1L, 
                           `3` = 1L, `4` = 4L, `5` = 5L, 
                           .combine_value_labels = T),
         ali_q4_9 = recode(ali_q4_9, `1` = 1L, `2` = 2L, 
                           `3` = 3L, `4` = 4L, `5` = 4L, 
                           .combine_value_labels = T),
         ali_q4_10 = recode(ali_q4_10, `1` = 1L, `2` = 1L, 
                            `3` = 3L, `4` = 4L, `5` = 5L, 
                            .combine_value_labels = T),
         ali_q6 = recode(ali_q6, `1` = 1L, `2` = 2L, `3` = 3L, 
                         `4` = 3L, `5` = 5L, 
                         .combine_value_labels = T),
         ali_q7 = recode(ali_q7, `1` = 1L, `2` = 2L, `3` = 3L, 
                         `4` = 3L, `5` = 5L, 
                         .combine_value_labels = T),
         con_buy_hyg = recode(con_buy_hyg, `1` = 1L, `2` = 2L, 
                              `3` = 3L, `4` = 4L, `5` = 4L, 
                              `6` = 4L, `7` = 4L, 
                              .combine_value_labels = T),
         con_buy_new = recode(con_buy_new, `1` = 1L, `2` = 2L, 
                              `3` = 3L, `4` = 4L, `5` = 4L, 
                              `6` = 4L, `7` = 4L, 
                              .combine_value_labels = T),
         se_cntry = case_when(                                    # Add each individuals' country of residence.
           str_sub(id, 1, 2) == "CH" ~ 1, T ~ 2),                 # "str_sub" gets a string from id by extracting everything in between character 1 and 2 (i.e., CH or FR).
         se_cntry = labelled(
           se_cntry, labels = c("Switzerland" = 1, "France" = 2), 
           label = "Country of residence"),
         se_educ = case_when(Q109 == 1 | Q109 == 2 | Q109 == 3 |  # Homogenize the education categories between France and Switzerland.
                               Q110 == 1 | Q110 == 2 | 
                               Q110 == 3 | Q110 == 5 ~ 1, 
                             Q109 == 4 | Q110 == 4 | Q110 == 6 | 
                               Q110 == 8 ~ 2,
                             Q109 == 5 | Q110 == 7 ~ 3,
                             Q109 == 6 | Q110 == 9 ~ 4,
                             Q109 == 7 | Q110 == 10 ~ 5,
                             T ~ NA),
         se_educ = labelled(
           se_educ, labels = c("none/primary/secondary" = 1, 
                               "vocational" = 2, "bac" = 3, 
                               "bachelor" = 4, "master" = 5), 
           label = "Level of education"),
         se_income = case_when(Q120 == 1 | Q121 == 1 | 
                                 Q121 == 2 ~ 1,                   # Homogenize the income categories (keeping the category "i dont want to answer").
                               Q120 == 2 | Q121 == 3 | 
                                 Q121 == 4 ~ 2,
                               Q120 == 3 | Q121 == 5 | 
                                 Q121 == 6 ~ 3,
                               Q120 == 4 | Q121 == 7 | 
                                 Q121 == 8 ~ 4,
                               Q120 == 5 | Q121 == 9 | 
                                 Q121 == 10 ~ 5,
                               Q120 == 6 | Q120 == 7 | 
                                 Q120 == 8 | Q120 == 9 | 
                                 Q121 == 11 ~ 6,
                               Q120 == 10 | Q121 == 12 ~ 7, 
                               T ~ NA),
         se_income = labelled(
           se_income, labels = c("< 2K" = 1, "2K - 4K" = 2, 
                                 "4K - 6K" = 3, "6K - 8K" = 4, 
                                 "8K - 10K" = 5, "> 10K" = 6, 
                                 "no answer" = 7)))


# 3 : Results ------------------------------------------------------------------


## ... 1 : Multiple Correspondance Analysis (MCA) ------------------------------

# The final step before running the analysis is making
# ... sure that there are no NA values among the active
# ... variables in the MCA.

palem_act <- palem_act %>% filter_at(                             # "filter_at" is an efficient way to remove observations based on multiple conditions at the same time.
  vars(mob_equip_car, mob_equip_pt, log_temp_lr:ali_q7),          # We check all these variables.
  ~ !is.na(.)) %>%                                                # And keep only observations without NAs.
  filter(genre %in% c(1, 2), !is.na(se_educ),                     # We do the same for the socioeconimic variables.
         !is.na(se_income), !is.na(typo)) %>% 
  droplevels()                                                    # "droplevels()" is only there to clean the data for the purpose of visual output later.

getindexcat(                                                      # See all of the categories from the active variables.
  select(palem_act, mob_equip_car, 
         mob_equip_pt, log_temp_lr:ali_q7))

mca <- speMCA(                                                    # "speMCA" is the function to do the Multiple Correspondance Analysis - we only need to specify the active variables.
  select(palem_act, mob_equip_car, mob_equip_pt, 
         log_temp_lr:ali_q7))

# One of the important indicators of MCA is the amount of 
# ... the total variance within the data that we are able to 
# ... cover with our new "dimensions". This is an easy 
# ... information to get with the package we are using.

as_tibble(mca$eig$mrate)                                          # The "mca" object is a list with many information - here we retrieve the "modified rates" of the "eigenvalues" for each dimension.


## ... 2 : Description of the main dimensions ----------------------------------

# In order to understand and describe the main dimensions in 
# ...the analysis, a first step is to understand which are the 
# ... active variables contributing to the "construction" of 
# ... each dimension. We can do that by extracting the 
# "contribution" of each active variable to each dimension.

as_tibble(mca$var$v.contrib, rownames = "variables") %>%          # We get the "variable contribution" from the "variable" element from the mca.
  arrange(-dim.1) %>%                                             # "arrange" lets us sort the contribution from the highest to the lowest.
  filter(dim.1 > 100 / (nrow(mca$var$v.contrib)))                 # We only want to consider the dimensions whose contribution is higher than the mean contribution.
                                                                  # Dimension 1 is related to frequency of journeys/trips and use of transport modes (car/bike).
### >>> Assignment 3 : DESCRIBE WHAT DIMENSION 2 IS RELATED ----
# TO.
as_tibble("ADD CODE HERE")                                        # Dimension 2 is related to ...

as_tibble(mca$var$v.contrib, rownames = "variables") %>%          # Dimension 3 is related to general eating/drinking practices and home heating.
  arrange(-dim.3) %>%
  filter(dim.3 > 100 / (nrow(mca$var$v.contrib)))

# If we now want to go deeper in the characterization of our 
# ... three main dimensions, we can plot all categories from the 
# ... active variables in a two dimensional plane (akin to the
# ... example in the lecture.

as_tibble(mca$var$coord, rownames = "categories") %>%             # We get the "coordinates" from the "variables" (categories) from the mca object. We also specify that the table we expect should include the row names as a column named "categories".
  rename(dim1_coord = `dim.1`, dim2_coord = `dim.2`,              # We rename to be more specific and not get lost afterwards.
         dim3_coord = `dim.3`, dim4_coord = `dim.4`, 
         dim5_coord = `dim.5`) %>%
  bind_cols(                                                      # "bind_cols" - contrary to "left_join" - helps us add new columns WITHOUT a shared variable, to use it we need to make sure that each row corresponds to the same individual (it's always the case in this code).
    as_tibble(mca$var$contrib) %>%                                # We bind the "contributions" from each "variables". Those will be helpful to know whether the correlations are significant. Note that we don't need the "categories" variable twice.
      rename(dim1_contrib = `dim.1`,                              # Once again we make sure to name our new variables adequately.
             dim2_contrib = `dim.2`, 
             dim3_contrib = `dim.3`, 
             dim4_contrib = `dim.4`, 
             dim5_contrib = `dim.5`)) %>%
  mutate(sig = dim1_contrib > 100 / nrow(mca$var$contrib),        # We create a new variable assessing whether the contribution of the category is significant FOR DIMENSION 1. 
         facet = "dim1") %>%                                      # ... and we create another new variable to let us remember that the above operation is only relevant for dimension 1.
  bind_rows(                                                      # "bind_rows" is similar to "bind_cols" but for rows - we want to do the exact same operations as before but for dimension 2, and we need to make sure that the exact same columns are present.
    as_tibble(mca$var$coord, rownames = "categories") %>%
      rename(dim1_coord = `dim.1`, dim2_coord = `dim.2`, 
             dim3_coord = `dim.3`, dim4_coord = `dim.4`, 
             dim5_coord = `dim.5`) %>%
      bind_cols(as_tibble(mca$var$contrib) %>%
                  rename(dim1_contrib = `dim.1`, 
                         dim2_contrib = `dim.2`, 
                         dim3_contrib = `dim.3`, 
                         dim4_contrib = `dim.4`, 
                         dim5_contrib = `dim.5`)) %>%
      mutate(sig = dim3_contrib > 100 / nrow(mca$var$contrib),    # Note here we are doing the same for DIMENSION 3.
             facet = "dim3")) %>% 
  ggplot(                                                         # "ggplot" is the package for plotting the results - it always start like this, but from now on we will use "+" and not "%>%" anymore because we will be adding layers rather than "piping" operations.
    aes(x = dim1_coord, y = dim3_coord)) +                        # "aes()" lets us specify what are the variables to be plotted - here we want a scatter plot of each category with both their coordinates on dimension 1 and 2.
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.50) + # We draw straight lines to mark both axes 0 coordinate.
  geom_vline(xintercept = 0, linetype = "dashed", alpha = 0.50) +
  geom_label_repel(                                               # "geom_label_repel" is a way to label points when there is a lot of information on the same graph - otherwise "geom_label" would have worked too.
    aes(label = if_else(sig == T, categories, NA)),               # Here we only label our categories if (and only if) there are significant on dimension 1 and 2 (see facet later).  
    fontface = "bold", size = 2, segment.size = 0.2,              # This is purely visual - you can play with these parameters. 
    min.segment.length = 0,  segment.linetype = 2, 
    box.padding = 0.25, force = 20) +
  geom_point(aes(alpha = sig), size = 1) +                        # "geom_point" adds a layer of points for each category - here we adjust the transparency based on the significance.
  theme_bw() +                                                    # This sets the theme of the plot - again purely aesthetic.
  facet_grid(. ~ facet,                                           # "facet_grid" lets ggplot know that we are not plotting one but two graphs: one where we care about categories' significance for dimension 1, and the other for dimension 2.
             labeller = as_labeller(                              # "labeller" lets us add a legend to both facets - here we chose the name of each dimension based on our interpretation.
               c("dim1" = "Significant categories for the 'Standards' axis", 
                 "dim3" = "Significant categories for the 'Lifestyle' axis")
             )) +
  theme(text = element_text(size = 9, color = "black"),           # Once again there are cosmetic details. 
        axis.title = element_text(face = "bold"), 
        strip.text = element_text(face = "italic"), 
        legend.title = element_text(face = "bold"), 
        legend.position = "none") +
  coord_cartesian(xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5)) +     # "coord_cartesian" lets us specify the bounds for our x and y axes.
  labs(                                                           # "labs" lets us choose the labels for both our axes.
    x = paste0(                                                   # "paste0" is useful here because we want to name the axis and also to retrieve the eigenvalue of each axis as a piece of information.
      "+ Privation // Abundance + \n (", round(                   # "round" otherwise the number of digits will be too high.
        mca$eig$mrate[1], 1), "% var. ex.)"),                     # Retrieve the eigenvalue of dimension 1 from the mca object.
    y = paste0("+ Urban // Rural + \n (", round(
      mca$eig$mrate[3], 1), "% var. ex.)"))

### >>> Assignment 4 : DESCRIBE AND NAME DIMENSION 2 BY ----
# DOING THE SAME EXERCISE WITH A PLANE MADE OF DIMENSIONS 1 
# and 2.
as_tibble("ADD CODE HERE")


## ... 3 : Correlations with socioeconomic variables ---------------------------

# Now that we know the three main dimensions summarizing the
# ... correlations between practices, we want to know who are
# ... the individuals behind those practices.

ggcloud_indiv(mca)                                                # All individuals on the main plane from the dataset - not super helpful.

ggcloud_indiv(mca) %>%
  ggadd_kellipses(                                                # Let's add tendency ellipses and check whether gender identification plays a role in one's position in the plane.
    ., mca, as_factor(palem_act$genre), kappa = 1, size = 1)      # "as_factor" let's us quickly transform our numbered categories into labelled ones (better for visual outputs).

ggsmoothed_supvar(mca, var = as_factor(palem_act$genre),          # Another way to see it : smoothing the position of each individual based on one category (here "woman"). 
                  cat = "Femme", center = TRUE)

ggcloud_indiv(mca) %>%                                            # The same now for level of education.
  ggadd_kellipses(., mca, as_factor(palem_act$se_educ), 
                  kappa = 1, label = F)

ggcloud_variables(mca, points = "best", shapes = F, alpha = .2,  
                  segment.alpha = .2, col = "lightgrey") %>%
  ggadd_interaction(., mca, as_factor(palem_act$genre),           # Is there any interaction between gender and level of education variables ?
                    as_factor(palem_act$se_educ), 
                    legend = "none")

ggcloud_indiv(mca) %>%                                            # The same for income levels.
  ggadd_kellipses(., mca, as_factor(palem_act$se_income), 
                  kappa = 1, label = F)

ggcloud_variables(mca, points = "best", shapes = F, alpha = .2,   # Is there any interaction between income and country of residence.
                  segment.alpha = .2, col = "lightgrey") %>%
  ggadd_interaction(., mca, as_factor(palem_act$se_cntry), 
                    as_factor(palem_act$se_income), 
                    sel2 = c(1:6), legend = "none")

ggcloud_indiv(mca, axes = c(1, 3)) %>%                            # For dimension 3, let's verify if it's indeed related to the (non-)urban context... 
  ggadd_kellipses(., mca, as_factor(palem_act$typo), 
                  kappa = 1, size = 1)

# Until now we have been rather "descriptive" in our results...
# ... But is all of this really "significant" ? MCA techniques
# ... are equipped with their own statistical tests to check
# ... whether our results can be considered as robust.

dimeta2(                                                          # The Eta2 statistic lets us know how much of each dimension our socioeconomic variable can explain.
  mca, select(palem_act, genre, se_educ, se_income, typo), 
  dim = c(1:3))

dimtypicality(                                                    # Typicality statistics test if socioeconomic variables are restricted to specific panes of the plane.
  mca, select(palem_act, genre, se_educ, se_income, typo), 
  dim = c(1:3))


## ... 4 : Cluster analysis ---------------------------------------------------

# Finally, let's perform some cluster analysis to identify 
# ... "similar individuals" in the data.

clust_d <- dist(                                                  # "dist" calculates the distance separating individuals based on their coordinates on all three dimensions.
  select(as_tibble(mca$ind$coord), dim.1, dim.2, dim.3))          # This time we retrieve the "coordinates" from "individuals" (rather than categories/variables) from the MCA.

clust_ahc <- hclust(clust_d, "ward.D2")                           # "hclust" performs ascending hierarchical clustering (merge individuals together).

clust_dhc <- diana(clust_d)                                       # "diana" performs descending hierarchical clustering (divide the whole sample into smaller groups).

clust_ahc_gr <- factor(cutree(clust_ahc, 4))                      # "cutree" lets us "play" with the number of groups we want to retain for the analysis.
clust_dhc_gr <- factor(cutree(clust_dhc, 4))

ggcloud_indiv(mca) %>%                                            # We can plot our groups on the main plane (of individuals).
  ggadd_chulls(., mca, clust_ahc_gr)
ggcloud_indiv(mca) %>%
  ggadd_chulls(., mca, clust_dhc_gr)

# Sometimes the differences are more clear on a 3D plot
# ... given we rely on three dimensions...

open3d()                                                          # Open a new 3D window.

par3d(windowRect = c(100, 100, 612, 612))                         # Resize the window.

as_tibble(mca$ind$coord) %>%                                      # As usual, get individuals' coordinates.
  bind_cols(as.factor(clust_dhc_gr)) %>%                          # Bind our group variable as a new column.
  rename(group = ...6) %>%
  plot3d(x = .$dim.1, y = .$dim.2, z = .$dim.3,                   # "plot3d" lets us do a scatter in three dimensions.  
         col = rainbow(4)[.$group],    
         type = "s", radius = .02, 
         xlab = "Dimension 1", ylab = "Dimension 2", 
         zlab = "Dimension 3",
         xlim = c(-1, 1), ylim = c(-1, 1), zlim = c(-1, 1))

legend3d("topright",                                              # We just need to add the legend afterwards.
         legend = paste('Group', levels(clust_dhc_gr)), pch = 16, 
         col = rainbow(4), inset = 0.02)

# Now that we have 4 distinctive groups in our population
# ... we can start characterizing them and looking for
# ... relevant socioeconomic differences among them.

palem_act %>% bind_cols(clust_dhc_gr) %>%                         # To do that let's just bind our new group variable to the original (pre-MCA) data.
  rename(group = ...56) %>%
  tabyl(group, genre) %>%                                         # "tabyl" lets us do a two-way table,
  adorn_totals(c("row", "col")) %>% adorn_percentages() %>%       # Cosmetics for the table.
  adorn_pct_formatting(1) %>% adorn_ns()

