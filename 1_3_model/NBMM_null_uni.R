# Mixed-effect negative binomial model for quantifying association between resistance and candidate factors

                              ## NULL MODEL and UNIVARIATE ANALYSIS ##

## Load data

df <- read.csv(paste0('ABR_data/', species, '_', name_atb_class,'_prepared.csv'))

    # country as factor
    df$Country <- as.factor(df$Country)
    countries <- levels(df$Country)
    
    # region as factor
    df$Region <- as.factor(df$Region)
    regions <- levels(df$Region)

## Create folder to store model results files
    
    if (!file.exists("Results_model")){
      dir.create("Results_model")
    }

## Filter out countries with less than 2 years with non-0 resistant isolates for specific

  if (pair %in% pair_zeroes) {
    
    df <- df %>%
      dplyr::group_by(Country) %>%
      dplyr::mutate(number_of_not_zero = sum(Resistant != 0, na.rm = T)) %>%
      filter(number_of_not_zero > 1) #at least 2 values not equal to 0
    
    print(unique(df$Country))
    
  }

## Sensitivity analysis --> Filter out countries without IQVIA data for atb consumption

  if(sensitivity_boolean == "T") {
    
    df_res_predictors_full <- df_res_predictors_full %>%
      filter(!(Country %in% c('Denmark', 'Netherlands', 'Latvia', 'Lithuania', 'Slovenia')))
    
  }

## Omit missing values from response data and factors
  
  response = c('Resistant', 'Total')
  
  df_na_omit <- na.omit(df[,c("Year", "Country", response, covariables)])

## Check number of 0 and extreme values and countries in the final model

  # Number of 0 resistant isolates
    print("Number of resistant isolates == 0:")
    print(length(which((df_na_omit$Resistant == 0) )))
  
  # Extreme values
    extreme_value = 200
    print("Observations with extreme values:")
    print(df_na_omit[which((df_na_omit$Resistant > extreme_value)), ])
  
  # Countries that will be included in the model
    print("Countries selected to enter the model:")
    print(unique(df_na_omit$Country))

  
## Standardization of co-variables

  # get index of co-variables columns (ONLY FOR NUMERIC CO-VARIABLES)
    index <- match(covariables, names(df_na_omit))
  
  #index numbers in ascending order to scale specific columns
    list_index <- sort(index)
    first = as.numeric(list_index[1])
    last = as.numeric(rev(list_index)[1])

  #scale these specific columns
  df_na_omit[, first:last] <- lapply(df_na_omit[, first:last], function(x) c(scale(x)))
  
  # check scaled variables
  print(summary(df_na_omit))
  

#################### MIXED-EFFET MODEL with standardized data ##################

# Year factor (substract baseline year) 
  df_na_omit$Year_factor <- as.integer(df_na_omit$Year) - as.integer(min(df_na_omit$Year))

## NULL model ----

mixed_mod_log <- lme4::glmer.nb(
  Resistant ~
    1
  + (1 | Year_factor)
  + (1 | Country)
  ,
  data = df_na_omit,
  offset = log(Total)
)

# ------  

## UNIVARIATE models ----

  for(i in 1:number_of_cov) {
    
    assign(
      
      paste0('mixed_mod_log_', i),
      
      # mixed-effect negative binomial model
      lme4::glmer.nb(
        Resistant ~
          1
        + get(covariables[i])
        + (1 | Year_factor)
        + (1 | Country)
        ,
        data = df_na_omit,
        offset = log(Total)
      )
      
    )
    
  }

## ------

################### Store output of null and univariate models ##################

# summaries of the models

  s <- summary(mixed_mod_log)
  print("Results null model:")
  print(s)

  for (i in 1:number_of_cov) {
    assign(
      paste0("s_", i),
      summary(get(paste0("mixed_mod_log_", i)))
    )
  }

# fixed effects of the model

  f <- exp(fixef(mixed_mod_log)) #fixed effects
  print(f)
  
  for (i in 1:number_of_cov) {
    assign(
      paste0("f_", i),
      exp(fixef((get(paste0("mixed_mod_log_", i)))))
    )
  }

# confidence intervals around estimated coefficients

  c <- exp(confint.merMod(mixed_mod_log, method = 'Wald')) #confidence intervals
  print(c)
  
  for (i in 1:number_of_cov) {
    assign(
      paste0("c_", i),
      exp(confint.merMod((get(paste0("mixed_mod_log_", i))), method = "Wald"))
    )
  }

# R-squared (null model only)

  r <- r.squaredGLMM(mixed_mod_log) 
  print(r)
  # R-squared marginal (describe proportion of variance explained by the fixed effects compare to null model)
  # R-squared conditional (describe proportion of variance explained by both the fixed and random effects)
  
