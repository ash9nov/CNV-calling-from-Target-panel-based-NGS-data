# Date created: 18:08:2017
# Last modified: 08:09:2017
# This code needs two arguments first (agrs[6]) input is sample_nucleotide_coverage file and second (args[7]) sample_SW_Mean_Depth file.
# Command: $  Rscript ~/my_tools/NGS_CNV_code/step2_code_for_sliding_window_CNV_analysis.r sample.coverage sample.Sliding_window
#------------------------------------------------------------------------------------------------------------------------
args <- commandArgs()
SAMPLE <- read.delim(args[6], header=TRUE, quote="")
TRSW<-read.csv(file = "/data/Data/NGS_CNV_target/TRSW75_skip10", header = TRUE,sep = ",") #this TRSW is calculated using the step0_code_for_sliding_window_template_calculation.
SAMPLE_SW<-as.data.frame(matrix(data = NA, nrow = nrow(TRSW), ncol= 4))
colnames(SAMPLE_SW)<- c("Chr", "Start", "End", "Mean_depth")
SAMPLE_SW[,1:3]<- TRSW
SAMPLE_SW[,4]<- 0
#k<-1
l<-1
for(i in 1:nrow(SAMPLE_SW))
#for(i in 1:7)
	{
		k<-l
		for(j in k:nrow(SAMPLE))
			{
				if(j !=nrow(SAMPLE)+1)
					{
						if(as.character(SAMPLE[j,1])==as.character(SAMPLE_SW[i,1]) && as.numeric(SAMPLE_SW[i,2])<=as.numeric(SAMPLE[j,2]) && as.numeric(SAMPLE_SW[i,3])>=as.numeric(SAMPLE[j,2]))
							{
								SAMPLE_SW[i,4]<- SAMPLE_SW[i,4]+ SAMPLE[j,3]
								k<-j+1
							}
						else
        					{
        						if(as.character(SAMPLE[j,1])==as.character(SAMPLE[j-1,1]) && as.numeric(SAMPLE[j,2])==as.numeric(SAMPLE[j-1,2]+1))
        							{
           								l<- l+10    #this line is for sliding the window by 10 Nycleotide position
            							break()
            						}
            					else
            						{
            							l<-j
            							break()	
            						}
            				}
            		}
            	else
            		{
        				k<- 1
           				break()
           			}
			}
	}
SAMPLE_SW$Mean_depth<- SAMPLE_SW$Mean_depth/75
write.table(SAMPLE_SW, file = args[7], sep = "\t", row.names = FALSE)
