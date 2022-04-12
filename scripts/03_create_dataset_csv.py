import pandas as pd
import numpy as np
import json
import sys
import csv
import argparse
import os
import joblib

country_pkls = {
    'usa' : ['united states' , 'us_states.pkl'],
    'ind' : ['india' , 'indian_states.pkl'],
    'uk' : ['united kingdom' , 'uk_states.pkl'],
    'sgp' : ['singapore' , 'sgp_states.pkl'],
    'arg' : ['argentina' , 'argentina_states.pkl'],
    'aus' : ['australia' , 'australia_states.pkl'],
    'austria' : ['austria' , 'austria_states.pkl'],
    'can' : ['canada' , 'canada_states.pkl'],
    'chile' : ['chile' , 'chile_states.pkl'],
    'colombia' : ['colombia' , 'colombia_states.pkl'],
    'costa' : ['costa rica' , 'costarica_states.pkl'],
    'fra' : ['france' , 'france_states.pkl'],
    'ger' : ['germany' , 'germany_states.pkl'],
    'ita' : ['italy' , 'italy_states.pkl'],
    'netherlands' : ['netherlands' , 'netherlands_states.pkl'],
    'nz' : ['new zealand' , 'newzealand_states.pkl'],
    'rus' : ['russia' , 'russia_states.pkl'],
    'esp' : ['spain' , 'spain_states.pkl'],
    'swiss' : ['switzerland' , 'switzerland_states.pkl'],
    'ven' : ['venezuela' , 'venezuela_states.pkl'],
    'bra' : ['brazil' , 'brazil_states.pkl'],
    'mex' : ['mexico', 'mexico_states.pkl'],
    'per' : ['peru', 'peru_states.pkl'],
    'nga' : ['nigeria', 'nigeria_states.pkl'],
    'tza' : ['tanzania', 'tanzania_states.pkl'],
    'zaf' : ['south africa', 'southafrica_states.pkl'],
    'eth' : ['ethiopia', 'ethiopia_states.pkl']
}


def extract_data(input_file, region) :
    outputfile = input_file[:-6] +"_"+region+"_complete.csv"
    states = joblib.load('./state_pkls/'+country_pkls[region][1])
    print(outputfile)
    
    with open(input_file,encoding='latin1',mode='r') as f , open(outputfile,encoding='latin1', mode='w') as tweet_csv :
        print("Data Extraction in progress... for file " + input_file + " and country:" + region)
        tweet_writer = csv.writer(tweet_csv, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
        tweet_writer.writerow(['created_at', 'month', 'date', 'time', 'day','tweet_id', 'country', 'location', 'full_text', 'language', 'retweet_count', 'favourite_count', 'reply_count'])

        for cnt, line in enumerate(f):
            region_flag = 0 
            # tweet = json.loads(line) # load it as Python dict
            try:
                tweet = json.loads(line) # load it as Python dict
            except:
                continue
            
            try :
                created_at = (tweet['created_at'])
                month =(tweet['created_at'].split(' ')[1])
                date = (tweet['created_at'].split(' ')[2])
                time = (tweet['created_at'].split(' ')[3])
                day = (tweet['created_at'].split(' ')[0])
            except :
                continue

            try :
                tweet_id =(tweet['id_str'])
            except:
                continue
                
            try :
                country = tweet['place']['country'].lower()
                
            except:
                country = 'none'
            
            try :
                location = 'none'
                l = tweet['user']['location']
                l = l.lower()
                temp = l.split(',')
                for i in temp :
                    if(i.lower() in states) :
                        location = country_pkls[region][0]
                        break 
            except :
                location = 'none'
                    
            if(country == country_pkls[region][0] ) :
                region_flag+=1
            if(location == country_pkls[region][0]) :
                region_flag+=1
            
            if(region_flag == 0) :
                continue
                
            # try :
            #     coordinates = tweet['coordinates']
            # except:
            #     coordinates = 'none'

            try :
                full_text = tweet['full_text']
            except:
                continue

            try :
                language = tweet['lang']
            except:
                language = 'none'
                
            # if(language != 'en') :
            #     continue

            try :
                retweet_count = tweet['retweet_count']
            except:
                retweet_count = 'none'

            try :
                favourite_count = tweet['favourite_count']
            except:
                favourite_count = 'none'

            try :
                reply_count = tweet['reply_count']
            except:
                reply_count = 'none'

            tweet_writer = csv.writer(tweet_csv, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
            tweet_writer.writerow([created_at, month, date, time, day, tweet_id, country, location, full_text, language, retweet_count, favourite_count, reply_count])
            

    print("completed!")


if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description='Script to extract tweet IDs from the given dataset in Hydrator compatible format.')
    parser.add_argument('-d', action="store", dest="dir" , help="Enter the directory containing the .jsonl files")
    results = parser.parse_args()

    directory = results.dir
    print(directory)
    
    #region_list = ['usa','ind','uk', 'sgp', 'arg','aus','austria','can', 'chile', 'colombia','costa', 'fra', 'ger', 'ita', 'netherlands', 'nz', 'rus', 'esp', 'swiss', 'ven']
    region_list = ['bra', 'mex', 'per', 'nga', 'tza', 'zaf', 'eth']

    to_be_converted = []
    for _,_, files in os.walk(directory) :
        for f in files :
            ext = f.split('.')[-1]
            if(ext=='jsonl') :
                #file_name = directory+f
                to_be_converted.append(f)
    print(to_be_converted)

    for f in to_be_converted :
        for region in region_list :
            extract_data(f, region)
            # print(region)
            # print(country_pkls[region][0])
            # path = './state_pkls/'+country_pkls[region][1]
            # states = joblib.load(path)
            # print(states)
    
    print("Script Execution Complete!")
