import MeerkatReader
import re
import os
import glob

#input files
indir="C:\Users\Ben\Dropbox\MeerkatReader\TrainingData"
searchpath=indir + "/*.jpg"
files=glob.glob(searchpath)

##Camera ID
IDs=[]

##ID labels
for f in files:
    fn=os.path.splitext(os.path.basename(f))[0]
    fn=fn.split("_")
    IDs.append(fn[0])

MeerkatReader.runMeerkat(indir=indir,outdir="C:/Users/Ben/Dropbox/MeerkatReader/Output/",text=IDs,debug=False,size=150,limit=5)

#Dates
dates=[]
for f in files:
    fn=os.path.splitext(os.path.basename(f))[0]
    fn=fn.split("_")
    dates.append(fn[1])

#years
years=[x[0:4] for x in dates]

#months
months=[x[4:6] for x in dates]

days=[x[6:8] for x in dates]

#format str

datef=[x[0] +"/" + x[1] +"/"+ x[2] for x in zip(days,months,years)]

MeerkatReader.runMeerkat(indir=indir,outdir="C:/Users/Ben/Dropbox/MeerkatReader/Output/",text=datef,debug=False,size=150,limit=5)

#Plotwatcher Label
#Dates
texts=[]
for f in files:
    texts.append("PLOTWATCHERPRO")

MeerkatReader.runMeerkat(indir=indir,outdir="C:/Users/Ben/Dropbox/MeerkatReader/Output/",text=texts,debug=False,size=150,limit=5)
