#!/usr/bin/env bash

# Current working directory
working_directory=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd -P )
echo "- current working directory: $working_directory"

# Nematus home path
nematus_home=$( python main_repos_finder.py "$working_directory" nematus )
echo "- nematus home: $nematus_home"

# Moses home path
moses_home=$( python main_repos_finder.py "$working_directory" moses )
# Moses' scripts path
moses_scripts=$moses_home/scripts
echo "- moses scripts: $moses_scripts"

# Path to suwbword-nmt directory
bpe_scripts=$( python main_repos_finder.py "$working_directory" subword-nmt )
echo "- bpe scripts: $bpe_scripts"

# Path to the corpus directory, the directory storing the data
corpus_dir=$working_directory/versions/v1.4/en
echo "- corpus dir: $corpus_dir"

# Path to the Stanford parser (StanfordCoreNLP latest version 4.3.2)
# TODO: Update the python script to simply find 'stanford-corenlp' (need a regex, probably)
stanford_path=$( python main_repos_finder.py "$working_directory" stanford-corenlp-4.3.2 )
echo "- stanford path: $stanford_path"

# Root path where the results are stored
root_dir=$working_directory/results
# Checking if the root exists. If it doesn't exist it's created
if [ ! -d "$root_dir" ]; then
  mkdir "$root_dir"
else
  echo "- root dir (to store results): $root_dir"
fi