#!/bin/sh

[ -f env.sh ] && . env.sh

java -cp target/twitter-naive-bayes-example-1.0-jar-with-dependencies.jar \
  com.chimpler.example.bayes.TweetTSVToSeq data/tweets-train.tsv tweets-seq
hadoop fs -rmr \*
hadoop fs -put  tweets-seq tweets-seq
mahout seq2sparse -i tweets-seq -o tweets-vectors
mahout split -i tweets-vectors/tfidf-vectors --trainingOutput train-vectors \
    --testOutput test-vectors --randomSelectionPct 40 --overwrite \
    --sequenceFiles -xm sequential
mahout trainnb -i train-vectors -el -li labelindex -o model -ow -c
mahout testnb -i train-vectors -m model -l labelindex -ow -o tweets-testing -c
mahout testnb -i test-vectors -m model -l labelindex -ow -o tweets-testing -c
hadoop fs -get labelindex labelindex
hadoop fs -get model model
hadoop fs -get tweets-vectors/dictionary.file-0 dictionary.file-0
hadoop fs -getmerge tweets-vectors/df-count df-count
