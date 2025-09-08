# 1. Install R
https://cran.rstudio.com  
For help getting started with R, see this excellent, free e-book: https://r4ds.hadley.nz  
You can start with the intro to get a global sense of R: https://r4ds.hadley.nz/intro.html  

# 2. Install RStudio IDE
https://posit.co/download/rstudio-desktop/  
For help getting started with RStudio, see: https://docs.posit.co/ide/user/ide/get-started/  
Walk through the example in the above link to familiarize yourself with R and RStudio  

# 3. Install specific libraries that we will need for this course
OPAL: https://epfl-lasur.github.io/Doc-Panel-L-manique/OPAL/  
```
install.packages("opalr")
```
PANLEMHELPERS: https://epfl-lasur.github.io/Doc-Panel-L-manique/fonction-helpers/  
```
install.packages("remotes")
remotes::install_github("EPFL-LASUR/panlemhelpers")
```
# 4. Start exploring data
Download a dataset of modal share in different cities here : https://github.com/rafaelprietocuriel/ModalShare/blob/main/ModalShare.csv  
What is the geographical scope of the dataset? How many cities? What is their geographical distribution?
What is the temporal scope of the dataset? What year(s) was the data collected?
What variables are included in this dataset? What can you do with them?
Plot modal share on a graph  
Plot cities on a world map
Plot evolution of modal share in Bogotá (2008-2023) and Buenos Aires (2010-2023)  
What do you observe?

