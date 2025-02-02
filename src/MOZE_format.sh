#!/bin/bash 

# Main function to execute all tasks
main() {
  local csv="$1"

  # Check if the file exists
  check_file_exists "$csv"

  # Step 1: Replace headers
  replace_headers "$csv"

  # Step 2: Reformat dates
  reformat_dates "$csv"

  # Step 3: Translate RecordType and MainCategory columns
  translate_columns "$csv"

  echo "CSV file updated successfully."
}

# Function to check if the input file exists
check_file_exists() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Error: File $file does not exist."
    exit 1
  fi
}

# Function to replace the first row with English headers
replace_headers() {
  local file="$1"
  local temp_file="temp.csv"
  local headers="Account,Currency,RecordType,MainCategory,Subcategory,Amount,Fee,Discount,Name,Merchant,Date,Time,Project,Description,Tags,Recipient_Counterparty"

  {
    echo "$headers"    # Add the new headers
    tail -n +2 "$file" # Append the rest of the file, skipping the first line
  } > "$temp_file"

  mv "$temp_file" "$file"
}

# Function to reformat dates from DD.MM.YY to YYYY-MM-DD
reformat_dates() {
  local file="$1"
  local temp_file="temp.csv"

  sed -E 's/([0-9]{2})\.([0-9]{2})\.([0-9]{2})/20\3-\2-\1/g' "$file" > "$temp_file"
  mv "$temp_file" "$file"
}

# Function to translate specific columns
translate_columns() {
  local file="$1"
  local temp_file="temp.csv"

  sed -E '
    # Translate RecordType column
    s/支出/Expense/g
    s/收入/Income/g
    s/轉出/Transfer Out/g
    s/轉入/Transfer In/g
    s/餘額調整/Balance Adjustment/g

    # Translate MainCategory column
    s/購物/Shopping/g
    s/轉帳/Transfer/g
    s/飲食/Food \& Beverage/g
    s/娛樂/Entertainment/g
    s/家居/Household/g
  ' "$file" > "$temp_file"

  mv "$temp_file" "$file"
}



# Entry point
main "$1"
