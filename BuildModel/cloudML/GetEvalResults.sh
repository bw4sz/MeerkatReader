#Get eval results for trained model
#See MeerkatReader.sh for generating a new model.

#Create images to run model
#create docker container instance
gcloud compute instances create gci --image-family gci-stable --image-project google-containers --scopes 773889352370-compute@developer.gserviceaccount.com="https://www.googleapis.com/auth/cloud-platform" --boot-disk-size "30"
gcloud compute ssh benweinstein2010@gci 

#get cloudml docker environment, run as privileged to allow mount
gcloud docker pull gcr.io/api-project-773889352370/cloudml
docker run --privileged -it --rm  -p "127.0.0.1:8080:8080" \
  --entrypoint=/bin/bash \
  gcr.io/api-project-773889352370/cloudml
  
#usage reporting very slow
gcloud config set disable_usage_reporting True
 
#Mount directory (still working on it in dockerfile)
export GCSFUSE_REPO=gcsfuse-jessie
echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add -
apt-get update
apt-get install -y gcsfuse

# # cd ~
# #make empty directory for mount
mkdir /mnt/gcs-bucket

# #give it permissions
chmod a+w /mnt/gcs-bucket
#MOUNT 
gcsfuse --implicit-dirs api-project-773889352370-ml /mnt/gcs-bucket

#must be run in the same directory of cloud training
#Model properties
declare MODEL_NAME=MeerkatReader

#process images#clone the git repo
git clone https://github.com/bw4sz/MeerkatReader.git

#extract eval frames to predict
cat mnt/gcs-bucket/TrainingData/testing_dataGCS.csv  | cut -f 1 -d "," > eval_files.txt
#fix local mount path
sed "s|gs://api-project-773889352370-ml/|mnt/gcs-bucket/|g" eval_files.txt  > jpgs.txt

#For single prediction
#python MeerkatReader/RunModel/API_wrapper.py -inputs jpgs.txt -model_name $MODEL_NAME -size 100 -outdir mnt/gcs-bucket/TrainingData/

#Batch prediction
JSON_INSTANCES=Instances_$(date +%Y%m%d_%H%M%S).json
python MeerkatReader/RunModel/images_to_json.py -o $JSON_INSTANCES $(cat jpgs.txt)
gsutil cp $JSON_INSTANCES gs://api-project-773889352370-ml/Prediction/

JOB_NAME=predict_Meerkat_$(date +%Y%m%d_%H%M%S)
gcloud beta ml jobs submit prediction ${JOB_NAME} \
    --model=${MODEL_NAME} \
    --data-format=TEXT \
    --input-paths=gs://api-project-773889352370-ml/Prediction/$JSON_INSTANCES \
    --output-path=gs://api-project-773889352370-ml/Prediction/ \
    --region=us-central1
    