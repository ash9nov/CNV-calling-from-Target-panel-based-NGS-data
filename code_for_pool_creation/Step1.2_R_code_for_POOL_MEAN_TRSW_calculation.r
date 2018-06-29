# Date created: 18:08:2017
# Last modified: 08:09:2017
# This code needs two arguments first (agrs[6]) input is ALL_TRSW_Mean_Depth file (input data) and second (args[7]) output ALL_TRSW_logCNR file.
# Command: $  Rscript ./Step1.2_R_code_for_POOL_MEAN_TRSW_calculation.r "$POOL_mean_TRSW" "POOL.$j.MEAN_TRSW"
#------------------------------------------------------------------------------------------------------------------------
args <- commandArgs()
ALL_TRSW_MD <- read.delim(args[6], header=TRUE, sep = ",")
#ALL_TRSW_CNR <- ALL_TRSW_MD
num_sample<- ncol(ALL_TRSW_MD)-3
#ALL_TRSW_CNR[,4:(num_sample+3)]<- NA
ALL_TRSW_MD$mean_cvg<- rowMeans(ALL_TRSW_MD[,4:(num_sample+3)])
ALL_TRSW_MD_only<- cbind.data.frame(ALL_TRSW_MD$Chr, ALL_TRSW_MD$Start, ALL_TRSW_MD$End, ALL_TRSW_MD$mean_cvg)
colnames(ALL_TRSW_MD_only)<-c("Chr","Start","End","mean_cvg")
write.table(ALL_TRSW_MD_only, file = args[7], sep = "\t", row.names = FALSE)
