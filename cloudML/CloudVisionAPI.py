#!/bin/bash 

#send json request to google cloud vision api.
response=curl -v -k -s -H "Content-Type: application/json" \
    https://vision.googleapis.com/v1/images:annotate?key=<API-key> \
    --data-binary @/Users/<username>/testdata/vision.json
    
