
.. image:: https://badge.fury.io/py/sequana-variant-calling.svg
     :target: https://pypi.python.org/pypi/sequana_variant_calling

.. image:: http://joss.theoj.org/papers/10.21105/joss.00352/status.svg
    :target: http://joss.theoj.org/papers/10.21105/joss.00352
    :alt: JOSS (journal of open source software) DOI

.. image:: https://github.com/sequana/variant_calling/actions/workflows/main.yml/badge.svg
   :target: https://github.com/sequana/variant_calling/actions/workflows    


This is the **variant_calling** pipeline from the `Sequana <https://sequana.readthedocs.org>`_ projet

:Overview: Variant calling from FASTQ files
:Input: FASTQ files from Illumina Sequencing instrument
:Output: VCF and HTML files
:Status: production
:Citation: Cokelaer et al, (2017), 'Sequana': a Set of Snakemake NGS pipelines, Journal of Open Source Software, 2(16), 352, JOSS DOI https://doi:10.21105/joss.00352


Installation
~~~~~~~~~~~~

If you already have all requirements, you can install the packages using pip::

    pip install sequana_variant_calling --upgrade

Otherwise, you can create a *sequana_variant_calling* conda environment executing::

    conda env create -f environment.yml

and later activate the environment::

  conda activate sequana_variant_calling

A third option is to install the pipeline with pip method (see above) and use singularity as explained afterwards.


Usage
~~~~~

::

    sequana_variant_calling --help
    sequana_variant_calling --input-directory DATAPATH --reference-file measles.fa

This creates a directory **variant_calling**. You just need to execute the pipeline::

    cd variant_calling
    sh variant_calling.sh

This launch a snakemake pipeline. If you are familiar with snakemake, you can
retrieve the pipeline itself and its configuration files and then execute the pipeline yourself with specific parameters::

    snakemake -s variant_calling.rules -c config.yaml --cores 4 --stats stats.txt

Or use `sequanix <https://sequana.readthedocs.io/en/main/sequanix.html>`_ interface.

Usage with singularity::
~~~~~~~~~~~~~~~~~~~~~~~~~

With singularity, initiate the working directory as follows::

    sequana_variant_calling --use-singularity

Images are downloaded in the working directory but you can store then in a directory globally (e.g.)::

    sequana_variant_calling --use-singularity --singularity-prefix ~/.sequana/apptainers

and then::

    cd variant_calling
    sh variant_calling.sh

if you decide to use snakemake manually, do not forget to add singularity options::

    snakemake -s variant_calling.rules -c config.yaml --cores 4 --stats stats.txt --use-singularity --singularity-prefix ~/.sequana/apptainers --singularity-args "-B /home:/home"

    

Requirements
~~~~~~~~~~~~

This pipelines requires the following executable(s):

- bwa
- freebayes
- picard (picard-tools)
- sambamba
- samtools
- snpEff

.. image:: https://raw.githubusercontent.com/sequana/sequana_variant_calling/main/sequana_pipelines/variant_calling/dag.png

Details
~~~~~~~~

Snakemake variant calling pipeline is based on
`tutorial <https://github.com/ekg/alignment-and-variant-calling-tutorial>`_
written by Erik Garrison. Input reads (paired or single) are mapped using
`bwa <http://bio-bwa.sourceforge.net/>`_ and sorted with
`sambamba-sort <http://lomereiter.github.io/sambamba/docs/sambamba-sort.html>`_.
PCR duplicates are marked with
`sambamba-markdup <http://lomereiter.github.io/sambamba/docs/sambamba-sort.html>`_. 
`Freebayes <https://github.com/ekg/freebayes>`_ is used to detect SNPs and short
INDELs. The INDEL realignment and base quality recalibration are not necessary
with Freebayes. For more information, please refer to a post by Brad Chapman on
`minimal BAM preprocessing methods
<https://bcbio.wordpress.com/2013/10/21/updated-comparison-of-variant-detection-methods-ensemble-freebayes-and-minimal-bam-preparation-pipelines/>`_.

The pipeline provides an analysis of the mapping coverage using
`sequana coverage <http://www.biorxiv.org/content/early/2016/12/08/092478>`_.
It detects and characterises automatically low and high genome coverage regions.

Detected variants are annotated with `SnpEff <http://snpeff.sourceforge.net/>`_ if a
GenBank file is provided. The pipeline does the database building automatically.
Although most of the species should be handled automatically, some special cases
such as particular codon table will required edition of the snpeff configuration file.

Finally, joint calling is also available and can be switch on if desired.


Changelog
~~~~~~~~~

========= ======================================================================
Version   Description
========= ======================================================================
0.11.0    * Add singularity containers
0.10.0    * fully integrated sequana wrappers and simplification of HTML reports
0.9.10    * Uses new sequana_pipetools and wrappers
0.9.5     * fix typo in the onsuccess and update sequana requirements to use
            most up-to-date snakemake rules
0.9.4     * fix typo related to the reference-file option new name not changed
            everyhere in the pipeline. 
0.9.3     * use new framework (faster --help, --from-project option)
          * rename --reference into --reference-file and --annotation to
            --annotation-file
          * add custom summary page
          * add multiqc config file
0.9.2     * snpeff output files are renamed sample.snpeff (instead of
            samplesnpeff)
          * add multiqc to show sequana_coverage and snpeff summary sections
          * cleanup onsuccess section
          * more options sanity checks and options (e.g., 
          * genbank_file renamed into annotation_file in the config
          * use --legacy in freebayes options
          * fix coverage section to use new sequana api
          * add the -do-coverage, --do-joint-calling options as well as
            --circular and --frebayes--ploidy
0.9.1     * Fix input-readtag, which was not populated
0.9.0     First release
========= ======================================================================

Contribute & Code of Conduct
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To contribute to this project, please take a look at the 
`Contributing Guidelines <https://github.com/sequana/sequana/blob/maib/CONTRIBUTING.rst>`_ first. Please note that this project is released with a 
`Code of Conduct <https://github.com/sequana/sequana/blob/main/CONDUCT.md>`_. By contributing to this project, you agree to abide by its terms.

