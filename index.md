# Deep learning for streamlining ecological image analysis: an example using Optical Character Recognition
Ben Weinstein

Department of Fisheries and Wildlife, Marine Mammal Institute, Oregon State University, 2030 Marine Science Drive, Newport, OR 97365, USA

The essential motivation was inspired by [this google blog post](https://cloud.google.com/blog/big-data/2016/12/how-to-train-and-classify-images-using-google-cloud-machine-learning-and-cloud-dataflow)

## Extract letters
* [Parse letters from raw images](BuildModel/main.py)

## Getting set up
* [Google CloudML](https://cloud.google.com/ml/docs/)

## Building a model
* [Building a model](BuildModel/cloudML/MeerkatReader.sh)
* [TrainingData](BuildModel/cloudML/training_data.csv)
* [TestingData](BuildModel/cloudML/testing_data.csv)

## Analyzing results
* [Figure generation](BuildModel/AnalyzeJson.html)

## Combine into date, time and ID
* [Generate csv](RunModel/ProcessingJson.Rmd)

## Helpful links
* http://adilmoujahid.com/posts/2016/06/introduction-deep-learning-python-caffe/

* http://colah.github.io/posts/2014-07-NLP-RNNs-Representations/

* https://www.tensorflow.org/how_tos/image_retraining/
