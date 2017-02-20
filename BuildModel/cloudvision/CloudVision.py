#!/usr/bin/env python

# Copyright 2017 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This application demonstrates how to perform basic operations with the
Google Cloud Vision API.
For more information, the documentation at
https://cloud.google.com/vision/docs.
"""

import argparse
import io
import os
import fnmatch
import json 

from google.cloud import vision
from google.cloud import storage

def detect_text_cloud_storage(uri):
    """Detects text in the file located in Google Cloud Storage."""
    image = vision_client.image(source_uri=uri)

    texts = image.detect_text()
    for text in texts:
        return(text.description)
        
if __name__ == '__main__':
    
    #json key
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = "C:/Users/Ben/Dropbox/Google/MeerkatReader-9fbf10d1e30c.json"
    
    #Get bucket
    
    client = storage.Client()
    bucket = client.get_bucket('api-project-773889352370-ml')    
    #imgs=bucket.list_blobs(prefix="TrainingData")
    imgs=bucket.list_blobs(prefix="Cameras/201612/")
    
    #image list
    image_list=[]
    for img in imgs:
        image_list.append("gs://" + bucket.name +"/"+ str(img.name))
    
    #only get .jpgs
    jpgs=fnmatch.filter(image_list,"*.jpg")
    
    print jpgs
    
    #output dict
    out={}
    
    
    ##Initialize vision client
    vision_client = vision.Client()
    
    for uri in jpgs[10:20]:
        image = vision_client.image(source_uri=uri)
        texts = image.detect_text(limit=1)
        for text in texts:
            text.description
            out[uri]=str(text.description)

    print out
    with open('CloudVision.json', 'w') as fp:
        json.dump(out, fp)
    fp.close()        