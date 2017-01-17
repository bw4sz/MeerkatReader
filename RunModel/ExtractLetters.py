#Text reader
import cv2
import numpy as np
import glob
import sourceM
from imutils import contours
import os
import csv

class MeerkatReader:
    def __init__(self,indir,outdir,debug,size=150,limit=None):    
        print "MeerkatReader object created"    

        #only import the viewer libraries if needed.
        if debug: 
            import matplotlib.pyplot as plt
            from pylab import *
            
        #Should files be written?
        self.debug=debug
        
        #File paths
        self.indir=indir
        self.outdir=outdir
        
        #set size limit for character
        self.size=size
        
        #list files in folder
        searchpath=self.indir + "/*.jpg"
        print "Searching for images in " + str(searchpath)
        self.files=glob.glob(searchpath)        
        
        print str(len(self.files)) + " images found" 
        
        if len(self.files)==0:
            raise "No images found, check input file path"
        
        #do just a portion of the files
        if limit:
            self.end=limit
        else:
            self.end=len(self.files)

    def getLetters(self,roi,asset):        

        self.roi_selected=roi
        #if outdist doesn't exist create it.
        if not os.path.exists(self.outdir):
            os.makedirs(self.outdir)
        
        if self.debug: fig = plt.figure()
        
        #output file names
        self.filname_list=[]
        
        #outpt infile paths
        self.infile=[]
        
        #get the image position, if there are no files start 0
        existing_files=glob.glob(self.outdir+"/*.jpg")
        if existing_files:
            outnumbers=[]
            for e in existing_files:
                fn=os.path.splitext(os.path.basename(e))[0]
                outnumbers.append(int(fn.split("_")[0]))
            offset=max(outnumbers)+1
        else:
            offset=0
        
        #frame number in the loop
        imagecounter=0
        
        for f in self.files[0:self.end]:               
            
            #new letter counter
            lettercounter=0
            
            img=cv2.imread(f)
            display_image=img[self.roi_selected[1]:self.roi_selected[3], self.roi_selected[0]:self.roi_selected[2]]     
            display_image=cv2.cvtColor(display_image,cv2.COLOR_RGB2GRAY)
            
            if self.debug: view(display_image)
        
            #resize by 10
            display_image = cv2.resize(display_image,None,fx=10, fy=10, interpolation = cv2.INTER_CUBIC)
            
            if self.debug: view(display_image)
        
            #threshold
            ret,display_image=cv2.threshold(display_image,247,255,cv2.THRESH_BINARY)
            
            if self.debug: view(display_image)
                        
            #Closing
            kernel = np.ones((20,20),np.uint8)
            display_image=cv2.morphologyEx(display_image,cv2.MORPH_CLOSE,kernel)
            
            if self.debug: view(display_image)

            ##split into letters##
            #get contours
            draw=display_image.copy()
            
            _,cnts,hierarchy = cv2.findContours(display_image.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE )
            len(cnts)
            
            for x in cnts:
                cv2.drawContours(draw,[x],-1,(100,100,255),3)
            if self.debug: view(display_image)
        
            #get rid of child
            #order contour left to right
            (cnts, _) = contours.sort_contours(cnts)    
            
            #remove tiny contours
            contsize = []
            for x in cnts:
                area=cv2.contourArea(x)
                if area > self.size:
                    contsize.append(x)
                else:
                    print str(area) + " is removed"
            
            #bouding boxes
            bounding_box_list=[]
            for cnt in contsize:
                cbox = cv2.boundingRect( cnt )
                bounding_box_list.append( cbox )
                            
            for bbox in bounding_box_list:
                
                #boxes as seperate matrices, make slightly larger so edges don't touch                
                letter=display_image[bbox[1]-10:bbox[1]+bbox[3]+10,bbox[0]-10:bbox[0]+bbox[2]+10]
                #inverse
                letter = cv2.bitwise_not(letter)    
                
                if letter is None:
                    print "no letter"
                    break
                
                if self.debug: view(display_image)            
                
                #add letter counter
                lettercounter=lettercounter+1
                filname = self.outdir  + str(imagecounter+offset) + "_" + asset + "_" + str(lettercounter) + ".jpg"
                
                #Write Letter to File
                if not self.debug: cv2.imwrite(filname,letter)
                self.filname_list.append(filname)
                self.infile.append(f)
                print filname
                                    
            #image counter
            imagecounter=imagecounter+1                
    def writeFile(self):
        
        #file name
        outfile=str(self.outdir) + "/" + "Manifest.csv"
        
        #create zip of files
        rows=zip(self.infile,self.filname_list)
        
        #if file exists 
        f = open(outfile, 'ab')
        try:
            writer = csv.writer(f)
            for row in rows:
                writer.writerow(row)
        finally:
            f.close()
        
#Helper functions
#debug viewer function
def view(display_image):
    plt.imshow(display_image,cmap="Greys")    
    fig = plt.show()        
    plt.pause(0.00001)    
    
def runMeerkat(indir,outdir,debug=False,size=150,limit=None):
    mr=MeerkatReader(debug=debug,size=size,indir=indir,outdir=outdir,limit=limit)
    
    #Camera ID
    roi=[453,702,578,755]
    mr.getLetters(roi=roi,asset="Camera")    
    
    #Date
    roi=[600,702,777,759]
    mr.getLetters(roi=roi,asset="Date")     
    
    #Time
    roi=[777,701,919,750]
    mr.getLetters(roi=roi,asset="Time") 
    
    mr.writeFile()