#Text reader
import cv2
import numpy as np
import glob
import matplotlib.pyplot as plt
from pylab import *
import sourceM
from imutils import contours
import os
import csv

class MeerkatReader:
    def __init__(self,debug,size):    
        print "MeerkatReader object created"    
        
        #Should files be written?
        self.debug=debug
        
        #set size limit for character
        self.size=size
    
    def defineROI(self,path):
        
        ion()
        
        searchpath=path + "/*.jpg"
        print "Searching for images in " + str(searchpath)
        self.files=glob.glob(searchpath)
        
        print str(len(self.files)) + " images found"
        print "Example file path:" + self.files[0]
        
        img=cv2.imread(self.files[0])
        
        #Set region of interest 
        self.roi_selected=sourceM.Urect(img.copy(),"Region of Interest")
        self.roi_selected=self.roi_selected[-4:]
        if len(self.roi_selected)==0 :
            raise ValueError('Error: No box selected. Please select an area by right clicking and dragging qwith your cursor to create a box. Hit esc to exit the window.')
        
    def getLetters(self,outdir,text,size=1000):        

        #if outdist doesn't exist create it.
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        
        if self.debug: fig = plt.figure()
        
        #output file names
        self.filname_list=[]
        
        #output training labels
        self.textlist=[]
        
        #get the image position, if there are no files start 0
        existing_files=glob.glob(outdir+"/*.jpg")
        if existing_files:
            outnumbers=[]
            for e in existing_files:
                fn=os.path.splitext(os.path.basename(e))[0]
                outnumbers.append(int(fn.split("_")[0]))
            offset=max(outnumbers)
        else:
            offset=0
        
        #frame number in the loop
        imagecounter=0
        
        for f in self.files:               
            
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
            
            #get letters from all the texts, turn into a list
            letterID=list(assignText(text[imagecounter]))
            
            #reverse order for pop
            letterID=letterID[::-1]
                
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
                filname = outdir  + str(imagecounter+offset) + "_" + str(lettercounter) + ".jpg"
                
                #Write Letter to File
                if not self.debug: cv2.imwrite(filname,letter)
                self.filname_list.append(filname)
                print filname
                
                #get text associate with that image
                #need if pop.
                try:
                    addLetter=letterID.pop()
                except:
                    pass
                if addLetter:
                    self.textlist.append(addLetter)
                    if self.debug: print addLetter
                else:
                    self.textlist.append("")   
                    
            #image counter
            imagecounter=imagecounter+1                
            
    def writeFile(self,outdir):
        
        #file name
        outfile=str(outdir) + "/" + "TrainingData.csv"
        
        #create zip of files
        rows=zip(self.filname_list,self.textlist)
        
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
    
def runMeerkat(indir,outdir,text,debug,size=1000):
    mr=MeerkatReader(debug,size)
    mr.defineROI(indir)
    mr.getLetters(outdir,text,size)
    if not mr.debug:
        mr.writeFile(outdir)

def assignText(text):
    
    #list of letters
    textlist=[]
    
    #Split into letters
    for l in text:
        textlist.append(l)
    return textlist

    