#!/usr/bin/env bash

. scripts/vars.sh

echo "Checking directories ..."

# Check if 'nematus' is in working directory
if [ ! -d "$nematus_home" ]; then
  echo "Cloning https://github.com/Wilscos/nematus.git in your working directory (ex. DeepNLG/nematus) ..."
  git clone https://github.com/Wilscos/nematus.git
else
  echo "- nematus home: Check"
fi

# Check if 'mosesdecoder/scripts' is in working directory
if [ ! -d "$moses_scripts" ]; then
  echo "Cloning https://github.com/moses-smt/mosesdecoder.git in your working directory (DeepNLG/mosesdecoder/scripts) ..."
  git clone https://github.com/moses-smt/mosesdecoder.git
else
  echo "- moses scripts: Check"
fi

# Check if 'suwbword-nmt' is in working directory
if [ ! -d "$bpe_scripts" ]; then
  echo "Cloning https://github.com/rsennrich/subword-nmt.git in your working directory (ex. DeepNLG/subword-nmt) ..."
  git clone https://github.com/rsennrich/subword-nmt.git
else
  echo "- bpe scripts: Check"
fi

# Check if 'versions/v1.4/en' is in working directory
if [ ! -d "$corpus_dir" ]; then
  echo "There is no 'versions/v1.4/en' directory. Please check if the directory was downloaded
        correctly from the repository"
  exit
else
  echo "- corpus dir: Check"
fi

# Check if 'versions/v1.4/en' is in working directory
if [ ! -d $stanford_path ]; then
  echo "Downloading from https://stanfordnlp.github.io/CoreNLP/ in your working directory (ex. DeepNLG/stanford-corenlp-xx.xx.xx)"
  wget --no-check-certificate https://nlp.stanford.edu/software/stanford-corenlp-latest.zip
  unzip stanford-corenlp-latest.zip
  rm stanford-corenlp-latest.zip
else
  echo "- stanford path: Check"
fi

# preprocessing
for task in end2end ordering structing lexicalization
  do
    echo "Task $task"
    task_dir=$root_dir/$task
    if [ ! -d "$task_dir" ];
    then
      mkdir $task_dir
    fi

    echo "task=$task" > scripts/tmp
    echo "task_dir=$task_dir" >> scripts/tmp

    # preprocessing
    if [ "$task" == "lexicalization" ] || [ "$task" == "end2end" ];
    then
      if [ "$OSTYPE" == "msys" ]; then
        echo "Your OS: $OSTYPE"
        python $task/preprocess.py $corpus_dir $task_dir $stanford_path
        bash ./scripts/preprocess_txt.sh
      else
        python3 $task/preprocess.py $corpus_dir $task_dir $stanford_path
        bash ./scripts/preprocess_txt.sh
      fi
    else
      if [ "$OSTYPE" == "msys" ]; then
        echo "Your OS: $OSTYPE"
        python $task/preprocess.py $corpus_dir $task_dir
        bash ./scripts/preprocess.sh
      else
        python3 $task/preprocess.py $corpus_dir $task_dir
        bash ./scripts/preprocess.sh
      fi
    fi
  done

if [ ! -d "$root_dir/reg" ];
then
  mkdir $root_dir/reg
fi

if [ "$OSTYPE" == "msys" ]; then
  echo "Your OS: $OSTYPE"
  python reg/preprocess.py $corpus_dir $root_dir/reg $stanford_path
else
  python3 reg/preprocess.py $corpus_dir $root_dir/reg $stanford_path
fi

# training the models for ordering, structing, lexicalization and end-to-end
for task in end2end ordering structing lexicalization
  do
    echo "Task $task"
    task_dir=$root_dir/$task

    echo "task=$task" > scripts/tmp
    echo "task_dir=$task_dir" >> scripts/tmp

    for model in transformer rnn
      do
        echo "model=$model" >> scripts/tmp
        for run in 1 2 3
          do
            if [ ! -d "$task_dir/$model/$model$run" ];
            then
              mkdir $task_dir/$model/$model$run
            fi

            echo "run=$run" >> scripts/tmp
            bash ./scripts/$model.sh
          done
      done
  done

