#!/bin/bash 

#send json request to google cloud vision api.
curl -v -k -s -H "Content-Type: application/json" \
    https://vision.googleapis.com/v1/images:annotate?key=<API-key> \
    --data-binary @/Users/<username>/testdata/vision.json
    
    
gsutil -m acl set -R -a public-read gs://bucket