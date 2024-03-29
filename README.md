The scripts 'attC-screening.sh' and 'IntI-screening.sh' can be used to filter DNA sequences to ensure that they represent amplicons from genuine integrons.

The 'attC-screening.sh' script filters input sequences for gene cassette recombination sites (*attC*s) and should be used for *attC-attC* amplicon data.
The 'IntI-screening.sh' script filters input sequences for intergron integrase (IntI) protein sequences and should be used for *intI-attC* amplicon data.

# attC-screening.sh

This script uses the [HattCI](https://github.com/maribuon/HattCI) + [Infernal](http://eddylab.org/infernal/) pipeline that has been previously described [here](https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-020-06830-5) and [here](https://doi.org/10.1038/s42003-021-02489-0). In short, 'attC-screening.sh' searches for the sequence and secondary structures conserved among *attC*s and retains any input sequence that has at least one *attC* site. The script can be used on data generated from any sequencing technology.

## attC-screening.sh usage:

**usage:** ./attC-screening.sh


**Mandatory arguments:**

-m : universal attC CM ('attCs.cm')

-i : input fasta of DNA sequences


**Optional arguments:**

-b : bit score cut-off for cmsearch | default: 20 

-l : minimum length of output sequences | default: 500 bp

-t : number of CPUs | default: 1 

-o : output directory | default: current directory


**Dependencies** (Script may work with older or newer versions):

[HattCI v1.0b](https://github.com/maribuon/HattCI)

[INFERNAL](http://eddylab.org/infernal/) version 1

[SAMtools](https://anaconda.org/bioconda/samtools) v1.12

[SeqKit](https://bioinf.shenwei.me/seqkit/) v0.7.2

# IntI-screening.sh

The script uses a profile HMM used by the [Integron Finder](https://github.com/gem-pasteur/Integron_Finder) program to detect the additional domain that is unique to integron integrases. The pipeline first uses [Prodigal](https://github.com/hyattpd/Prodigal) to predict all encoded protein sequences, and then screens them for the IntI-specific domain using hmmsearch from the [HMMER v3](http://hmmer.org/) software package. Any sequences that do not contain a recognisable integron integrase are discarded. Similarly, intI_screening.sh can be used on data generated from any sequencing technology.

## IntI-screening.sh usage:

**usage:** ./IntI-screening.sh


**Mandatory arguments:**

-m : IntI HMM ('IntI-Cterm.hmm')

-i : input fasta of DNA sequences


**Optional arguments:**

-l : minimum length of output sequences | default: 800 bp

-t : number of CPUs | default: 1 

-o : output directory | default: current directory


**Dependencies** (Script may work with older or newer versions):

[Prodigal](https://github.com/hyattpd/Prodigal) v2.6.3

[HMMER](http://hmmer.org/) version 3

[SAMtools](https://anaconda.org/bioconda/samtools) v1.12

[SeqKit](https://bioinf.shenwei.me/seqkit/) v0.7.2


# Citations:

If you use either script (**attC-screening.sh** or **IntI-screening.sh**), please cite:

Ghaly, T.M., Penesyan, A., Pritchard, A., Qi, Q., Rajabal, V., Tetu, S.G. and Gillings, M.R. 2021. Methods for the targeted sequencing and analysis of integrons and their gene cassettes from complex microbial communities. *Microbial Genomics*, **8**(3): 000788. doi: [10.1099/mgen.0.000788](https://doi-org.simsrad.net.ocs.mq.edu.au/10.1099/mgen.0.000788).

Please also cite all of their dependencies listed above.

**IntI-screening.sh** makes use of the IntI-Cterm.hmm profile used by Integron Finder. If you use this script, please also cite their paper:

Cury, J., Jové, T., Touchon, M., Néron, B. and Rocha, E.P. 2016. Identification and analysis of integrons and cassette arrays in bacterial genomes. *Nucleic Acids Research*, 44(10):4539-4550.
