"""Mapping and process before variant calling rules"""


rule bwa_index:
    input:
        reference=get_reference(reference_file)
    output:
        bwa_bwt=get_reference(new_reference) + ".bwt",
        fai=get_reference(new_reference) + ".fai"
    log:
        "reference/build.log"
    params:
        options="",
        index_algorithm="is"
    threads: 2
    wrapper:
        f"{sequana_wrapper_branch}/wrappers/bwa/build"

# ========================================================= bwa mapping
rule bwa:
    input:
        fastq=manager.getrawdata(),
        bwa_bwt=new_reference + ".bwt",
        fai=new_reference + ".fai",
        reference=new_reference
    output:
        sorted="{sample}/bwa/{sample}.sorted.bam"
    log:
        "{sample}/bwa/{sample}.log"
    params:
        options=config["bwa_mem"]["options"],
        tmp_directory=config["bwa_mem"]["tmp_directory"]
    threads: 2
    wrapper:
        f"{sequana_wrapper_branch}/wrappers/bwa/align"


# ========================================================= add read group
#
rule add_read_group:
    input:
        manager.getrawdata() if config["input_pattern"].endswith(".bam") 
            else "{sample}/bwa/{sample}.sorted.bam"
    output:
        "{sample}/add_read_group/{sample}.sorted.bam"
    log:
        "{sample}/add_read_group/{sample}.log"
    params:
        options=config["add_read_group"]["options"],
        SM="{sample}"
    wrapper:
        f"{sequana_wrapper_branch}/wrappers/add_read_group"



# ============================================= Mark duplicates with sambamba markdup
if config["sambamba_markdup"]["do"]:

    rule sambamba_markdup:
        input:
            "{sample}/add_read_group/{sample}.sorted.bam"
        output:
            "{sample}/sambamba_markdup/{sample}.sorted.bam"
        log:
            out="{sample}/sambamba_markdup/{sample}.out",
            err="{sample}/sambamba_markdup/{sample}.err"
        params:
            options=config["sambamba_markdup"]["options"],
            tmp_directory=config["sambamba_markdup"]["tmp_directory"],
            remove_duplicates=config["sambamba_markdup"]["remove_duplicates"]
        wrapper:
            f"{sequana_wrapper_branch}/wrappers/sambamba_markdup"

    __sambamba_filter__input = "{sample}/sambamba_markdup/{sample}.sorted.bam"
    __freebayes__input       = "{sample}/sambamba_markdup/{sample}.sorted.bam"
    __samtools_depth__input  = "{sample}/sambamba_markdup/{sample}.sorted.bam"
else:
    __sambamba_filter__input  = "{sample}/add_read_group/{sample}.sorted.bam"
    __samtools_depth__input   = "{sample}/add_read_group/{sample}.sorted.bam"
    __freebayes__input        = "{sample}/add_read_group/{sample}.sorted.bam"

# ============================================== bam quality filter with sambamba
if config["sambamba_filter"]["do"]:

    rule sambamba_filter:
        input:
            __sambamba_filter__input
        output:
            "{sample}/sambamba_filter/{sample}.filter.sorted.bam"
        log:
            out="{sample}/sambamba_filter/{sample}_sambamba_filter.out",
            err="{sample}/sambamba_filter/{sample}_sambamba_filter.err"
        params:
            threshold=config["sambamba_filter"]["threshold"],
            options=config["sambamba_filter"]["options"]
        wrapper:
            f"{sequana_wrapper_branch}/wrappers/sambamba_filter"

    __freebayes__input = "{sample}/sambamba_filter/{sample}.filter.sorted.bam"
    __samtools_depth__input = [
        "{sample}/sambamba_filter/{sample}.filter.sorted.bam",
    ]