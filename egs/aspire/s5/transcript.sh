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

# Get variables to help
source cmd.sh
source path.sh

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
  'ark:|lattice-best-path --acoustic-scale=1.0 ark:- ark,t:- | $KALDI_ROOT/egs/aspire/s5/utils/int2sym.pl -f 2- $KALDI_ROOT/egs/aspire/s5/exp/tdnn_7b_chain_online/graph_pp/words.txt > '"$output" &> /dev/null

sentence=$(cat $output | cut -c 7-)

echo $(python $dir/ner.py "$sentence")

rm $output
rm $wav
