#!/bin/bash

############################################################################################################################################
:'Step1: List generation of samples from differnt run. 
Here RUN.sample_summary will be used to find sample+coverage information'
######################################################################
#making directory for collecting the files of nucleotide level coverage
mkdir pool_coverage_files 
# Generating an empty file "list_of_samples" for collecting the list of all samples selected for pooling, by entring the the respective RUNs:  
echo -n > list_of_samples

echo "Enter the file_name (with complete path) which contains the list of RUNS"
read list_of_runs

echo "Enter the POOL SIZE" #it will be used in step2.
read K

#Now running the loop with number of runs, which is being passed thrung list_of_runs file.
while IFS= read -r dir1
do
  echo "$dir1"
	#add the desired run in 
	cut -f 1,3 /mnt/miseq/Medisinsk_Genetikk/Resultater/*/coverage_report/$dir1.sample_summary|grep -v 'sample\|Total' >> list_of_samples
	# Now copying the Nucleotide level coverage data for all samples in the selected run
		cp  /mnt/miseq/Medisinsk_Genetikk/Resultater/*/coverage_report/$dir1 ./pool_coverage_files
		#-------------------------------------------------------------------------------------
		:'Step1.1: Generation of sample.Sliding_Window files of samples in one of selected runs'
		#-------------------------------------------------------------------------------------
		# Creating Sample.Sliding_Window files
		export dir1;
		sh ~/my_tools/NGS_CNV_code/code_for_pool_creation/Step1.1_code_to_generate_Sample.Sliding_Window_file.sh
done < "$list_of_runs"

# Sorting the list_of_samples in increasing order of coverage depth.
sort -k1,1 list_of_samples |uniq |sort -k2n > list_of_samples_SORTED_cvg
# removing samples with coverage less then 100.
awk '{if ($2 >= 100) print $1,$2}' list_of_samples_SORTED_cvg >list_of_samples_final
rm list_of_samples
rm list_of_samples_SORTED_cvg
############################################################################################################################################
:'Step2: Splitting the list of samples in different pool with a given pool size "K"
Final output of this step will be a directory "ALL_POOLS" of files, where each file has list of "K-1" samples which will make a specific pool
((If there are "N" samples in a list_of_samples, and the chosen size of pool is "K" [where k-1 samples from static pool & 1 pasient-sample ] then there will be total of "N-K+2" number of pools))'
######################################################################
# calculating the number of samples in list of samples
N=$(wc -l list_of_samples_final| cut -d ' ' -f 1)
		#Next two line are moved on top of code. as to take all inputs from USER in start
			#echo "Enter the POOL SIZE"
			#read K
NOP=$((N-K+2))
echo " $NOP number of pools will be created"
# Generating the $NOP number pools, each with K-1 number of samples.
mkdir ALL_POOLS
i=1
while [ "$i" -le "$NOP" ]; 
do
	i2=$((K+i-2))
	head -$i2 list_of_samples_final| tail -$((K-1)) >"POOL.$i"
	i=$(($i+1))
done
mv POOL.* ALL_POOLS

############################################################################################################################################
:'Step3: generating Info_Table_of_Pools which contains information about mean coverage of each pool.
Final output of this step will a file Info_Table_of_Pools, which will contain two columns, 1st will be pool name, 2nd will be mean coverage of the pool.'
######################################################################
echo -n > Info_Table_of_Pools
i=1
while [ "$i" -le "$NOP" ]; 
do
	i2=$((K+i-2))
	M=$(head -$i2 list_of_samples_final| tail -$((K-1))|awk '{ total += $2 } END { print total/NR }')
	echo "POOL.$i\t$M" >>Info_Table_of_Pools
	i=$(($i+1))
done

############################################################################################################################################
:'Step4: Joining the Sample sliding window files coulmn-vise
Final output of the step will POOL directories with all its samples and POOL_TRSW_mean_depth (with sliding window info) '
######################################################################

#Making individual pool directories, each with their pool_names
cut -f 1 Info_Table_of_Pools > pool_names
pool_file="$(pwd)/pool_names"
mkdir ALL_POOLS/Pool_with_samples
cd ALL_POOLS/Pool_with_samples
while IFS= read -r line
do
	mkdir $line
done <"$pool_file"
cd ../..

#this loop is to rename the column-name "Mean_depth" to "sample-name", so when joined in single file, samples will be identifiable by the column-name
for i in pool_coverage_files/*.Sliding_window 
	do
		i2=${i%.*}
		sed -i "s|Mean_depth|"$i2"|g" $i
		sed -i "s|pool_coverage_files\/||g" $i
	done

# Copying the sample.sliding_window file to their respective pool directories
pool_file2="$(pwd)/pool_coverage_files/"
i=1
while [ "$i" -le "$NOP" ];
	do
		cut -d ' ' -f 1 "$(pwd)/ALL_POOLS/POOL.$i" > pool_sample_temp
		pool_file1="$(pwd)/pool_sample_temp"
		while IFS= read -r line1
			do
				cp "$pool_file2$line1.Sliding_window" ALL_POOLS/Pool_with_samples/POOL.$i
			done <"$pool_file1"
		i=$(($i+1));
	done

#Joining the Sample sliding window files coulmn-vise for each pool
i=1
j=1
while [ "$j" -le "$NOP" ] ;
	do 
		cd ALL_POOLS/Pool_with_samples/POOL.$j
		for i in ./*.Sliding_window;
			do
    			cut -f  4 $i > "$i.Mean_Depth"
			done
		paste -d "," /data/Data/NGS_CNV_target/TRSW75_skip10 *.Mean_Depth > "POOL.$j.TRSW_Mean_Depth"
		POOL_mean_TRSW="POOL.$j.TRSW_Mean_Depth"
		#NOW running the Rscript, which will calculate the mean of all samples sliding window to one column with name POOL.MEAN_TRSW
		Rscript ~/my_tools/NGS_CNV_code/code_for_pool_creation/Step1.2_R_code_for_POOL_MEAN_TRSW_calculation.r "$POOL_mean_TRSW" "POOL.$j.MEAN_TRSW"
		rm *.Mean_Depth
		cd ../../..
		j=$(($j+1));
	done

############################################################################################################################################
:'This is the FINAL OUTPUT POOL.MEAN_TRSW which will be stored as STATIC_POOL_INFORMATION and will be used
for CNV calculation for each incoming sample'
######################################################################
