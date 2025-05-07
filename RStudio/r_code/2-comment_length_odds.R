resolved <- read.csv("csv_final/6-issues_analyzed.csv")
unresolved <- read.csv("csv_final/6-issues_analyzed_unresolved.csv")

# Add a 'resolved' indicator
resolved$resolved <- 1
unresolved$resolved <- 0

# Combine datasets
all_issues <- rbind(resolved[, c("commentlength", "resolved")],
                    unresolved[, c("commentlength", "resolved")])

# Logistic regression
logit_model <- glm(resolved ~ commentlength, data = all_issues, family = binomial)
summary(logit_model)

# Odds Ratio
exp(coef(logit_model))






## Export Data:
# Get coefficients and p-values
summary_data <- summary(logit_model)$coefficients

# Convert to data frame
summary_df <- as.data.frame(summary_data)

# Add odds ratios
summary_df$OddsRatio <- exp(coef(logit_model))

# Write to CSV
write.csv(summary_df, "RStudio/exports/logistic_regression_results.csv", row.names = TRUE)




# Export Data w/ CI:
# Confidence intervals for coefficients
confint_vals <- confint(logit_model)

# Odds ratio confidence intervals
odds_ratio_ci <- exp(confint_vals)

# Combine with summary
summary_df$OR_lower <- odds_ratio_ci[, 1]
summary_df$OR_upper <- odds_ratio_ci[, 2]

# Export updated file
write.csv(summary_df, "RStudio/exports/logistic_regression_with_CI.csv", row.names = TRUE)
