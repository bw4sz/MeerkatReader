#Query already run model on cloudml
#See MeerkatReader.sh for generating a new model.

#Create images to run model
#create docker container instance
gcloud compute instances create gci --image-family gci-stable --image-project google-containers ^Zgcloud compute ssh gci --image-family gci-stable --image-project google-containers
gcloud compute ssh benweinstein2010@gci --image-family gci-stable --image-project google-containers 

#mount bucket?

#get cloudml docker environment
docker pull gcr.io/cloud-datalab/datalab:local
docker run -it -p "127.0.0.1:8080:8080" \
  --entrypoint=/bin/bash \
  gcr.io/cloud-datalab/datalab:local

#must be run in the same directory of cloud training
#Model properties
declare MODEL_NAME=MeerkatReader

#jpgs=$(find `pwd` TrainingData -type f -name "*.jpg" | head -n 20)

#jpgs=$(gsutil ls gs://api-project-773889352370-ml/Cameras/ ".jpg" | head -n 20)

python cloudML/images_to_json.py -o cloudML/request.json $jpgs

#Outfile name
outfile=$(date +%Y%m%d_%H%M%S_predicted.json)
gcloud beta ml predict --model ${MODEL_NAME} --json-instances cloudML/request.json > cloudML/${outfile}

#post results
gsutil cp cloudML/${outfile} gs://api-project-773889352370-ml/Prediction/
