## CNV_ANALYSIS
    
##**STATIC pooling steps**
![Static_pooling_25 09 2018](https://user-images.githubusercontent.com/8995865/69148410-86da0100-0ad4-11ea-810c-db1877dc94c4.png)

![Fig2_CNV_Pipeline_Workflow](https://user-images.githubusercontent.com/8995865/115881872-7b6ad200-a44c-11eb-8eeb-aa3bdad62eed.png)
![Fig3_V2_Sliding_window_template_creation](https://user-images.githubusercontent.com/8995865/115881888-80c81c80-a44c-11eb-9ffa-b96ef833e922.png)
![Fig4_V2_Static_pools_creation](https://user-images.githubusercontent.com/8995865/115881916-89b8ee00-a44c-11eb-9e3b-0606e85b3ed9.png)
![Fig5_V2_SVG _Plot_of_logCNR-score](https://user-images.githubusercontent.com/8995865/115881937-8e7da200-a44c-11eb-9cd5-83b35f987d67.png)





##**Step to run the CNV_ANALYSIS**
> sh step1_code_for_running_CNV_analysis_parallel.sh

***it will initiate the***

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

