import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-o', '--output', default='request.txt',
                    help='Output file to write encoded images to.')
parser.add_argument('-i', '--input', help='Input files',nargs="*")
args = parser.parse_args()

f=open(args.output)
for x in args.input:
    towrite=str(x) + "1:3" + "/n"
    f.write(towrite)
    
