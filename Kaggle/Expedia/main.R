###
# KAGGLE EXPEDIA
###

###
# WRITTEN BY: MIGUEL SERRANO, RUI MACHADO
# DATE: 21-04-2016

# Local Path
rm(list = ls())
setwd('/home/miguelserrano/Projects/Kaggle/Expedia')
source(file = 'functions.R', echo = T)
# LIBRARIES
library(rpart)
library(data.table)
library(gtools)

system.time(train <- fread(input = '../../Data/Kaggle/Expedia/train.csv')) #, nrows = 10000
test_data <- fread(input = '../../Data/Kaggle/Expedia/test.csv')
# destinations <- fread(input = '../../Data/Kaggle/Expedia/destinations.csv')

# Most Frequent Hotels - Bookings and Clicks
frequentHotels <- function(x) {
 5/ sum(x) * 0.9 + length(x) * 0.1
}

train_frequent_hotels <- train[, .(score = frequentHotels(is_booking)),by=list(srch_destination_id, hotel_cluster)]

top_five <- function(hc,v1){
  hc_sorted <- hc[order(v1,decreasing=TRUE)]
  n <- min(5,length(hc_sorted))
  paste(hc_sorted[1:n],collapse=" ")
}



train_frequent_hotels <- merge(train_frequent_hotels, train_frequent_hotels[, .N, by = srch_destination_id], by = 'srch_destination_id')
my_hotels_scored <- train_frequent_hotels[ , .(frequent = paste(hotel_cluster[order(-score)[1:min(5,N)]], collapse = " ")), by = 'srch_destination_id']
test_data$srch_destination_id %in% my_hotels_scored$srch_destination_id

submission <- merge(test_data[, .(id, srch_destination_id) ], my_hotels_scored, by = 'srch_destination_id', all.x = T)
submission[is.na(frequent), frequent:= " "] 
submission <- submission[,.(id, hotel_cluster = frequent)]
write.csv(submission, file = '../../Data/Kaggle/Expedia/miguel_first.csv', row.names = F)









# nr_of_nights
train[, nr_of_nights:= as.integer(as.Date(srch_co) - as.Date(srch_ci))]

# days_before_booking
train[, days_in_advance:= as.integer(as.Date(srch_ci) - as.Date(date_time))]

# domestic vs international
train[, domestic_booking:= 0]
train[hotel_country == user_location_country, domestic_booking:= 1]

setnames(train, 'is_booking', 'CONVERSION')


# DOWNSAMPLE

train_down_sampled <- getStratifiedSample(data = train, sampleSize = nrow(train)*0.10)
train_down_sampled <- train[train_down_sampled$ID_unit,]

train <- NULL
gc()

setcolorder(train_down_sampled, c(names(train_down_sampled)[names(train_down_sampled)!='CONVERSION'], 'CONVERSION'))
train_down_sampled[, HAS_CONV:= CONVERSION]
train_down_sampled[, CONVERSION:= NULL]
train_down_sampled[HAS_CONV == 1, CONVERSION:= 'YES']
train_down_sampled[HAS_CONV == 0, CONVERSION:= 'NO']
train_down_sampled[, HAS_CONV:= NULL]
train_down_sampled[, domestic_continent:= 0]
train_down_sampled[posa_continent == hotel_continent, domestic_continent:= 1]

for (i in names(train_down_sampled)[1:(ncol(train_down_sampled)-1)]) {
  
  print(paste('Na Replace @ ', i, sep= ''))
  eval(parse(text=paste("train_down_sampled[,",i,":=na.replace(",i,",-1",")]")))
  eval(parse(text=paste("train_down_sampled[is.null(",i,"),",i,":=-1","]")))
  eval(parse(text=paste("train_down_sampled[is.infinite(",i,"),",i,":=-1","]")))
  eval(parse(text=paste("train_down_sampled[is.nan(",i,"),",i,":=-1","]")))

}

names(train_down_sampled)
train_down_sampled <- train_down_sampled[, .(
  site_name                 
  ,posa_continent            
  ,user_location_country    
  ,user_location_region      
  ,user_location_city        
  ,orig_destination_distance 
  ,is_mobile                 
  ,is_package                
  ,channel                   
  ,srch_adults_cnt          
  ,srch_children_cnt         
  ,srch_rm_cnt              
  ,srch_destination_id      
  ,srch_destination_type_id 
  ,cnt                       
  ,hotel_continent          
  ,hotel_country            
  ,hotel_market             
  ,hotel_cluster             
  ,nr_of_nights             
  ,days_in_advance          
  ,domestic_booking         
  ,domestic_continent        
  ,CONVERSION   
)]

missedClass <- 0.55
ninja <- 10

write.csv(train_down_sampled, file = '../../Data/Kaggle/Expedia/no_user_id.csv', row.names = F)
