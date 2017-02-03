# NFL RB survival analysis, data collection code
# we are trying to extract each player's height and weight

import pandas as pd
import string
import numpy as np
nfl = pd.read_csv("nflrb_data.csv")

nfl.rename(columns={'Unnamed: 4': 'Name'}, inplace=True)

names = nfl.Name
list = []
for i in names:
    list.append(i)

nameStore = []
letterStore = []
p = 0
while p < len(list):
    if ("\\" in list[p]):
        nameStore.append(list[p][-8:])
        letterStore.append(list[p][-8])
    p += 1

p-=1
while p > 0:
    if ("\\" not in list[p]):
        nfl.drop(nfl.index[p],inplace = True)
    p -= 1
    
i = 0
urlList = []
while i < 1156:
    urlList.append("http://www.pro-football-reference.com/players/%s/%s.htm" % (letterStore[i],nameStore[i]))
    i += 1
nfl = nfl.reset_index(drop = True)

from bs4 import BeautifulSoup
import requests
heights = []
weights = []
i = 0
while i < len(urlList):
    if i == 91 or i == 235:
        heights.append(0)
        weights.append(0)
        i += 1
    baseurl = urlList[i]
    response = requests.get(baseurl)
    content = response.content
    parser = BeautifulSoup(content,'html.parser')
    heights.append(parser.find_all(itemprop = "height")[0].text)
    weights.append(parser.find_all(itemprop = "weight")[0].text)
    i += 1
    
nfl['Height'] = pd.Series(heights, index=nfl.index)
nfl['Weight'] = pd.Series(weights, index=nfl.index)
 
