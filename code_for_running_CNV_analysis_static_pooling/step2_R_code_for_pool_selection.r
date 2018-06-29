args <- commandArgs()
SAMPLE_mean <- read.delim(args[6], header=TRUE, quote="")
# SAMPLE_mean <- read.delim(file="/data/test_dir/Data/Intensities/BaseCalls/coverage_report/CNV_static_pooling/test_dir.sample_mean", header=TRUE, quote="")
Info_Table_of_Pools<-read.csv(file = "/data/test/CNV_static_pooling/Info_Table_of_Pools", header = FALSE,sep = "\t")
colnames(Info_Table_of_Pools)<- c("POOL", "Mean_Cvg")
SAMPLE_mean$selected_pool<-NA #additional column created to store the selected pool
SAMPLE_mean$pool_mean_cvg<-NA
for (i in 1:nrow(SAMPLE_mean))
 {
 	temp_table<- Info_Table_of_Pools
 	temp_table$diff<- as.data.frame(abs(Info_Table_of_Pools$Mean_Cvg- SAMPLE_mean[i,2]))
 	names(temp_table)[3] <-"diffrence"
 	temp<- temp_table[temp_table$diffrence==min(temp_table$diffrence,na.rm=T),]
	temp<- temp[!is.na(temp[,1]),]
	SAMPLE_mean[i,3]<-as.character(temp[1,1])
	SAMPLE_mean[i,4]<-as.character(temp[1,2])
 }
 write.table(SAMPLE_mean, file = args[7], sep = "\t", row.names = FALSE)