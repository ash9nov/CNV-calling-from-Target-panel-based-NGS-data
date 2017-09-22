# Date Ctrated: 08:09:2017
#last modified: 15:09:17
# This code plots the  individual sample.logCNR file for each gene.
#
#---------------------------------------------------------------------------------------------------------
args <- commandArgs()
SAMPLE <- read.delim(args[6], header=TRUE, sep="\t")
Path<- args[7]
Gene_names<-read.csv(file = "/data/Data/NGS_CNV_target/Gene_names", header = TRUE)
for(i in 1:nrow(Gene_names))
	{
		t<-paste(Path,"/",as.character(Gene_names[i,1]), sep = "")	
     		png(filename = t, width = 1920,height = 1056)
		plot.default(SAMPLE[which(SAMPLE$Gene==Gene_names[i,1]),5], type = 'h')
		dev.off()
	}
