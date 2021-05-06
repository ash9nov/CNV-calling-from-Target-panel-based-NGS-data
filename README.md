# In-Silico CNV detetion from Target Panel based NGS data:
Its common practice to use Next generation sequencing in diagnostics lab to detect SNP/INDELs. But still to detect CNVs, diagnostic labs are still using wetlab based methods e.g. MLPA (MRC Hollend), RNA sequencing, or long-range PCR method. These methods are expensive , lab-intensive and time consuming. Due to availablity of NGS data its very suitable to use it to detect CNVs too in diagnotics.
Target panels are commonly used in diagnotics labs due to specificity of aims towards checking variantions in certain genes.
Our pipeline utlized the NGS data from target panels to detect CNVs for genetics diagnostics.
- - - -
## Prerequisites 

Following softwares have to be pre-installed.
* GATK.
* R programming.
* ImageMagick. 
- - - -
## Downloading code
	git clone https://github.com/ash9nov/Target-panel-based-CNV-detection
- - - -
## Preparing input data:
[GATK's DepthOfCoverage](https://gatk.broadinstitute.org/hc/en-us/articles/360041851491-DepthOfCoverage-BETA-) is used on all the BAM files  of any NGS run for creating requied input data.

`find <path_to_NGS_run_BAM_files> -name "*.bam"| sort > FINAL_BAMs.list`

`mkdir coverage_report`

`java -jar GATK/GenomeAnalysisTK.jar -T DepthOfCoverage -R ucsc.hg19.fasta -I FINAL_BAMs.list -o NGS_run -L Target_panel.bed`

## Outputs files: **per_locus_coverage** file (consisting of nucleotide level coverage of each sample in RUN) and **run_summary** file (consiting mean coverage of each sample in RUN) are used by pipeline for the analysis purpose
- - - -
## How to use

### ***Step0: Splitting of Target region in overlapping sliding windows:***
To increase resolution each target region is divided into overlapping sub-regions in a sliding window approach (as shown in Figure below), forming the template for a window-based representation of each target region. This approach is called the Target Region based Sliding Windows (TRSW) approach, or just sliding windows. This also helps in detecting CNVs occurring in smaller sub-regions, e.g., part of an exon. Selection of window size is based on length of sequencing reads and the required resolution of CNV predictions.

![Fig3_V2_Sliding_window_template_creation](https://user-images.githubusercontent.com/8995865/115881888-80c81c80-a44c-11eb-9ffa-b96ef833e922.png)

#### R code: (run in R shell.)

`step0_R_code_for_breaking_target_regions_on_fixed_window_size.r`

*Here default length of window is 75 nucleotide, sliding length is 10.*

#### Input: bed file for Target panel (sorted and without overlaps in adjucent regions) consisting of four columns  `chr		start		end		gene`
#### Output: Two files **TRSW75_skip10** and **TRSW75_skip10_annotated** which will be used by pipeline as templete for CNV calculation.
- - - -
### ***Step1: Creating static pools:***

![Fig4_V2_Static_pools_creation](https://user-images.githubusercontent.com/8995865/115881916-89b8ee00-a44c-11eb-9e3b-0606e85b3ed9.png)
- - - -
### ***Step2: Calculating CNV results:***
- - - -
***Figure2: Pipline work-flow:***
![Fig2_CNV_Pipeline_Workflow](https://user-images.githubusercontent.com/8995865/115881872-7b6ad200-a44c-11eb-8eeb-aa3bdad62eed.png)





<!---
***Figure5: example plot of a CNV positive sample:***
![Fig5_V2_SVG _Plot_of_logCNR-score](https://user-images.githubusercontent.com/8995865/115881937-8e7da200-a44c-11eb-9cd5-83b35f987d67.png)
--->




##Step to run the CNV_ANALYSIS
> sh step1_code_for_running_CNV_analysis_parallel.sh

***it will initiate the***

> step2_R_code_for_SlidingWindow_MeanDepth_calculation.r

> step3_R_code_for_log_CopyNumberRatio_calculation.r

> step4_R_code_for_plotting_sample_for_each_individual_gene.r

pass it with the nucleotide level coverage depth file of the pool of samples generated throught <GATK DepthOfCoverage>  
it will generate the LOG_CNR file based on sliding window of given length (here length is 75) and with the slode of the 10 nucleotide.
  
List of supporting file is:
  
> Gene_names;




