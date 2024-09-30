#!/bin/bash

# Read the list of notebooks to skip from the JSON file
SKIP_NOTEBOOKS=$(python -c "import json; print('\n'.join(json.load(open('docs/notebooks_no_execution.json'))))")

# Get the working directory or specific notebook file from the input parameter
WORKING_DIRECTORY=$1

# Function to execute a single notebook
execute_notebook() {
    file="$1"
    echo "Starting execution of $file"
    start_time=$(date +%s)
    if ! output=$(time poetry run jupyter nbconvert --to notebook --execute $file 2>&1); then
        end_time=$(date +%s)
        execution_time=$((end_time - start_time))
        echo "Error in $file. Execution time: $execution_time seconds"
        echo "Error details: $output"
        exit 1
    fi
    end_time=$(date +%s)
    execution_time=$((end_time - start_time))
    echo "Finished $file. Execution time: $execution_time seconds"
}

export -f execute_notebook

# Determine the list of notebooks to execute
if [ "$WORKING_DIRECTORY" == "all" ]; then
    notebooks=$(find docs/docs/tutorials -name "*.ipynb" | grep -v ".ipynb_checkpoints" | grep -vFf <(echo "$SKIP_NOTEBOOKS"))
else
    notebooks=$(find "$WORKING_DIRECTORY" -name "*.ipynb" | grep -v ".ipynb_checkpoints" | grep -vFf <(echo "$SKIP_NOTEBOOKS"))
fi

# Execute notebooks sequentially
for file in $notebooks; do
    execute_notebook "$file"
done