library(ggplot2)
library(forcats)

### SCRAPBOOK
hist(df_hist$nr_contacts)

### Data Analysis
df_hist[, sum(target) / .N, by = is_unknown] # -->>> All calls should be made from a recognizable phone NR
df_hist[, sum(target) / .N, by = same_network] # -->>> All calls should be made from a different Network phone NR ???
df_hist[, sum(target) / .N, by = moment_in_day]
df_hist[, sum(target) / .N, by = day_of_week]
df_hist[, sum(target) / .N, by = day_of_week]



# Call Center Distribution of Nr Attemps
# Call Center Handle Success Rate by Nr Attempts
p <- ggplot(data = df_hist[, (.N / nrow(df_hist)), by = nr_contacts_bin][order(nr_contacts_bin)], 
                   aes(x = nr_contacts_bin, y = V1)) +
                   geom_bar(stat = "identity", fill = 'grey') +
                   geom_text(aes(label = nr_contacts_bin), vjust = 1.5, colour = "white")
p = p + 
  aes(x = fct_inorder(nr_contacts_bin)) + 
  ggtitle('Distribution of Nr Attemps') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Nr Attempts') +
  ylab('Relative frequency (%)')
ggsave(filename = 'Distribution of Nr Attemps.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)
# Call Center Handle Success Rate by Nr Attempts
p <- ggplot(data = df_hist[, (sum(target) / .N), by = nr_contacts_bin][order(nr_contacts_bin)], 
                   aes(x = nr_contacts_bin, y = V1)) +
                   geom_bar(stat = "identity", fill = 'lightgreen') +
                   geom_text(aes(label = nr_contacts_bin), vjust = 1.5, colour = "white")
p = p + 
    aes(x = fct_inorder(nr_contacts_bin)) + 
    ggtitle('Handle Success Rate by Nr Attempts') + 
    theme(plot.title = element_text(hjust = 0.5)) +
    xlab('Handle Success Rate (%)') +
    ylab('Nr Attempts')
ggsave(filename = 'Handle Success Rate by Nr Attempts.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)


# Call Center Occupancy by hour of day
# Call Center Success Rate by hour of day
# Call Center Success Rate by Moment in Day
p <- ggplot(data = df_hist[, .N / nrow(df_hist), by = hour_of_contact][order(hour_of_contact)], 
            aes(x = hour_of_contact, y = V1)) +
  geom_bar(stat = "identity", fill = 'grey') +
  geom_text(aes(label = hour_of_contact), vjust = 1.5, colour = "white")
p = p + 
    ggtitle('Distribution of Attempts per Hour') + 
    theme(plot.title = element_text(hjust = 0.5)) +
    xlab('Hour of Day') +
    ylab('Relative frequency (%)')
ggsave(filename = 'Distribution of Attempts per Hour.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)
# Call Center Success Rate by hour of day
p <- ggplot(data = df_hist[, (sum(target) / .N), by = hour_of_contact][order(hour_of_contact)], 
            aes(x = hour_of_contact, y = V1)) +
  geom_bar(stat = "identity", fill = 'royalblue1') +
  geom_text(aes(label = hour_of_contact), vjust = 1.5, colour = "white")
p = p + 
  ggtitle('Success Rate by hour of day') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Hour of Day') +
  ylab('Handle Success Rate (%)')
ggsave(filename = 'Success Rate by hour of day.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)
# Call Center Success Rate by Moment in Day
df_hist$moment_in_day <- factor(df_hist$moment_in_day, levels= c("morning", "lunch", "afternoon", "evening"))
p <- ggplot(data = df_hist[, (sum(target) / .N), by = moment_in_day][order(moment_in_day)], 
            aes(x = moment_in_day, y = V1)) +
  geom_bar(stat = "identity", fill = 'royalblue1') +
  geom_text(aes(label = moment_in_day), vjust = 1.5, colour = "white")
p = p + 
  aes(x = fct_inorder(moment_in_day, ordered = TRUE)) + 
  ggtitle('Success Rate by Moment in Day') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Hour of Day') +
  ylab('Handle Success Rate (%)')
ggsave(filename = 'Success Rate by Moment in Day.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)


# Call Center Occupancy by Day of Week
# Call Center Success Rate by Day of Week
df_hist$day_of_week <- factor(df_hist$day_of_week, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
p <- ggplot(data = df_hist[, .N / nrow(df_hist), by = day_of_week][order(day_of_week)], 
            aes(x = day_of_week, y = V1)) +
  geom_bar(stat = "identity", fill = 'grey') +
  geom_text(aes(label = day_of_week), vjust = 1.5, colour = "white")
p = p + 
    aes(x = fct_inorder(day_of_week, ordered = TRUE)) + 
    ggtitle('Occupancy by Day of Week') + 
    theme(plot.title = element_text(hjust = 0.5)) +
    xlab('Day of Week') +
    ylab('Relative frequency (%)')
ggsave(filename = 'Occupancy_by_Day_of_Week.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)
# Call Center Success Rate by Day of Week
df_hist$day_of_week <- factor(df_hist$day_of_week, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
p <- ggplot(data = df_hist[, (sum(target) / .N), by = day_of_week][order(day_of_week)], 
            aes(x = day_of_week, y = V1)) +
  geom_bar(stat = "identity", fill = 'royalblue1') +
  geom_text(aes(label = day_of_week), vjust = 1.5, colour = "white")
p = p + 
  aes(x = fct_inorder(day_of_week, ordered = TRUE)) + 
  ggtitle('Success Rate by Day of Week') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Day of Week') +
  ylab('Handle Success Rate (%)')
ggsave(filename = 'Success Rate by Day_of_Week.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)



# Call Center Nr Attempts by time interval between attempts
# Call Center Success Rate by time interval between attempts
p <- ggplot(data = df_hist[, .N / nrow(df_hist), by = diff_contacts_bin][order(diff_contacts_bin)], 
            aes(x = diff_contacts_bin, y = V1)) +
  geom_bar(stat = "identity", fill = 'lightgreen') +
  geom_text(aes(label = diff_contacts_bin), vjust = 1.5, colour = "white")
p = p + 
    ggtitle('Attempts by time interval between attempts') + 
    theme(plot.title = element_text(hjust = 0.5)) +
    xlab('Intervals between attempts') +
    ylab('Relative frequency (%)')
ggsave(filename = 'Attempts_by_interval_between_attempts.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)
# Call Center Success Rate by time interval between attempts
p = ggplot(data = df_hist[, (sum(target) / .N), by = diff_contacts_bin][order(diff_contacts_bin)], 
            aes(x = diff_contacts_bin, y = V1)) +
  geom_bar(stat = "identity", fill = 'lightgreen') +
  geom_text(aes(label = diff_contacts_bin), vjust = 1.5, colour = "white")
p = p + 
    ggtitle('Success Rate by lag between attempts') + 
    theme(plot.title = element_text(hjust = 0.5)) +
    xlab('Intervals between attempts') +
    ylab('Handle Success Rate (%)')
ggsave(filename = 'Success_Rate_lag_between_attempts.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)
