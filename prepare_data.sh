#!/bin/bash

#PBS -N xtend-data
#PBS -M gthakkar@m.ffzg.hr
#PBS -m be
#PBS -j oe
#PBS -q cpu	
#PBS -l select=1:ncpus=4:mem=32GB


cd ${PBS_O_WORKDIR}
echo "-1-"
echo ${PBS_NODEFILE} 
echo "-2-"
echo $(wc -l 0<${PBS_NODEFILE})
echo "-3-"
cat ${PBS_NODEFILE}
echo "-4-"

################################################################
# Hostfile generation
################################################################
GPUS_PER_NODE=1
mkdir -p hostfiles
# need to add the current slurm jobid to hostfile name so that we don't add to previous hostfile
hostfile=hostfiles/hosts_${PBS_JOBID}

# be extra sure we aren't appending to a previous hostfile
rm $hostfile &> /dev/null
# loop over the node names
for i in `cat $PBS_NODEFILE`
do
    # add a line to the hostfile
    echo $i slots=$GPUS_PER_NODE >>$hostfile
done

################################################################
export HOSTNAMES=`cat "$PBS_NODEFILE"`
export MASTER_ADDR=$(cat "$PBS_NODEFILE" | head -n 1)
export MASTER_PORT=12802
export COUNT_NODE=`cat "$PBS_NODEFILE" | wc -l`

# Tell DeepSpeed where to find our generated hostfile via DLTS_HOSTFILE
export DLTS_HOSTFILE=hostfile

# Prepare

# apptainer run --nv xtend.sif  prepare_data.py -d ./data

# apptainer run --nv xtend.sif tools/preprocess_data.py
# \ --input ./data/CLASSLA-web.hr.1.0.jsonl 
# \ --output-prefix ./data/classla 
# \ --vocab-file data/gpt2-vocab.json 
# \ --merge-file data/gpt2-merges.txt 
# \ --append-eod 



apptainer run --nv xtend.sif tools/datasets/preprocess_data.py --input ./data/CLASSLA-web.hr.1.0.jsonl --output-prefix ./data/classla  --vocab-file data/gpt2-vocab.json  --merge-file data/gpt2-merges.txt  --tokenizer-type GPT2BPETokenizer   --append-eod 