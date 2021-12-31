#!/usr/bin/env bash

# Current working directory
scripts_directory=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd -P )
working_directory="$( dirname "$scripts_directory")"

# Nematus home path
nematus_home=$working_directory/nematus
echo "- nematus home: $nematus_home"

# Moses home path
moses_home=$working_directory/mosesdecoder
# Moses' scripts path
moses_scripts=$moses_home/scripts
echo "- moses scripts: $moses_scripts"

# Path to suwbword-nmt directory
bpe_scripts=$working_directory/subword-nmt
echo "- bpe scripts: $bpe_scripts"

# Path to the corpus directory, the directory storing the data
corpus_dir=$working_directory/versions/v1.4/en
echo "- corpus dir: $corpus_dir"

# Path to the Stanford parser (StanfordCoreNLP latest version 4.3.2)
stanford_path=$working_directory/stanford-corenlp-4.3.2
echo "- stanford path: $stanford_path"

# Root path where the results are stored
root_dir=$working_directory/results
# Checking if the root exists. If it doesn't exist it's created
if [ ! -d "$root_dir" ]; then
  mkdir "$root_dir"
else
  echo "- root dir (to store results): $root_dir"
fi