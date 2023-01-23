# Detecting copy number variation in next generation sequencing data from diagnostic gene panels
https://bmcmedgenomics.biomedcentral.com/articles/10.1186/s12920-021-01059-x

![Screenshot from 2021-10-04 15-05-16](https://user-images.githubusercontent.com/8995865/135857448-2d44a6aa-f605-4ba9-8a47-382097f9b03e.png)

# In-silico CNV detection from target panel-based NGS data:
It is common practice to use Next Generation Sequencing in diagnostics lab to detect SNPs/INDELs. But to detect CNVs diagnostic labs are still using wetlab-based methods, e.g. MLPA (MRC Holland), RNA sequencing, or long-range PCR methods. These methods are expensive, lab-intensive and time consuming. Due to the availability of NGS data it is very relevant to use it to detect also CNVs in diagnostics. Target panels are commonly used in diagnostics labs due to specificity of aims towards checking for variations in specific genes. Our pipeline utilizes NGS data from target panels to detect CNVs for genetic diagnostics.
- - - -
## Prerequisites 

The following softwares needs to be pre-installed.
* GATK.
* R programming.
* ImageMagick. 
- - - -
## Downloading code
	git clone https://github.com/ash9nov/Target-panel-based-CNV-detection
- - - -
## Preparing input data
[GATK's DepthOfCoverage](https://gatk.broadinstitute.org/hc/en-us/articles/360041851491-DepthOfCoverage-BETA-) is used on all the BAM files  of any NGS run for creating requied input data.

`find <path_to_NGS_run_BAM_files> -name "*.bam"| sort > FINAL_BAMs.list`

`mkdir coverage_report`
### for GATK version3
`java -jar GATK/GenomeAnalysisTK.jar -T DepthOfCoverage -R ucsc.hg19.fasta -I FINAL_BAMs.list -o NGS_run -L Target_panel.bed`

### for GATK version4
`java -jar GATK/GenomeAnalysisTK.jar DepthOfCoverage -R ucsc.hg19.fasta -I FINAL_BAMs.list -o NGS_run -L Target_panel.bed`

#### Output: (for pipeline use) 
***per_locus_coverage*** file (consisting of nucleotide level coverage of each sample in RUN) and ***run_summary*** file (consisting of mean coverage of each sample in RUN) are used by pipeline for the analysis
- - - -
## How to use

### ***Step0: Splitting of target region into overlapping sliding windows***
To increase resolution each target region is divided into overlapping sub-regions in a sliding window approach (as shown in figure below), forming the template for a window-based representation of each target region. This approach is called the Target Region based Sliding Windows (TRSW) approach, or just sliding windows. This also helps in detecting CNVs occurring in smaller sub-regions, e.g., part of an exon. Selection of window size is based on length of sequencing reads and the required resolution of CNV predictions.

![Fig3_V2_Sliding_window_template_creation](https://user-images.githubusercontent.com/8995865/115881888-80c81c80-a44c-11eb-9ffa-b96ef833e922.png)

#### R code: (run in R shell)

`step0_R_code_for_breaking_target_regions_on_fixed_window_size.r`

*Here default length of window is 75 nucleotide, sliding length is 10.*

#### Input: bed file for Target panel (sorted and without overlaps in adjacent regions) consisting of four columns;  `chr		start		end		gene`

#### Output: Two files **TRSW75_skip10** and **TRSW75_skip10_annotated** which will be used by pipeline as template for CNV calculation.
- - - -
### ***Step1: Creating static pools***
Pipeline generates static pools from normal samples (with no CNVs), sorted according to coverage depth. The pipeline can then select a pool of samples that matches the coverage depth of the query sample and use this to estimate expected coverage depth (without any CNVs) for a region of interest.

The figure below shows the steps of creating static pools from normal samples. In **step-1** normal samples are selected from available NGS runs and get listed in order of increasing coverage depth. In **step-2** the coverage depth is calculated for each window across each sample. In **step-3** the list of selected normal samples is divided into different pools of size K, where Pool-1 consists of the first K samples, followed by the next pool consisting of the next K samples after skipping the first sample of the previous pool. In **step-4** the mean TRSW of each pool is calculated.

![Fig4_V2_Static_pools_creation](https://user-images.githubusercontent.com/8995865/115881916-89b8ee00-a44c-11eb-9e3b-0606e85b3ed9.png)

#### Code: (to run in unix shell)
`sh Steps_for_generating_static_pooling.sh`

**INPUT** : List of NGS runs (provided as text file) consisting of samples to be used in static pools, and pool size. 

**OUTPUTS** :

This script uses ***RUN.sample_summary*** and ***per_locus_coverage*** files (output from GATK's DepthOfCoverage) from provided ***List_of_runs*** .

**A**. Creates sorted  list of samples with coverage information.

**B**. Creates sample's sliding window level coverage via script `Step1.1_code_to_generate_Sample.Sliding_Window_file.sh`

**C**. Splits the list of samples in different pools with given pool size **"K"**.

**D**. Generating Info_Table_of_Pools which contains mean coverage of each pool via script `NGS_CNV_code/step2_R_code_for_SlidingWindow_MeanDepth_calculation.r` 

**E**. Generating Pool_TRSW_mean_depth. via running the script `Step1.2_R_code_for_POOL_MEAN_TRSW_calculation.r`
- - - -
### ***Step2: Calculating CNV results:***

For a given query sample the coverage depth is first calculated for each sliding window. A static pool is then chosen from the set of static pools where mean coverage depth of the selected pool is closest to coverage depth of the sample. The coverage depth for each window of the query sample is compared against mean coverage depth of each corresponding window of the selected pool. This ratio is converted to log2 scale to calculate the final CNV score, i.e., log copy number ratio score (logCNR score) for that window.

The figure below shows the general workflow for CNV calculation. In **step-1** sliding window level (TRSW) coverage for the query sample is calculated. In **step-2** a static pool is selected (from the list of pools) based on its mean coverage depth similarity to the query sample's coverage depth. In **step-3** "log-copy-number-ratio" is calculated for for each sliding window of query sample, which gets gene annotated in **step-4**. This is the final output of the pipeline.

***Pipeline workflow***

![Github_Fig5_CNV_pipeline_workflow](https://user-images.githubusercontent.com/8995865/117399611-3ab99100-af01-11eb-8a39-ed29c7f4f611.png)

#### Code: (to run in unix shell)
`sh step1_code_for_running_CNV_analysis_parallel_NGS_pipeline_integration.sh`

This script will do the follwoing calculations:

***A.*** Calculates mean coverage depth at sliding window level for query samples using the R script `step2_R_code_for_SlidingWindow_MeanDepth_calculation.r`

***B.*** Runs this script `step1_shell_code_for_running_CNV_analysis_with_STSTIC_pooling.sh` which calculates following

***B.1.*** Selects the most suitable pool among available pools using R script `step2_R_code_for_pool_selection.r`

***B.2.*** Calculates logCopyNumberRatio for all sliding windows of query sample w.r.t. selected static pool using script `step3_R_code_for_logCopyNumberRation_calculation_with_STATIC_pooling.r`

***B.3.*** Plots the logCopyNumberRatio score calculated in previous step using script `step4_R_code_for_plotting_sample_for_each_individual_gene_static_pooling.r`

***B.4.*** Calculates the % coverage daviation for query sample vs selected pool using script `step5_R_code_for_quality_control_in_STATIC_pooling.r`

***C.***  Concatenates all the plots for different genes one under each other in a single image using script  `step_FINAL_code_for_combining_all_runwise_and_static_pooling_plots_from_all_samples_for_each_gene.sh`




<!---
***Figure5: example plot of a CNV positive sample:***
![Fig5_V2_SVG _Plot_of_logCNR-score](https://user-images.githubusercontent.com/8995865/115881937-8e7da200-a44c-11eb-9cd5-83b35f987d67.png)
--->




