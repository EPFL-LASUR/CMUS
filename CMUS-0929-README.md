# 1. Introduction
Today's R session uses Structural Equation Modeling (SEM) and latent variables to get access to the Panel Lémanique respondents' social dispositions and habitus. More specifically, we are interested in the mental grid/network of dispositions composing the habitus and related to: 
1) spatial environment,
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
Because SEM typically functions with continuous or dummy variables (rather than categorical ones, unlike MCA), here is a reminder about how some of the variables are coded:
* Gender identities : 1 = man, 2 = woman (considered as a dummy).
* Level of education : the higher the value the higher the education level.
* Income : the higher the value the higher the income.
* Transport mode (in)convenience (Q101 through Q104) : the higher the value the more convenient the mode.
* Ease to travel in physical space (Q94) : the higher the value the more easy for people to travel in space.
* Knowledge about residential surroundings (Q95) : the higher the value the more familiar people are with their surroundings.
* Environmental care(lessness) : you will have to do the job here!

For non-French speakers, here's a translation of the questions used today:
* rep_q2
When it comes to the environment, my relatives usually behave …

* rep_q3
When it comes to the environment, my relatives expect me to behave …

* rep_q4
The media (news, reports, on television, in newspapers, on the internet, etc.) ______ me to behave in an environmentally friendly way.

* rep_q5
If I want to behave in an environmentally friendly way, …

* rep_q6
For someone like me, behaving in an environmentally friendly way is …

* rep_q7
If I am asked to pay higher prices for goods and services in order to help protect the environment, I would be …

* rep_q8
When I behave in an environmentally friendly way, I feel …

* rep_q9
I believe that my behavior can have a positive impact ______ on the environment.

* rep_q10
Environmental concerns have a ______ place in my consumer and purchasing choices.

* rep_q11
For me, protecting the environment is …

* rep_q12
If we continue like this, we are heading towards …

* rep_q13
I think that many environmentalists present environmental problems in a … way.

* rep_q14
In today’s environmental context, we should all ______ our standard of living.

* rep_q15
Politicians are doing ______ to protect the environment.

* rep_q20_1
How responsible are the following actors for protecting the environment and preventing harmful behaviors towards it? – Politicians

* rep_q20_2
How responsible are the following actors for protecting the environment and preventing harmful behaviors towards it? – Citizens

* rep_q20_3
How responsible are the following actors for protecting the environment and preventing harmful behaviors towards it? – Other actors (industry, businesses, etc.)

* rep_q16
Please indicate your level of agreement with the following statement. It is justified not to worry about the environment because there are more important things in life.

* rep_q17
The impact of one person’s behavior is small, which is why it is pointless to restrict oneself for the environment.

* rep_q18
In general, I behave in a very environmentally friendly way, so it is acceptable if I do not care about the environment in some behaviors (e.g., if I go on vacation by plane).

* rep_q19
Environmentally friendly behavior often costs more than unfriendly behavior, so sometimes I act in an environmentally unfriendly way (e.g., going on vacation by plane instead of paying more to travel in a more environmentally friendly way).

* rep_q21
People who accuse others of negative environmental behaviors usually do no better than others.

* Q94_1
In unfamiliar places, how comfortable are you at finding your way using the following means? – A route planner (smartphone / GPS)

* Q94_2
In unfamiliar places, how comfortable are you at finding your way using the following means? – A map / a public transport map

* Q94_3
In unfamiliar places, how comfortable are you at finding your way using the following means? – Street numbers / road signs

* Q94_4
In unfamiliar places, how comfortable are you at finding your way using the following means? – An unfamiliar person (asking someone you don’t know)

* Q94_5
In unfamiliar places, how comfortable are you at finding your way using the following means? – A familiar person (asking someone you know)

* Q95_1
Please indicate your level of agreement with the following statements. – If disruptions occur before my departure, I am able to change my route or mode of transport without difficulty

* Q95_2
Please indicate your level of agreement with the following statements. – If I have a choice, I prefer my leisure activities to be close to my home

* Q95_3
Please indicate your level of agreement with the following statements. – I am aware of the leisure activities available around my home (restaurants, shops, sports, etc.)

* Q95_4
Please indicate your level of agreement with the following statements. – In general, I try to look for new places and activities that I can do in my city/region

# 4. Getting familiar with the data (correlation matrices and plots)
### Assessment 1 - Compute and comment correlation plots for indicators related to environmental care(lessness)
What are the relationships you observe between "rep_q..." questions, which are related to enviromnetal care(lessness)?
What are the (multiple) dispositions that could explain such correlations?

# 5. Advanced Structural Equations models
Based on the simple SEM and CFA examples discussed in class, you can now try to scale up the model and include more information contained in the data. You can also try different specification to uncover the gendered dimension(s) of the results.
### Assessment 2 - Compute a CFA for the indicators related to the disposition for environmental care(lessness)
Chose one specification that sounds theoretically and statistically appealing to you. Then name each latent variable (disposition) according to the indicators it is tied to (considering the positive/negative signs of the factor loadings).
### Assessment 3 - Build a SEM integrating the dispositions you have identified
Estimate the results from your model specification and describe the results, first with a statistical point of view, and then in the perspective of urban policies recommendations.
