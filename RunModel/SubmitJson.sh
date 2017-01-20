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
gcloud config set disable_usage_reporting True
 
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

#extract letters
python MeerkatReader/RunModel/main.py -indir mnt/gcs-bucket/Cameras/201612/ -outdir mnt/gcs-bucket/Cameras/201612/letters -limit=5 

#sen

#get folder (TODO: needs to be a variable )
find mnt/gcs-bucket/Cameras/201612/letters -type f -name "*.jpg" > jpgs.txt

#Outfile name
#For single prediction
#python MeerkatReader/RunModel/API_wrapper.py -inputs jpgs.txt -model_name $MODEL_NAME -size 100 -outdir mnt/gcs-bucket/TrainingData/

#single prediction
#gcloud beta ml predict --model ${MODEL_NAME} --json-instances images/request.json > images/${outfile}

#Batch prediction
python MeerkatReader/RunModel/images_to_json.py -o request.json $(cat jpgs.txt)

JOB_NAME=predict_Meerkat_$(date +%Y%m%d_%H%M%S)
gcloud beta ml jobs submit prediction ${JOB_NAME} \
    --model=${MODEL_NAME} \
    --data-format=TEXT \
    --input-paths=request.json\
    --output-path=mnt/gcs-bucket/TrainingData/output \
    --region=us-central1
#post results
gsutil cp images/${outfile} gs://api-project-773889352370-ml/Prediction/
