#tesseract comparison
try:
    import Image
except ImportError:
    from PIL import Image
import pytesseract
import glob
import os
import json


#get list of images
predict={}
imgs=glob.glob("C:/Users/Ben/Dropbox/MeerkatReader/Output/*.jpg")
for img in imgs:
    pyimage=Image.open(img)
    pyimage.load()
    i = pytesseract.image_to_string(pyimage,lang="eng",config="-psm 10")
    print i
    #string name, string out file path
    predict[os.path.basename(img).split(".")[0]]=i

print predict

#dump to json
with open('tesseract.json', 'w') as fp:
    json.dump(predict, fp)
fp.close()