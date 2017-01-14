#Query already run model on cloudml
#See MeerkatReader.sh for generating a new model.

#must be run in the same directory of cloud training
#Model properties
declare MODEL_NAME=MeerkatReader
declare VERSION_NAME=v2  # for example

jpgs=$(find `pwd` TrainingData -type f -name "*.jpg" | head -n 20)

python cloudML/images_to_json.py -o cloudML/request.json $jpgs

#Outfile name
outfile=$(date +%Y%m%d_%H%M%S_predicted.json)
gcloud beta ml predict --model ${MODEL_NAME} --json-instances cloudML/request.json > cloudML/${outfile}

#post results
gsutil cp cloudML/${outfile} gs://api-project-773889352370-ml/Prediction/
