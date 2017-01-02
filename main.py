import MeerkatReader
import re
import os
import glob
#Entry Point

#parse names

indir="C:\Users\Ben\Dropbox\MeerkatReader\TrainingData"
searchpath=indir + "/*.jpg"
files=glob.glob(searchpath)

#ID frame
IDs=[]

#Get IDs
for f in files:
    fn=os.path.splitext(os.path.basename(f))[0]
    fn=fn.split("_")
    IDs.append(fn[0])
    
MeerkatReader.runMeerkat(indir=indir,outdir="C:/Users/Ben/Desktop/test/",text=IDs)
