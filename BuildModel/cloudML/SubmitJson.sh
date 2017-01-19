#Query already run model on cloudml
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

#get folder (TODO: needs to be a variable )
find mnt/gcs-bucket/Cameras/201612 -type f -name "*.jpg" > jpgs.txt

python MeerkatReader/RunModel/API_wrapper.py -model_name $MODEL_NAME -size 100

#sen
python MeerkatReader/RunModel/images_to_json.py -o images/request.json $jpgs

#Outfile name
outfile=$(date +%Y%m%d_%H%M%S_predicted.yaml)
gcloud beta ml predict --model ${MODEL_NAME} --json-instances images/request.json > images/${outfile}

#post results
gsutil cp images/${outfile} gs://api-project-773889352370-ml/Prediction/
