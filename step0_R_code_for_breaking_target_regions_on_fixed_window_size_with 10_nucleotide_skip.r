#Rcode for breaking TARGET_REGION in templetes of fixed window size, with 10 nucleotide skip.
########

#sliding_window_size<- 50
sliding_window_size<- 75
skip_length <- 10
TRS <- read.csv(file = "/data/Data/NGS_CNV_target/target_regions_sorted_merging_overlapped.bed", header = TRUE,sep = "\t")
TRS["template"] <- NA
TRS["extra_nucleotides"] <- NA
for(i in 1:nrow(TRS))
{
	template_size<- {(TRS[i,3]-TRS[i,2]-sliding_window_size) %/% skip_length} +1 
	extra_nucleotides<- {(TRS[i,3]-TRS[i,2]-sliding_window_size) %% skip_length} +1  # here when the there are extra nucleotide in the end with are less then 10, it dose not slide till end, so added extra. here in this code 
	if(template_size>0)
		{
			if(extra_nucleotides!= skip_length) # here, this IF block makes sure that if there are 10 extra nucleotide left then it will make that entry 0 and add 1 extra templete to the Templete column.
				{
					TRS[i,4]<- template_size
					TRS[i,5]<- extra_nucleotides
				}
			else
				{
					TRS[i,4]<- template_size+1
					TRS[i,5]<- 0	
				}
		}
	else #this else block is for target regions less the window size
		{
			TRS[i,4]<- 1
			TRS[i,5]<-0
		}
}
#-------------
#Now generating the "TARGET_REGION_SORTED_with_WINDOW" , here window size is 75, and 10 nucleotide skip.
TRSW<- as.data.frame(matrix(nrow= sum(TRS$template), ncol= 3))
	# here the sum of templetes will be ROW_length of TRSW 
colnames(TRSW)<-c("Chr","Start","End")
#Now running loop for placing the sliding windows of 50 in TRSW

for(i in 1:nrow(TRS))
{
	if(i>1) # as variable K ask for values at i-1 position, this IF is for doing the operating from row 2nd or further
		{
			k<-sum(TRS[1:i-1,4])  # this variable K will count the previusly used rows, and provide the new loop for the next availabe row for next templete run
			for(j in 1:as.numeric(TRS[i,4]))
				{
					if(as.numeric(TRS[i,4])>1)  #This IF block is for the targets which are LARGER then SLIDING_WINDOW_SIZE.
						{
							TRSW[k+j,1]<- as.character(TRS[i,1])
							TRSW[k+j,2]<- TRS[i,2]+(j-1)*10
							TRSW[k+j,3]<- TRS[i,2]+(j-1)*10+sliding_window_size-1
						}
					else #This ELSE blocK is for the targets which are SMALLER then SLIDING_WINDOW_SIZE.
						{
							TRSW[k+j,1]<- as.character(TRS[i,1])
							TRSW[k+j,2]<- TRS[i,2]
							TRSW[k+j,3]<- TRS[i,3]
						}
				}
		}
	else # this else block is for processing the loop for i=1 value
		{
			for(j in 1:as.numeric(TRS[i,4]))
    			{
					if(as.numeric(TRS[i,4])>1)
        				{
            				TRSW[i+j-1,1]<- as.character(TRS[i,1])
            				TRSW[i+j-1,2]<- TRS[i,2]+(j-1)*10
            				TRSW[i+j-1,3]<- TRSW[i+j-1,2]+sliding_window_size-1
        				}
        			else
        				{
            				TRSW[i+j-1,1]<- as.character(TRS[i,1])
            				TRSW[i+j-1,2]<- TRS[i,2]
            				TRSW[i+j-1,3]<- TRS[i,3]
        				}
    			}
		}
}
#this for loop is to add the extra nucleotides to the last sliding window templete of each target exon.
for(l in 1:nrow(TRS)) # comment:miner_Error: the In this loop, if the number of templetes is 1, then the extra_nucleotides are getting added twice in the end of last templete of the target region.
	{
		m<-sum(TRS[1:l,4])
		n<-as.numeric(TRSW[m,3])+as.numeric(TRS[l,5])
		TRSW[m,3]<-n
	}

for(o in 1:nrow(TRS)) # this for loop is to correct the erroer in previous loop, which means deletion of extra_nucleotides (as it is copied twice) from the end of last templete of the target region.
	{
		if(TRS[o,4]==1)
			{
				TRSW[sum(TRS[1:o,4]),3]<- TRSW[sum(TRS[1:o,4]),3]- TRS[o,5]
			}
	}
write.table(TRSW, file = "/data/Data/NGS_CNV_target/TRSW75_skip10") # this is main traget file for the analysis.
#----------------------------------------------------------------------
# NOW annotating the TargetRegionSlidingWindow75_with10Nucleotide_skip file (TRSW75_skip10)
Target_with_gene_info_merged_sorted <- read.csv(file = "/data/Data/NGS_CNV_target/Target_with_gene_info_merged_sorted.bed", header = TRUE,sep = "\t")
TRSW75_skip10_annotated<-TRSW
TRSW75_skip10_annotated$Gene<- NA
for(i in 1:nrow(Target_with_gene_info_merged_sorted))
        {
                for(j in 1:nrow(TRSW75_skip10_annotated))
                        {
                                if(as.character(TRSW75_skip10_annotated[j,1])==as.character(Target_with_gene_info_merged_sorted[i,1]) && as.numeric(TRSW75_skip10_annotated[j,2])>=as.numeric(Target_with_gene_info_merged_sorted[i,2]) && as.numeric(TRSW75_skip10_annotated[j,3])<=as.numeric(Target_with_gene_info_merged_sorted[i,3]))
                                        {
                                                TRSW75_skip10_annotated[j,4]<-Target_with_gene_info_merged_sorted[i,4]
                                        }
                        }
        }
write.csv(TRSW75_skip10_annotated, file = "/data/Data/NGS_CNV_target//TRSW75_skip10_annotated")


























