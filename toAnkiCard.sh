#!/bin/bash
# 2024/02/17, Grace
# Extract the information from each field from a table to a Anki card formate.
# The number of field is user defined. Two key words are used 
# 1. "## Vocabulary list": define the head line of table, which is 4 lines below
# 2. "## Anki card": define the bottom of table, which is 2 lines above. 
# 

input=$1

headKey="## Vocabulary list"
tailKey="## Anki card"

line_s=$(grep -n -A 4 "$headKey" $input| tail -n 1 |awk '{print $1}'| tr -cd '[:digit:]. ')
line_f=$(grep -n -B 2 "$tailKey" $input| head -n 1 |awk '{print $1}'| tr -cd '[:digit:]. ')

num_card=$(($line_f - $line_s -1))

field=($(sed -n "$line_s,$line_s p" $input | sed 's/|//g'))
num_field=${#field[@]}

line_s_card=$(($line_s + 2))
# cannot use array because of blank in elements.
for ((n=1;n<=$num_field;n++))
do 
    sed -n "$line_s_card,$line_f p" $input | cut -d '|' -f $(($n+1)) > tmp_toAnki$n.dat  
done 

#Main program 

grep -A 2 "$headKey"  $input | tail -n 1 >> $input 
echo '' >> $input 

for ((n=1;n<=$num_card;n++))
do 
    echo 'START' >> $input 
    echo 'DU1 (DU to EN)' >> $input 

    for  ((m=1;m<=$num_field;m++))
    do 
        col=$(sed -n "$n,$n p" tmp_toAnki$m.dat) 
        echo ${field[$(($m-1))]}':' "$col" >> $input 
    done 
    
    echo '' >> $input 
    echo 'END' >> $input 
    echo '' >> $input 
done 

rm -f tmp_toAnki*.dat
