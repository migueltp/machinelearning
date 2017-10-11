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


# Call Center Nr attempts by caller ID (origin)
# Call Center Success rate by Known vs Unknown
# Call Center Same network VS different network Success Rate
p <- ggplot(data = df_hist[, (.N / nrow(df_hist)), by = indic_tlf_ori_A][order(-V1)], 
            aes(x = indic_tlf_ori_A, y = V1)) +
  geom_bar(stat = "identity", fill = 'grey') +
  geom_text(aes(label = indic_tlf_ori_A), vjust = 1.5, colour = "white")
p = p + 
  aes(x = fct_inorder(indic_tlf_ori_A)) + 
  ggtitle('Nr attempts by caller ID') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Caller ID') +
  ylab('Relative frequency (%)')
ggsave(filename = 'Nr attempts by caller ID.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)
# Call Center Success rate by Known vs Unknown
p <- ggplot(data = df_hist[, sum(target) / nrow(df_hist), by = is_unknown][order(-V1)], 
            aes(x = is_unknown, y = V1, fill = is_unknown)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = is_unknown), vjust = 1.5, colour = "white")
p = p + 
  aes(x = fct_inorder(is_unknown)) + 
  ggtitle('Success Rate by Known vs Unknown Caller') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Known(0) VS Unknown(1)') +
  ylab('Handle Success Rate (%)')
ggsave(filename = 'Success rate by Known vs Unknown.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)
# Same network operator Success Rate
df_hist$same_network <- factor(df_hist$same_network, levels= c("1", "0"))
p <- ggplot(data = df_hist[, sum(target) / .N, by = same_network][order(same_network)], 
            aes(x = same_network, y = V1, fill=same_network)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = same_network), vjust = 1.5, colour = "white")
p = p + 
  ggtitle('Success Rate by Same Network Operator') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Same Operator(1) VS Different Operator(0)') +
  ylab('Handle Success Rate (%)')
ggsave(filename = 'Same network operator Success Rate.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)




# Call Center Success rate by caller ID (destination)
# Call Center Nr attempts TO caller ID (destination)
df_hist$indic_tlf_dest_A <- factor(df_hist$indic_tlf_dest_A)
p <- ggplot(data = df_hist[, (.N / nrow(df_hist)), by = indic_tlf_dest_A][order(-V1)], 
            aes(x = indic_tlf_dest_A, y = V1)) +
  geom_bar(stat = "identity", fill = 'grey') +
  geom_text(aes(label = indic_tlf_dest_A), vjust = 1.5, colour = "white")
p = p + 
  ggtitle('Nr attempts by Operator ID (destination)') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Destination Operator ID') +
  ylab('Relative frequency (%)')
ggsave(filename = 'Nr attempts TO caller ID (destination).png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)
# Call Center Success rate TO caller ID (destination)
p <- ggplot(data = df_hist[, (sum(target) / .N ), by = indic_tlf_dest_A][order(-V1)], 
            aes(x = indic_tlf_dest_A, y = V1)) +
  geom_bar(stat = "identity", fill = 'lightgreen') +
  geom_text(aes(label = indic_tlf_dest_A), vjust = 1.5, colour = "white")
p = p + 
  ggtitle('Success Rate by Operator ID (destination)') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Destination Operator ID') +
  ylab('Handle Success Rate (%)')
ggsave(filename = 'Success Rate TO caller ID (destination).png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)


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
  geom_bar(stat = "identity", fill = 'grey') +
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

