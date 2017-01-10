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
gcloud components install beta

#clone MeerkatReader repo
cd ~
git clone https://github.com/bw4sz/MeerkatReader.git

cd MeerkatReader
# Assign user variables
USER=MeerkatReader
PROJECT=$(gcloud config list project --format "value(core.project)")
JOB_ID="MeerkatReader_${USER}_$(date +%Y%m%d_%H%M%S)"
BUCKET="gs://${PROJECT}-ml"
GCS_PATH="${BUCKET}/${USER}/${JOB_ID}"

#upload needed documents for analysis

#format testing and training data
sed "s|C:/Users/Ben/Documents/MeerkatReader|/${BUCKET}|g" cloudML/testing_data.csv > cloudML/testing_dataGCS.csv
sed "s|C:/Users/Ben/Documents/MeerkatReader|/${BUCKET}|g" cloudML/training_data.csv > cloudML/training_dataGCS.csv


#upload images for now, later write them directly to google cloud storage.
gsutil -m cp -r TrainingData $BUCKET

#dict file defniing classes, from R analysis.
gsutil cp cloudML/dict.txt $BUCKET/TrainingData
gsutil cp cloudML/testing_dataGCS.csv $BUCKET/TrainingData
gsutil cp cloudML/training_dataGCS.csv $BUCKET/TrainingData

#Data Path
EVAL_PATH=$BUCKET/TrainingData/testing_dataGCS.csv
TRAIN_PATH=$BUCKET/TrainingData/training_dataGCS.csv
DICT_FILE=$BUCKET/TrainingData/dict.txt

cd cloudML

# Preprocess the train set.
python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$TRAIN_PATH" \
  --output_path "${GCS_PATH}/preproc/train" \
  --cloud
#preprocess the evaluation set 
  python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$EVAL_PATH" \
  --output_path "${GCS_PATH}/preproc/eval" \
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
  --train_data_paths "${GCS_PATH}/preproc/train*"

 #should wait until its complete, check with
gcloud beta ml jobs describe $JOB_ID

#boot tensorboard, only during interactive use
#tensorboard --logdir=$GCS_PATH/trainnig/train --port=8080

#Model name needs to be clear on console.
MODEL_NAME=MeerkatReader
VERSION_NAME=v1  # for example
gcloud beta ml models create ${MODEL_NAME}
gcloud beta ml versions create --origin ${GCS_PATH}/training/model/ --model ${MODEL_NAME} ${VERSION_NAME}
gcloud beta ml versions set-default --model ${MODEL_NAME} ${VERSION_NAME}

# Copy a test image to local disk.
gsutil cp $BUCKET/TrainingData/0_1.jpg flower.jpg

# Create request message in json format.
python -c 'import base64, sys, json; img = base64.b64encode(open(sys.argv[1], "rb").read()); print json.dumps({"key":"0", "image_bytes": {"b64": img}})' flower.jpg &> request.json

# Call prediction service API to get classifications
gcloud beta ml predict --model ${MODEL_NAME} --json-instances request.json