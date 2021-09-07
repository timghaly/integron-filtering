#!/bin/bash

usage() { printf "\nusage: ./attC-screening.sh -m -i [optional arguments]\n\nMandatory arguments:\n-m : universal attC CM \n-i : input fasta of DNA sequences\n\nOptional arguments:\n-b : bit score cut-off for cmsearch | default: 20 \n-l : minimum length of output sequences | default: 500 bp\n-t : number of CPUs | default: 1 \n-o : output directory | default: current directory\n\nDependencies:\nHattCI v1.0b\nINFERNAL version 1\nSAMtools\nSeqKit\n\n"; exit 0;}
[ $# -eq 0 ] && usage

while getopts m:i:b:l:t:o: flag
do
case "${flag}"
in
m) CM=${OPTARG};;
i) INPUT=${OPTARG};;
b) BITSCORE=${OPTARG};;
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

if [ -z "$BITSCORE" ]
then
BITSCORE="20"
fi


if [ -z "$MINLENGTH" ]
then
MINLENGTH="500"
fi

if [ -z "$CM" ]
then
printf "\nMissing: -m <universal attC CM>\n" >&2
usage
exit 0
fi

if [ -z "$INPUT" ]
then
printf "\nMissing: -i <input.fasta>\n" >&2
usage
exit 0
fi

# Extract sample name from contig file
name=$(basename "$INPUT" | rev | cut -d'.' -f2- | rev);

# Run Pipeline
printf "\n\nRunning HattCI...\n\n"

sed '/^>/ s/ .*//' $INPUT > $OUTPUT/$name.input.fasta;

hattci.out -b -t $THREADS $OUTPUT/$name.input.fasta $OUTPUT/$name.HattCI_all.out; sed '/^>/ s/ .*//' outHattCI.fasta > $OUTPUT/$name.attCs_all.fasta; 
rm outHattCI.fasta;

printf "\nDone\n\nRunning cmsearch...\n\n"

cmsearch --max --cpu $THREADS --notrunc -T $BITSCORE --tblout $OUTPUT/$name.cmsearch_attCs.tab $CM $OUTPUT/$name.attCs_all.fasta > /dev/null; 
sed '/^#/ d' $OUTPUT/$name.cmsearch_attCs.tab | awk '{print $1}' > $OUTPUT/$name.attC_struct_ids.txt; 
sed 's/_[^_]*$//' $OUTPUT/$name.attC_struct_ids.txt | sed 's/_[^_]*$//' | awk '!a[$1]++' | xargs -n 1 samtools faidx $OUTPUT/$name.input.fasta | seqkit seq -m $MINLENGTH > $OUTPUT/$name.attC_filtered.fasta; 
rm $OUTPUT/$name.input.fasta.fai; rm $OUTPUT/$name.input.fasta;
xargs -n 1 samtools faidx $OUTPUT/$name.attCs_all.fasta < $OUTPUT/$name.attC_struct_ids.txt > $OUTPUT/$name.attCs.fasta; 
rm $OUTPUT/$name.attCs_all.fasta; rm $OUTPUT/$name.attCs_all.fasta.fai;
awk '{print $1"\t"$2"_"$3"_"$4"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13}' $OUTPUT/$name.HattCI_all.out | grep -Fw -f $OUTPUT/$name.attC_struct_ids.txt - > $OUTPUT/$name.HattCI.out;
head -n1 $OUTPUT/$name.HattCI_all.out | awk '{print $1"\tattC_ID\tSeq_"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\tdirection"}' | cat - $OUTPUT/$name.HattCI.out > $OUTPUT/$name.temp.out && mv $OUTPUT/$name.temp.out $OUTPUT/$name.HattCI.out;
rm $OUTPUT/$name.HattCI_all.out; rm $OUTPUT/$name.attC_struct_ids.txt

printf "Finsihed\n\nInput sequences that have an attC site (and at least $MINLENGTH bp long) saved as $OUTPUT/$name.attC_filtered.fasta\n\nFasta file of all attC sequences saved as $OUTPUT/$name.attCs.fasta\n\nFiltered HattCI output saved as $OUTPUT/$name.HattCI.out\n\ncmsearch output saved as $OUTPUT/$name.HattCI.out\n\n"


