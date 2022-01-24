######################################## MAIN FILE ###################################

# Eve Rahbé

## Pipeline for analyzing drug-bug pair data using custom-made functions ##

            # spatio-temporal trends and associated factors #

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

#######################################################################################

## Set working environment correctly
rm(list = ls())
path = "/Users/evrahbe/Desktop/these/code/drug_bug_pair_NBMM"
#path = ".."
setwd(path)

#######################################################################################

## Initial Parameters

source("0_dictionary.R")

    # Name of bacterial species
    print(species_dictionary) #dictionary
      
    species_key = readline("Enter a valid key for a bacterial species: ")
    
      if(!(species_key %in% keys(species_dictionary))){
        print("Wrong key for valid bacterial species.")
        print("Try other key or create your own key for a new bacterial species name.")
      } else {
        print("Valid bacterial species:")
        species <- species_dictionary[[species_key]] #bacterial species name
        print(species)
      }
    
    # Name of antibiotic class or molecule
    print(antibiotic_dictionary) #dictionary
    
    antibiotic_key = readline("Enter a valid key for an antibiotic class: ")
    
      if(!(antibiotic_key %in% keys(antibiotic_dictionary))){
        print("Wrong key for valid antibiotic class.")
        print("Try other key or create your own key for new antibiotic class name.")
      } else {
        print("Valid antibiotic class:")
        name_atb_class <- antibiotic_dictionary[[antibiotic_key]] #antibiotic class name
        print(name_atb_class)
      }
    
    # Threshold number of isolates tested per year (n = 10)
    n_threshold_isolates = readline("Enter valid isolates threshold value (10 or 20): ")
    # n = 20 isolates for sensitivity analysis
    
    # Sensitivity analysis
    sensitivity_boolean = readline("Do you want to perform a sensitivity analysis ? (T or F): ")
        # --> sensitivity analysis: exclude countries that do not have IQVIA data for atb consumption, but ESAC-Net data instead
    
    # From initial parameters, create drug-bug pair name
    source("0_drug_bug_pair_name.R")
    print(pair)
    
    # Covariables
    number_of_cov = readline("How many covariables do you want to test?: ") 
    number_of_cov <- as.integer(number_of_cov)
    covariables = c('mockCov_1', 'mockCov_2', 'mockCov_3', 'mockCov_4') # --> ENTER your co-variables names
    
    # Name of initial parameters
    initial_parameters = c("path",
                           "species",
                           "name_atb_class",
                           "n_threshold_isolates",
                           "sensitivity_boolean",
                           "pair",
                           "number_of_cov",
                           "covariables",
                           "initial_parameters")
    
    rm(list = setdiff(ls(), initial_parameters))
    setwd(path)

#######################################################################################
        
## Prepare data for subsequent analysis
    
    #addition of World's Region based on Country name
    #filtering based on isolates threshold
    #imputation of missing values
    #addition of proportion of resistance and 95% CI around proportions
    #addition of co-variables data for each country-year

  source("1_1_data_prep/data_prep.R")

  rm(list = setdiff(ls(), initial_parameters))
  setwd(path)
  
#######################################################################################
  
## Visualization of antibiotic resistance data

  ## Resistance rate map for specific year
  
  specific_year = readline("Specify the year to map resistance data: ")
  specific_year <- as.numeric(specific_year)

  ## Temporal trends
    
  year_start = readline("Specify the starting year to determine temporal trend: ")
  year_end = readline("Specify the ending year to determine temporal trend: ")
  year_start <- as.numeric(year_start)
  year_end <- as.numeric(year_end)

    source("1_2_data_viz/data_viz.R")
  
    rm(list = setdiff(ls(), initial_parameters))
    setwd(path)

#######################################################################################
    
## Mixed-effect negative binomial model - null model and univariate models
    
    pair_zeroes = c("specific_pair_with_a_lot_of_zeroes", "specific_pair_2_with_a_lot_of_zeroes")
        #(only for drug-bug pairs with a lot of 0) --> ENTER name of drug-bug pairs
    
      source("1_3_model/NBMM_null_uni.R")
      
      rm(list = setdiff(ls(), c(initial_parameters, 'pair_zeroes')))
      setwd(path)
    
## Mixed-effect negative binomial model - multivariable analysis
    
      source("1_3_model/NBMM_multi.R")
      
      rm(list = setdiff(ls(), initial_parameters))
      setwd(path)
   
#######################################################################################
    
## Spatial Random Effect by Country Plot from null and multivariable results
    
    source("1_4_model_viz/viz_RE.R")
    
    rm(list = setdiff(ls(), initial_parameters))
    setwd(path)


