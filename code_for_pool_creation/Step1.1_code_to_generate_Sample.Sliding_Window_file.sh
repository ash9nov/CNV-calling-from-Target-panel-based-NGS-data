#!/bin/bash


cd ./pool_coverage_files
# now tuning the run_file as per code: splitting the "Locus:position" to "Locus     Position" 
sed -i 's/Locus/Locus:Position/g' $dir1
tr ':' '\t' < $dir1 > "$dir1.modified"
cp $dir1.modified $dir1
rm $dir1.modified
#---------------------------------
#counting number of samples in run.
smpl=$(grep -o 'Depth_for_' $dir1 |wc -w)
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
#####+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Step2: Running the R code (in parallel)for calculating mean depth with sliding of 10 nucleotide.
a=$((smpl/12)) #Here we 12 is the number of samples will run in parallel in one GO.
b=$((smpl%12))
i=1
while [ "$i" -le "$a" ]; 
do
        c=$((i*12))
        find ./ -name "*.Coverage" |sort | head -n $c| tail -n 12| sed 's/.Coverage//g' | parallel Rscript ~/my_tools/NGS_CNV_code/step2_R_code_for_SlidingWindow_MeanDepth_calculation.r {}.Coverage {}.Sliding_window
        i=$(($i+1))        
done
##
find ./ -name "*.Coverage" |sort | tail -n $b| sed 's/.Coverage//g' | parallel Rscript ~/my_tools/NGS_CNV_code/step2_R_code_for_SlidingWindow_MeanDepth_calculation.r {}.Coverage {}.Sliding_window
#Removing the Sample.Coverage files (multiple runs so, removing Coverage file will not let them re-run )
rm ./*.Coverage

# At This stage, all the samples from all pools will have SAMPLE.Sliding_window files.
#####+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++