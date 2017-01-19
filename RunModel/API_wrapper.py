import argparse
from subprocess import call
import images_to_json

if __name__ == '__main__':
    
    #input args
    parser = argparse.ArgumentParser()

    parser.add_argument("-inputs", help="path to jpeg list file",type=argparse.FileType('r'))
    parser.add_argument("-size", help="number of jpegs written at once",type=int)
    parser.add_argument("-model_name", help="model name",type=str)
    parser.add_argument("-outdir", help="where to put outfile predictions",type=str)
    
    args = parser.parse_args()
    
    #define helpfile
    def chunker(seq, size):
        return (seq[pos:pos + size] for pos in xrange(0, len(seq), size))    
    
    #mimic current output argparse structure
    class imagef:
        def __init__(self,n):
            self.name=n
    
    #read file 
    with open(args.inputs) as f:
        lines = f.readlines()
        image_paths=lines[0].split()
        
    #write in chunks
    for group in chunker(image_paths,args.size):        
        
        infile=imagef(n=group)
        
        #write json request
        images_to_json.make_request_json(input_images=infile, output_json="request.json",do_resize=True)
        
        
        #make API request
        if not os.path.exists(outdir + "/yamls/"):
            os.makedirs(outdir + "/yamls/")
            
        outfile=args.outdir + "/yamls/" + str(time.time()).split(".")[0] + "_prediction.yaml"
        cmd = "gcloud beta ml predict --model" + str(args.model_name) + " --json-instances images/request.json >" + str(outfile)
        call(cmd)

    