# AIC (null model only)
  
  a <- extractAIC(mixed_mod_log) #AIC criterion
  print(a)

###################### Save outputs of models into file ########################
  
# create file to store all models' outputs by pair in the "Results_model" file
  
  dir.create(paste0("Results_model/Results_model_", pair))
  setwd(paste0("Results_model/Results_model_", pair))

# Save results of null model in a text file

    sink(paste0("Results_null_model_", pair,".txt"))
    
            cat("\n Filter on number of isolates: \n")
              print(n_threshold_isolates)
            cat("\n Output of the model: \n")
              print(s)
            cat("\n Fixed effects of the model (exponential): \n")
              print(round(f, digits = 2))
            cat("\n Confindence Intervals of parameters (exponential): \n")
              print(round(c, digits = 2))
            cat("\n R-squared: \n")
              print(r)
            cat("\n AIC: \n")
              print(a)
            cat("\n Variance of temporal random effects: \n")
              print(
                round(as.data.frame(VarCorr(mixed_mod_log))[1,'vcov'], digits=2)
              )
            cat("\n Variance of spatial random effects: \n")
              print(
                round(as.data.frame(VarCorr(mixed_mod_log))[2,'vcov'], digits=4)
              )
      
    sink()  # returns output to the console

# Save results of univariate models in a text file

    sink(paste0("Results_univariate_models_", pair, ".txt"))

            for (i in 1:number_of_cov) {
              
              cat(paste0("\n", covariables[i], "\n"))
              
              cat("\n Output: \n")
                print(
                  summary(get(paste0("s_", i)))
                )
                
              cat("\n Estimates: \n")
                print(
                  summary(get(paste0("f_", i)))
                )
                
              cat("\n 95% CI: \n")
                print(
                  summary(get(paste0("c_", i)))
                )
            }
            
    sink()  # returns output to the console

# Write results of significant co-variables from univariate analysis in a csv file
  
  p_threshold <- as.numeric(0.2) #p-value < 20%
    
  significant_cov <- c()
  
  for (i in 1:number_of_cov) {
    
    if(coef(summary(get(paste0("mixed_mod_log_", i))))[2,4] < p_threshold) {
      
      name_cov = covariables[i]
      significant_cov <- append(significant_cov, name_cov)
      
    }
  }
  
  write.csv(significant_cov, file = paste0('significant_cov_uni_', pair,'.csv'))

  
###################### Visual checks of model assumptions ########################

## Histogram of the response variable

  pdf(file = paste0("histogram_resistant_isolates_country_year_", pair,".pdf"))
  
  hist(df_na_omit$Resistant,
       breaks = 30,
       xlab = 'Number of resistant isolates',
       ylab = 'Country/year observations',
       main = '')
  
  dev.off()

## Histogram of random effects from null model

  #check that temporal random effects are normally distributed (unstructured temporal errors)
    pdf(file = "histogram_random_effects_temporal.pdf")
      hist(as.vector(ranef(mixed_mod_log)[["Year_factor"]])[,1])
    dev.off()
  
  #check that spatial random effects are normally distributed (unstructured spatial errors)
    pdf(file = "histogram_random_effects_spatial.pdf")
      hist(as.vector(ranef(mixed_mod_log)[["Country"]])[,1])
    dev.off()
  
  #store each b-random effects b for each country and save it into a csv file to plot it later
    df_ran_ef_c <- ranef(mixed_mod_log)[["Country"]]
    write.csv(df_ran_ef_c, file = paste0('random_effects_by_country_', pair,".csv" ))
  
  #plot each temporal random effects b for each year
    df_ran_ef_t <- ranef(mixed_mod_log)[["Year_factor"]]
  
    pdf(file = paste0("dotplot_random_effects_temporal_", pair,".pdf"))
      print(dotplot(ranef(mixed_mod_log))[["Year_factor"]])
    dev.off()

## Histogram of the residuals of the null model

  #check that residuals are normally distributed
  pdf(file = paste0("histogram_residuals_", pair,".pdf"))
    hist(resid(mixed_mod_log), breaks = 15)
  dev.off()

## plot Residuals vs fitted values (null model)

  pdf(file = paste0("residuals_vs_fitted_", pair,".pdf"))
    print(plot(fitted(mixed_mod_log), residuals(mixed_mod_log), xlab = 'Fitted Values', ylab = 'Residuals'))
    print(abline(h=0, lty=2))
    print(lines(smooth.spline(fitted(mixed_mod_log), residuals(mixed_mod_log), spar=1), col = 'red'))
  dev.off()

