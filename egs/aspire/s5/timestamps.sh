#https://chrisearch.wordpress.com/2017/03/11/speech-recognition-using-kaldi-extending-and-using-the-aspire-model/
#https://groups.google.com/forum/#!msg/kaldi-help/xTE20HaMLwk/LoI6PSNqCwAJ

# Get variables to help
source cmd.sh
source path.sh

# Create new ffmpeg wav file from input
ffmpeg -i $1 -acodec pcm_s16le -ac 1 -ar 8000 tmp.wav &> /dev/null 

# Execute model and save it to output.txt
online2-wav-nnet3-latgen-faster \
  --online=false \
  --do-endpointing=false \
  --frame-subsampling-factor=3 \
  --config=$KALDI_ROOT/egs/aspire/s5/exp/tdnn_7b_chain_online/conf/online.conf \
  --max-active=7000 \
  --beam=15.0 \
  --lattice-beam=6.0 \
  --acoustic-scale=1.0 \
  --word-symbol-table=$KALDI_ROOT/egs/aspire/s5/exp/tdnn_7b_chain_online/graph_pp/words.txt \
  exp/tdnn_7b_chain_online/final.mdl \
  exp/tdnn_7b_chain_online/graph_pp/HCLG.fst \
  'ark:echo id1 id1|' \
  'scp:echo id1 tmp.wav|' \
  'ark:|lattice-scale --acoustic-scale=10.0 ark:- ark:- | lattice-1best --lm-scale=11 ark:- ark:- | lattice-align-words $KALDI_ROOT/egs/aspire/s5/exp/tdnn_7b_chain_online/graph_pp/phones/word_boundary.int $KALDI_ROOT/egs/aspire/s5/exp/tdnn_7b_chain_online/final.mdl ark:- ark:- | nbest-to-ctm --frame-shift=0.01 --print-silence=false ark:- - | $KALDI_ROOT/egs/aspire/s5/utils/int2sym.pl -f 5 $KALDI_ROOT/egs/aspire/s5/exp/tdnn_7b_chain_online/graph_pp/words.txt > output.txt' &> /dev/null

# Print the output
cat output.txt | cut -c 7-

# Delete the output file and ffmpeg result
rm output.txt
rm tmp.wav
