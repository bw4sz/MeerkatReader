#!/bin/bash 
#BootCloudML
#start docker container, keep port open for tensorboard
docker run -it -p "127.0.0.1:8080:8080" --entrypoint=/bin/bash gcr.io/cloud-datalab/datalab:local

#set  authentication, this needs to be done every time, for now.
gcloud auth application-default login
gcloud config list
gcloud init

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
sed "s|C:/Users/Ben/Documents/MeerkatReader|/${BUCKET}|g" TrainingData/TrainingData.csv > TrainingDataGCS.csv

#split into random 80-20 training testing.
#get total number of tn=wc TrainingDataGCS.csv -l
tn=$(wc TrainingDataGCS.csv -l)[0]
num=$[tn*.8]
shuf input_file > random.csv
head random.csv tn > Train_set.csv
tail random.csv  > Train_set.csv
rm random.csv

#upload images for now, later write them directly to google cloud storage.
gsutil -m cp -r TrainingData $BUCKET

#dict file defniing classes, from R analysis.
gsutil cp cloudML/dict.txt $BUCKET

#Data Path
EVAL_PATH=$BUCKET/TrainingData/TrainingData.csv 
TRAIN_PATH=$BUCKET/TrainingData/TrainingData.csv 
DICT_FILE=$BUCKET/dict.txt

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

#needs to wait better here, runs too fast.

#Model name needs to be clear on console.
MODEL_NAME=MeerkatReader
VERSION_NAME=v1  # for example
gcloud beta ml models create ${MODEL_NAME}
gcloud beta ml models versions create --origin ${GCS_PATH}/training/model/ --model ${MODEL_NAME} ${VERSION_NAME}
gcloud beta ml models versions set-default --model ${MODEL_NAME} ${VERSION_NAME}

# Copy a test image to local disk.
gsutil cp gs://cloud-ml-data/img/flower_photos/tulips/4520577328_a94c11e806_n.jpg flower.jpg

# Create request message in json format.
python -c 'import base64, sys, json; img = base64.b64encode(open(sys.argv[1], "rb").read()); print json.dumps({"key":"0", "image_bytes": {"b64": img}})' flower.jpg &> request.json

sleep 5m

# Call prediction service API to get classifications
gcloud beta ml predict --model ${MODEL_NAME} --json-instances request.json