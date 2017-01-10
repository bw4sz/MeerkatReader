#!/bin/bash 
#run from git bash
#start docker container, keep port open for tensorboard
#winpty docker run -it -p "127.0.0.1:8080:8080" --entrypoint=/bin/bash  gcr.io/cloud-datalab/datalab:local-20170108
#from shell
docker run -it -p "127.0.0.1:8080:8080" --entrypoint=/bin/bash  gcr.io/cloud-datalab/datalab:local-20161227

#set  authentication, this needs to be done every time, for now.
#update gcloud tools
gcloud init
gcloud config list

#clone MeerkatReader repo
cd ~
git clone https://github.com/bw4sz/MeerkatReader.git

cd MeerkatReader
# Assign user variables
declare -r USER=MeerkatReader
declare -r PROJECT=$(gcloud config list project --format "value(core.project)")
declare -r JOB_ID="MeerkatReader_${USER}_$(date +%Y%m%d_%H%M%S)"
declare -r BUCKET="gs://${PROJECT}-ml"
declare -r GCS_PATH="${BUCKET}/${USER}/${JOB_ID}"

#upload needed documents for analysis

#format testing and training data
#just grab a tiny dataset to play with
sed "s|C:/Users/Ben/Documents/MeerkatReader|/root/MeerkatReader/cloudML|g" cloudML/testing_data.csv | head -n 20 > cloudML/small_eval.csv
sed "s|C:/Users/Ben/Documents/MeerkatReader|/root/MeerkatReader/cloudML|g" cloudML/training_data.csv | head -n 10 > cloudML/small_train.csv

#Data Path
EVAL_PATH=/root/MeerkatReader/cloudML/small_eval.csv
TRAIN_PATH=/root/MeerkatReader/cloudML/small_train.csv
DICT_FILE=/root/MeerkatReader/cloudML/dict.txt

cd cloudML

# Preprocess the train set.
python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$TRAIN_PATH" \
  --output_path "/root/MeerkatReader/cloudML/preproc/train" 

# Preprocess the eval set.
python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$EVAL_PATH" \
  --output_path "/root/MeerkatReader/cloudML/preproc/eval"  
  
 #Training locally, just as a test
 gcloud beta ml local train \
  --package-path=trainer \
  --module-name=trainer.task