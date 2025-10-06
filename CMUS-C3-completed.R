
# //////////////////////////////////////////////////////////////////////////////
# CMUS EXAMPLE 3 - THE HIGHWAY BALLOT IN THE SWISS POLITICAL LANDSCAPE
# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


# 1 : Libraries ----------------------------------------------------------------


## ... 1 : Load libraries ------------------------------------------------------

install.packages("purrr")
install.packages("rvest")
install.packages("selenider")
install.packages("PCAmixdata")
intall.packages("plotly")

library(dplyr)                                                      # Base R.
library(tidyr)                                                      # Base R.
library(stringr)                                                    # For string manipulation.
library(purrr)                                                      # For the pluck function (read html tables).
library(rvest)                                                      # Everything needed to scrap the web.
library(selenider)                                                  # Everything needed to scrap the web.
library(PCAmixdata)
library(ggplot2)
library(plotly)
library(corrplot)


## ... 2 : Working directory ---------------------------------------------------

setwd("YOUR WORKING DIRECTORY HERE")                                # Set the working directory.


# 2 : Web scrapping ------------------------------------------------------------


## ... 1 : Example -------------------------------------------------------------

session <- selenider_session("chromote",                            # Create a web browser. 
                             browser = "chrome",                    # Use something you have on your computer.
                             options = chromote_options(            # If you do not specify FALSE, you will not see what is actually happening.
                               headless = F))

                                                                    
open_url(                                                           # Start controling the browser. Let's load a webpage.
  "https://www.pxweb.bfs.admin.ch/pxweb/fr/px-x-1703030000_101/-/px-x-1703030000_101.px/")

n_ballots <- session %>%                                            # Let's get the information about how many ballots we can have access to.
  find_element(                                                     # Based on the selector code, we identify the number of ballots on the page.
    "#ctl00_ContentPlaceHolderMain_VariableSelector1_VariableSelector1_VariableSelectorValueSelectRepeater_ctl02_VariableValueSelect_VariableValueSelect_SelectedStatisticsnotifyscreenreader > p > span:nth-child(4)") %>% 
  elem_text() %>% as.numeric()                                      # We specify that it's a text element and we save it as a numerical value.

session %>% find_element(                                           # We click on some elements to navigate through the webpage.
  "#ctl00_ContentPlaceHolderMain_VariableSelector1_VariableSelector1_VariableSelectorValueSelectRepeater_ctl01_VariableValueSelect_VariableValueSelect_SelectAllButton") %>% 
  elem_click()                                                      # Here we click the "select all" html button.

session %>% find_element(                                           # We want to select the oldest ballot available (1960).
  paste0(                                                           # paste0 allows to create a string from a variable we have - here n_ballot. Therefore, we look for "option:nth-child(499)".
    "#ctl00_ContentPlaceHolderMain_VariableSelector1_VariableSelector1_VariableSelectorValueSelectRepeater_ctl02_VariableValueSelect_VariableValueSelect_ValuesListBox > option:nth-child(", n_ballots, ")")) %>% 
  elem_click()

session %>% find_element(                                           # We only care about the share of yes at the level of all Swiss municipalities.
  "#ctl00_ContentPlaceHolderMain_VariableSelector1_VariableSelector1_VariableSelectorValueSelectRepeater_ctl03_VariableValueSelect_VariableValueSelect_ValuesListBox > option:nth-child(7)") %>% 
  elem_click()

session %>% find_element(                                           # We click the "Continue" button.
  "#ctl00_ContentPlaceHolderMain_VariableSelector1_VariableSelector1_ButtonViewTable") %>% 
  elem_click()

session %>% find_element(                                           # We read the data available on the page.
  "#ctl00_ctl00_ContentPlaceHolderMain_cphMain_Table1_Table1_DataTable") %>% 
  read_html() %>% html_table() %>% pluck(1) -> ballots              # We save the data in a new object - the pluck function is necessary when we deal with "list" elements.

