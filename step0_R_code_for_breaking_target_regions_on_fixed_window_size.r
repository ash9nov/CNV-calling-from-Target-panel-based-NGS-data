#Rcode for generating "TARGET_REGION_SORTED" with templete of given size size
#########

#sliding_window_size<- 50
sliding_window_size<- 75
TRS <- read.csv(file = "~/Dropbox/sliding_window/target_regions_sorted_merging_overlapped.bed", header = TRUE,sep = "\t")
TRS["template"] <- NA
for(i in 1:nrow(TRS))
{
	template_size<- TRS[i,3]-TRS[i,2]-sliding_window_size +2
	if(template_size>0)
		{
			TRS[i,4]<- template_size
		}
	else
		{
			TRS[i,4]<- 1
		}
}
#-------------
#Now generating the "TARGET_REGION_SORTED_with_WINDOW" , here size is 50.
TRSW<- as.data.frame(matrix(nrow= sum(TRS$template), ncol= 3))
	# here the sum of templetes will be ROW_length of TRSW 
colnames(TRSW)<-c("Chr","Start","End")
#Now running loop for placing the sliding windows of 50 in TRSW

for(i in 1:nrow(TRS))
{
	if(i>1) # as variable K ask for values at i-1 position, this IF is for doing the operating from row 2nd or further
		{
			k<-sum(TRS[1:i-1,4])  # this variable K will count the previusly used rows, and provide the new loop for the next availabe row fore next templete run
			for(j in 1:as.numeric(TRS[i,4]))
				{
					if(as.numeric(TRS[i,4])>1)  #This IF block is for the targets which are LARGER then SLIDING_WINDOW_SIZE.
						{
							TRSW[k+j,1]<- as.character(TRS[i,1])
							TRSW[k+j,2]<- TRS[i,2]+j-1
							TRSW[k+j,3]<- TRS[i,2]+j+sliding_window_size-2
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
            				TRSW[i+j-1,2]<- TRS[i,2]+j-1
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
