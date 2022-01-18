# Pipeline vs. End-to-End Architecture to Neural Data-to-Text

This is the code used to obtained the results reported in the manuscript "Neural data-to-text generation: 
A comparison between pipeline and end-to-end architectures". 
[Link to the article available on arXiv](https://arxiv.org/abs/1908.09022v1).

The file `main.sh` is the main script of this project. You may run it to extract the intermediate representations
from the data, to train the models, to evaluate each step of the pipeline approach (reported in Section 6 of the paper) 
as well as to generate text from the non-linguistic approach based on each model (reported in Section 7 of the paper).

To run the script, first install the Python dependencies by running the following command:

`
pip install > requirements.txt
`

## Main differences from the main repository

- Solve some issues with the requirements. The [requirements.txt](requirements.txt) file has been updated accordingly;
- The paths are all relative and not absolute. For this reason, there is no need to change the paths in the 
  [scripts/vars](scripts/vars) file. Instead of calling this file, the scripts will call 
  [scripts/vars.sh](scripts/vars.sh). Every time the script is called it will echo/print the paths to the 
  needed directories;
- You don't need to clone the dependencies: [Moses](https://github.com/moses-smt/mosesdecoder), 
  [Nematus](https://github.com/EdinburghNLP/nematus) and [Suboword NMT](https://github.com/rsennrich/subword-nmt).
  If these are not in Master (DeepNLG/), then they will be cloned in this directory once the main script is called;
- The scripts should now work also on Windows;
- Fixed errors with some scripts where there were encoding issues;
- Also fixed some error that kept occurring from the [Nematus](https://github.com/EdinburghNLP/nematus) dependency. 
  This is why [my forked repository](https://github.com/Wilscos/nematus) is cloned instead of the original one.

## How to run the repository

To execute everything without issues I suggest running the main script as follows:

`
bash ./main.sh
`

## More data

The augmented version of the WebNLG corpus is available [here](versions/v1.4). To see information about the evaluation, 
go to [the evaluation folder](evaluation/).

# Reproducibility

For reproducibility reasons, the data used in the experiments can be found [here](https://github.com/ThiagoCF05/DeepNLG/tree/master/evaluation/data), whereas the results are [here](https://github.com/ThiagoCF05/DeepNLG/tree/master/evaluation/results).
