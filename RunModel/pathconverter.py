#simple script to combine mounted bucket paths, easier than messing around in bash
import argparse
import sys

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-gcs_path", help="Current directory on bucket",type=str)
    parser.add_argument("-mount", help="Directory to place extracted letters",type=str)
    args = parser.parse_args()
    
    newpath=[args.mount + str(x) for x in args.gcs_path]
    print newpath