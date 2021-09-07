#!/bin/bash

usage() { printf "\nusage: ./IntI-screening.sh -m -i [optional arguments]\n\nMandatory arguments:\n-m : IntI HMM \n-i : input fasta of DNA sequences\n\nOptional arguments:\n-l : minimum length of output sequences | default: 800 bp\n-t : number of CPUs | default: 1 \n-o : output directory | default: current directory\n\nDependencies:\nProdigal\nHMMER version 3\nSAMtools\nSeqKit\n\n"; exit 0;}
[ $# -eq 0 ] && usage

while getopts m:i:l:t:o: flag
do
case "${flag}"
in
m) HMM=${OPTARG};;
i) INPUT=${OPTARG};;
l) MINLENGTH=${OPTARG};;
t) THREADS=${OPTARG};;
o) OUTPUT=${OPTARG};;
*) usage exit 0;;
esac
done


if [ -z "$THREADS" ]
then
THREADS="1"
fi

if [ -z "$OUTPUT" ]
then
OUTPUT="."
fi

if [ -z "$MINLENGTH" ]
then
MINLENGTH="800"
fi

if [ -z "$HMM" ]
then
printf "\nMissing: -m <IntI HMM>\n" >&2
usage
exit 0
fi

if [ -z "$INPUT" ]
then
printf "\nMissing: -i <input.fasta>\n" >&2
usage
exit 0
fi

#Extract sample name from contig file
name=$(basename "$INPUT" | rev | cut -d'.' -f2- | rev);


printf "\n\nRunning Prodigal...\n\n"

prodigal -p meta -q -a $OUTPUT/$name.Temp.faa -i $INPUT -o /dev/null

printf "Done\n\nRunning hmmsearch...\n\n"

hmmsearch --tblout $OUTPUT/$name.IntI-hmmsearch.tab --cpu $THREADS $HMM $OUTPUT/$name.Temp.faa > /dev/null

awk '{print $1}' $OUTPUT/$name.IntI-hmmsearch.tab | sed '/^#/ d' | sed 's/_[^_]*$//' | awk '!a[$1]++' | xargs -n 1 samtools faidx $INPUT | seqkit seq -m $MINLENGTH > $OUTPUT/$name.IntI_filtered.fasta

rm $OUTPUT/$name.Temp.faa; rm $INPUT.fai

printf "Finsihed\n\nInput sequences that have an integron integrase gene (and are at least $MINLENGTH bp long) saved as $OUTPUT/$name.IntI_filtered.fasta\n\nhmmmsearch output saved as $OUTPUT/$name.IntI-hmmsearch.tab\n\n"


