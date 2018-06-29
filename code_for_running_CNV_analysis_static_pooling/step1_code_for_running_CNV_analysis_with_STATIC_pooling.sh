#!/bin/bash

#This code need to export variable "$dir1" from mother shell code.
# path to the CNV-run-pooling results: /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis
#dir1="test_dir" #this step was for testing directly after sample.Sliding_window files are created
mkdir /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_static_pooling
cp /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_analysis/*.Sliding_window /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_static_pooling
cd /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_static_pooling
cut -f 1,3 /data/$dir1/Data/Intensities/BaseCalls/coverage_report/$dir1.sample_summary|grep -v 'Total' > $dir1.sample_mean

# Now R code for selecting the relevent Pool for each sample.
Rscript ~/my_tools/NGS_CNV_code/code_for_running_CNV_analysis_static_pooling/step2_R_code_for_pool_selection.r $dir1.sample_mean  $dir1.sample_with_selected_pool
rm $dir1.sample_mean
#Now calculation logCNR scores for all the samples in run.

for i in *.Sliding_window;
	do
		i2=${i%.*}
		grep "$i2" $dir1.sample_with_selected_pool| cut -f 3 > $i2.Pool
		sed -i 's/"//g' $i2.Pool
		pool=$(head -1 $i2.Pool)
		rm $i2.Pool
		cp /data/Data/CNV_static_pooling/ALL_POOLS/Pool_with_samples/$pool/$pool.MEAN_TRSW ./
		# Now calculating the logCNR_score by passing Sample.Sliding_window & respective POOL.MEAN_TRSW
		Rscript ~/my_tools/NGS_CNV_code/code_for_running_CNV_analysis_static_pooling/step3_R_code_for_logCopyNumberRatio_calculation_with_STATIC_pooling.r $i $pool.MEAN_TRSW $i2.sample_TRSW_logCNR
		# In this Rscript "$i2.sample_TRSW_logCNR" is the output file with has logCNR scores for target region.
		sed -i 's/"//g' "$i2.sample_TRSW_logCNR"
		rm $pool.MEAN_TRSW
	done
#NOW plotting the individual sample TRSW_logCNR file for each gene
# here for each individual sample there will be a directory, and all the genes plotted for that sample will be store in that specifc directory
for i in /data/$dir1/Data/Intensities/BaseCalls/coverage_report/CNV_static_pooling/*.sample_TRSW_logCNR;
do
	i2=${i%.*}
	mkdir $i2
	cd $i2
	Path=$PWD 
    Rscript ~/my_tools/NGS_CNV_code/code_for_running_CNV_analysis_static_pooling/step4_R_code_for_plotting_sample_for_each_individual_gene.r $i $Path
    cd ..
done
