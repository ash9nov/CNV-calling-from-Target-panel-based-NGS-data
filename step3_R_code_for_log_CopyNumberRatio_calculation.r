# Date created: 18:08:2017
# Last modified: 08:09:2017
# This code needs two arguments first (agrs[6]) input is ALL_TRSW_Mean_Depth file (input data) and second (args[7]) output ALL_TRSW_logCNR file.
# Command: $  Rscript ~/my_tools/NGS_CNV_code/step3_R_code_for_log_CopyNumberRatio_calculation.r ALL_TRSW_MD.coverage ALL_TRSW_MD.Sliding_window
#------------------------------------------------------------------------------------------------------------------------
args <- commandArgs()
ALL_TRSW_MD <- read.delim(args[6], header=TRUE, sep = ",")
ALL_TRSW_CNR <- ALL_TRSW_MD
num_sample<- ncol(ALL_TRSW_MD)-3
ALL_TRSW_CNR[,4:(num_sample+3)]<- NA
ALL_TRSW_MD$mean_cvg<- rowMeans(ALL_TRSW_MD[,4:(num_sample+3)])
ALL_TRSW_CNR[,4:(num_sample+3)]<- ALL_TRSW_MD[,4:(num_sample+3)]/ALL_TRSW_MD$mean_cvg
ALL_TRSW_logCNR<-as.data.frame(matrix(NA, nrow = nrow(ALL_TRSW_CNR), ncol = ncol(ALL_TRSW_CNR)))
colnames(ALL_TRSW_logCNR) <- colnames(ALL_TRSW_CNR)
ALL_TRSW_logCNR[,1:3] <- ALL_TRSW_CNR[,1:3]
ALL_TRSW_logCNR[,4:(num_sample+3)]<- log2(ALL_TRSW_CNR[,4:(num_sample+3)])
TRSW75_skip10_annotated<-read.csv(file = "/data/Data/NGS_CNV_target/TRSW75_skip10_annotated", header = TRUE,sep = ",")  # this file is imported to annonated the log_CNR file
ALL_TRSW_logCNR$Gene<-TRSW75_skip10_annotated$Gene # this step is annonation step of LOG_CNR file
write.table(ALL_TRSW_logCNR, file = args[7], sep = "\t", row.names = FALSE)