back()                                                              # We navigate back to the previous webpage.


## ... 2 : Loop ----------------------------------------------------------------

i = 1                                                               # To do the job for the n_ballot - 1 other ballots, we will need a loop. We initiate a loop variable.

for (i in 1:5) {                                                    # We create a loop on the variable i. To avoid long computation, we stop at 5 - but it should go until n_ballot.
  session %>% find_element(                                         # Same as before.
    "#ctl00_ContentPlaceHolderMain_VariableSelector1_VariableSelector1_VariableSelectorValueSelectRepeater_ctl02_VariableValueSelect_VariableValueSelect_DeselectAllButton") %>% 
    elem_click()
  
  session %>% find_element(                                         # Same as before using the loop variable i.
    paste0(
      "#ctl00_ContentPlaceHolderMain_VariableSelector1_VariableSelector1_VariableSelectorValueSelectRepeater_ctl02_VariableValueSelect_VariableValueSelect_ValuesListBox > option:nth-child(", n_ballots - i, ")")) %>% 
    elem_click()
  
  session %>% find_element(                                         # Same as before.
    "#ctl00_ContentPlaceHolderMain_VariableSelector1_VariableSelector1_ButtonViewTable") %>% 
    elem_click()
  
  Sys.sleep(1)                                                      # Make sure that the webpage has enough time to load (you can increase/decrease the number of seconds).

  session %>% find_element(                                         # We store the data from iteration i in a new object.
    "#ctl00_ctl00_ContentPlaceHolderMain_cphMain_Table1_Table1_DataTable") %>% 
    read_html() %>% html_table() %>% pluck(1) -> ballots_add        # We call it "ballots_add".
  
  ballots <- ballots %>% bind_rows(ballots_add)                     # And then we bind the data with the existing "ballots" object.
  
  back()                                                            # Get the browser ready for the next iteration.
  
  i <- i + 1                                                        # We iterate for another run until n_ballots (or i max) is reached.
}


## ... 3 : Save data -----------------------------------------------------------

write.csv(ballots, "Data/ballots.csv")                              # Given how long the collection can be, we want to make sure to save the data for later. NOTE THAT this will only work if you have a "Data" folder in your working directory.
ballots <- read.csv("Data/ballots.csv")                             # If you want to load the data you just saved.


## ... 4 : Clean data ----------------------------------------------------------

data_ballots <- ballots %>% select(X1:X3) %>%                       # Clean the data.
  rename(entity = X1, ballot = X2, result = X3) %>%                 # Rename columns.
  filter(str_sub(entity, 1, 3) == "...") %>%                        # Only keep values at the level of the municipalities (which all start with "..." in the data).
  mutate(result = case_when(result == ".." ~ NA,                    # We impute NAs when needed (this is because of the fusion/dissolution of municipalities over time).
                            T ~ as.numeric(str_replace(             # When there's no NA, we just change the format from commas to point to allow for numerical conversion.
                              result, ",", "."))),
         entity = str_sub(entity, 7, 100)) %>%                      # We remove the leading "......" to retain the name of the municipalities.
  pivot_wider(names_from = ballot, values_from = result) %>%        # We transform the data in "wide format" where every column is a ballot and every line is a municipality.
  print()

## ... 5 : Get the full data --------------------------------------------------

write.csv(data_ballots, "Data/data_ballots.csv")                    # Save the file once again since it is much smaller.

### >>> START HERE FOR THE ASSESSMENT ----
data <- as_tibble(read.csv("Data/data_ballots.csv")) %>%            # Read the data.
  select(-c(3:121)) %>% na.omit()                                   # We work with a subset of ballots (from 1981) to avoid too much information loss due to NAs.

