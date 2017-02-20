
f=open(args.output)
for x in args.input:
    towrite=str(x) + " 1:3" + "/n"
    f.write(towrite)
    
