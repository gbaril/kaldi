#!/bin/bash

#https://chrisearch.wordpress.com/2017/03/11/speech-recognition-using-kaldi-extending-and-using-the-aspire-model/
#https://groups.google.com/forum/#!msg/kaldi-help/xTE20HaMLwk/LoI6PSNqCwAJ

# Generate files id
new_id=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
wav="/tmp/$new_id.wav"
output="/tmp/$new_id.txt"

# Get variables to help
export dir=$(cd `dirname $0` && pwd)

source $dir/cmd.sh
source $dir/path.sh

# Create new ffmpeg wav file from input
ffmpeg -i $1 -acodec pcm_s16le -ac 1 -ar 8000 $wav &> /dev/null 

# Execute model and save it to output.txt
online2-wav-nnet3-latgen-faster \
  --online=false \
  --do-endpointing=false \
  --frame-subsampling-factor=3 \
  --config=$TDNN/conf/online.conf \
  --max-active=7000 \
  --beam=15.0 \
  --lattice-beam=6.0 \
  --acoustic-scale=1.0 \
  --word-symbol-table=$TDNN/graph_pp/words.txt \
  $dir/exp/tdnn_7b_chain_online/final.mdl \
  $dir/exp/tdnn_7b_chain_online/graph_pp/HCLG.fst \
  'ark:echo id1 id1|' \
  'scp:echo id1 '"$wav"'|' \
  'ark:|lattice-scale --acoustic-scale=10.0 ark:- ark:- | lattice-1best --lm-scale=11 ark:- ark:- | lattice-align-words $TDNN/graph_pp/phones/word_boundary.int $TDNN/final.mdl ark:- ark:- | nbest-to-ctm --frame-shift=0.01 --print-silence=false ark:- - | $dir/utils/int2sym.pl -f 5 $TDNN/graph_pp/words.txt > '"$output" &> /dev/null

# Print the output
cat $output | cut -c 7-

# Delete the output file and ffmpeg result
rm $output
rm $wav
