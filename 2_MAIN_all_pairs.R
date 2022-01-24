######################################## MAIN FILE 2 ###################################

# Eve Rahbé

## Pipeline for jointly analyzing drug-bug pairs data from ATLAS, after mixed-effect model runs ##

#libraries required
library(ggplot2)
library(tidyr)
library(dplyr)
library(tidyverse) #str_replace_all()
library(stringr)
library(reshape2) #melt()
library(countrycode) #get continent names form countries
library(imputeTS) #imputation (mean average)
library(binom) #binomial proportion confidence intervals
library(ggpmisc) #print regression equation for ggplot
library(lme4) #mixed-model package
library(ciTools) #library to compute 95% CI around fitted values from lme4 models
library(MuMIn) #R-squared for GLMM (marginal and conditional)
library(lattice) #dotplot()
library(DHARMa) #residuals analysis for gl(m)m
library(car) #test for auto-correlation in the residuals + VIF
library(patchwork) #laying out nicely ggplots together
library(performance) #VIF calculation
library(hash) #library to create dictionaries

library(heatmaply) #heatmap

################################################################################

## Set working environment correctly
rm(list = ls())
path = "/Users/evrahbe/Desktop/these/code/drug_bug_pair_NBMM" #--> CHANGE PATH
setwd(path)

################################################################################

## Initial Parameters

  # Threshold number of isolates tested per year (n = 10)
    n_threshold_isolates = readline("Enter valid isolates threshold value (10 or 20): ")
    
  # Names of the 9 drug-bug pairs (by species and by antibiotic)
    all_atb_class = c('mockAtb', 'mockAtb2') # --> ENTER there the name of all antibiotic classes you want to compare
    all_species = c('mockSpecies', 'mockSpecies2') # --> ENTER there the name of all bacterial species you want to compare
    all_pairs = c('mockPair', 'mockPair2') # --> ENTER there the name of all drug-bug pairs you want to compare

  # Name of initial parameters
    initial_parameters = c("n_threshold_isolates",
                           "all_atb_class",
                           "all_species",
                           "all_pairs",
                           "initial_parameters",
                           "path")
  
################################################################################
      
## Box plot for resistance rates distribution between all pairs for one year across countries
    
    ## Resistance rate plot for specific year
    
    specific_year = readline("Specify the year to plot resistance data: ")
    specific_year <- as.numeric(specific_year)

    ## Load data for all drug-bug pairs
    
    for (i in seq_along(all_atb_class)) {
      assign(
        paste0('df_', all_species[i], '_', all_atb_class[i]), 
        read.csv(paste0('ABR_data/', all_species[i], '_', all_atb_class[i], '_prepared.csv'))
      )
    }
    
  source("2_1_all_pairs_viz/boxplot_pairs.R")

  rm(list = setdiff(ls(), initial_parameters))
  setwd(path)
    
################################################################################
  
## Create heat map of temporal trends (from weighted linear regression) by drug-bug pairs and countries

    ## Load data for all drug-bug pairs
    
    for (i in seq_along(all_atb_class)) {
      assign(
        paste0('df_', all_species[i], '_', all_atb_class[i]), 
        read.csv(paste0('Results_viz_data/', all_species[i], '_', all_atb_class[i], '_trend_bycountry_lm_weights_summary.csv'))
      )
    }
  
  source("2_1_all_pairs_viz/heatmap_pairs.R")

  rm(list = setdiff(ls(), initial_parameters))
  setwd(path)

################################################################################
  
  ## Create plot for visualizing spatial RE from final models for all drug-bug pairs
  
  ## Load data for all drug-bug pairs
  
  for (i in seq_along(all_atb_class)) {
    assign(
      paste0('df_', all_species[i], '_', all_atb_class[i]),
      read.csv(paste0('Results_model/Results_final_model_', all_pairs[i],'/random_effects_by_country_', all_pairs[i], '.csv'))
    )
  }
  
  source("2_1_all_pairs_viz/spatial_RE_pairs.R")
  
  rm(list = setdiff(ls(), initial_parameters))
  setwd(path)
  
  
  