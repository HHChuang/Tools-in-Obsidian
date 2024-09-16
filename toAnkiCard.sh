#!/bin/bash
# Extract the information from each field from a table to a Anki card formate.
# The number of field is user defined. Two key words are used 
# 1. "## Vocabulary list": define the head line of table, which is 4 lines below
# 2. "## Anki card": define the bottom of table, which is 2 lines above. 
# 
# 2024/02/17, Grace
# 2024/08/03, Grace, Free the position of section of Vocabulary list and Anki card

input=$1

# case insensitive
inputKey="Vocabulary list"
outputKey="Anki card"
cardType='Basic'

targetDeck=$(grep "TARGET DECK" $input|head -n 1)

# Calculate the initial and final number of line for the input vocabulary list, and also the total number of vocabularies. 
vocab_iniL=$(grep -n "##" $input | grep -i "$inputKey"| cut -d ':' -f 1| head -n 1 ) 
vocab_finL=$(grep -n "##" $input | grep -A 1 -i "$inputKey"| cut -d ':' -f 1| tail -n 1 ) 
temp_iniL=$(sed -n "$vocab_iniL,$vocab_finL p" $input | grep -n '|'| cut -d ':' -f 1 |head -n 1)
temp_finL=$(sed -n "$vocab_iniL,$vocab_finL p" $input | grep -n '|'| cut -d ':' -f 1 |tail -n 1)
nVocab=$(($temp_finL - $temp_iniL - 1))
vocab_iniL=$(($vocab_iniL + $temp_iniL - 1))
vocab_finL=$(($vocab_iniL + $nVocab + 1))

field=($(sed -n "$vocab_iniL,$vocab_iniL p" $input | sed 's/|//g'))
num_field=${#field[@]}

# Calculate the output line number 
output_iniL=$(grep -n "##" $input | grep -i "$outputKey"| cut -d ':' -f 1| head -n 1 )

# extract metadata into $vocab_field[$m,$n]

# use 2d array variable 
declare -a vocab_field

output_iniL=$(($output_iniL+1))
sed -i '' "$output_iniL s/^/$targetDeck\n/" $input 
sed -i '' "$output_iniL s/^/ \n/" $input 
output_iniL=$(($output_iniL+2))

for ((n=1;n<=$nVocab;n++))
do 
    echo 'START' > card.tmp 
    echo "$cardType" >> card.tmp 
    
    tmp_Line=$(($vocab_iniL+1+$n))

    for  ((m=1;m<=$num_field;m++))
    do 
        vocab_field[$m,$n]=$(sed -n "$tmp_Line,$tmp_Line p" $input | cut -d '|' -f $(($m+1)))
        echo ${field[$(($m-1))]}: ${vocab_field[$m,$n]} >> card.tmp 
    done 
    echo '' >> card.tmp 
    echo 'END' >> card.tmp 
    echo '' >> card.tmp 

    sed -i '' "$output_iniL r card.tmp" $input
    output_iniL=$(($output_iniL+$num_field+5))

done 

rm -f card.tmp 
