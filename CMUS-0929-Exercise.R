
# //////////////////////////////////////////////////////////////////////////////
# CMUS EXAMPLE 2 - ENVIRONMENTAL CARE(LESSNESS) AND TRANSPORT MODE SUITABILITY
# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


# 1 : Libraries and data -------------------------------------------------------


## ... 1 : Load libraries ------------------------------------------------------

install.packages("corrplot")
install.packages("lavaan")
install.packages("semPlot")

library(dplyr)                                                   # Base R.
library(tidyr)                                                   # Base R.
library(opalr)                                                   # Get access to the data.
library(haven)                                                   # Format of the datasets (labelled).
library(labelled)                                                # Additional functions for labelled (remove_val_labels)
library(corrplot)                                                # Correlation plots useful for descriptive purposes.
library(lavaan)                                                  # The main package for Structural Equation Modeling (SEM).
library(semPlot)

setwd("YOUR WORKING DIRECTORY PATH HERE")                        # Set the working directory.


## ... 2 : Import the data -----------------------------------------------------

o <- opal.login(token = "YOUR TOKEN HERE",                       # Token from OPAL.
                url = "https://panel-lemanique-data.epfl.ch/")   # Where the data is hosted.

palem_w1 <- opal.table_get(o, "Panel_Lemanique", "wave1")        # Wave 1 is about mobility.

