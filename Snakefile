#######################
#   CNV calling pipeline :URL:  https://rdcu.be/c4Nse
#   Copyright (C) 2023 Ashish Kumar Singh - St.Olavs hospital - NTNU - Norway
########################

configfile: "config.yaml"

import pandas as pd
import io
SAMPLESHEET = config['SAMPLESHEET']
HOME = config['HOME']
BATCH = BATCHFOLDER.split("-")[0]

SCRIPTS = config['SCRIPTS']
NGSCNVCODE = config['NGSCNVCODE']
CNV_static_pooling = config['CNV_static_pooling']

DATABASES = config['DATABASES']
EXPORT = config['EXPORT']

rule sambamba_coverage:
    input:
        "results/samples/{sample}/bam/{sample}_sorted_dedup_RG_Baserecal.bam"
    output:
        o1="results/coverage_report/region_base_coverage/{sample}_region_base_coverage"        
    shell:
        """
	    samtools flagstat {input} > results/coverage_report/flagstat/{wildcards.sample}_mapping_summary.txt
        {SCRIPTS}/sambamba depth region -F 'not duplicate and not failed_quality_control' -T 10 -T 15 -T 20 -T 50 -T 100 -L {TARGETPANEL} -o results/coverage_report/region_mean_coverage/{wildcards.sample}_region_mean_coverage {input}
        {SCRIPTS}/sambamba depth base -F 'not duplicate and not failed_quality_control' -L {TARGETPANEL} -o {output.o1} {input}
        """

rule coverage_stats:
    input:
        expand("results/coverage_report/region_base_coverage/{sample}_region_base_coverage",sample=samples)
    output:
        touch("coverage_stats_done")
    params:
        len(samples)
    run:
      if len(input)==len(samples):
          shell("python {SCRIPTS}/coverage_stats.py {HOME} {BATCHFOLDER} {TARGETPANEL} {COVTHRESHOLD} {GAPCOVTHRESHOLD} {UTRREGIONS}")
          shell("cp {HOME}/{BATCHFOLDER}/results/coverage_report/sample_summary.txt {HOME}/{BATCHFOLDER}/results/CNV_analysis/sample_summary.txt")
          shell("{SCRIPTS}/makeNucleotideCoverage.sh results/coverage_report/nucleotide_coverage.txt")


rule copy_number_variation_analysis_step1:
    input:
        i1="coverage_stats_done"
    output:
        o1=touch("results/samples/{sample}/status/ind_sliding_done")
    shell:
        """
	    cd results/CNV_analysis
	    Rscript {SCRIPTS}/NGS_CNV_code_hg37/step2_R_code_for_SlidingWindow_MeanDepth_calculation.r {wildcards.sample}.Coverage {wildcards.sample}.Sliding_window {DATABASES}/panels/TRSW75_skip10_annotated_V3Panel
        """

rule sliding_window:
    input:
        i1=expand("results/samples/{sample}/status/ind_sliding_done",sample=samples)       
    output:
        touch("results/CNV_analysis/sliding_done")
    params:
        len(samples)
    run:
        if len(samples)==len(input):
            shell("{SCRIPTS}/NGS_CNV_code_hg37/step3_sliding_window.sh {HOME} {BATCHFOLDER} {SCRIPTS} {DATABASES} {params} results/coverage_report/sample_summary.txt")

         

rule cnv_individual_plots:
    input:
        i2="results/CNV_analysis/sliding_done"
    output:
        touch("results/samples/{sample}/status/cnv_individual_plots_done")
    shell:
        """
        ##step6: plotting the individual sample TRSW_logCNR file for each gene
        # here for each individual sample there will be a directory, and all the genes plotted for that sample will be store in that specific directory
        cd results/CNV_analysis
        mkdir -p {wildcards.sample}
	    Rscript {SCRIPTS}/NGS_CNV_code_hg37/step6_R_code_for_plotting_sample_for_each_individual_gene_runwise_pooling.r {wildcards.sample} {HOME}/{BATCHFOLDER}/results/CNV_analysis/{wildcards.sample} {DATABASES}/panels/Target_with_gene_info_V3panel_collapsed.bed {DATABASES}/panels/TRSW75_skip10_annotated_V3Panel_with_flag_position_marking
        """

rule cnv_static_pooling_select_pool:
    input:
        i1=expand("results/samples/{sample}/status/cnv_individual_plots_done",sample=samples)
    output:
        touch("CNV_static_pooling_done")
    params:
        len(samples)
    run:
        if len(input)==len(samples):
            shell("cp results/CNV_analysis/*.Sliding_window results/CNV_static_pooling/;cd results/CNV_static_pooling;cut -f 1,3 {HOME}/{BATCHFOLDER}/results/coverage_report/sample_summary.txt|grep -v 'Total' > out.sample_mean;Rscript {SCRIPTS}/NGS_CNV_code_hg37/code_for_running_CNV_analysis_static_pooling/step2_R_code_for_pool_selection.r out.sample_mean out.sample_with_selected_pool {CNV_static_pooling}/Info_Table_of_Pools;rm -f out.sample_mean")
        

rule cnv_static_pooling_and_plots:
    input:
        #i1="results/CNV_analysis/{sample}.Sliding_window",
        i2="CNV_static_pooling_done"
    output:
        touch("results/samples/{sample}/status/cnv_static_pooling_done")
        #touch("results/cnv_static_pooling_done")
    shell:
        """
        {SCRIPTS}/NGS_CNV_code_hg37/code_for_running_CNV_analysis_static_pooling/step1_code_for_running_CNV_analysis_with_STATIC_pooling.sh {HOME} {BATCHFOLDER} {SCRIPTS} {DATABASES} {CNV_static_pooling} {wildcards.sample}.Sliding_window 
        """


#Quality control: calculation of %deviation from pool coverage
rule cnv_static_pooling_quality:
    input:
        i1=expand("results/samples/{sample}/status/cnv_static_pooling_done",sample=samples)
    output:
        o1="results/CNV_static_pooling/out.static_pooling_OUALITY.csv"
    run:
        if len(input)==len(samples):   
            shell("Rscript {SCRIPTS}/NGS_CNV_code_hg37/code_for_running_CNV_analysis_static_pooling/step5_R_code_for_quality_control_in_STATIC_pooling.r results/CNV_static_pooling/out.sample_with_selected_pool {output.o1}")


rule cnv_combining_all_plots_pooling:
    input:
        i1="results/CNV_static_pooling/out.static_pooling_OUALITY.csv",
    output:
        touch("results/genes/{gene}_copy_number_variant_analysis_done")
    shell:
        """
        {SCRIPTS}/NGS_CNV_code_hg37/step_FINAL_code_for_combining_all_runwise_and_static_pooling_plots_from_all_samples_for_each_gene.sh {HOME} {BATCHFOLDER} {DATABASES} {wildcards.gene}
        """

rule cnv_check_all_done:
    input:
        expand("results/genes/{gene}_copy_number_variant_analysis_done",gene=genes)
    output:
        touch("results/genes_copy_number_variant_analysis_done")
    run:
        if len(input)==len(genes):
            "ok"
