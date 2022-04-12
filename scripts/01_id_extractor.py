import pandas as pd
import argparse
import os 

def extract_from_file(filename) :
    output_file= filename.split('/')[2]
    output_file = output_file.strip("_clean-dataset.tsv")
    # print(output_file)
    tweet_ids = pd.read_csv(filename , sep='\t')
    tweet_ids = tweet_ids.drop(['date','time'], axis=1)
    tweet_ids.to_csv(output_file, header=False, index=False)

def extract_from_folder(foldername) :
	for _,_,files in os.walk(foldername) :
		print("files read")
	for f in files :
		file_name = foldername +f
		extract_from_file(file_name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Script to extract tweet IDs from the given dataset in Hydrator compatible format.')

    parser.add_argument('-m', action="store", default=0, type=int, dest="mode" , help="pass 0 for file mode and 1 for folder mode")
    parser.add_argument('-f', action="store", default="full_dataset.tsv", dest="filename" , help="if mode is 0 , pass the filename")
    parser.add_argument('-d', action="store", default="raw_dataset", dest="directory", help="if mode is 1 , pass the directory name")
    results = parser.parse_args()

    mode = results.mode
    if(mode == 0) :
        filename = results.filename
        extract_from_file(filename)
    elif(mode ==1) :
        foldername = results.directory
        extract_from_folder(foldername)
    else :
        print("Invalid Output. Please run with proper mode")
        exit(0)
