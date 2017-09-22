#!/bin/bash

#-----------------------
#last modified: 15:09:2017
#-----------------------
# this part of the code is to test the CNV pipeline
echo "enter the run"
read dir1
echo "enter the number of samples"
read smpl
#----------------------
#Last Modified: 08:09:2017
mkdir /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis
cp /data/$dir1/Data/Intensities/BaseCalls/coverage_report/$dir1 /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis
cd /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis
# now tuning the run_file as per code: splitting the "Locus:position" to "Locus     Position" 
sed -i 's/Locus/Locus:Position/g' $dir1
tr ':' '\t' < $dir1 > "$dir1.modified"
cp $dir1.modified $dir1
rm $dir1.modified
#---------------------------------
#step1: Breaking the run_nucleotide_coverage file to sample nucleotide coverage file...........
sed -i 's/Depth_for_//g' $dir1 # changing the long names of columns
i=1
cut -f 1,2 "$dir1" > "$dir1.nucleotide_position"
while [ "$i" -le "$smpl" ] ; 
do
        jj=$(($i+4))
        cut -f $jj "$dir1" > "$dir1.sample_nucleotide_level_coverage"
        read -r FIRSTLINE < $dir1.sample_nucleotide_level_coverage
        paste -d "\t" "$dir1.nucleotide_position" "$dir1.sample_nucleotide_level_coverage" > "$FIRSTLINE.Coverage" # here the $FIRSTLINE.Coverage file is our desired file
        i=$(($i+1));        
done
rm "$dir1.nucleotide_position"
rm "$dir1.sample_nucleotide_level_coverage"
# Step2: Running the R code (in parallel)for calculating mean depth with sliding of 10 nucleotide.
a=$((smpl/12)) #Here we 12 is the number of samples will run in parallel in one GO.
b=$((smpl%12))
i=1
while [ "$i" -le "$a" ]; 
do
        c=$((i*12))
        find /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis -name "*.Coverage" |sort | head -n $c| tail -n 12| sed 's/.Coverage//g' | parallel Rscript ~/my_tools/NGS_CNV_code/step2_R_code_for_SlidingWindow_MeanDepth_calculation.r {}.Coverage {}.Sliding_window
        i=$(($i+1))        
done
##
find /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis -name "*.Coverage" |sort | tail -n $b| sed 's/.Coverage//g' | parallel Rscript ~/my_tools/NGS_CNV_code/step2_R_code_for_SlidingWindow_MeanDepth_calculation.r {}.Coverage {}.Sliding_window

### Step3: Joining the Sample sliding window files coulmn-vise
for i in /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis/*.Sliding_window; #this loop is to rename the column-name "Mean_depth" to "sample-name", so when joined in single file, coumns will be identifiable by the column
do
	i2=${i%.*}
	sed -i "s|Mean_depth|"$i2"|g" $i
	sed -i "s|\/data\/"$dir1"\/Data\/Intensities\/BaseCalls\/coverage_report\/CNV_analysis\/||g" $i
done
#####################################################

for i in /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis/*.Sliding_window;
do
        cut -f  4 $i > "$i.Mean_Depth"
done
paste -d "," /data/Data/NGS_CNV_target/TRSW75_skip10 *.Mean_Depth > "$dir1.TRSW_Mean_Depth"
rm *.Mean_Depth
######################################################

#Step4: calculating the Copy Number Ratio from the "$dir1.TRSW_Mean_Depth " file.
Rscript ~/my_tools/NGS_CNV_code/step3_R_code_for_log_CopyNumberRatio_calculation.r "$dir1.TRSW_Mean_Depth"  "$dir1.TRSW_logCNR"

sed -i 's/"//g' "$dir1.TRSW_logCNR"  #this step is to remove " from the file, which affects the file_names of individual samples 
#--------------------------------------------------------
#step5: Breaking the $dir1.TRSW_logCNR file to sample.logCNR file...........
 Gene=$(($smpl+4))
i=1
cut -f 1,2,3,$Gene "$dir1.TRSW_logCNR" > "$dir1.sliding_windows"
while [ "$i" -le "$smpl" ] ; 
do
        jj=$(($i+3))
        cut -f $jj "$dir1.TRSW_logCNR" > "$dir1.sample_sliding_window"
        read -r FIRSTLINE < $dir1.sample_sliding_window
        paste -d "\t" "$dir1.sliding_windows" "$dir1.sample_sliding_window" > "$FIRSTLINE.sample_TRSW_logCNR" # here the $FIRSTLINE.sample_TRSW_logCNR file is our desired file
        i=$(($i+1));
done
rm "$dir1.sliding_windows"
rm "$dir1.sample_sliding_window"
#########################################################
##step6: plotting the individual sample TRSW_logCNR file for each gene
# here for each individual sample there will be a directory, and all the genes plotted for that sample will be store in that specifc directory
for i in /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis/*.sample_TRSW_logCNR;
do
	i2=${i%.*}
	mkdir $i2
	cd $i2
	Path=$PWD 
        Rscript ~/my_tools/NGS_CNV_code/step4_R_code_for_plotting_sample_for_each_individual_gene.r $i $Path
done

############################################################################################################################################################################