# training NeuralREG for Referring Expression Generation
if [ "$OSTYPE" == "msys" ]; then
  echo "Your OS: $OSTYPE"
  python reg/neuralreg.py --dynet-gpu
else
  python3 reg/neuralreg.py --dynet-gpu
fi

echo "Baselines Evaluation"
root_baseline=$root_dir/baselines

if [ ! -d "$root_baseline" ];
then
  mkdir $root_baseline
fi

for task in ordering structing lexicalization
  do
    root_task=$root_baseline/$task
    if [ ! -d "$root_task" ];
    then
      mkdir $root_task
    fi

    for baseline in rand major
      do
        for set in dev test
          do
            cp $root_dir/$task/data/$set.$eval $root_task
            if [ "$OSTYPE" == "msys" ]; then
              echo "Your OS: $OSTYPE"
              python $task/$baseline.py $root_task/$set.$eval $root_task/$baseline.$set $root_dir/$task/data/train.json
            else
              python3 $task/$baseline.py $root_task/$set.$eval $root_task/$baseline.$set $root_dir/$task/data/train.json
            fi
            ref=$root_dir/$task/data/references/$set.$trg
            refs=$ref"1 "$ref"2 "$ref"3 "$ref"4 "$ref"5"

            echo $task "-" $set "-" $baseline
            # evaluate with detokenized BLEU (same as mteval-v13a.pl)
            if [ "$task" = "lexicalization" ];
            then
              $nematus_home/data/multi-bleu-detok.perl $refs < $root_task/$baseline.$set
            else
              script_dir=`dirname $0`/scripts
              if [ "$OSTYPE" == "msys" ]; then
                echo "Your OS: $OSTYPE"
                python $script_dir/accuracy.py $ref $root_task/$baseline.$set
              else
                python3 $script_dir/accuracy.py $ref $root_task/$baseline.$set
              fi
            fi
          done
      done
  done

echo "Models Evaluation"
# Evaluation of the approaches for Discourse Ordering, text Structuring, Lexicalization, REG and End-to-End
for task in ordering structing lexicalization end2end
  do
    echo "Task $task"

    echo "task=$task" > scripts/tmp

    task_dir=$root_dir/$task
    echo "task_dir=$task_dir" >> scripts/tmp

    for model in transformer rnn
      do
        echo "model=$model" >> scripts/tmp
        # evaluating the model
        for set in dev test
          do
            echo "task=$task" > scripts/tmp
            echo "task_dir=$task_dir" >> scripts/tmp
            echo "model=$model" >> scripts/tmp
            echo "test_prefix=$set" >> scripts/tmp
            bash ./scripts/evaluate.sh
          done
      done
  done

echo "Baseline Pipeline"
root_pipeline=$root_dir/pipeline

if [ ! -d "$root_pipeline" ];
then
  mkdir $root_pipeline
fi
echo "root_pipeline=$root_pipeline" > scripts/tmp

