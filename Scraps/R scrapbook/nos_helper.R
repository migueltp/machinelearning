# helpers
library(ggplot2)
library(forcats)


### SCRAPBOOK
hist(df$nr_contacts)


### Data Analysis
df[, sum(target) / .N, by = is_unknown] # -->>> All calls should be made from a recognizable phone NR
df[, sum(target) / .N, by = same_network] # -->>> All calls should be made from a different Network phone NR ???
df[, sum(target) / .N, by = moment_in_day]
df[, sum(target) / .N, by = day_of_week]
df[, sum(target) / .N, by = day_of_week]

# Handle Success Rate by Nr Attempts
p <- ggplot(data = df[, (sum(target) / .N), by = nr_contacts_bin][order(nr_contacts_bin)], 
            aes(x = nr_contacts_bin, y = V1)) +
     geom_bar(stat = "identity", fill = 'grey') +
     geom_text(aes(label = nr_contacts_bin), vjust = 1.5, colour = "white")
p
p + 
  aes(x = fct_inorder(nr_contacts_bin)) + 
  ggtitle('Handle Success Rate by Nr Attempts') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Handle Success Rate (%)') +
  ylab('Nr Attempts')

# Call Center Occupancy by hour of day
p <- ggplot(data = df[, .N / nrow(df), by = hour_of_contact][order(hour_of_contact)], 
            aes(x = hour_of_contact, y = V1)) +
  geom_bar(stat = "identity", fill = 'grey') +
  geom_text(aes(label = hour_of_contact), vjust = 1.5, colour = "white")
p
p + 
  ggtitle('Distribution of Attempts per Hour') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Hour of Day') +
  ylab('Relative frequency (%)')

# Call Center Occupancy by Day of Week
df$day_of_week <- factor(df$day_of_week, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
p <- ggplot(data = df[, .N / nrow(df), by = day_of_week][order(day_of_week)], 
            aes(x = day_of_week, y = V1)) +
  geom_bar(stat = "identity", fill = 'grey') +
  geom_text(aes(label = day_of_week), vjust = 1.5, colour = "white")
p
p + 
  aes(x = fct_inorder(day_of_week, ordered = TRUE)) + 
  ggtitle('Occupancy by Day of Week') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('Day of Week') +
  ylab('Relative frequency (%)')
