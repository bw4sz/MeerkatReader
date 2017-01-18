#Query already run model on cloudml
#See MeerkatReader.sh for generating a new model.

#Create images to run model
#create docker container instance
gcloud compute instances create gci --image-family gci-stable --image-project google-containers --scopes 773889352370-compute@developer.gserviceaccount.com="https://www.googleapis.com/auth/cloud-platform"
gcloud compute ssh benweinstein2010@gci 


#get cloudml docker environment, run as privileged to allow mount
docker pull gcr.io/cloud-datalab/datalab:local
docker run --privileged -it --rm  -p "127.0.0.1:8080:8080" \
  --entrypoint=/bin/bash \
  gcr.io/cloud-datalab/datalab:local
  
#usage reporting very slow
cloud config set disable_usage_reporting False 
#Mount directory (still working on it )
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
jpgs=$(head mnt/gcs-bucket/TrainingData/testing_dataGCS.csv  | cut -f 1 -d "," |grep )

awk '$0="mnt/gcs-bucket/TrainingData/"$0' $jpgs

#sen
python MeerkatReader/RunModel/images_to_json.py -o request.json $jpgs


#Outfile name
outfile=$(date +%Y%m%d_%H%M%S_predicted.json)
gcloud beta ml predict --model ${MODEL_NAME} --json-instances images/request.json > images/${outfile}

#post results
gsutil cp images/${outfile} gs://api-project-773889352370-ml/Prediction/
