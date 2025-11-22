# 1. Introduction  
For today’s session, we will try to bring together concepts from the past few weeks to estimate the carbon footprint of our daily mobility based on the Panel Lémanique GPS tracking dataset you previously downloaded and [Mobitool CO2 emission factors](https://www.suisseenergie.ch/programmes/calculateur-environnemental-transport/?pk_vid=2a335ec0f1f345b11763814208362476)

# 2. Data
For this practice session, we created a simplified spreadsheet of lifecycle CO2 emission factors, which integrate not only tailpipe emissions, but also energy required for vehicle manufacture, maintenance, end of life as well as energy supply and infrastructure. The [Mobitool CO2 emission factors](https://www.suisseenergie.ch/programmes/calculateur-environnemental-transport/?pk_vid=2a335ec0f1f345b11763814208362476) are the industry reference in Switzerland for C02 emissions calculations. In different countries, energy sources as well as vehicle stocks vary, which means that we would need to apply different emission factors for different countries.
Download the facteurs_mobitool_simpl.csv from the Github repository to get started. The numbers correspond to whole-lifecycle grams of CO2 emitted per kilometer travelled by each transport mode.

# 3. Methodology
This week, we will give you more autonomy in exploring the datasets and developing your own methodology to compute emissions associated with daily mobility. As a starting point, develop a "back-of-the-envelope" equation to relate emission factors with the GPS tracking dataset we have.

# 4. Application
Go ahead and estimate how many tons of CO2 were emitted by panel lémanique respondents over the month of May 2023. Which day had the largest emissions? Why? Which mode emitted the most overall?
