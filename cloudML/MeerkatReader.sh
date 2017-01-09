#!/bin/bash 
#BootCloudML
#start docker container, keep port open for tensorboard
docker run -it -p "127.0.0.1:8080:8080" --entrypoint=/bin/bash gcr.io/cloud-datalab/datalab:local

#set  authentication, this needs to be done every time, for now.
gcloud init
gcloud config list

#clone MeerkatReader repo
git clone https://github.com/bw4sz/MeerkatReader.git

cd MeerkatReader
# Assign user variables
USER=MeerkatReader
PROJECT=$(gcloud beta config list project --format "value(core.project)")
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

# Preprocess the eval set.
python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$EVAL_PATH" \
  --output_path "${GCS_PATH}/preproc/eval" \
  --cloud

  echo Preprocessing complete
# Preprocess the train set.
python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$TRAIN_PATH" \
  --output_path "${GCS_PATH}/preproc/train" \
  --cloud
  
  echo Submitting Training Job
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

# Monitor training logs.
gcloud beta ml jobs stream-logs "$JOB_ID"

#Model name needs to be clear on console.
MODEL_NAME=MeerkatReader
VERSION_NAME=v1  # for example
gcloud beta ml models create ${MODEL_NAME}
gcloud beta ml models versions create --origin ${GCS_PATH}/training/model/ --model ${MODEL_NAME} ${VERSION_NAME}
gcloud beta ml models versions set-default --model ${MODEL_NAME} ${VERSION_NAME}

# Copy a test image to local disk.
gsutil cp $BUCKET/TrainingData/0_1.jpg flower.jpg

# Create request message in json format.
python -c 'import base64, sys, json; img = base64.b64encode(open(sys.argv[1], "rb").read()); print json.dumps({"key":"0", "image_bytes": {"b64": img}})' flower.jpg &> request.json

sleep 5m

# Call prediction service API to get classifications
gcloud beta ml predict --model ${MODEL_NAME} --json-instances request.json