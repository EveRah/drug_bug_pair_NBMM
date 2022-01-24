# Resistance data preparation

#Load dataset
df <- read.csv2(paste0('ABR_data/', species , '_', name_atb_class, '.csv'),
                header = TRUE,
                na.strings = c("","NA"))

#Extract list of countries present in the dataset
countries <- unique(df$Country)

#Extract vector of years present in the dataset
years <- as.numeric(unique(df$Year))

#######################################################################################

# Region

# Add a variable : Region of the World
df$Region <- countrycode(sourcevar = df[, "Country"],
                         origin = "country.name",
                         destination = "region") #based on World Bank Data Indicators

#######################################################################################

# Data filtering

## Filter out years with less than "n_threshold_isolates" isolates

  df_filtered <- df %>%
    dplyr::mutate(
      Total = ifelse((Total < n_threshold_isolates) | is.na(Total),
                     NA, Total),
      Resistant = ifelse((Total < n_threshold_isolates) | is.na(Total),
                         NA, Resistant),
      NonResistant = ifelse((Total < n_threshold_isolates) | is.na(Total),
                            NA, NonResistant)
    )
  
  print(paste0("Number of observations with more than ", n_threshold_isolates ," isolates per country-year:"))
  print(nrow(na.omit(df_filtered)))

## Filter out countries with strictly less than 5 years of data (over 16 years: 2004-2019)

  x = length(years) - 5
  
  df_filtered <- df_filtered %>%
    dplyr::group_by(Country) %>%
    dplyr::mutate(number_of_na = sum(is.na(Total))) %>%
    filter(number_of_na < x) 
  
  print("Countries with strictly more than 5 years of data:")
  print(unique(df_filtered$Country))

#######################################################################################

# Data imputation (moving average with imputeTS package)

  # Set cells to NA if no data

  tmp <- df_filtered %>%
    dplyr::mutate(Resistant = ifelse(is.na(Total) == TRUE, NA, Resistant) )
  
  tmp <- tmp %>%
    dplyr::mutate(NonResistant = ifelse(is.na(Total) == TRUE, NA, NonResistant) )
  
  # Imputation of Total isolates
  
  tmp_imputeTS <- tmp %>%
    group_by(Country) %>%
    dplyr::mutate(Total = if(sum(is.na(Total)) < 15) na_ma(Total, k = 1, weighting = "simple", maxgap = 3) else Total)
  #if country have more than one observation (strictly less than 15 NAs for 16 years of observation),
  #then apply moving average function
  #mean average on windows of i-1 and i+1 with k = 1
  #3 max number of successive NAs to still perform imputation on with maxgap = 3
  
  tmp_imputeTS$Total <- as.integer(tmp_imputeTS$Total)
  
  # Imputation of Resistant isolates
  
  tmp_imputeTS <- tmp_imputeTS %>%
    group_by(Country) %>%
    dplyr::mutate(Resistant = if(sum(is.na(Resistant)) < 15) na_ma(Resistant, k = 1, weighting = "simple", maxgap = 3) else Resistant)
  
  tmp_imputeTS$Resistant <- as.integer(tmp_imputeTS$Resistant)

  # NonResistant isolates
  
  tmp_imputeTS$NonResistant <- ifelse(is.na(tmp_imputeTS$NonResistant) == T,
                                      (tmp_imputeTS$Total - tmp_imputeTS$Resistant),
                                      tmp_imputeTS$NonResistant)
  
  ## Compare number of missing values before/after imputation
  
      #Total isolates
      print("Total isolates: before/after imputation")
      print(summary(tmp$Total)) #before
      print(summary(tmp_imputeTS$Total)) #after
      
      #Resistant isolates
      print("Resistant isolates: before/after imputation")
      print(summary(tmp$Resistant)) #before
      print(summary(tmp_imputeTS$Resistant)) #after
      
  ## Include imputed values to original dataset
      
      df_filtered_imputed <- tmp_imputeTS
  
#######################################################################################

# Proportion and associated 95% CI

  ## Calculate proportions (resistant isolates over total isolates)
  
      df_filtered_imputed$propResvsNonRes <- round(df_filtered_imputed$Resistant / df_filtered_imputed$Total, digit = 3)
  
  ## Calculate CI at 95% for new proportions (Bayesian approach)
  
  ICinfProp <- as.character()
  ICsupProp <- as.character()
  
  for (i in 1:nrow(df_filtered_imputed)) {
    if( !is.na(df_filtered_imputed$Total[i]) ) {
      
      l <- binom.confint(df_filtered_imputed$Resistant[i], df_filtered_imputed$Total[i], methods = "bayes")$lower
      ICinfProp <- append(ICinfProp, l)
      
      u <- binom.confint(df_filtered_imputed$Resistant[i], df_filtered_imputed$Total[i], methods = "bayes")$upper
      ICsupProp <- append(ICsupProp, u)
      
    } else {
      ICinfProp <- append(ICinfProp, NA)
      ICsupProp <- append(ICsupProp, NA)
    }
  }
    
    df_filtered_imputed$ICinfProp <- round(as.numeric(ICinfProp), digit = 3)
    df_filtered_imputed$ICsupProp <- round(as.numeric(ICsupProp), digit = 3)

#######################################################################################

# Co-variables addition

# Load data
    
    for (i in seq_along(covariables)) {
      assign(
        paste0(covariables[i]), 
        read.csv2(paste0('COV_data/', covariables[i],'.csv'))
      )
    }

# Get dataframes in a list
    
    l <- lapply(covariables[1:number_of_cov], get)
    
# Merge co-variables and resistance data
    
    # Add co-variables data by Year and Country to the main dataframe
      df_cov <- plyr::join_all(l, by = c('Year', 'Country'), type = 'left')
    
    df_filtered_imputed_merged <- df_filtered_imputed %>%
      dplyr::left_join(df_cov, by = c("Year", 'Country'))


    # Check the full dataframe
    print(summary(df_filtered_imputed_merged))

    
#######################################################################################
    
# Saving final prepared co-variables + resistance data into new csv file
    
name_csv = paste0('ABR_data/', species, '_', name_atb_class, '_prepared.csv')
    
write.csv(df_filtered_imputed_merged, name_csv, row.names = FALSE)
    
    
    





