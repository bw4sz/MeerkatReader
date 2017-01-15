#!/bin/bash 
#run from git bash
#create docker container for authentication
#docker run -t -i --entrypoint=/bin/bash  --name gcloud-config bw4sz/cloudml gcloud init

#from shell
docker run -it --volumes-from gcloud-config --rm -p "127.0.0.1:8080:8080" --entrypoint=/bin/bash  bw4sz/cloudml

# use the correct conda space
source activate cloudml
#gcloud init --skip-diagnostics
#auth for tensorboard?
#gcloud auth application-default login
#gcloud config list

#clone MeerkatReader repo
cd ~
git clone https://github.com/bw4sz/MeerkatReader.git

cd MeerkatReader
# Assign user variables
declare USER=MeerkatReader
declare PROJECT=$(gcloud config list project --format "value(core.project)")
declare JOB_ID="MeerkatReader_${USER}_$(date +%Y%m%d_%H%M%S)"
declare BUCKET="gs://${PROJECT}-ml"
declare GCS_PATH="${BUCKET}/${USER}/${JOB_ID}"

#Data Paths
declare EVAL_PATH=$BUCKET/TrainingData/testing_dataGCS.csv
declare TRAIN_PATH=$BUCKET/TrainingData/training_dataGCS.csv
declare DICT_FILE=$BUCKET/TrainingData/dict.txt

#Model properties
declare MODEL_NAME=MeerkatReader
declare VERSION_NAME=v2  # for example

echo
echo "Using job id: " $JOB_ID
#set -v -e

#upload needed documents for analysis

#format testing and training data. Make a small dataset for now
sed "s|C:/Users/Ben/Documents/MeerkatReader|${BUCKET}|g" cloudML/testing_data.csv  > cloudML/testing_dataGCS.csv
sed "s|C:/Users/Ben/Documents/MeerkatReader|${BUCKET}|g" cloudML/training_data.csv > cloudML/training_dataGCS.csv

#upload images for now, later write them directly to google cloud storage.
#gsutil -m cp -r TrainingData $BUCKET

#dict file defining classes, from R analysis.
gsutil cp cloudML/dict.txt $BUCKET/TrainingData
gsutil cp cloudML/testing_dataGCS.csv $BUCKET/TrainingData
gsutil cp cloudML/training_dataGCS.csv $BUCKET/TrainingData

#into git directory
cd cloudML

# Preprocess the train set.
python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$TRAIN_PATH" \
  --output_path "${GCS_PATH}/preproc/train" \
  --num_workers 7 \
  --cloud
  
#preprocess the evaluation set 
  python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$EVAL_PATH" \
  --output_path "${GCS_PATH}/preproc/eval" \
  --num_workers 7 \
  --cloud

  # Submit training job.
gcloud beta ml jobs submit training "$JOB_ID" \
  --module-name trainer.task \
  --package-path trainer \
  --staging-bucket "$BUCKET" \
  --region us-central1 \
  -- \
  --output_path "${GCS_PATH}/training" \
  --eval_data_paths "${GCS_PATH}/preproc/eval*" \
  --train_data_paths "${GCS_PATH}/preproc/train*" \
  --label_count 13

 #should wait until its complete, check with
gcloud beta ml jobs describe $JOB_ID

#boot tensorboard, only during interactive use
#gcloud auth application-default login
#tensorboard --logdir=$GCS_PATH/training/train --port=8080

#Model name needs to be clear on console.
#if the first run
#gcloud beta ml models create ${MODEL_NAME}
gcloud beta ml versions create --origin ${GCS_PATH}/training/model/ --model ${MODEL_NAME} ${VERSION_NAME}
gcloud beta ml versions set-default --model ${MODEL_NAME} ${VERSION_NAME}

# Copy a test image to local disk.
gsutil cp $BUCKET/TrainingData/0_1.jpg flower.jpg

# Create request message in json format.
python -c 'import base64, sys, json; img = base64.b64encode(open(sys.argv[1], "rb").read()); print json.dumps({"key":"0", "image_bytes": {"b64": img}})' flower.jpg &> request.json

#takes a moment to boot
sleep 10m

# Call prediction service API to get classifications
gcloud beta ml predict --model ${MODEL_NAME} --json-instances request.json