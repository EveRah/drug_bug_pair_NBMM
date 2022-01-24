# Visualization of resistance data

# Load data

df <- read.csv(paste0('ABR_data/', species, '_', name_atb_class,'_prepared.csv'))

#################################################################################

# Statistics for one specific year

  # Print summary statistics of resistance proportions across countries into text file
  
  sink(paste0("Results_viz_data/", species, '_', name_atb_class, "_stats_", as.character(specific_year), ".txt"))
  
    # mean of proportions across countries
    cat("\n Mean: \n")
    print(
      round(mean(df$propResvsNonRes, na.rm = T), digits = 3) * 100
    )
  
    # standard deviation
    cat("\n Standard Deviation: \n")
    print(
      round(sd(df$propResvsNonRes, na.rm = T), digit = 3) * 100
    )
  
    # quantiles
    cat("\n Quantiles: \n")
    print(
      round(quantile(df$propResvsNonRes, na.rm = T), digit = 3) * 100
    )
  
  sink()

#################################################################################

# Map of resistance prevalence worldwide for one specific year
  
  # If needed --> replace country names to fit the data in "map.world" from the package rworldmap
  
  # df$Country <- str_replace_all(df$Country, c("United States" = "USA",
  #                                             "United Kingdom" = "UK",
  #                                             "Korea, South" = "South Korea",
  #                                             "Slovak Republic" = "Slovakia"))
  
  
  # Subset only the year of interest
  
  df_subset = df %>% filter(Year %in% specific_year)
  
  # Create a blank ggplot theme
  theme_opts <- list(theme(panel.grid.minor = element_blank(),
                           panel.grid.major = element_blank(),
                           panel.background = element_blank(),
                           plot.background = element_blank(),
                           panel.border = element_blank(),
                           axis.line = element_blank(),
                           axis.text.x = element_blank(),
                           axis.text.y = element_blank(),
                           axis.ticks = element_blank(),
                           axis.title.x = element_blank(),
                           axis.title.y = element_blank(),
                           legend.position = "bottom",
                           legend.key.width = unit(2.5, "cm"),
                           plot.title = element_text(size = 20, face = "bold"),
                           legend.title = element_text(size = 20)))
  
  # Plot map of resistance
  
  map.world <- map_data(map = "world") #load map of the world

  gg <- ggplot()
  gg <- gg + theme(legend.position = "right") #position of the colour bar
  gg <- gg + geom_map(data = map.world,
                      map = map.world,
                      aes(map_id = region, x = long, y = lat),
                      fill = "white", colour = "black", size=0.25)
  
  gg <- gg + geom_map(data = df_subset,
                      map = map.world,
                      aes(map_id = Country, fill = propResvsNonRes * 100),
                      color = "white",
                      size = 0.25)   #adding the data (resistance in long format)
  
  gg <- gg + scale_fill_gradient2(low = "#1a9641",
                                  mid = "#ffffbf",
                                  high = "#d7191c", 
                                  space = "Lab",
                                  na.value = "grey50",
                                  guide = "colourbar",
                                  midpoint = 50,
                                  limits = c(0, 100)) #color bar
  
  gg <- gg + labs(title = paste0(pair, " rates, ", as.character(specific_year))) #title
  gg <- gg + theme(plot.title = element_text(hjust = 0.5)) #center the title
  gg <- gg + theme_opts
  
  gg <- gg + labs(fill = "ABR rates \n ") #title of legend
  
  print(gg)
  
  # Save map into PDF file
  
  pdf(file = paste0("Results_viz_data/", species, "_", name_atb_class, "_map_", as.character(specific_year), ".pdf"),
      height = 10,
      width = 15)
  
    print(gg)
  
  dev.off()

#################################################################################

# Plot of resistance datapoints over time time by country
  
  gg <- ggplot(data = df, aes(x = Year, y = propResvsNonRes, group = Country)) +
    geom_point(color = "#2ca25f") +
    geom_line(color = "#99d8c9") +
    ylim(0,1) +
    geom_errorbar(aes(ymin = ICinfProp, ymax = ICsupProp),
                  width = 0.2, position = position_dodge(0.9),
                  color = "black", alpha = 0.8) #95% CI
  
  gg <- gg +
    ggtitle(paste0("Country-specific trajectories of resistance with 95% CI - Drug-bug pair: ", pair)) +
    facet_wrap(~ Country) +
    xlab("Years") +
    ylab("Proportion of resistant isolates") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90)) +
    scale_x_continuous(breaks = seq(as.numeric(year_start),
                                    as.numeric(year_end), 2))
  
  print(gg)
  
  ## Save into pdf    
  
  pdf(file = paste0("Results_viz_data/", species, "_", name_atb_class, "_trend.pdf"),
      height = 10, width = 18)
  
    print(gg)
  
  dev.off()
  
