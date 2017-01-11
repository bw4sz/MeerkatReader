#!/bin/bash 
#run from git bash
#start docker container, keep port open for tensorboard
#winpty docker run -it -p "127.0.0.1:8080:8080" --entrypoint=/bin/bash  gcr.io/cloud-datalab/datalab:local-20170108
#from shell

#make volume with auth if needed
#docker run -ti --entrypoint=/bin/bash --name gcloud-config gcr.io/cloud-datalab/datalab:local-20161227 gcloud init 

docker run -it --rm -p "127.0.0.1:8080:8080" --entrypoint=/bin/bash  gcr.io/cloud-datalab/datalab:local-20161227

#set  authentication, this needs to be done every time, for now.
#update gcloud tools
gcloud init --skip-diagnostics
gcloud auth application-default login
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

#Data Paths
declare -r EVAL_PATH=$BUCKET/TrainingData/testing_dataGCS.csv
declare -r TRAIN_PATH=$BUCKET/TrainingData/training_dataGCS.csv
declare -r DICT_FILE=$BUCKET/TrainingData/dict.txt

#Model properties
declare -r MODEL_NAME=MeerkatReader
declare -r VERSION_NAME=v1  # for example

echo
echo "Using job id: " $JOB_ID

#upload needed documents for analysis

#format testing and training data. Make a small dataset for now
sed "s|C:/Users/Ben/Documents/MeerkatReader|/${BUCKET}|g" cloudML/testing_data.csv | head -n 100 > cloudML/testing_dataGCS.csv
sed "s|C:/Users/Ben/Documents/MeerkatReader|/${BUCKET}|g" cloudML/training_data.csv | head -n 20 > cloudML/training_dataGCS.csv

cd cloudML

# Preprocess the train set.
python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$TRAIN_PATH" \
  --output_path "${GCS_PATH}/preproc/train"  

# Preprocess the eval set.
python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$EVAL_PATH" \
  --output_path "${GCS_PATH}/preproc/eval"   
  
 #Training locally, just as a test
 gcloud beta ml local train \
  --package-path=trainer \
  --module-name=trainer.task