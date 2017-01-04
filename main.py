import MeerkatReader
import re
import os
import glob


#input files
indir="C:\Users\Ben\Dropbox\MeerkatReader\TrainingData"
searchpath=indir + "/*.jpg"
files=glob.glob(searchpath)

##ID frame
#IDs=[]

##ID labels
#for f in files:
    #fn=os.path.splitext(os.path.basename(f))[0]
    #fn=fn.split("_")
    #IDs.append(fn[0])

#MeerkatReader.runMeerkat(indir=indir,outdir="C:/Users/Ben/Documents/MeerkatReader/TrainingData/",text=IDs,debug=True,size=200)

##ID frame
#IDs=[]

#for f in files:
    #IDs.append("/")
    
#MeerkatReader.runMeerkat(indir=indir,outdir="C:/Users/Ben/Documents/MeerkatReader/TrainingData/",text=IDs,debug=True,size=50)

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

MeerkatReader.runMeerkat(indir=indir,outdir="C:/Users/Ben/Desktop/Test/",text=datef,debug=False,size=150)
