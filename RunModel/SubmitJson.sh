#Query already run model on cloudml

#Create images to run model
#create docker container instance
gcloud compute instances create gci --image-family gci-stable --image-project google-containers --scopes 773889352370-compute@developer.gserviceaccount.com="https://www.googleapis.com/auth/cloud-platform" --boot-disk-size "40"
gcloud compute ssh benweinstein2010@gci 

#Custom docker env
docker pull gcr.io/api-project-773889352370/cloudml:latest
docker run --privileged -it --rm  -p "127.0.0.1:8080:8080" \
  --entrypoint=/bin/bash \
  gcr.io/api-project-773889352370/cloudml:latest
  
#usage reporting very slow
gcloud config set disable_usage_reporting True
 
#declare month variable
declare MONTH=201612

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

#need imutils
pip install imutils

#extract letters
python MeerkatReader/RunModel/main.py -indir mnt/gcs-bucket/Cameras/$MONTH/ -outdir mnt/gcs-bucket/Cameras/$MONTH/letters/ -limit=5 

gsutil ls gs://api-project-773889352370-ml/Cameras/$MONTH/*.jpg > jpgs.txt

python MeerkatReader/RunModel/images_to_json.py -o mnt/gcs-bucket/Cameras/$MONTH/request.json $(cat jpgs.txt)

#submit job
JOB_NAME=predict_Meerkat_$(date +%Y%m%d_%H%M%S)
gcloud beta ml jobs submit prediction ${JOB_NAME} \
    --model=${MODEL_NAME} \
    --data-format=TEXT \
    --input-paths=gs://api-project-773889352370-ml/Cameras/$MONTH/request.json \
    --output-path=gs://api-project-773889352370-ml/Cameras/$MONTH/prediction/ \
    --region=us-central1
    
#describe job
gcloud beta ml jobs describe ${JOB_NAME}
 
#exit ssh
exit

#kill instance
gcloud compute instances delete gci

#run Rscript to combine strings
Rscript ProcessingJson.Rmd $MONTH