import argparse
from subprocess import call
import images_to_json
import os
import time

if __name__ == '__main__':
    
    #input args
    parser = argparse.ArgumentParser()

    parser.add_argument("-inputs", help="path to jpeg list file")
    parser.add_argument("-size", help="number of jpegs written at once, max 100",type=int,default=100)
    parser.add_argument("-model_name", help="model name",type=str)
    parser.add_argument("-outdir", help="where to put outfile predictions",type=str)
    
    args = parser.parse_args()
    
    #define helpfile
    def chunker(seq, size):
        return (seq[pos:pos + size] for pos in xrange(0, len(seq), size))    
        
    #read file 
    with open(args.inputs) as f:
        lines = f.read()
        image_paths=lines.split("\n")
        
    #write in chunks
    for group in chunker(image_paths,args.size):        
        #write temp file
        with open("tmpfile.txt", mode='w') as txt:
            for item in group:
                txt.write("%s\n" % item)
        txt.close()
        
        #write json request, not as pretty as i'd like it.
        call("python MeerkatReader/RunModel/images_to_json.py -o request.json $(cat tmpfile.txt)",shell=True)
        
        #make API request
        if not os.path.exists(args.outdir + "/yamls/"):
            os.makedirs(args.outdir + "/yamls/")
            
        outfile=args.outdir + "/yamls/" + str(time.time()).split(".")[0] + "_prediction.yaml"
        cmd = "time gcloud beta ml predict --model " + str(args.model_name) + " --json-instances request.json >" + str(outfile)
        call(cmd,shell=True)
        os.remove("tmpfile.txt")

    