for baseline in rand major
  do
    pipeline_dir=$root_pipeline/$baseline   # pipeline/rand and pipeline/major
    if [ ! -d "$pipeline_dir" ];
    then
      mkdir $pipeline_dir
    fi
    echo "pipeline_dir=$pipeline_dir" > scripts/tmp


    for set in dev test
      do
        cp $root_dir/end2end/data/$set.$eval $pipeline_dir
        task=end2end
        #echo "task=$task" > scripts/tmp

        task_dir=$root_dir/$task
        #echo "task_dir=$task_dir" >> scripts/tmp

        # ordering
        if [ "$OSTYPE" == "msys" ]; then
          echo "Your OS: $OSTYPE"
          python ordering/$baseline.py $pipeline_dir/$set.$eval $pipeline_dir/$set.ordering $root_dir/ordering/data/train.json
          python mapping.py $pipeline_dir/$set.$eval $pipeline_dir/$set.ordering ordering $pipeline_dir/$set.ordering.mapped
          # structing
          python structing/$baseline.py $pipeline_dir/$set.ordering.mapped $pipeline_dir/$set.structing $root_dir/structing/data/train.json
          python mapping.py $pipeline_dir/$set.$eval $pipeline_dir/$set.structing structing $pipeline_dir/$set.structing.mapped
          # lexicalization
          python lexicalization/$baseline.py $pipeline_dir/$set.structing.mapped $pipeline_dir/$set.lex $root_dir/structing/data/train.json
          # referring expression generation
          # TODO: But dev.lex and test.lex are not present in $root_dir/pipeline/rand
          python reg/generate.py $pipeline_dir/$set.lex $pipeline_dir/$set.ordering.mapped $pipeline_dir/$set.reg baseline path
          # textual realization
          # TODO: But dev.reg and test.reg are not present in $root_dir/pipeline/rand
          python realization.py $pipeline_dir/$set.reg $pipeline_dir/$set.realized $root_dir/lexicalization/surfacevocab.json
        else
          python3 ordering/$baseline.py $pipeline_dir/$set.$eval $pipeline_dir/$set.ordering $root_dir/ordering/data/train.json
          python3 mapping.py $pipeline_dir/$set.$eval $pipeline_dir/$set.ordering ordering $pipeline_dir/$set.ordering.mapped
          # structing
          python3 structing/$baseline.py $pipeline_dir/$set.ordering.mapped $pipeline_dir/$set.structing $root_dir/structing/data/train.json
          python3 mapping.py $pipeline_dir/$set.$eval $pipeline_dir/$set.structing structing $pipeline_dir/$set.structing.mapped
          # lexicalization
          python3 lexicalization/$baseline.py $pipeline_dir/$set.structing.mapped $pipeline_dir/$set.lex $root_dir/structing/data/train.json
          # referring expression generation
          python3 reg/generate.py $pipeline_dir/$set.lex $pipeline_dir/$set.ordering.mapped $pipeline_dir/$set.reg baseline path
          # textual realization
          python3 realization.py $pipeline_dir/$set.reg $pipeline_dir/$set.realized $root_dir/lexicalization/surfacevocab.json
        fi

        cat $pipeline_dir/$set.realized | \
        sed -r 's/\@\@ //g' |
        $moses_scripts/tokenizer/normalize-punctuation.perl -l $lng > $pipeline_dir/$set.out

        cat $pipeline_dir/$set.realized | \
        sed -r 's/\@\@ //g' |
        $moses_scripts/recaser/detruecase.perl |
        $moses_scripts/tokenizer/normalize-punctuation.perl -l $lng |
        $moses_scripts/tokenizer/detokenizer.perl -l $lng > $pipeline_dir/$set.out.postprocessed

        data_dir=$task_dir/data/references
        ref=$data_dir/$set.$trg
        refs=$ref"1 "$ref"2 "$ref"3 "$ref"4 "$ref"5"
        $nematus_home/data/multi-bleu-detok.perl $refs < $pipeline_dir/$set.out
      done
  done

echo "Pipeline Models"
echo "root_pipeline=$root_pipeline" > scripts/tmp

