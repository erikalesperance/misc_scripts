#!/bin/bash
#bash script to concatenate fastQ reads (pooling them based on phenotypes) prior to alignment to genome 

#input file containing phenotypes and corresponding IDs of reads (excluding _R1.fq.gz), see phenotypes.txt in same repository for example 
MAPPING_FILE="phenotypes.txt"

#directory where the input data is stored
INPUT_DIR="s1_fastqc"

#directory where the output should be stored
OUTPUT_BASE_DIR="phenotypes"

#read each line from the mapping file
while IFS=: read -r PHENOTYPE READ_IDS; do
    echo "Processing phenotype: $PHENOTYPE"

    #create a subdirectory for the current phenotype in the output directory
    PHENOTYPE_DIR="${OUTPUT_BASE_DIR}/${PHENOTYPE}"
    mkdir -p "$PHENOTYPE_DIR"

    #initialize output files for concatenation
    R1_OUTPUT="${PHENOTYPE_DIR}/${PHENOTYPE}_R1.fq.gz"
    R2_OUTPUT="${PHENOTYPE_DIR}/${PHENOTYPE}_R2.fq.gz"

    #remove any existing output files for this phenotype
    > "$R1_OUTPUT"
    > "$R2_OUTPUT"

    #convert comma-separated read IDs into an array
    IFS=',' read -r -a IDS_ARRAY <<< "$READ_IDS"

    #concatenate R1 and R2 files in order
    for ID in "${IDS_ARRAY[@]}"; do
        R1_FILE="${INPUT_DIR}/${ID}_R1.fq.gz"
        R2_FILE="${INPUT_DIR}/${ID}_R2.fq.gz"

        if [[ -f "$R1_FILE" && -f "$R2_FILE" ]]; then
            echo "Adding $R1_FILE and $R2_FILE to $PHENOTYPE"
            cat "$R1_FILE" >> "$R1_OUTPUT"
        else
            echo "Warning: Missing files for $ID (Expected $R1_FILE and $R2_FILE)"
        fi
    done
done < "$MAPPING_FILE"

echo "Concatenation complete! Output files are organized in $OUTPUT_BASE_DIR"