municipalities_list <- as_tibble(                                   # We use complementary data from the Swiss Confederation about municipalities (available on moodle).
  read.csv("Data/municipalities_region.csv", 
           fileEncoding = "ISO-8859-1")) %>%                        # Specify the encoding to make the import work (you can use the guess_encoding() function if needed.)
  rename(entity = Nom.de.la.commune, canton = Canton) %>%           # Make sure that the name of the column with municipalities is the same as with the data we have.
  select(entity, canton) %>%                                        # We keep name of the municipality and its region for later purposes.
  left_join(as_tibble(                                              # We join another file with other information - by default we join through the municipality name variable.
    read.csv("Data/municipalities.csv", 
             fileEncoding = "ISO-8859-1")) %>%
              rename(entity = Commune, nb_hab = Habitants, 
                     socialist = PS, nationalist = UDC,
                     green = PES, liberal = PLR.2.) %>%
              select(entity, nb_hab,
                     socialist, nationalist, green, liberal))       # We keep information about number of inhabitants et political positions in municipalities.


# 3 : Application --------------------------------------------------------------

## ... 1 : Principal component analysis (PCA) ----------------------------------

pca <- PCAmix(                                                      # PCAmix is another package for Geometric Data Analysis (cf. W2). This one is more straightforward when we are only working with continuous indicators (here the share of yes for all ballots), i.e., Principal Component Analysis (PCA).
  X.quanti = splitmix(                                              # PCAmix can handle a mix of continuous and categorical data. Here we only have the first one (X.quanti).
    select(data, -X, -entity))$X.quanti, ndim = 10)                 # We keep all variables but the row number and the name of the municipality to perform PCA. We ask for 10 dimensions max.

### >>> ASSESSMENT 1 ----
as_tibble(pca$quanti$coord, rownames = "ballot") %>%                # 1 - Retrieve the coordinates of each ballot.
  slice(376) %>%                                                    # 2 - Keep only the 2024 highway ballot (row n° is 376).
  mutate(ballot = "coord") %>%                                      # 3 - Create a new variable named "ballot" where each row has the same string value "coord". 
  bind_rows(as_tibble(                                              # 4 - Bind one new row which is exactly the same but for the contributions rather than the coordinates. Each row should have the same string value "contrib" for the "ballot" variable.
    pca$quanti$contrib.pct, rownames = "ballot") %>% 
      slice(376) %>% 
      mutate(ballot = "contrib")) %>%
  pivot_longer(-ballot, names_to = "dim") %>%                       # 5 - Create a longer format with three columns : ballot (with values "coord" or "contrib"), dim (for each dimension) and value (for the coordinates/contributions). You should get a 20x3 tibble.
  pivot_wider(names_from = ballot)                                  # 6 - Create a wider format with three columns : dim (for each dimension), coord (for the coordinates) and contrib (for the contribution). You should get a 10x3 tibble.

as_tibble(pca$quanti$cos2, rownames = "ballot") %>%                 # cos2 is an indicator of the relevance of each main dimension from the PCA for each ballot.
  slice(376:379)                                                    # Here we search for the ballot about the highways we are interested in (#377).

data_pca <- as_tibble(                                              # We create a table where every line is a ballot with information for all the dimensions.
  pca$quanti$contrib.pct, rownames = "ballots") %>%                 # First we add the contribution from all ballots to each dimension.
  rename(dim1_ctr = `dim 1`, dim2_ctr = `dim 2`,                    # We name them to remember they are contribution. 
         dim3_ctr = `dim 3`, dim4_ctr = `dim 4`, 
         dim5_ctr = `dim 5`,dim6_ctr = `dim 6`, 
         dim7_ctr = `dim 7`, dim8_ctr = `dim 8`, 
         dim9_ctr = `dim 9`, dim10_ctr = `dim 10`) %>%
  bind_cols(as_tibble(pca$quanti$coord)) %>%                        # We do the same for the coordinates of each ballot (similar to W2).
  rename(dim1_crd = `dim 1`, dim2_crd = `dim 2`,                    # We name them accordingly.
         dim3_crd = `dim 3`, dim4_crd = `dim 4`, 
         dim5_crd = `dim 5`, dim6_crd = `dim 6`, 
         dim7_crd = `dim 7`, dim8_crd = `dim 8`, 
         dim9_crd = `dim 9`, dim10_crd = `dim 10`) %>%
  mutate(date = as.Date(str_sub(ballots, 2, 11),                    # We create a new variable to extract the date of each ballot from its name (it's between the 2nd and 11th character).
                        format = '%Y.%m.%d'),                       # We can use the as.Date function to specify a format.
         ballots = str_sub(ballots, start = 13)) %>%                # Now we can remove information about the date from the name itself. 
  select(ballots, date, dim1_ctr, dim1_crd, dim2_ctr, dim2_crd,     # We keep the dimensions we are the most interested in - the three main ones and the 8th since it's related to the highway ballot.
         dim3_ctr, dim3_crd, dim8_ctr, dim8_crd)