for model in transformer rnn
  do
    pipeline_dir=$root_pipeline/$model
    if [ ! -d "$pipeline_dir" ];
    then
      mkdir $pipeline_dir
    fi

    for set in dev test
      do
        cp $root_dir/end2end/data/$set.$eval $pipeline_dir

        # ordering
        task=ordering
        echo "pipeline_dir=$pipeline_dir" > scripts/tmp
        task_dir=$root_dir/$task
        echo "task_dir=$task_dir" >> scripts/tmp
        echo "model=$model" >> scripts/tmp
        echo "input=$set.$eval" >> scripts/tmp
        echo "output=$set.ordering" >> scripts/tmp
        bash ./scripts/pipeline.sh
        if [ "$OSTYPE" == "msys" ]; then
          echo "Your OS: $OSTYPE"
          python mapping.py $pipeline_dir/$set.$eval $pipeline_dir/$set.ordering.postprocessed ordering $pipeline_dir/$set.ordering.mapped
        else
          python3 mapping.py $pipeline_dir/$set.$eval $pipeline_dir/$set.ordering.postprocessed ordering $pipeline_dir/$set.ordering.mapped
        fi
        # structuring
        task=structing
        echo "pipeline_dir=$pipeline_dir" > scripts/tmp
        task_dir=$root_dir/$task
        echo "task_dir=$task_dir" >> scripts/tmp
        echo "model=$model" >> scripts/tmp
        echo "input=$set.ordering.mapped" >> scripts/tmp
        echo "output=$set.structing" >> scripts/tmp
        bash ./scripts/pipeline.sh
        if [ "$OSTYPE" == "msys" ]; then
          echo "Your OS: $OSTYPE"
          python mapping.py $pipeline_dir/$set.$eval $pipeline_dir/$set.structing.postprocessed structing $pipeline_dir/$set.structing.mapped
        else
          python3 mapping.py $pipeline_dir/$set.$eval $pipeline_dir/$set.structing.postprocessed structing $pipeline_dir/$set.structing.mapped
        fi

        # lexicalization
        task=lexicalization
        echo "pipeline_dir=$pipeline_dir" > scripts/tmp
        task_dir=$root_dir/$task
        echo "task_dir=$task_dir" >> scripts/tmp
        echo "model=$model" >> scripts/tmp
        echo "input=$set.structing.mapped" >> scripts/tmp
        echo "output=$set.lex" >> scripts/tmp
        bash ./scripts/pipeline.sh

        if [ "$OSTYPE" == "msys" ]; then
          echo "Your OS: $OSTYPE"
          # TODO: There is no data in these files
          python mapping.py $pipeline_dir/$set.ordering.mapped $pipeline_dir/$set.lex.postprocessed lexicalization $pipeline_dir/$set.lex.mapped
          # reg
          python reg/generate.py $pipeline_dir/$set.lex.postprocessed $pipeline_dir/$set.ordering.mapped $pipeline_dir/$set.reg neuralreg $root_dir/reg/model1.dy
          # textual realization
          python realization.py $pipeline_dir/$set.reg $pipeline_dir/$set.realized $root_dir/lexicalization/surfacevocab.json
        else
          python3 mapping.py $pipeline_dir/$set.ordering.mapped $pipeline_dir/$set.lex.postprocessed lexicalization $pipeline_dir/$set.lex.mapped
          # reg
          python3 reg/generate.py $pipeline_dir/$set.lex.postprocessed $pipeline_dir/$set.ordering.mapped $pipeline_dir/$set.reg neuralreg $root_dir/reg/model1.dy
          # textual realization
          python3 realization.py $pipeline_dir/$set.reg $pipeline_dir/$set.realized $root_dir/lexicalization/surfacevocab.json
        fi

        cat $pipeline_dir/$set.realized | \
        sed -r 's/\@\@ //g' |
        $moses_scripts/tokenizer/normalize-punctuation.perl -l $lng > $pipeline_dir/$set.out

        cat $pipeline_dir/$set.realized | \
        sed -r 's/\@\@ //g' |
        $moses_scripts/recaser/detruecase.perl |
        $moses_scripts/tokenizer/normalize-punctuation.perl -l $lng |
        $moses_scripts/tokenizer/detokenizer.perl -l $lng > $pipeline_dir/$set.out.postprocessed

        data_dir=$root_dir/end2end/data/references
        ref=$data_dir/$set.$trg
        refs=$ref"1 "$ref"2 "$ref"3 "$ref"4 "$ref"5"
        $nematus_home/data/multi-bleu-detok.perl $refs < $pipeline_dir/$set.out.postprocessed
      done
  done