#!/bin/bash 

#from shell
docker run -it --rm -p "127.0.0.1:8080:8080" bw4sz/cloudml

#usage reporting very slow
gcloud config set disable_usage_reporting True

#give credentials (still working on this)
gcloud init

 
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

#Model properties
declare MODEL_NAME=MeerkatReader
declare VERSION_NAME=v3  # for example

echo
echo "Using job id: " $JOB_ID
#set -v -e

#format testing and training data. Make a small dataset for now
sed "s|C:/Users/Ben/Dropbox/MeerkatReader/Output/|${BUCKET}/TrainingData/|g" BuildModel/cloudML/testing_data.csv  > BuildModel/cloudML/testing_dataGCS.csv
sed "s|C:/Users/Ben/Dropbox/MeerkatReader/Output/|${BUCKET}/TrainingData/|g" BuildModel/cloudML/training_data.csv > BuildModel/cloudML/training_dataGCS.csv

#upload needed documents for analysis
#upload from MeerkatReader
gsutil cp BuildModel/cloudML/dict.txt $BUCKET/TrainingData/
gsutil cp BuildModel/cloudML/testing_dataGCS.csv $BUCKET/TrainingData/
gsutil cp BuildModel/cloudML/training_dataGCS.csv $BUCKET/TrainingData/

#Declare data paths
declare EVAL_PATH=$BUCKET/TrainingData/testing_dataGCS.csv
declare TRAIN_PATH=$BUCKET/TrainingData/training_dataGCS.csv
declare DICT_FILE=$BUCKET/TrainingData/dict.txt

#upload images for now, later write them directly to google cloud storage.
#gsutil -m cp -r C:/Users/Ben/Dropbox/MeerkatReader/Output/* gs://api-project-773889352370-ml/TrainingData/
#make files public readable? Still struggling with credentials
#gsutil -m acl set -R -a public-read gs://api-project-773889352370-ml/TrainingData

#into git directory
cd BuildModel/cloudML

# Preprocess the train set.
python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$TRAIN_PATH" \
  --output_path "${GCS_PATH}/preproc/train" \
  --num_workers 8 \
  --cloud
  
#preprocess the evaluation set 
  python trainer/preprocess.py \
  --input_dict "$DICT_FILE" \
  --input_path "$EVAL_PATH" \
  --output_path "${GCS_PATH}/preproc/eval" \
  --num_workers 8 \
  --cloud

  # Submit training job
    #number of classes (CHANGE MANUALLY FOR NOW)

gcloud beta ml jobs submit training "$JOB_ID" \
  --module-name trainer.task \
  --package-path trainer \
  --staging-bucket "$BUCKET" \
  --region us-central1 \
  -- \
  --output_path "${GCS_PATH}/training" \
  --eval_data_paths "${GCS_PATH}/preproc/eval*" \
  --train_data_paths "${GCS_PATH}/preproc/train*" \
  --label_count 22

 #should wait until its complete, check with
gcloud beta ml jobs describe $JOB_ID

#Model name needs to be clear on console.
#if the first run
#gcloud beta ml models create ${MODEL_NAME}
gcloud beta ml versions create --origin ${GCS_PATH}/training/model/ --model ${MODEL_NAME} ${VERSION_NAME}
gcloud beta ml versions set-default --model ${MODEL_NAME} ${VERSION_NAME}

# Copy a test image to local disk.
gsutil cp $BUCKET/TrainingData/604_6.jpg flower.jpg

# Create request message in json format.
python -c 'import base64, sys, json; img = base64.b64encode(open(sys.argv[1], "rb").read()); print json.dumps({"key":"0", "image_bytes": {"b64": img}})' flower.jpg &> request.json

#takes a moment to boot
sleep 10m

# Call prediction service API to get classifications
gcloud beta ml predict --model ${MODEL_NAME} --json-instances request.json