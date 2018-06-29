# Date created: 21:06:2016
# Last modified:
# This code needs 3 arguments first (agrs[6]) input is SAMPLE_TRSW_Mean_Depth file (input sample file) second (args[7]) POOL_TRSW_MD (input pool file) & third (args[8])output SAMPLE_TRSW_logCNR file.

#------------------------------------------------------------------------------------------------------------------------
args <- commandArgs()
SAMPLE_TRSW_MD <- read.delim(args[6], header=TRUE, sep = "\t") #sample_trsw imported
POOL_TRSW_MD <- read.delim(args[7], header=TRUE, sep = "\t") #pool_trsw imported
#CNR calculation step
SAMPLE_TRSW_CNR<- SAMPLE_TRSW_MD
SAMPLE_TRSW_CNR[,4]<- NA
SAMPLE_TRSW_CNR[,4]<-SAMPLE_TRSW_MD[,4]/POOL_TRSW_MD[,4]
SAMPLE_TRSW_logCNR<- SAMPLE_TRSW_MD
#ANNOTATION Step
SAMPLE_TRSW_logCNR[,4]<- NA
names(SAMPLE_TRSW_logCNR)[4]<- "Gene"
TRSW75_skip10_annotated<-read.csv(file = "/data/Data/NGS_CNV_target/TRSW75_skip10_annotated", header = TRUE,sep = ",")  # this file is imported to annonated the log_CNR file
SAMPLE_TRSW_logCNR$Gene<-TRSW75_skip10_annotated$Gene # this step is annonation step of LOG_CNR file
#logCNR calculation step
SAMPLE_TRSW_logCNR[,5]<- NA
names(SAMPLE_TRSW_logCNR)[5]<- names(SAMPLE_TRSW_MD)[4]
SAMPLE_TRSW_logCNR[,5]<- log2(SAMPLE_TRSW_CNR[,4])
write.table(SAMPLE_TRSW_logCNR, file = args[8], sep = "\t", row.names = FALSE)
