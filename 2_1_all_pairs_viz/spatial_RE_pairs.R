# PCV bar plot for all drug-bug pairs, for both spatial and temporal random effects (RE)

# Create list from dataframes of all pairs

  df_list = list(df_mockSpecies_mockAtb,
                 df_mockSpecies2_mockAtb2) # --> ENTER the name of other drug-bug pairs

# Function for changing column names

  ChangeNames <- function(x) {
    names(x) <- c("Country", "RE")
    return(x)
  }

# Rename column names

  df_list <- lapply(df_list, ChangeNames)

# Merge datasets together

  all_df <- df_list[[1]] #first pair
  
  for(i in head(seq_along(df_list), -1) ) {
    
    all_df <- merge(all_df,
                    df_list[[i+1]],
                    suffixes = paste0('_', all_pairs[i:(i+1)]),
                    all = TRUE,
                    by = c('Country'))
  }
  
  countries <- unique(as.character(all_df$Country))

# Long format

  all_df_long <- all_df %>% gather(key = Pair, value = RE, starts_with("RE"))


############## Violin plots for all spatial RE from different pairs ############

# legend by species
  
  all_df_long$Species <- ifelse(all_df_long$Pair == 'RE_mockPair', 'mockSpecies',
                                'mockSpecies2')


v_p <- ggplot(all_df_long, aes(y = as.numeric(RE), x = Pair, fill = Species)) +
  geom_violin(trim = T) +
  geom_point(size = 0.8, alpha = 0.5) +
  theme(legend.position = "none") +
  ylim(-3, 3) +
  ylab("Spatial Random Effects") +
  xlab("") +
  theme_classic() +
  theme(axis.text.x = element_text(size = 14, face = "bold"),
        axis.title.y = element_text(size = 15),
        axis.title.x = element_text(size = 13))

print(v_p)

## Highlight some countries of interest (estimates far away from the mean)

# y_RE_value <- 0
# x_name_pair <- ""
# 
# v_p <- v_p + 
#   annotate(geom = "point", y = y_RE_value, x = x_name_pair, size = 3) + 
#   annotate(geom = "point", y = y_RE_value, x = x_name_pair)
# 
# print(v_p)

# Save into PDF file  

  pdf(file = "Results_viz_all_pairs/Spatial_RE_violin_plots.pdf", width = 18, height = 13)
    print(v_p)
  dev.off()
  
  
  
  