Sys.time()
D1143_17_SW<-as.data.frame(matrix(data = NA, nrow = nrow(TRSW), ncol= 4))
colnames(D1143_17_SW)<- c("Chr", "Start", "End", "Mean_depth")
D1143_17_SW[,1:3]<- TRSW
D1143_17_SW[,4]<- 0
#k<-1
l<-1
for(i in 1:nrow(D1143_17_SW))
#for(i in 1:7)
	{
		#cat("I in Outer-for loop----------------------------- ", i , "\n")
		k<-l
		#cat("K in Outer-for loop----------------------------- ", k , "\n")
			
				for(j in k:nrow(D1143_17))
					{
		#				cat("J in inner-for loops starts here¤¤¤¤¤¤¤ \n")
						if(j !=nrow(D1143_17)+1)
							{
		#						cat("Value of J in Bigger-if block: ", j, "\n")
								if(as.character(D1143_17[j,1])==as.character(D1143_17_SW[i,1]) && as.numeric(D1143_17_SW[i,2])<=as.numeric(D1143_17[j,2]) && as.numeric(D1143_17_SW[i,3])>=as.numeric(D1143_17[j,2]))
									{
										D1143_17_SW[i,4]<- D1143_17_SW[i,4]+ D1143_17[j,3]
										k<-j+1
		#								cat("Value of J in small-if block: ", j, "\n")
									}
								else
            						{
        #  								cat("Value of J in small-else block: ", j, "\n")
           								if(as.character(D1143_17[j,1])==as.character(D1143_17[j-1,1]) && as.numeric(D1143_17[j,2])==as.numeric(D1143_17[j-1,2]+1))
           									{
           										l<- l+1
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
        #    					cat("Value of J in Bigger else block: ", j, "\n")
            					k<- 1
            					break()
            				}

					}
	}

Sys.time()
write.table(D1143_17_SW, file = "~/Dropbox/sliding_window/D1143_17_SW", sep = "\t", row.names = FALSE)