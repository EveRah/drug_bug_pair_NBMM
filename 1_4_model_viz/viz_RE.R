# Visualization of null and multivariable model spatial random effects distribution

# Create folder to store visualization PDFs and results files
if (!file.exists("Results_viz_data")){
  dir.create("Results_viz_data")
}

# Set working directory
setwd(dir = paste0(path, '/Results_model'))

# Load data
path_null = paste0("Results_model_", pair, "/random_effects_by_country_", pair, ".csv")
path_cov = paste0("Results_final_model_", pair, "/random_effects_by_country_", pair, ".csv")

df_ran_ef_null <- read.csv(path_null)
df_ran_ef_cov <- read.csv(path_cov)

# Prepare data for Dotplot and distribution of spatial RE

  # Get country names
  colnames(df_ran_ef_null) <- c("Country", "Null_model")
  colnames(df_ran_ef_cov) <- c("Country", "Covariables_model")

  countries <- unique(as.character(df_ran_ef_null$Country))

  # Join the two datasets
  df_ran_ef <- df_ran_ef_null %>% left_join(df_ran_ef_cov, by = 'Country')

  # Order random effects values 
  df_ran_ef_ordered <- df_ran_ef[order(df_ran_ef[,2]), , drop = FALSE] #order with null model
  df_ran_ef_ordered_bis <- df_ran_ef[order(df_ran_ef[,3]), , drop = FALSE] #order with co-variables model
  
  # Get dataframe into long format
  df_ran_ef_ordered <- df_ran_ef_ordered %>% gather(key = Model, value = RE, ends_with("model"))

  # Country as factor
  df_ran_ef_ordered$Country <- factor(unique(df_ran_ef_ordered$Country), levels = unique(df_ran_ef_ordered$Country))

  # Plot only co-variables model random effect and color countries based on regions
  df_ran_ef_ordered_bis$Country <- factor(unique(df_ran_ef_ordered_bis$Country), levels = unique(df_ran_ef_ordered_bis$Country))

  # color countries labels by Region of the World
  df_ran_ef_ordered_bis$Region <- countrycode(sourcevar = df_ran_ef_ordered_bis[, "Country"],
                                              origin = "country.name",
                                              destination = "region")

  df_ran_ef_ordered_bis$Region <- as.factor(df_ran_ef_ordered_bis$Region)

  # vector of color for the different Regions of the World
  
      color_region_dictionary <- hash()
      
      color_region_dictionary[["East Asia & Pacific"]] <- "#e6ab02"
      color_region_dictionary[["Europe & Central Asia"]] <- "#66a61e"
      color_region_dictionary[["Latin America & Caribbean"]] <- "#d95f02"
      color_region_dictionary[["Middle East & North Africa"]] <- "#7570b3"
      color_region_dictionary[["North America"]] <- "#1b9e77"
      color_region_dictionary[["South Asia"]] <- "#e5c494"
      color_region_dictionary[["Sub-Saharan Africa"]] <- "#e78ac3"
      
      #for loop to assign colors to each Region if present in the dataset
      col_bis <- c()
      for(i in 1:length(levels(df_ran_ef_ordered_bis$Region))){
        color_region <- color_region_dictionary[[ levels(df_ran_ef_ordered_bis$Region)[i] ]]
        col_bis <- append(col_bis, color_region)
      }
      
     colors <- col_bis[df_ran_ef_ordered_bis$Region] #get colors per Country

# Choose xlim values
     
    x <- max(abs(df_ran_ef_ordered$RE))
     
    xlim_1 <- -round(x, digit = 2)
    xlim_2 <- round(x, digit = 2)
    
     
# Dotplot for covariables model
     
  g <- ggplot(df_ran_ef_ordered_bis, aes(x = Covariables_model, y = Country)) +
    geom_point(size = 2.5) +
    xlim(xlim_1, xlim_2) + #to be centered in 0 --> you can CHANGE the range of values
    xlab("Spatial Random effect") +
    ggtitle(paste0("Random geographical effects distribution covariables model - Drug-bug pair: ", pair)) +
    theme(axis.text.y = element_text(colour = colors, size = 14))
  
  print(g)

# Distributions of the two datasets of RE for null and covariables model (--> should be normal)

  d <- ggplot(df_ran_ef_ordered, aes(x = RE)) +
    geom_density(aes(fill = factor(Model)), alpha = 0.2) +
    scale_fill_manual("Model", labels = c("M_multi model", "M_null model"), values = c("#F8766D", "#00BFC4")) +
    geom_vline(xintercept = 0, linetype = "dotted") +
    xlim(xlim_1, xlim_2) +
    xlab("Spatial Random effect") +
    ylab("Density") +
    theme_bw()
  
  print(d)

# save into individual PDF
  
  pdf(file = paste0('../Results_viz_data/', species, '_', name_atb_class ,'_random_effects_by_country_multi.pdf'), height = 10, width = 15)
    print(g)
  dev.off()

  pdf(file = paste0('../Results_viz_data/', species, '_', name_atb_class, '_random_effects_distributions.pdf'), height = 10, width = 15)
    print(d)
  dev.off()


# save into patchowrk (both by country and distribution in same PDF) --> library patchwork

  patchwork <- g + inset_element(d,
                                 left = 0.55, 
                                 bottom = 0.01, 
                                 right = 0.98, 
                                 top = 0.4,
                                 align_to = "panel")
  
  print(patchwork)
  
  pdf(file = paste0('../Results_viz_data/', species, '_', name_atb_class, '_random_effects_plot.pdf'), height = 10, width = 15)
    print(patchwork)
  dev.off()
