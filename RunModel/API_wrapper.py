import argparse
from subprocess import call
import images_to_json

if __name__ == '__main__':
    
    #input args
    parser = argparse.ArgumentParser()

    parser.add_argument("-jpgs", help="path to jpeg list file",type=str)
    parser.add_argument("-path_jsonpy", help="path to python ",type=str)
    parser.add_argument("-size", help="number of jpegs written at once",type=int)
    parser.add_argument("-model_name", help="model name",type=str)
    
    args = parser.parse_args()
    
    #define helpfile
    def chunker(seq, size):
        return (seq[pos:pos + size] for pos in xrange(0, len(seq), size))    
    
    #read file 
    infile=args.jpgs
    with open(infile) as f:
        lines = f.readlines()
        image_paths=lines[0].split()
        
    #write in chunks
    for group in chunker(image_paths,args.size):        
        #write json request
        images_to_json.make_request_json(input_images=group, output_json="request.json",do_resize=True)
        
        #make API request
        outfile=str(time.time()).split(".")[0] + "_prediction.yaml"
        cmd = "gcloud beta ml predict --model" + str(args.model_name) + " --json-instances images/request.json >" + str(outfile)
        call(cmd)
)
    
