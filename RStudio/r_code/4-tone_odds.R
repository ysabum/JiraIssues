resolved <- read.csv("csv_final/6-issues_analyzed.csv")
unresolved <- read.csv("csv_final/6-issues_analyzed_unresolved.csv")

# Create angry tone indicator: TRUE if tone is frustrated or angry
resolved$angry_tone <- resolved$tone %in% c("frustrated", "angry")
unresolved$angry_tone <- unresolved$tone %in% c("frustrated", "angry")

resolved$resolved <- 1
unresolved$resolved <- 0

all_issues <- rbind(resolved[, c("resolved", "angry_tone")],
                    unresolved[, c("resolved", "angry_tone")])

logit_angry <- glm(resolved ~ angry_tone, data = all_issues, family = binomial)
summary(logit_angry)

# Odds ratio + confidence interval
exp(cbind(OR = coef(logit_angry), confint(logit_angry)))




## Export Data:
# Fit your model (if not already done)
logit_model <- glm(resolved ~ angry_tone, data = all_issues, family = binomial)

# Extract coefficient summary
coef_summary <- summary(logit_model)$coefficients

# Compute confidence intervals
conf_intervals <- confint(logit_model)  # default is 95% CI

# Combine into one data frame
export_df <- cbind(
  Estimate     = coef_summary[, "Estimate"],
  Std_Error    = coef_summary[, "Std. Error"],
  z_value      = coef_summary[, "z value"],
  p_value      = coef_summary[, "Pr(>|z|)"],
  CI_lower_95  = conf_intervals[, 1],
  CI_upper_95  = conf_intervals[, 2]
)

# Write to CSV
write.csv(round(export_df, 5), "RStudio/exports/logit_angry_tone_summary.csv", row.names = TRUE)

