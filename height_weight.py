# NFL RB survival analysis, data collection code
# we are trying to extract each player's height and weight

# to reproduce what we had, cut and paste each code block into jupyter notebook where i tell you to

# begin code block 1

import pandas as pd
import string
import numpy as np
nfl = pd.read_csv("nflrb_data.csv")

nfl.rename(columns={'Unnamed: 4': 'Name'}, inplace=True)

names = nfl.Name

nfl.head()
print(names)
print(type(names))

# end code block 1

# begin code block 2

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

i = 0
urlList = []
while i < 1156:
    urlList.append("http://www.pro-football-reference.com/players/%s/%s.htm" % (letterStore[i],nameStore[i]))
    i += 1
print(urlList[91])

# end code block 2

# begin code block 3

from bs4 import BeautifulSoup
import requests
heights = []
weights = []
i = 0
while i < len(urlList): 
    if i == 91 or i == 235:
        i += 1 # this takes out the 2 guys with no height or weight. fuck them.
    baseurl = urlList[i]
    response = requests.get(baseurl)
    content = response.content
    parser = BeautifulSoup(content,'html.parser')
    heights.append(parser.find_all(itemprop = "height")[0].text)
   
    weights.append(parser.find_all(itemprop = "weight")[0].text)

    print(heights, weights)
    i += 1
    
# end code block 3

# current issue: our data frame (referenced by nfl) still contains 1500 players, only 1156 of them have player profiles on pro-football-reference.com
# need to remove these 1500-1156 = 344 losers from our dataset so we can add columns for height/weight