dico_w1 <- as_tibble((                                           # The tibble format is the best for tables.
  opal.table_dictionary_get(o, "Panel_Lemanique",                # Get the dictionary of variables.
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

palem_typo <- as_tibble(                                         # Complementary home made spatial typology.
  read.csv2("EPFL_vague1_typo-territoire.csv")) %>%              # The path to the file (from your wd)
  rename(id = IDNO, typo = dom_Typo_panel)                       # "rename" help us change names of columns.


# 2 : Data handling -----------------------------------------------------------

palem <- select(palem_w2, id) %>%                                # The pipe operator "%>%" is fundamental and lets us chain operations. We start by only keeping the id column from the 2nd (smallest) dataset.
  left_join(palem_w1, by = "id") %>%                             # "left_join" help merge two datasets that share one common variable - here id.
  left_join(palem_w2, by = "id", 
            suffix = c("_w1", "_w2")) %>%                        # "suffix" makes sure that identical column names in both databases will be differentiated after merging.
  left_join(palem_typo, by = "id") %>%
  select(id,                                                     # From here we start picking relevant columns.
         Q94_1:Q95_4,                                            # 1) Sense of direction & spatial preferences.
         Q101_1:Q104_5,                                          # 2) Transport modes (in)conveniences.
         rep_q2:rep_q21,                                         # 3) Environmental care(lessness).
         genre, Q109, Q110, Q120, Q121, typo)                    # 4) Additional sociological and spatial information.

palem_sem <- palem %>% filter(genre %in% c(1, 2)) %>%            # Because our models will compare male- and female-identifying individuals, we only keep these answers.
  mutate(se_educ = case_when(Q109 == 1 | Q109 == 2 | Q109 == 3 | # Homogenize the education categories between France and Switzerland.
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
                               #Q120 == 10 | Q121 == 12 ~ 7,      # Note here that contrary to Week 2, we will work with linear regressions - therefore we do not have a good strategy to account for people who do not report their income.
                               T ~ NA),
         se_income = labelled(
           se_income, labels = c("< 2K" = 1, "2K - 4K" = 2, 
                                 "4K - 6K" = 3, "6K - 8K" = 4, 
                                 "8K - 10K" = 5, "> 10K" = 6, 
                                 "no answer" = 7)),
         se_sub = case_when(                                      # We create dummy variables for each spatial profile in the typology (except one, urban centers, which will be used as a reference).
           typo == "Agglomérations centres et suburbains" ~ 1,
           T ~ 0),
         se_sub = labelled(
           se_sub, labels = c("Suburban = yes" = 1, 
                           "Suburban = no" = 2)
         ),
         se_secnd = case_when(
           typo == "Centres secondaires" ~ 1,
           T ~ 0),
         se_secnd = labelled(
           se_secnd, labels = c("Secondary centers = yes" = 1, 
                                "Secondary centers = no" = 2)
         ),
         se_periph = case_when(
           typo == "Périphéries d'agglomération" ~ 1,
           T ~ 0),
         se_periph = labelled(
           se_periph, labels = c("Urban peripheries = yes" = 1, 
                                 "Urban peripheries = no" = 2)
         ),
         se_rural = case_when(
           typo == "Faibles densités et périurbain" ~ 1,
           T ~ 0),
         se_rural = labelled(
           se_rural, labels = c("Rural = yes" = 1, 
                                "Rural = no" = 2)
         )) %>%
  filter_at(                                                      # Only keep observations for which we have access to the entire information
    vars(Q101_1:Q104_5, Q94_1:Q95_4, rep_q2:rep_q21,
         se_educ, se_income),
    all_vars(!is.na(.)))


# 3 : Models and results -------------------------------------------------------


## ... 1 : Correlation matrices and plots --------------------------------------

palem_sem %>% select(Q94_1:Q95_4) %>% cor() %>%                   # cor() computes the correlation between all (environmental care) variables (considered as continuous). 
  corrplot(order = "hclust")                                      # corrplot() from the corresponding package provides visualization tools for correlation. You can try other ordering methods such as 'AOE' (see ?corrplot).

### >>> ASSESSMENT 1 : Compute and comment correlation plots for indicators related to environmental care(lessness) -------

palem_sem %>% select(rep_q2:rep_q21) %>% cor() %>%                # cor() computes the correlation between all (environmental care) variables (considered as continuous). 
  corrplot(order = "AOE")                                         # Here we see that rep_q12 to rep_q19 go in the same direction and that all other variables go in the other direction.

palem_sem %>% select(rep_q2:rep_q21) %>% cor() %>% 
  corrplot(order = "hclust")                                      # Here we see some smaller correlation groups appear.


## ... 2 : A first Structural Equations Model -----------------------------------

palem_sem_cont <- palem_sem %>% remove_val_labels()               # Because Structural Equation Models mostly work with continuous (or dummy) variables, we only keep the factor levels in our dataset (i.e., the numbered version of the data). This is a strong hypothesis for indicators and it would need a discussion about potential limits!

                                                                  # Now we can start creating our first SEM model. Here we have three variables :
                                                                  # 1) The "sense of orientation" or, better, "disposition for spatial orientation" (independent structural variable).
                                                                  # 2) Inclination for car use (i.e., to what extent do individuals think the car is suitable in the future) - (dependent structural variable).
                                                                  # 3) One latent variable yet unnamed that mimic how much individuals do (not) care for the environment (mediating structural variable).
                                                                  # We can then link these latent variables with manifest (objective) variables and between each other through three possible relationships :
                                                                  # 1) =~ is a measurement : latent variables (dispositions) condition indicators.
                                                                  # 2) ~ is a regression : latent variables (dispositions) are "explained" by manifest or other latent variables.
                                                                  # 3) ~~ is a correlation : indicators or latent variables (dispositions) have other reasons to vary together.
model_ex <- ' 
  # measurement model
    ## dependent variables
      car =~ Q102_1 + Q102_2 + Q102_3 + Q102_4 + Q102_5
    ## mediation variables
      ease =~ Q94_1 + Q94_2 + Q94_3
      fac =~ rep_q20_1 + rep_q20_2 + rep_q20_3
    ## indicators
      Q102_1 ~~ Q102_2
  # structural model
    ease ~ se_educ + se_income
    fac ~ ease + se_educ + se_income
    car ~ ease + fac + se_educ + se_income + se_sub + 
          se_secnd + se_periph + se_rural '

fit <- sem(model_ex, data = palem_sem_cont)                       # sem(), provided with data, estimates the parameters of the model.

summary(fit, standardized = T, fit.measures = T)                  # summary produces a summary of the model estimates and quality.

semPaths(fit, what = "std", style = "lisrel", layout = "spring",   # semPaths is a quick way of plotting the model and exploring the results when it's not too complicated.
         rotation = 1, layoutSplit = T)


## ... 3 : Advanced Structural Equation models ---------------------------------

                                                                  # efa() - standing for Exploratory Factor Analysis - helps us in the construction of the "best" latent variables.
                                                                  # Here the idea is to see how many latent variables are "working" in the background of one set of indicators (here transport mode suitability).
                                                                  # To identify the best solution, we rely on both statistical efficience and empirical/theoretical considerations.
efa_model <- '
  efa("efa")*f1 +
  efa("efa")*f2 +
  efa("efa")*f3 +
  efa("efa")*f4 +
  efa("efa")*f5 =~ Q101_1 + Q101_2 + Q101_3 + Q101_4 + Q101_5 + 
                   Q102_1 + Q102_2 + Q102_3 + Q102_4 + Q102_5 + 
                   Q103_1 + Q103_2 + Q103_3 + Q103_4 + Q103_5 + 
                   Q104_1 + Q104_2 + Q104_3 + Q104_4 + Q104_5
'

efa_fit <- efa(efa_model,                                         # We estimate the model and assume that the solution is somewhere between 1 and 5 latent variables.
               data = select(palem_sem, Q101_1:Q104_5), 
               nfactors = 1:5)

summary(efa_fit)                                                  # Print the results.

                                                                  # We can do the same for spatial dispositions.
efa_model <- '
  efa("efa")*f1 +
  efa("efa")*f2 +
  efa("efa")*f3 =~ Q94_1 + Q94_2 + Q94_3 + Q94_4 + Q94_5 + 
                   Q95_1 + Q95_2 + Q95_3 + Q95_4
'

efa_fit <- efa(efa_model, 
               data = select(palem_sem, Q94_1:Q95_4), 
               nfactors = 1:3)

summary(efa_fit)


### >>> ASSESSMENT 2 : Compute a CFA for the indicators related to the disposition for environmental care(lessness) -------


### >>> ASSESSMENT 3 : Build a SEM integrating the dispositions you have identified -------

fit <- sem(`YOUR MODEL NAME HERE`, data = palem_sem_cont, group = "ADD A GROUPING VARIABLE HERE IF WANTED")

summary(fit, standardized = T, fit.measures = T)

semPaths(fit)

modindices(fit, sort = TRUE, maximum.number = 30)                 # modindices() let you know what relationships (=~, ~, or ~~) you could add in order to improve the statistical power of your model.
                                                                  # NOTE THAT this should be used with parcimony and ONLY when the relationships make sense from a theoretical standpoint.




