## CNV_ANALYSIS
  ## Wrkflow
  ![CNV_Analysis_work_flow_FINAL_screen_quality_12 10 2018](https://user-images.githubusercontent.com/8995865/69148320-51351800-0ad4-11ea-88cb-0e56cabf89ec.png)
      ##STATIC pooling steps
      # CNV_static_pooling
      ![Static_pooling_25 09 2018](https://user-images.githubusercontent.com/8995865/69148410-86da0100-0ad4-11ea-810c-db1877dc94c4.png)




##Step to run the CNV_ANALYSIS
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