# Plot datapoints and trends of resistance over time by country 
    #with weighted linear regression trend 
    #with associated p-value
    #with color for positive (red) or negative (blue) trend
  
  ## 1. Weighted linear regression for each country
      #keeping count of significant positive and negative trends
  
  significant_positive_trends <- as.integer(0)
  significant_negative_trends <- as.integer(0)
  
  countries <- unique(df$Country)
  
  p_value <- as.numeric(0.05)
  
  results_lm_R <- vector(mode ='numeric') #store R-squared
  results_lm_P <- vector(mode ='numeric') #store P-value
  results_lm_T <- vector(mode = 'numeric') #store T-value
  results_lm_trend <- vector(mode ='numeric') #store slope (trend)
  
  sink(paste0("Results_viz_data/", species, "_", name_atb_class, "_weighted_regression_bycountry.txt"))
  
      for (j in seq_along(countries)) {
        
        #weighted linear regression
        if( sum(is.na(df[df$Country == countries[j], "propResvsNonRes"])) != 16 ) {
          
          reg_c <- lm(formula = propResvsNonRes ~ as.numeric(Year-2004),
                      data = subset(df, df$Country == countries[j]),
                      weights = Total)
          
          print(countries[j])
          
          print(summary(reg_c))
          
          #store results for p-value and R-squared, t-value and slope (trend)
          results_lm_R <- append(results_lm_R, round( summary(reg_c)$r.squared, digits = 3))
          results_lm_P <- append(results_lm_P, round( coef(summary(reg_c))[2,4], digits = 3))
          results_lm_T <- append(results_lm_T, round( coef(summary(reg_c))[2,3], digits = 3))
          results_lm_trend <- append(results_lm_trend, coef(summary(reg_c))[2,1] )
          
        }
        
        #is the trend trend significant ? is the trend positive or negative ?
        if(dim(coef(summary(reg_c)))[1] != 1) {
          
          if( !is.na(coef(summary(reg_c))[2,4]) &
              (coef(summary(reg_c))[2,4] < p_value) &
              (coef(summary(reg_c))[2,1] > 0) ) {
            
            significant_positive_trends <- significant_positive_trends + 1
            
          } else if( !is.na(coef(summary(reg_c))[2,4]) &
                     (coef(summary(reg_c))[2,4] < p_value) &
                     (coef(summary(reg_c))[2,1] < 0) ) {
            
            significant_negative_trends <- significant_negative_trends + 1
            
          }
          
        }
        
      }
      
      print("Number of significant positive temporal trends:")
      print(significant_positive_trends)
      
      print("NUmber of significant negative temporal trends:")
      print(significant_negative_trends)
  
  sink()
  
  #merge all values (results from regression) into dataframe for subsequent analysis
    df_results_lm <- data.frame(countries,
                                df$Total,
                                results_lm_P,
                                results_lm_R,
                                results_lm_T,
                                results_lm_trend)
    
    colnames(df_results_lm) <- c("Country",
                                 "Total",
                                 "p-value",
                                 "R-squared",
                                 "t-value",
                                 "Trend")
  
  #set specific colors depending on sign of the trends
    #red for positive trend
    #blue for negative trend
    #grey for missing values
    df_results_lm$color <- ifelse(df_results_lm$Trend > 0, '#fc9272',
                                ifelse(df_results_lm$Trend < 0, '#9ecae1',
                                       'lightgrey'))
  
  
  #if p-value == 0, change it to < 0.001
  df_results_lm_graph <- df_results_lm
  df_results_lm_graph$`p-value` <- ifelse(df_results_lm_graph$`p-value` == 0,
                                          '<0.001',
                                          df_results_lm_graph$`p-value`)
  
  ## 2. Plot datapoints with weighted linear trends and associated p-values
  
  gg_2 <- ggplot(data = df, aes(x = Year, y = propResvsNonRes, group = Country, weight = Total)) +
    geom_point(color = "#2ca25f") +
    ylim(0,1) +
    geom_errorbar(aes(ymin = ICinfProp, ymax = ICsupProp),
                  width = 0.2, position = position_dodge(0.9),
                  color = "grey", alpha = 0.8,
                  size = 0.5) +
    geom_smooth(method = 'lm', colour = '#fdb863', size = 0.5, se = F) +
    ggtitle(paste0("Country-specific trajectories of resistance with weighted linear trend - Drug-bug pair: ", pair))
    
  #add label
  gg_2  <- gg_2 + geom_label(data = df_results_lm_graph,
               aes(x = Inf, y = Inf,
                   label = `p-value`),
               hjust = 1,
               vjust = 1,
               size = 2.5,
               fill = df_results_lm$color) +
    facet_wrap(~ Country) +
    xlab("Years") +
    ylab("Proportion of resistant isolates") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90)) +
    scale_x_continuous(breaks = seq(as.numeric(year_start),
                                    as.numeric(year_end), 2))
  
  print(gg_2)
  
  ## Save into pdf
  
  pdf (file = paste0("Results_viz_data/", species,"_", name_atb_class, "_resistance_trend_weights_P_VALUES.pdf"),
       height = 10, width = 15)
  
  print(gg_2)
  
  dev.off()
  
  
  ## Store summary results from weighted temporal linear regression for Heat map
  
  df_results_lm_subset <- df_results_lm[1:length(countries), -2]
  
  write.csv(df_results_lm_subset,
            file = paste0( "Results_viz_data/",  species, "_", name_atb_class, "_trend_bycountry_lm_weights_summary.csv"))
  
  
  


