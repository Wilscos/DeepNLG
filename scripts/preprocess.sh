#!/bin/bash
# Distributed under MIT license

# this sample script preprocesses a sample corpus, including tokenization,
# truecasing, and subword segmentation.
# for application to a different language pair,
# change source and target prefix, optionally the number of BPE operations,

script_dir=`dirname $0`
# temporary variables
. $script_dir/tmp
# variables (toolkits; source and target language)
. scripts/vars.sh

main_dir=$script_dir/..
data_dir=$task_dir/data

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$moses_scripts/training/clean-corpus-n.perl $data_dir/train $src $trg $data_dir/corpus 1 80

# build network dictionaries for separate source / target vocabularies
if [ "$OSTYPE" == "msys" ]; then
  echo "Your OS: $OSTYPE"
  python $nematus_home/data/build_dictionary.py $data_dir/corpus.$src $data_dir/corpus.$trg
else
  python3 $nematus_home/data/build_dictionary.py $data_dir/corpus.$src $data_dir/corpus.$trg
fi

# build network dictionary for combined source + target vocabulary (for use
# with tied encoder-decoder embeddings)
cat $data_dir/corpus.$src $data_dir/corpus.$trg > $data_dir/corpus.both
if [ "$OSTYPE" == "msys" ]; then
  echo "Your OS: $OSTYPE"
  python $nematus_home/data/build_dictionary.py $data_dir/corpus.both
else
  python3 $nematus_home/data/build_dictionary.py $data_dir/corpus.both
fi