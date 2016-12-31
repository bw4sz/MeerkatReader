import MeerkatReader
#Entry Point

if __name__ == "__main__":
    mr=MeerkatReader.MeerkatReader()
    mr.defineROI("C:/Users/Ben\Dropbox/Thesis/Maquipucuna_SantaLucia/HolgerCameras/201608/*")
    mr.getLetters(outdir="C:/Users/Ben/Desktop/test/")
    