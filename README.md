**Mixed-effect negative binomial (NBMM) model using longitudinal count data of resistant vs non-resistant isolates by drug-bug pair**

Code related to the article: _Worldwide antibiotic resistance dynamics: how different is it from one drug-bug pair to another?_ \
Eve Rahbe et al., Institut Pasteur, Paris \
January 2022

RUN WITH MOCK DATA

**1. Run 1_MAIN_pair_by_pair.R**

Script to:
- _visualize resistance data for one drug-bug pair of interest (maps and trends)_
- _run a mixed-effect negative binomial model (NBMM) for one drug-bug pair of interest and  visualizeresults from the model_

Input data:
- ABR_data/mockSpecies_mockAtb.csv (long format by country and year of number of isolates resistant and number of total isolates tested with susceptibility status of each isolate determined with EUCAST or CLSI breakpoints standards)
- ABR_data/mockSpecies2_mockAtb2.csv
- COV_data/mockCov_1.csv
- COV_data/mockCov_2.csv
- COV_data/mockCov_3.csv
- COV_data/mockCov_4.csv

Initial parameters:
- bacterial species
- antibiotic class
- isolates threshold (10 or 20) by country-year
- sensitivity analysis or not

Outputs:
1. File by drug-bug pair prepared (filtered, imputed and with corresponding co-variables)\
2. Visualisation of antibiotic resistance data\
a. Map one year\
b. Trends over a period of time by country\
3. Mixed-effect negative binomial model results - Univariate analysis and selection of covariables (p-value<20%)\
4. Mixed-effect negative binomial model results - Multivariate analysis with backward selection (p-value<5%)\
5. Visualization of spatial random effects distribution

**2. Run 2_MAIN_all_pairs.R**

Script to:
- _visualize resistance data for multiple drug-bug pairs (boxplots and heatmap of temporal trends) to compare them_
- _visualize results from mixed-effect negative binomial models for multiple drug-bug pairs to compare them_

Input data:
- Outputs from 1_MAIN_pair_by_pair.R

Initial parameters:
- all bacterial species to be compared
- all antibiotic class to be compared
- all drug-bug pairs to be compared
- isolates threshold (10 or 20) by country-year

Outputs:
1. Box plot for ALL drug-bug pairs of resistance prevalence distribution across countries, for one year
2. Heat map for ALL drug-bug pairs and all countries based on temporal trends (slope)
3. Spatial Random Effects distribution for ALL drug-bug pairs from final multivariable analysis
