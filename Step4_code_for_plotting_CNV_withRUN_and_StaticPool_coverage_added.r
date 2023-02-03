#coverage
X21TAR15_TRSW_coverage <- read.delim("Q:/Miseq_STO/Medisinsk_Genetikk/Ashish_data/CNV_plot_related/21TAR15_100014283609_NF1_dup_ex58-3pUTR/CNV_static_pooling/21TAR15_TRSW_coverage")
X21TAR15_TRSW_coverage$TRSW_coverage_mean<- (as.data.frame(rowMeans(X21TAR15_TRSW_coverage[5:52]))) #meanCVG
colnames(X21TAR15_TRSW_coverage$TRSW_coverage_mean)<- c("TRSW_coverage_mean")

#logCNR
X21TAR15_TRSW_logCNR <- read.delim("Q:/Miseq_STO/Medisinsk_Genetikk/Ashish_data/CNV_plot_related/21TAR15_100014283609_NF1_dup_ex58-3pUTR/CNV_static_pooling/21TAR15_TRSW_logCNR")
X21TAR15_TRSW_logCNR$TRSW_logCNR_mean<- (as.data.frame(rowMeans(X21TAR15_TRSW_logCNR[5:52]))) #meanlogCNR
colnames(X21TAR15_TRSW_logCNR$TRSW_logCNR_mean)<- c("TRSW_logCNR_mean")
X21TAR15_TRSW_logCNR$TRSW_logCNR_SD<-as.data.frame(apply(X21TAR15_TRSW_logCNR[5:52],1,sd))   #https://stackoverflow.com/questions/47765455/r-standard-deviation-across-rows
colnames(X21TAR15_TRSW_logCNR$TRSW_logCNR_SD)<-c("TRSW_logCNR_SD")

#plotting
png(filename = "X21TAR15_100014283609_NF1_dup_ex58-3pUTR.png", width = 1920,height = 1056)
par(mar=c(4,4,4,5)+.1)   # for margines  https://stackoverflow.com/questions/2807060/r-is-plotting-labels-off-the-page/2807122
plot.default(X21TAR15_TRSW_logCNR$X21TAR15_100014283609_S14[which(X21TAR15_TRSW_logCNR$Gene=="NF1")], type = 'h', ylim = c(-1.5,1), , xlim = c(0, nrow(X21TAR15_TRSW_logCNR[which(X21TAR15_TRSW_logCNR$Gene=="NF1"),])),xlab ="Sliding Window", ylab = "", main="X21TAR15_100014283609_NF1_dup_ex58-3pUTR", yaxt="none")
axis(2, ylim=c(-1.5,1),col="black",las=1)  ## las=1 makes horizontal labels
mtext("logCNR scores",side=2,line=2.5)
par(new=TRUE)
plot.default(X21TAR15_TRSW_logCNR$TRSW_logCNR_mean[which(X21TAR15_TRSW_logCNR$Gene=="NF1"),], type = 'l', ylim = c(-1.5,1), xlim = c(0, nrow(X21TAR15_TRSW_logCNR[which(X21TAR15_TRSW_logCNR$Gene=="NF1"),])), col = "yellow",xlab ="", ylab = "",axes=FALSE, yaxt="none")
abline(h = c(0.58,-1), col = "orange")
par(new=TRUE)
plot.default(X21TAR15_TRSW_logCNR$TRSW_logCNR_SD[which(X21TAR15_TRSW_logCNR$Gene=="NF1"),], type = 'l', ylim = c(-1.5,1), xlim = c(0, nrow(X21TAR15_TRSW_logCNR[which(X21TAR15_TRSW_logCNR$Gene=="NF1"),])), col = "red",xlab ="", ylab = "",axes=FALSE, yaxt="none")
grid(NA, 12, lwd = 1)
box()
## Allow a second plot fo window coverage depth on the same graph on right axis
par(new=TRUE)
plot.default(X21TAR15_TRSW_coverage$X21TAR15_100014283609_S14[which(X21TAR15_TRSW_coverage$Gene=="NF1")], type = 'l', ylim = c(0,1500), xlim = c(0, nrow(X21TAR15_TRSW_coverage[which(X21TAR15_TRSW_coverage$Gene=="NF1"),])),col = "green",xlab ="", ylab = "",axes=FALSE, yaxt="none")
mtext("Window's Coverage Depth",side=4,line=3) ## a little farther out (line=3) to make room for labels
axis(4, ylim=c(0,1500), col="black",col.axis="black",las=1)
## Adding Mean CVG depth plot of all samples
par(new=TRUE)
plot.default(X21TAR15_TRSW_coverage$TRSW_coverage_mean[which(X21TAR15_TRSW_coverage$Gene=="NF1"),], type = 'p', ylim = c(0,1500), xlim = c(0, nrow(X21TAR15_TRSW_coverage[which(X21TAR15_TRSW_coverage$Gene=="NF1"),])),col = "purple",xlab ="", ylab = "",axes=FALSE, yaxt="none")
#Add Legend
#legend("topleft",legend=c("Sample's logCNR score (left axis)","Sample's Sliding Window coverage depth (right axis)","RUN's Average logCNR score (left axis)","RUN's average Sliding Window coverge depth(right axis)","Standard daviation of logCNR-scores in RUN (right axis)","Theoretical.Values for logCNR.Score ((left axis))"), text.col=c("black","green","yellow","purple","red", "orange"),pch=c(20,20),col=c("black","green","yellow","purple","red","orange"))
legend("topleft",legend=c("Sample's logCNR score (left axis)","Sample's Sliding Window coverage depth (right axis)","RUN's Average logCNR score (left axis)","RUN's average Sliding Window coverge depth(right axis)","Standard daviation of logCNR-scores in RUN (right axis)","Theoretical.Values for logCNR.Score ((left axis))"),fill=c("black","green","yellow","purple","red","orange"))
dev.off()
