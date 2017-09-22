# CNV_ANALYSIS
Step to run the CNV_ANALYSIS
> sh step1_code_for_running_CNV_analysis_parallel.sh

it will initiate the

> step2_R_code_for_SlidingWindow_MeanDepth_calculation.r

> step3_R_code_for_log_CopyNumberRatio_calculation.r

> step4_R_code_for_plotting_sample_for_each_individual_gene.r

pass it with the nucleotide level coverage depth file of the pool of samples generated throught <GATK DepthOfCoverage>  
it will generate the LOG_CNR file based on sliding window of given length (here length is 75) and with the slode of the 10 nucleotide.
  
List of supporting file is:
  
> Gene_names;

> TRSW_50;

> TRSW75_skip10;

> TRSW75_skip10_annotated;

To generate the templete of sliding window (of desired length and skip length)
 
> step0_R_code_for_breaking_target_regions_on_fixed_window_size.r

or

> step0_R_code_for_breaking_target_regions_on_fixed_window_size_with 10_nucleotide_skip.r