as_tibble(pca$quanti$coord, rownames = "ballots") %>%               # plot_ly is an alternative to ggplot that allows for interaction. Here we want a scatter plot of the ballots.
  plot_ly(type = "scatter", x = ~ `dim 1`, y = ~ `dim 2`,           # We can use these plots to interpret the dimensions.
          text = ~ ballots)                                         # We want the name of the ballot to appear upon hovering.

  
## ... 2 : Evolution of divides within the Swiss political landscape -----------

data_pca %>% select(ballots, date,                                  # When did the main dimensions emerge? Are they related to specific time periods?
                    dim1_ctr, dim2_ctr, dim3_ctr, dim8_ctr) %>% 
  pivot_longer(dim1_ctr:dim8_ctr) %>%                               # pivot_longer is the opposite function of pivot_wider (see above)
  group_by(name) %>% mutate(test = cumsum(value)) %>%               # We calculate the cumulative sum of the contribution of each ballot to observe the evolution of each dimension over time.
  ggplot() + geom_line(aes(x = date, y = test, color = name)) +     # We now plot the cumulative distribution over time.
  theme_bw() +
  scale_x_date(expand = c(0, 0)) +                                  # This is to avoid blank spaces at the tails of the x axis.
  scale_y_continuous(expand = c(0, 0)) +                            # Same for y axis.
  scale_color_discrete(                                             # Name the dimensions.
    labels = c("D1 - Social conservatism vs. progressivism", 
               "D2 - Sociotechnical skepticism vs. innovation", 
               "D3 - Market liberalism vs. intervensionnism", 
               "D8 - Ecoenvironmental sustainability vs. efficiency")) +
  labs(x = "Ballots date", y = "Cumulative contribution",           # Name the labels.
        color = "Dimension")

  
## ... 3 : The highway ballot within the Swiss political landscape -------------

### >>> ASSESSMENT 2 ----                                               
                                                                    # Here you can change which dimensions are represented on the graph and analyze the position of the 2024 ballot for each resulting plane. Don't forget to change the name of the axes!
data_pca %>% mutate(highway = case_when(                            # Where does the highway ballot rank within the Swiss political landscape?
  ballots == "Arrêté.fédéral.sur.l.étape.d.aménagement.2023.des.routes.nationales" ~ "2024 highway ballot", 
  T ~ "All other ballots")) %>%                                     # We create a variable to differentiate this ballot from the others.
  ggplot() +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.50) +   # Cosmetic lines on the 0 axes.
  geom_vline(xintercept = 0, linetype = "dashed", alpha = 0.50) +
  geom_point(aes(x = dim1_crd, y = dim3_crd,                        # We look at the position on the 1/2 plane.
                 color = highway, shape = highway)) +               # We use a different color and shape based on our new variable.
  theme_bw() +                                                      # Cosmetic.
  theme(text = element_text(size = 9, color = "black"), 
        axis.title = element_text(face = "bold"), 
        legend.title = element_text(face = "bold"), 
        legend.position = "bottom") +
  coord_cartesian(xlim = c(-1, 1), ylim = c(-1, 1)) +               # We set the limits of the plot. 
  scale_color_manual(values = c("red", "black")) +                  # We choose the colors of the points.
  scale_shape_manual(values = c(15, 19)) +                          # And their shape.
  labs(x = "D1 - Social conservatism vs. progressivism",            # We name the labels. 
       y = "D3 - Market liberalism vs. intervensionnism",                        
       color = "Ballots", shape = "Ballots")