## Check is there is auto-correlation in the residuals
  
  pdf(file = paste0("residuals_PACF_", pair,".pdf"))
    pacf(residuals(mixed_mod_log))   
  dev.off()

  print(durbinWatsonTest(residuals(mixed_mod_log))) #test for auto-correlation in the residuals

## Q_Q plot

  pdf(file = paste0("qq_plot_", pair,".pdf"))
    qqnorm(residuals(mixed_mod_log))
  dev.off()

## test for near singularity (null model)
  
print("Is singular ?:")
  print(isSingular(mixed_mod_log, tol = 1e-4))

## plot Fitted vs Observed
  
  pdf(file = paste0("actual_vs_fitted_", pair,".pdf"))
    print(plot(fitted(mixed_mod_log), df_na_omit$Resistant,
           xlab = 'Fitted values',
           ylab = 'Actual values'))
  dev.off()
  
## Over-dispersion in the data ?
  
  dev <- sum((residuals(mixed_mod_log, type = "pearson"))^2)
  deg_freedom <- df.residual(mixed_mod_log)
  
  print("Overdispersion coefficient:")
  print(overdisp <- dev / deg_freedom) ## deviance / residuals degrees of freedom
  
  if(overdisp > 1.1) {
    print("Data is overdispersed.")
  } else {
    print("Data is not overdispersed.")
  }
  
## Mixed-effect model diagnostics (dharma package)
  
  testDispersion(mixed_mod_log) #dispersion
  simulationOutput <- simulateResiduals(fittedModel = mixed_mod_log, plot = F)
  plot(simulationOutput)

  pdf(paste0("dharma_diag", pair,".pdf"), height = 10, width = 15)
    print(plot(simulationOutput))
  dev.off()

## Visualization of fitted values by null model (fitted vs observed)

  # calculate Confidence Intervals with ciTools library (add_ci function)
  # add fitted values (pred) and CI 95% to the dataset
  
  df_na_omit$Fitted <- fitted(mixed_mod_log)
  
  df_na_omit <- df_na_omit %>% add_ci(mixed_mod_log,
                                      type = "boot",
                                      includeRanef = T, #conditional 95% CI (conditional to a group)
                                      names = c('CI.lower', 'CI.upper'))

  # 1st plot: Observed vs Fitted resistance rates for all countries
  
  gg_1 <- ggplot(data = df_na_omit) +
    geom_point(aes(x = Year, y = (Resistant / Total), group = Country, colour = "#2ca25f")) +
    geom_point(aes(x = Year, y = (Fitted / Total), group = Country, colour = "red")) +
    ggtitle(paste0("Resistance rates by country - ", pair)) +
    # facet_wrap(~ Country, ncol = 7, scales = "free_y") +
    ylim(0,1) +
    facet_wrap(~ Country, ncol = 7) +
    xlab("Years") +
    ylab("Proportion of resistant isolates (resistance rate)") +
    scale_color_discrete(name = "Values",
                         labels = c("Observed", "Fitted")) +
    theme(axis.text.x = element_text(angle = 90)) +
    scale_x_continuous(breaks = seq(2006, 2019, 2))
  
  print(gg_1)
  
  # save into pdf
  pdf(paste0("fitted_rate_over_time", pair,".pdf"), height = 10, width = 15)
    print(gg_1)
  dev.off()

  # 2nd plot: Observed vs Fitted resistance rates with 95% CI around fitted values
  
  gg_2 <- ggplot(data = df_na_omit, aes(x = Year, y = pred, group = Country)) +
    geom_point(color = "#2ca25f") +
    geom_errorbar(data = df_na_omit, aes(ymin = CI.lower,
                                         ymax = CI.upper),
                  width = 0.2, position = position_dodge(0.9),
                  color = "black", alpha = 0.8) +
    geom_point(aes(y = (Resistant / Total)), size = 0.8, color = "red") +
    ggtitle(paste0("Resistance rates by country - ", pair)) +
    # facet_wrap(~ Country, ncol = 7, scales = "free_y") +
    facet_wrap(~ Country, ncol = 7) +
    xlab("Years") +
    ylab("Proportion of resistant isolates (resistance rate)") +
    scale_color_discrete(name = "Values",
                         labels = c("Observed", "Fitted")) +
    theme(axis.text.x = element_text(angle = 90)) +
    scale_x_continuous(breaks = seq(2006, 2019, 2))
  
  print(gg_2)
  
  # save into pdf
  pdf(paste0("fitted_rate_over_time_CI_", pair,".pdf"), height = 10, width = 15)
    print(gg_2)
  dev.off()

