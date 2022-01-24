# Generate heat map for pairs x countries data on temporal weighted linear trends

# Create folder to store visualization PDFs and results files for compared analysis

if (!file.exists("Results_viz_all_pairs")){
  dir.create("Results_viz_all_pairs")
}

# Create list from dataframes of all pairs
  df_list = list(df_mockSpecies_mockAtb,
                 df_mockSpecies2_mockAtb2) #--> ENTER the name of other pairs

# Get only columns of interest for all df
  df_list <- lapply(df_list, function(x) {
    x %>% select(c("Country", "Trend")) #Trend is temporal trend for time period of interest
  })

# Merge datasets together by country
  all_df <- df_list[[1]] #first pair
  
  for(j in head(seq_along(df_list), -1)) {
    all_df <- merge(all_df,
                    df_list[[j+1]],
                    all = TRUE, 
                    suffixes = paste0(all_atb_class[j:(j+1)], '_', all_species[j:(j+1)]),
                    by = c("Country"))
  }

# Name of columns
  colnames(all_df) <- c('Country' , all_pairs)

# Get dataframe into Matrix format (required for the heat map) without countries names
  df_all_matrix <- as.matrix(all_df[,-1])

# Get countries as rownames
  rownames(df_all_matrix) <- all_df[,1]

# Transpose the matrix to get pairs as rows and countries as columns
  df_all_matrix <- t(df_all_matrix)

# Colors for the legend
  
    ## Column side : coloring countries by Region of the World
      # get Region names for countries
      df_region_countries <- data.frame(all_df[,1])
      colnames(df_region_countries) <- "Country"
      df_region_countries$Region <- countrycode(sourcevar = df_region_countries[, "Country"],
                                                origin = "country.name",
                                                destination = "region") #based on World Bank Data Indicators
      
      df_region_countries$Region <- as.factor(df_region_countries$Region)

    ## Row side : coloring pairs by Bacterial Species
      # get Region names for countries
      df_species_pairs <- as.data.frame(matrix (nrow = length(all_pairs)) )
      df_species_pairs$Pair <- all_pairs
      df_species_pairs$Species <- as.factor(all_species)
      
    ## Values: coloring legend for values in the heat map
      
      # Histogram of all values
        hist(df_all_matrix)
      
      # Get maximum value of the matrix
        max_slope <- max(df_all_matrix, na.rm = T)
        max_slope
      
      # Get minimum value of the matrix
        min_slope <- min(df_all_matrix, na.rm = T)
        min_slope
  
      # Colors for slope legend (temporal trends)  
      gradient_color <- ggplot2::scale_fill_gradientn(
        #colors from blue to red
        colours = c("#4575b4",
                    "#74add1",
                    "#abd9e9",
                    "#e0f3f8",
                    "#ffffbf",
                    "#fee090",
                    "#fdae61", 
                    "#f46d43", 
                    "#d73027", 
                    "#a50026"),
        breaks = seq(from = round(min_slope, digit=3)-round(max_slope, digit=2)/2,
                     to = round(max_slope, digit=3)+round(max_slope, digit=2)/2,
                     length.out = 11),
        labels = as.character(seq(from = round(min_slope, digit=3)-round(max_slope, digit=2)/2,
                     to = round(max_slope, digit=3)+round(max_slope, digit=2)/2,
                     length.out = 11)*100), 
        na.value = "grey90",
        name = "Temporal trend (%/year)"
      )

# Plot Heat Map

  pp_2 <- ggheatmap(df_all_matrix,
                    dendrogram = "column",
                    xlab = "",
                    ylab = "",
                    main = "",
                    scale = "none",
                    
                    scale_fill_gradient_fun = gradient_color,
                    
                    margins = c(60,100,40,20),
                    grid_color = "white",
                    grid_width = 0.00001,
                    titleX = FALSE,
                    branches_lwd = 0.1,
                    fontsize_row = 13,
                    fontsize_col = 9.5,
                    labCol = colnames(df_all_matrix),
                    labRow = rownames(df_all_matrix),
                    
                    #column colors legend
                    col_side_colors = data.frame("Region " = df_region_countries$Region, check.names = F),
                    
                    col_side_palette = c("East Asia & Pacific" = '#e6ab02',
                                         "Europe & Central Asia"= '#66a61e',
                                         "Latin America & Caribbean" = '#d95f02',
                                         "Middle East & North Africa" = '#7570b3',
                                         "North America" = '#1b9e77',
                                         "South Asia" =  '#e5c494',
                                         "Sub-Saharan Africa" ='#e78ac3'),
                    
                    #row colors legend
                    row_side_colors = data.frame("Species " = df_species_pairs$Species, check.names = F),
                    
                    row_side_palette = c("mockSpecies" = '#d95f02',
                                         "mockSpecies2" = '#1b9e77'
                                         # "E. coli" = "#5ab4ac",
                                         # "K. pneumoniae" = "#c7eae5",
                                         # "P. aeruginosa" = "#01665e",
                                         # "A. baumannii" = "#8c510a",
                                         # "S. pneumoniae" = "#f6e8c3",
                                         # "Enterococci" ="#d8b365"
                                         ),
                    
                    heatmap_layers = theme(axis.line = element_blank(),
                                           axis.text.x = element_text(angle = 90, face = "bold"),
                                           axis.text.y = element_text(face = "bold"),
                                           legend.key.width = unit(0.8, "cm"),
                                           legend.title = element_text(size = 13),
                                           legend.text = element_text(size = 12, face ="bold"))
  )
  
  pp_2

  
# Save into PDF file  
  pdf(file = "Results_viz_all_pairs/HeatMap_temporal_trends.pdf", width = 25, height = 18)
    print(pp_2)
  dev.off()

  