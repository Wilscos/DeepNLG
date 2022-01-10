#!/usr/bin/env bash

# Source and target ($data_dir/corpus.src and $data_dir/corpus.trg)
src=src
trg=trg
eval="eval"
# Language
lng=en

echo "- Source corpus: corpus.$src"
echo "- Target corpus: corpus.$trg"
echo "- Validation data: dev.$eval"
echo "- Language: $lng"

# Current working directory
scripts_directory=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd -P )
working_directory="$( dirname "$scripts_directory")"
echo "Working directory $working_directory"

# Nematus home path
nematus_home=$working_directory/nematus
echo "- nematus home: $nematus_home"

# Moses home path
moses_home=$working_directory/mosesdecoder
# Moses' scripts path
moses_scripts=$moses_home/scripts
echo "- moses scripts: $moses_scripts"

# Path to suwbword-nmt directory
bpe_scripts=$working_directory/subword-nmt/subword_nmt
echo "- bpe scripts: $bpe_scripts"

# Path to the corpus directory, the directory storing the data
corpus_dir=$working_directory/versions/v1.4/en
echo "- corpus dir: $corpus_dir"

# Path to the Stanford parser (StanfordCoreNLP latest version)
stanford_corenlp=( stanford* )
stanford_path="$working_directory/$stanford_corenlp"
echo "- stanford path: $stanford_path"

# Root path where the results are stored
root_dir=$working_directory/results
# Checking if the root exists. If it doesn't exist it's created
if [ ! -d "$root_dir" ]; then
  mkdir "$root_dir"
else
  echo "- root dir (to store results): $root_dir"
fi