# 3 : Additional html outputs --------------------------------------------------


## ... 1 : Divisions between linguistic regions --------------------------------

as_tibble(pca$ind$coord) %>% bind_cols(select(data, entity)) %>%    # We retrieve the municipalities' coordinates from the PCA and bind the pre-PCA data.
  left_join(municipalities_list) %>% filter(!is.na(canton)) %>%     # We join the information we have about the municipalities and make sure there is no NA.
  mutate(region = case_when(
    canton == "TI" ~ "italian",                                     # We create a new (approximate) variable for the linguistic region based on the region (canton).
    canton == "VD" | canton == "VS" | canton == "GE" | 
      canton == "FR" | canton == "JU" | canton == "NE" ~ "french",
    T ~ "german")) %>%
  plot_ly(type = "scatter",                                         # plot_ly is an alternative to ggplot that allows for interaction. Here we want a scatter plot of the municipalities.
          x = ~ `dim 1`, y = ~ `dim 2`,                             # We choose to examine municipalities on dimensions 1 and 3.
          color = ~ region, text = ~ entity) %>%                    # We use the region as a coloring variable and we make the name of the municipality appear upon hovering. 
  layout(xaxis = list(
    title = "D1 - Social conservatism vs. progressivism"), 
    yaxis = list(
      title = "D2 - Sociotechnical skepticism vs. innovation"))


## ... 2 : Correlation with local success of the political parties -------------

### >>> ASSESSMENT 3 ----
as_tibble(pca$ind$coord) %>%                                        # 1 - Retrieve the coordinates of each municipality from the PCA.
  bind_cols(select(data, entity)) %>%                               # 2 - Bind the "entity" column from the "data" object you have in your environment.
  left_join(municipalities_list) %>%                                # 3 - Join all the information from the "municipalities_list" object you have in your environment.
  filter(nationalist != "*", socialist != "*",                      # 4 - Filter out all municipalities for which we do not know the share of votes for the political parties (they are coded as "*").
         green != "*", liberal != "*") %>%                                 
  mutate(nationalist = as.numeric(nationalist),                     # 5 - Transform the column for each political party into numerical values.
         socialist = as.numeric(socialist),
         green = as.numeric(green),
         liberal = as.numeric(liberal)) %>%            
  select(`dim 1`, `dim 2`, `dim 3`, `dim 8`,                        # 6 - Select the columns related to some dimensions (e.g., 1, 2, 3, and 8) and the columns with the score of each political party.
         socialist, nationalist, green, liberal) %>%
  cor() %>%
  corrplot()

as_tibble(pca$ind$coord) %>% bind_cols(select(data, entity)) %>%    # Once again we retrieve municipalities' coordinate.
  left_join(municipalities_list) %>% filter(nationalist != "*") %>% # We join information about political votings - we make sure there's no NA for the party we are interested in (UDC, far-right).
  mutate(nationalist = as.numeric(nationalist)) %>%                 # We transform the share from UDC into a numerical variable.
  plot_ly(x = ~ `dim 1`, y = ~ `dim 3`,                             # We choose dimensions 1 and 3.
          text = ~ paste(entity, ":",                               # We use paste() to create a label upon hovering.
                         nationalist, "% votes for UDC"),      
          color = ~ nationalist) %>%                                # We use the share of votes for UDC as a coloring variable.
  layout(xaxis = list(
    title = "D1 - Social conservatism vs. progressivism"),
    yaxis = list(
      title = "D3 - Market liberalism vs. intervensionnism"))
  