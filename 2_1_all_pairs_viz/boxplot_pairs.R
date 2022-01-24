## Box plot of resistance rates distribution across all countries for one year, for all pairs


# Create list from dataframes of all pairs
df_list = list(df_mockSpecies_mockAtb,
               df_mockSpecies2_mockAtb2) #--> ENTER the name of other pairs

# Get only data for one year for all dataframes
df_list <- lapply(df_list, function(x) {
  x %>% filter(Year %in% specific_year)
})

# Get only columns of interest for all dataframes
df_list <- lapply(df_list, function(x) {
  x %>% dplyr::select(c("Country", "Year", "propResvsNonRes"))
})

# Merge datasets for all pairs together, by year and country
all_df <- df_list[[1]] #fist pair

  for(j in head(seq_along(df_list), -1)) {
    all_df <- merge(all_df,
                    df_list[[j+1]],
                    all = TRUE, 
                    suffixes = paste0(all_species[j:(j+1)], '_', all_atb_class[j:(j+1)]),
                    by = c("Year", "Country"))
  }

# Get data from all pairs in long format
colnames(all_df) <- c('Year', 'Country' , all_pairs)

df_long <- all_df %>% pivot_longer(cols = -c("Country", "Year"),
                                   names_to = "Pair",
                                   values_to = "Prop")


# Box plots for all drug-bug pair

    #if you want to order the pair in a specific order on the graph --> ENTER order here
      df_long$Pair <- factor(df_long$Pair, levels = c('mockPair', 'mockPair2')) #change order of pairs

  # Plot
  gg <- ggplot(data = df_long, aes(y = Prop*100, x = as.factor(Pair)) ) +
  stat_boxplot(geom = "errorbar", width = 0.2) +
  geom_boxplot(fill = "#f1eef6") +
  geom_point(size = 1, col = "#2c7bb6") +
  theme(axis.text.x = element_text(size = 20, colour = df_long$Example),
        axis.text.y = element_text(size = 25),
        axis.title.y = element_text(size = 30),
        legend.position = "none") +
  xlab("") +
  ylab(paste0("Resistance rate (%), ", as.character(specific_year)))

  print(gg)

# Save into PDF
pdf(file = paste0('Results_viz_all_pairs/boxplot_all_pairs_', as.character(specific_year),'.pdf'), height = 10, width = 15)
  print(gg)
dev.off()

