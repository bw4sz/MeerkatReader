import ExtractLetters
import argparse
import sys

if __name__ == '__main__':
    
    #input args
    parser = argparse.ArgumentParser()

    parser.add_argument("-indir", help="Directory of plotwatcher images to extract letters",type=str)
    parser.add_argument("-outdir", help="Directory to place extracted letters",type=str)
    parser.add_argument("-limit", help="Maximum number of images to process",type=int,default=None)
    parser.add_argument("-size", help="minimum size of contour",type=int,default=150)
    parser.add_argument("-debug", help="View debugger",action="store_true",default=False)    
    args = parser.parse_args()
        
    print "indir is: " + str(args.indir)
    print "outdir is: " + str(args.outdir)
    
    ExtractLetters.runMeerkat(indir=args.indir,outdir=args.outdir,debug=args.debug,size=args.size,limit=args.limit)
