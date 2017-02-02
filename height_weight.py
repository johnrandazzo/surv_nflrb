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

# our code breaks at element 91 -> http://www.pro-football-reference.com/players/C/CoxxMi00.htm
# this fucker did not have a height and weight listed
# we need to find a way around this
# we found one

# begin code block 3

from bs4 import BeautifulSoup
import requests
heights = []
weights = []
i = 0
while i < 100: # we are just trying to get it to work on a small scale
# if it did work it would be -> while i < len(urlList):
    if i == 91:
        i += 1 # this takes out the guy with no height or weight. fuck him.
    baseurl = urlList[i]
    response = requests.get(baseurl)
    content = response.content
    parser = BeautifulSoup(content,'html.parser')
    heights.append(parser.find_all(itemprop = "height")[0].text)
   # if heights[i] is None:
   #     heights[i] = 0
   #     continue
    weights.append(parser.find_all(itemprop = "weight")[0].text)
   # if weights[i] is None:
   #     weights[i] = 0
   #     continue
    print(heights, weights)
    i += 1
    
# end code block 3


