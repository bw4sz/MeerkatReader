#Text reader
import cv2
import numpy as np
import glob
import matplotlib.pyplot as plt
from pylab import *
import sourceM
from imutils import contours
import os

class MeerkatReader:
    def __init__(self):    
        print "MeerkatReader object created"    
    
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
        
    def getLetters(self,outdir,viewer=False):        

        #if outdist doesn't exist create it.
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        
        if viewer: fig = plt.figure()
        
        IDlist=[]
        imagecounter=0
        for f in self.files:   
            
            #image counter
            imagecounter=imagecounter+1
            
            #new letter counter
            lettercounter=0
            
            img=cv2.imread(f)
            display_image=img[self.roi_selected[1]:self.roi_selected[3], self.roi_selected[0]:self.roi_selected[2]]     
            display_image=cv2.cvtColor(display_image,cv2.COLOR_RGB2GRAY)
            
            if viewer: view(display_image)
        
            #resize by 10
            display_image = cv2.resize(display_image,None,fx=10, fy=10, interpolation = cv2.INTER_CUBIC)
            
            if viewer: view(display_image)
        
            #threshold
            ret,display_image=cv2.threshold(display_image,247,255,cv2.THRESH_BINARY)
            
            if viewer: view(display_image)
                        
            #Closing
            kernel = np.ones((20,20),np.uint8)
            display_image=cv2.morphologyEx(display_image,cv2.MORPH_CLOSE,kernel)
            
            if viewer: view(display_image)

            ##split into letters##
            #get contours
            draw=display_image.copy()
            
            _,cnts,hierarchy = cv2.findContours(display_image.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE )
            len(cnts)
            
            for x in cnts:
                cv2.drawContours(draw,[x],-1,(100,100,255),3)
            if viewer: view(display_image)
        
            #get rid of child
            #order contour left to right
            (cnts, _) = contours.sort_contours(cnts)    
            
            #remove tiny contours
            contsize = []
            for x in cnts:
                area=cv2.contourArea(x)
                if area > 1000:
                    contsize.append(x)
                else:
                    print str(area) + " is removed"
            
            #bouding boxes
            bounding_box_list=[]
            for cnt in contsize:
                cbox = cv2.boundingRect( cnt )
                bounding_box_list.append( cbox )
            
            #boxes as seperate matrices, make slightly larger so edges don't touch
            ID=[]
            for bbox in bounding_box_list:
                
                letter=display_image[bbox[1]-10:bbox[1]+bbox[3]+10,bbox[0]-10:bbox[0]+bbox[2]+10]
                #inverse
                letter = cv2.bitwise_not(letter)    
                
                if letter is None:
                    break
                
                if viewer: view(display_image)            
                
                #add letter counter
                lettercounter=lettercounter+1
                filname = outdir  + str(imagecounter) + "_" + str(lettercounter) + ".jpg"
                cv2.imwrite(filname,letter)
                print filname
    def getPaths(self):
        
        for f in self.files:
            
            
        

#Helper functions
#debug viewer function
def view(display_image):
    plt.imshow(display_image,cmap="Greys")    
    fig = plt.show()        
    plt.pause(0.00001)    
    
def runMeerkat(indir,outdir,getP=F):
    mr=MeerkatReader()
    mr.defineROI(indir)
    mr.getLetters(outdir)
    if getP:
        mr.getPaths()