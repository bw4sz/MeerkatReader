import ExtractLetters
import argparse
import sys

if __name__ == '__main__':
    
    #input args
    parser = argparse.ArgumentParser()

    parser.add_argument("-indir", help="Directory of plotwatcher images to extract letters",type=str)
    parser.add_argument("-outdir", help="Directory to place extracted letters",type=str)
    parser.add_argument("-limit", help="Maximum number of images to process",type=str,default='None')
    
    print "indir is: " + str(indir)
    print "outdir is: " + str(outdir)
    
    ExtractLetters.runMeerkat(indir=indir,outdir=outdir,debug=False,size=150,limit=limit)
