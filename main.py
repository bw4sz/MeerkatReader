import MeerkatReader
import re
import os
import glob


#input files
indir="C:\Users\Ben\Dropbox\MeerkatReader\TrainingData"
searchpath=indir + "/*.jpg"
files=glob.glob(searchpath)

#ID frame
IDs=[]

#ID labels
for f in files:
    fn=os.path.splitext(os.path.basename(f))[0]
    fn=fn.split("_")
    IDs.append(fn[0])

MeerkatReader.runMeerkat(indir=indir,outdir="C:/Users/Ben/Documents/MeerkatReader/TrainingData/",text=IDs,debug=False,size=200)

#ID frame
IDs=[]

for f in files:
    IDs.append("/")
    
MeerkatReader.runMeerkat(indir=indir,outdir="C:/Users/Ben/Documents/MeerkatReader/TrainingData/",text=IDs,debug=False,size=50)
