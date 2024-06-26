#!/bin/bash

#PBS -N xtend-train
#PBS -M gthakkar@m.ffzg.hr
#PBS -m be
#PBS -j oe
#PBS -q gpu-test	
#PBS -l select=1:ncpus=2:mem=1GB:ngpus=1
#PBS -l place=scatter

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
export NEOX_DATA_PATH=/mnt/sda/data/enwiki8 #or wherever your data is stored on your system
export NEOX_CHECKPOINT_PATH=/mnt/sda/checkpoints

# Launch training
apptainer run --nv xtend.sif  deepy.py train.py configs/pythia/160M.yml
