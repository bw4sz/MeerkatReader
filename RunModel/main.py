import ExtractLetters
import argparse
import sys

if __name__ == '__main__':
    args=sys.argv[1:]
    indir=args[0]
    outdir=args[1] 
    print "indir is: " + str(indir)
    print "outdir is: " + str(outdir)
    ExtractLetters.runMeerkat(indir=indir,outdir=outdir,debug=False,size=150)
