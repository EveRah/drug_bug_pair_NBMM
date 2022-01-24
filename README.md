{\rtf1\ansi\ansicpg1252\cocoartf2580
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica-Bold;\f1\fswiss\fcharset0 Helvetica;\f2\fswiss\fcharset0 Helvetica-Oblique;
\f3\fswiss\fcharset0 Helvetica-BoldOblique;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;\red0\green0\blue0;}
{\*\expandedcolortbl;;\csgray\c0\c0;\csgray\c0;}
\paperw11900\paperh16840\margl1440\margr1440\vieww28300\viewh14960\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\b\fs24 \cf0 \ul \ulc0 Mixed-effect negative binomial model using longitudinal count data of resistant vs non-resistant isolates\ulnone \

\f1\b0 \
Code related to the article: \'ab\'a0Worldwide antibiotic resistance dynamics: how different is it from one drug-bug pair to another ?\'a0\'bb \
Eve Rahbe, Institut Pasteur, Paris\
January 2022\
\
MOCK RUN WITH MOCK DATA\
\

\f0\b \ul 1. Run 1_MAIN_pair_by_pair.R
\f1\b0 \ulnone \
\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f2\i \cf0 Script to:\
- 
\f3\b visualize
\f2\b0  resistance data for one drug-bug pair of interest (maps and trends)\
- 
\f3\b run
\f2\b0  a mixed-effect negative binomial model for one drug-bug pair of interest and 
\f3\b visualize
\f2\b0  results from the model
\f1\i0 \
\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0 \ul 	Input data:\
	
\f0\b \ulnone ABR_data/mockSpecies_mockAtb.csv
\f1\b0 \cb2  (long format by country and year of number of isolates resistant and number of total isolates tested \'97> with susceptibility status of each isolate determined with EUCAST or CLSI breakpoints standards)\
	
\f0\b \cb1 ABR_data/mockSpecies2_mockAtb2.csv
\f1\b0 \
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\b \cf0 	COV_data/mockCov_1.csv\
	COV_data/mockCov_2.csv\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0 	COV_data/mockCov_3.csv\
	COV_data/mockCov_4.csv
\f1\b0 \
\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0 \ul 	Initial parameters\ulnone : \
		Specify:\
			- bacterial species\
			- antibiotic class\
			- isolates threshold (10 or 20) by country-year\
			- sensitivity analysis or not\
\
	\ul Outputs\ulnone :\
		1. 
\f0\b File
\f1\b0  by drug-bug pair prepared (filtered, imputed and with corresponding co-variables)\
		5. Visualisation of antibiotic resistance data\
			\cf3 a. 
\f0\b Map
\f1\b0  for\cb2  one year\
			b. 
\f0\b Trends
\f1\b0  over a period of time\cb1  by country\cf0 \
		6. Mixed-effect negative binomial model results - 
\f0\b Univariate
\f1\b0  analysis and selection of covariables (p-value<20%)\
		7. Mixed-effect negative binomial model results - 
\f0\b Multivariate
\f1\b0  analysis with backward selection (p-value<5%)\
		8. Visualization of 
\f0\b spatial random effects distribution
\f1\b0 \
\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\b \cf0 \ul 2. Run 2_MAIN_all_pairs.R
\f1\b0 \ulnone \
\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f2\i \cf0 Script to:\
- 
\f3\b visualize
\f2\b0  resistance data for multiple drug-bug pairs (boxplots and heatmap of temporal trends) to compare them\
- 
\f3\b visualize
\f2\b0  results from mixed-effect negative binomial models for multiple drug-bug pairs to compare them
\f1\i0 \
\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0 \ul 	Input data\ulnone : \
		Specify:\
			- all bacterial species\
			- all antibiotic class\
			- isolates threshold (10 or 20) by country-year\
\cb2 		Outputs from 1_MAIN_pair_by_pair.R\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0 \cb1 \
	\ul Outputs:\ulnone \
		1. 
\f0\b Box plot
\f1\b0  for ALL drug-bug pairs of resistance prevalence distribution across countries, for one year\
		2. 
\f0\b Heat map
\f1\b0  for ALL drug-bug pairs and all countries based on temporal trends (slope)\
		3. 
\f0\b Spatial Random Effects distribution
\f1\b0  for ALL drug-bug pairs from final multivariable analysis\
\

\f0\b \
\

\f1\b0 \
\
\
}