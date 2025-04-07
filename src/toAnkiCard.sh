#!/bin/bash
# Extract the information from each field from a table to a Anki card formate.
# The number of field is user defined. Two key words are used 
# 1. "## Vocabulary list": define the head line of table, which is 4 lines below
# 2. "## Anki card": define the bottom of table, which is 2 lines above. 
# 
# History: 
# 2024/02/17, Grace
# 2024/08/03, Grace, Free the position of section of Vocabulary list and Anki card
# 2024/10/31, Grace, Add a checking step to update Vocabulary list
# 

input=$1

echo "============================================================================="
echo "Purpose: This Bash script transform a markdown table to an Anki card format "
echo "for using an Obsidian plug-in, Obsidian_to_Anki "
echo "(https://github.com/ObsidianToAnki/Obsidian_to_Anki). "
echo "============================================================================="
echo ""

# case insensitive
inputKey="Vocabulary list"
outputKey="Anki Card"
cardType='DU1 (DU to EN)' # 1. English 2. DU1 (DU to EN)
targetDeck_default='DU::focus'

echo "The title for input: ## "$inputKey
echo "The title for output:  ## "$outputKey
echo ""

# Check if there is already an existing card 
tmp=$(grep -n '##' "$input" | grep -A 1 -i "$outputKey" | cut -d ':' -f 1 | head -n 1 )
check_iniL=$(($tmp+1))
tmp=$(grep -n '##'  "$input" | grep -A 1 -i "$outputKey" | cut -d ':' -f 1 | tail -n 1 )
check_finL=$(($tmp-1))
if sed -n "$check_iniL,$check_finL p" "$input" | grep -q '[^[:space:]]'
then 
    # There exist old anki card already
    newFile=false
    nVocab_exist=$(sed -n "$check_iniL,$check_finL p" "$input" | grep -c "START")
else
    # This is a new file; no anki card existing.
    newFile=true
fi

# Check if "TARGET DECK" exists in the input file
targetDeck=$(grep "TARGET DECK" "$input" | head -n 1)

if [ -z "$targetDeck" ]; then
    # If "TARGET DECK" does not exist, insert it under "## Anki Card"
    awk '/## Anki Card/ {print; print "TARGET DECK: DU::focus"; next} {print}' "$input" > temp_file && mv temp_file "$input"
    targetDeck="TARGET DECK: ${targetDeck_default}"
fi


# Calculate the initial and final number of line for the input vocabulary list, and also the total number of vocabularies. 
vocab_iniL=$(grep -n "##" "$input" | grep -i "$inputKey"| cut -d ':' -f 1| head -n 1 ) 
vocab_finL=$(grep -n "##" "$input" | grep -A 1 -i "$inputKey"| cut -d ':' -f 1| tail -n 1 ) 
temp_iniL=$(sed -n "$vocab_iniL,$vocab_finL p" "$input" | grep -n '|'| cut -d ':' -f 1 |head -n 1)
temp_finL=$(sed -n "$vocab_iniL,$vocab_finL p" "$input" | grep -n '|'| cut -d ':' -f 1 |tail -n 1)
nVocab=$(($temp_finL - $temp_iniL - 1))
vocab_iniL=$(($vocab_iniL + $temp_iniL - 1))
vocab_finL=$(($vocab_iniL + $nVocab + 1))

field=($(sed -n "$vocab_iniL,$vocab_iniL p" "$input" | sed 's/|//g'))
num_field=${#field[@]}

# use 2d array variable 
declare -a vocab_field

if [ "$newFile" = true ]
then 
    echo "Start to transform markdown table to Anki card"
    echo "Total vocabulary: ${nVocab}"
    echo "Card type: ${cardType}"
    echo "Default target deck: ${targetDeck_default}"

    output_iniL=$check_iniL
    sed -i '' "$output_iniL s/^/ \n/" "$input"

    output_iniL=$(($output_iniL+2))

    for ((n=1;n<=$nVocab;n++))
    do 
        echo 'START' > card.tmp 
        echo "$cardType" >> card.tmp 
        
        tmp_Line=$(($vocab_iniL+1+$n))

        for  ((m=1;m<=$num_field;m++))
        do 
            vocab_field[$m,$n]=$(sed -n "$tmp_Line,$tmp_Line p" "$input" | cut -d '|' -f $(($m+1)))
            echo ${field[$(($m-1))]}: ${vocab_field[$m,$n]} >> card.tmp 
        done 
        echo '' >> card.tmp 
        echo 'END' >> card.tmp 
        echo '' >> card.tmp 

        # echo "Appending at line: $output_iniL"
        # cat card.tmp
        # sed "$output_iniL r card.tmp" "$input" > temp_file && mv temp_file "$input"

        sed -i '' "$output_iniL r card.tmp" "$input"
        output_iniL=$(($output_iniL+$num_field+5))

    done 
elif [ "$newFile" = false ]
then 
    nVocab_rest=$(($nVocab-$nVocab_exist))
    echo "Updating transformation of markdown table from new vocabulary to Anki card"
    echo "Total vocab.: " $nVocab
    echo "Existing vocab.: " $nVocab_exist
    echo "New vocab.: " $nVocab_rest

    output_iniL=$check_finL
    n_iniL=$(($nVocab_exist+1))

    for ((n=$n_iniL;n<=$nVocab;n++))
    do 
        echo 'START' > card.tmp 
        echo "$cardType" >> card.tmp 
        
        tmp_Line=$(($vocab_iniL+$n+1))
        for  ((m=1;m<=$num_field;m++))
        do 
            vocab_field[$m,$n]=$(sed -n "$tmp_Line,$tmp_Line p" "$input" | cut -d '|' -f $(($m+1)))
            echo ${field[$(($m-1))]}: ${vocab_field[$m,$n]} >> card.tmp 
        done 
        echo '' >> card.tmp 
        echo 'END' >> card.tmp 
        echo '' >> card.tmp 

        # Add the new card to the end of the existing Anki card
        echo $output_iniL
        cat card.tmp
        sed -i '' "$output_iniL r card.tmp" "$input"
        output_iniL=$(($output_iniL+$num_field+5))

    done 
else 
    echo "Something goes wrong"
fi 

# rm -f card.tmp 
