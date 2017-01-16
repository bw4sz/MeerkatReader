#Query already run model on cloudml
#See MeerkatReader.sh for generating a new model.

#Create images to run model
#create docker container instance
gcloud compute instances create gci --image-family gci-stable --image-project google-containers 
gcloud compute ssh benweinstein2010@gci 

#get cloudml docker environment
#still struggling with credentials
#-e GOOGLE_APPLICATION_CREDENTIALS=/src/gcloud_service_account.j‌​son

docker pull gcr.io/cloud-datalab/datalab:local
docker run -it --rm  -p "127.0.0.1:8080:8080" \
  --entrypoint=/bin/bash \
  gcr.io/cloud-datalab/datalab:local
  

#Mount directory (still working on it )
# export GCSFUSE_REPO=gcsfuse-jessie
# echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list
# curl https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add -
# apt-get update
# apt-get install -y gcsfuse

# cd ~
#make empty directory for mount
# mkdir /mnt/gcs-bucket
#give it permissions
# chmod a+w /mnt/gcs-bucket
#MOUNT 
# gcsfuse api-project-773889352370-ml /mnt/gcs-bucket


#must be run in the same directory of cloud training
#Model properties
declare MODEL_NAME=MeerkatReader

#get 
#jpgs=$(find `pwd` TrainingData -type f -name "*.jpg" | head -n 20)

jpgs=$(gsutil ls gs://api-project-773889352370-ml/Cameras/| head -n 20)

#copy locally (only if you can't mount)
python cloudML/images_to_json.py -o cloudML/request.json $jpgs

#Outfile name
outfile=$(date +%Y%m%d_%H%M%S_predicted.json)
gcloud beta ml predict --model ${MODEL_NAME} --json-instances cloudML/request.json > cloudML/${outfile}

#post results
gsutil cp cloudML/${outfile} gs://api-project-773889352370-ml/Prediction/
