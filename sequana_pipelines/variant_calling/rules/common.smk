"""Functions that define the pipeline path"""
from pathlib import Path
from functools import lru_cache


mapping_output = {
    "bwa": "{sample}/bwa/{sample}.sorted.bam",
    "minimap2": "{sample}/bwa/{sample}.sorted.bam"
}

@lru_cache
def get_reference():
    """Get reference with locus for snpeff or copy reference"""
    if config["snpeff"]["do"]:
        return f"snpeff_reference/{REF_FILE.name}"
    elif not reference.with_suffix(REF_FILE.suffix + ".fai").exists():
        return f"reference/{REF_FILE.name}"
    return str(REF_FILE)


def get_bam(wildcards):
    """Get data mapped with bwa or minimap2"""
    if config["input_pattern"].endswith(".bam"):
        return manager.sample[wildcards.sample][0]
    return mapping_output[config["mapper"]].format(sample=wildcards.sample)



