# 1. Introduction
Today's R session uses Structural Equation Modeling (SEM) and latent variables to get access to the Panel Lémanique respondents' social dispositions and habitus. More specifically, we are interested in the mental grid/network of dispositions composing the habitus and related to: 
1) relationship with space,
2) environmental care(lessness),
3) transport modes.

The primary research question we want to tackle is whether individuals' dispositions for (un)sustainable transport modes (3.) are conditionned by their "disposition for spatial orientation" and their "engagement with local places" (1.), while accounting for their enviromnental care(lessness) as potential mediating dispositions (2.). 

The second research question we want to tackle is to determine whether the relationships between these dispositions (i.e., part of the habitus) are gendered, echoing the concept of petromasculinity covered in class. 

Both questions could prove critical in the perspective of designing inclusive and sustainable transport policies. 

We will use the "lavaan" package for R (https://lavaan.ugent.be/).

# 2. Load the data
We use the same data as Week 2 - PaLem Wave 1 includes questions about how (in)convenient people consider 4 transport modes (car, PT, bike, walking) for multiple purposes, about how much they care about their residential surroundings, and about how easily they can travel in space. PalLem Wave 2 includes a lot of questions about environmental care.

You can reuse the token you have created for Week 2 - please think about disconnecting from OPAL after loading the data.

# 3. Information about the data used
Because SEM typically functions with continuous or dummy variables (rather than categorical, contrary to MCA), here is a reminder about how some of the variables are coded:
* Gender identities : 1 = man, 2 = woman (considered as a dummy).
* Level of education : the higher the value the higher the education level.
* Income : the higher the value the higher the income.
* Transport mode (in)convenience (Q101 through Q104) : the higher the value the more convenient the mode.
* Ease to travel in physical space (Q94) : the higher the value the more easy for people to travel in space.
* Knowledge about residential surroundings (Q95) : the higher the value the more familiar people are with their surroundings.
* Environmental care(lessness) : you will have to do the job here!

# 4. Getting familiar with the data (correlation matrices and plots)
### Assessment 1 - Compute and comment correlation plots for indicators related to environmental care(lessness)
What are the relationships you observe between "rep_q..." questions, which are related to enviromnetal care(lessness)?
What are the (multiple) dispositions that could explain such correlations?

# 5. Advanced Structural Equations models
Based on the simple SEM and CFA examples discussed in class, you can now try to scale up the model and include more information contained in the data. You can also try different specification to uncover the gendered dimension(s) of the results.
### Assessment 2 - Compute a CFA for the indicators related to the disposition for environmental care(lessness)
Chose one specification that sounds theoretically and statistically appealing to you. Then name each latent variable (disposition) according to the indicators it is tied to (considering the positive/negative signs of the factor loadings).
### Assessment 3 - Build a SEM integrating the dispositions you have identified, estimate the results and describe them in a the perspective of sustainable urban (transport) policies
...

