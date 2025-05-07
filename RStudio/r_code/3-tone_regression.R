library(ggplot2)

resolved <- read.csv("csv_final/6-issues_analyzed.csv")

ggplot(resolved, aes(x = tone, y = resolutiontime)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Resolution Time by Tone (Resolved Issues)",
       x = "Tone", y = "Resolution Time (days)") +
  theme_minimal()

anova_model <- aov(resolutiontime ~ tone, data = resolved)
summary(anova_model)

# Load dplyr if not already
library(dplyr)

# Group and summarize resolution time by tone
tone_summary <- resolved %>%
  group_by(tone) %>%
  summarise(
    count = n(),
    mean_resolution = mean(resolutiontime, na.rm = TRUE),
    median_resolution = median(resolutiontime, na.rm = TRUE),
    sd_resolution = sd(resolutiontime, na.rm = TRUE)
  )

# Create the plot object
plot1 <- ggplot(resolved, aes(x = tone, y = resolutiontime)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Resolution Time by Tone (Resolved Issues)",
       x = "Tone", y = "Resolution Time (days)") +
  theme_minimal()



## Export Data:
# Save as PNG
ggsave("RStudio/exports/resolution_time_by_tone.png", plot = plot1, width = 8, height = 6, dpi = 300)

# Extract the first (and only) table from the summary
anova_results <- summary(anova_model)
anova_df <- as.data.frame(anova_results[[1]])

# Export to CSV
write.csv(anova_df, "RStudio/exports/anova_resolutiontime_by_tone.csv", row.names = TRUE)
write.csv(tone_summary, "RStudio/exports/resolutiontime_by_tone.csv", row.names = FALSE)
