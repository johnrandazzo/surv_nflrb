Abstract
--------

This project focuses on using basic survival analysis techniques to
determine factors influencing career length of NFL running backs,
employing Kaplan-Meier esimates and Cox Proportional Hazards modeling
procedures with the aid of RStudio and its
[survival](https://github.com/cran/survival) library. We extract data
from pro-football-reference.com using .csv files for career statistics
and [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/) for
physical measurements and maintain our dataset using
[pandas](http://pandas.pydata.org/). We present our results in a
visually appealing and easily comprehensible manner through the use of
[ggplot2](https://github.com/tidyverse/ggplot2), in addition to other R
libraries employed for analytical purposes.

Contributors
------------

-   Brian Luu
-   Kevin Wang
-   John Randazzo

Motivation
==========

## Runningbacks don't last very long in the NFL

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/giphy%20(1).gif' >

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/giphy-tumblr.gif' >

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/statistic_id240102_average-length-of-player-careers-in-the-nfl.png' >

Methodology- Web Scraping
=========================

Getting started with the .csv file
----------------------------------

1.  Start by going here (<http://www.pro-football-reference.com/draft/>)
    and selecting RB in the drop-down menu for Position. We are deeply
    grateful to be able to scrape their data without much consequence.
2.  Next to the "Drafted Players" heading, there is an option labeled
    "Share & more" which we will click, yielding an option to generate a
    .csv file that is suitable for Microsoft Excel. This is the
    compressed data of 300 NFL running backs. You can literally cut and
    paste this whole file into your text processor of choice. (We
    use TextWrangler)
3.  To get more observations from previous generations of NFL players,
    we go to the bottom of the table on the website and click "Next
    Page" and then repeat step 2 with one caveat: when cutting and
    pasting the raw data file, omit the first line with all of the
    columns' names.
4.  With Step 3 in mind, repeat Step 2, 4 more times. You should have
    1500 observations total.
5.  Save your file as a .csv file and read into Python. We save it as
    nflrb\_data.csv and that is the name we use in the Python part. Yay!
    We are ready to plug this baby into Python.

# Getting Started in Python

We are using Python to obtain further measures of interest for the RBs in our dataset. Namely, we wish to extract each player's height and weight in order to compute their Body Mass Index. To accomplish this, we need to write a function that accesses each player's Pro-Football-Reference page, then extracts the player's height and weight by parsing the page's .html code and finding a familiar expression. We also store the player's height and weight in integer form in two new columns in our dataset.

## Importing the Required Libraries


```python
import pandas as pd
import numpy as np
from bs4 import BeautifulSoup
import requests
```

## Cleaning the Dataset


```python
nfl = pd.read_csv("nflrb_data.csv")
nfl.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Rk</th>
      <th>Year</th>
      <th>Rnd</th>
      <th>Pick</th>
      <th>Unnamed: 4</th>
      <th>Pos</th>
      <th>DrAge</th>
      <th>Tm</th>
      <th>From</th>
      <th>To</th>
      <th>...</th>
      <th>G</th>
      <th>GS</th>
      <th>Att</th>
      <th>Yds</th>
      <th>TD</th>
      <th>Rec</th>
      <th>Yds.1</th>
      <th>TD.1</th>
      <th>College/Univ</th>
      <th>Unnamed: 23</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>2016</td>
      <td>1</td>
      <td>4</td>
      <td>Ezekiel Elliott\ElliEz00</td>
      <td>RB</td>
      <td>21.0</td>
      <td>DAL</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>...</td>
      <td>15.0</td>
      <td>15.0</td>
      <td>322.0</td>
      <td>1631.0</td>
      <td>15.0</td>
      <td>32.0</td>
      <td>363.0</td>
      <td>1.0</td>
      <td>Ohio St.</td>
      <td>College Stats</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>2016</td>
      <td>2</td>
      <td>45</td>
      <td>Derrick Henry\HenrDe00</td>
      <td>RB</td>
      <td>22.0</td>
      <td>TEN</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>...</td>
      <td>15.0</td>
      <td>1.0</td>
      <td>110.0</td>
      <td>490.0</td>
      <td>5.0</td>
      <td>13.0</td>
      <td>137.0</td>
      <td>0.0</td>
      <td>Alabama</td>
      <td>College Stats</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>2016</td>
      <td>3</td>
      <td>73</td>
      <td>Kenyan Drake\DrakKe00</td>
      <td>RB</td>
      <td>22.0</td>
      <td>MIA</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>...</td>
      <td>16.0</td>
      <td>1.0</td>
      <td>33.0</td>
      <td>179.0</td>
      <td>2.0</td>
      <td>9.0</td>
      <td>46.0</td>
      <td>0.0</td>
      <td>Alabama</td>
      <td>College Stats</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>2016</td>
      <td>3</td>
      <td>90</td>
      <td>C.J. Prosise\ProsC.00</td>
      <td>RB</td>
      <td>22.0</td>
      <td>SEA</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>...</td>
      <td>6.0</td>
      <td>2.0</td>
      <td>30.0</td>
      <td>172.0</td>
      <td>1.0</td>
      <td>17.0</td>
      <td>208.0</td>
      <td>0.0</td>
      <td>Notre Dame</td>
      <td>College Stats</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>2016</td>
      <td>4</td>
      <td>119</td>
      <td>Tyler Ervin\ErviTy00</td>
      <td>RB</td>
      <td>22.0</td>
      <td>HOU</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>...</td>
      <td>12.0</td>
      <td>0.0</td>
      <td>1.0</td>
      <td>3.0</td>
      <td>0.0</td>
      <td>3.0</td>
      <td>18.0</td>
      <td>0.0</td>
      <td>San Jose St.</td>
      <td>College Stats</td>
    </tr>
  </tbody>
</table>
<p>5 rows x 24 columns</p>
</div>




```python
## getting rid of the useless column that is never going to be used
nfl.drop(["Rk","Unnamed: 23"], axis=1, inplace=True)
nfl.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Year</th>
      <th>Rnd</th>
      <th>Pick</th>
      <th>Unnamed: 4</th>
      <th>Pos</th>
      <th>DrAge</th>
      <th>Tm</th>
      <th>From</th>
      <th>To</th>
      <th>AP1</th>
      <th>...</th>
      <th>CarAV</th>
      <th>G</th>
      <th>GS</th>
      <th>Att</th>
      <th>Yds</th>
      <th>TD</th>
      <th>Rec</th>
      <th>Yds.1</th>
      <th>TD.1</th>
      <th>College/Univ</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2016</td>
      <td>1</td>
      <td>4</td>
      <td>Ezekiel Elliott\ElliEz00</td>
      <td>RB</td>
      <td>21.0</td>
      <td>DAL</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>1</td>
      <td>...</td>
      <td>16.0</td>
      <td>15.0</td>
      <td>15.0</td>
      <td>322.0</td>
      <td>1631.0</td>
      <td>15.0</td>
      <td>32.0</td>
      <td>363.0</td>
      <td>1.0</td>
      <td>Ohio St.</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2016</td>
      <td>2</td>
      <td>45</td>
      <td>Derrick Henry\HenrDe00</td>
      <td>RB</td>
      <td>22.0</td>
      <td>TEN</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>0</td>
      <td>...</td>
      <td>4.0</td>
      <td>15.0</td>
      <td>1.0</td>
      <td>110.0</td>
      <td>490.0</td>
      <td>5.0</td>
      <td>13.0</td>
      <td>137.0</td>
      <td>0.0</td>
      <td>Alabama</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2016</td>
      <td>3</td>
      <td>73</td>
      <td>Kenyan Drake\DrakKe00</td>
      <td>RB</td>
      <td>22.0</td>
      <td>MIA</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>0</td>
      <td>...</td>
      <td>2.0</td>
      <td>16.0</td>
      <td>1.0</td>
      <td>33.0</td>
      <td>179.0</td>
      <td>2.0</td>
      <td>9.0</td>
      <td>46.0</td>
      <td>0.0</td>
      <td>Alabama</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2016</td>
      <td>3</td>
      <td>90</td>
      <td>C.J. Prosise\ProsC.00</td>
      <td>RB</td>
      <td>22.0</td>
      <td>SEA</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>0</td>
      <td>...</td>
      <td>3.0</td>
      <td>6.0</td>
      <td>2.0</td>
      <td>30.0</td>
      <td>172.0</td>
      <td>1.0</td>
      <td>17.0</td>
      <td>208.0</td>
      <td>0.0</td>
      <td>Notre Dame</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2016</td>
      <td>4</td>
      <td>119</td>
      <td>Tyler Ervin\ErviTy00</td>
      <td>RB</td>
      <td>22.0</td>
      <td>HOU</td>
      <td>2016.0</td>
      <td>2016.0</td>
      <td>0</td>
      <td>...</td>
      <td>0.0</td>
      <td>12.0</td>
      <td>0.0</td>
      <td>1.0</td>
      <td>3.0</td>
      <td>0.0</td>
      <td>3.0</td>
      <td>18.0</td>
      <td>0.0</td>
      <td>San Jose St.</td>
    </tr>
  </tbody>
</table>
<p>5 rows x 22 columns</p>
</div>



### Renaming the Columns


```python
nfl.columns
```




    Index(['Year', 'Rnd', 'Pick', 'Unnamed: 4', 'Pos', 'DrAge', 'Tm', 'From', 'To',
           'AP1', 'PB', 'St', 'CarAV', 'G', 'GS', 'Att', 'Yds', 'TD', 'Rec',
           'Yds.1', 'TD.1', 'College/Univ'],
          dtype='object')




```python
nfl.columns = ['Year', 'Rnd', 'Pick', 'Player', 'Pos', 'DrAge', 'Tm', 'From', 'To',
       'AP1', 'PB', 'St', 'CarAV', 'G', 'GS', 'Att', 'Yds', 'TD', 'Rec',
       'Yds.1', 'TD.1', 'College/Univ']
```

### Getting Rid of Some Missing Data


```python
nfl.isnull().sum()
```




    Year              0
    Rnd               0
    Pick              0
    Player            0
    Pos               0
    DrAge           344
    Tm                0
    From            361
    To              361
    AP1               0
    PB                0
    St                0
    CarAV           361
    G               361
    GS              361
    Att             450
    Yds             450
    TD              450
    Rec             488
    Yds.1           488
    TD.1            488
    College/Univ      2
    dtype: int64




```python
print("Number of Observations:", nfl.shape[0])
```

    Number of Observations: 1500



```python
## getting rid of the observations where not enough info could be found
nfl = nfl[nfl["From"].isnull() == False]
print("Number of Observations:", nfl.shape[0])
```

    Number of Observations: 1139



```python
## getting rid of the players that did not retire by 2016
nfl = nfl[nfl["To"]!=2016]
print("Number of Observations:", nfl.shape[0])
```

    Number of Observations: 1037



```python
nfl.isnull().sum()
```




    Year              0
    Rnd               0
    Pick              0
    Player            0
    Pos               0
    DrAge             0
    Tm                0
    From              0
    To                0
    AP1               0
    PB                0
    St                0
    CarAV             0
    G                 0
    GS                0
    Att              88
    Yds              88
    TD               88
    Rec             127
    Yds.1           127
    TD.1            127
    College/Univ      0
    dtype: int64



## Finding New Data

When the original .csv file was extracted, it contained a column that had the player's name along with a snippet of the URL that was part of their ProFootballReference page. This function returns a list containing the player's name and respective ProFootballReference URL. We run this function and then append the output sequentially to our existing dataset.


```python
baseurl = "http://www.pro-football-reference.com/players/"
def split_player(row):
    split_list = row["Player"].split("\\")
    player_name = split_list[0]
    player_url_code = split_list[1]
    first_letter = player_url_code[0]
    full_url = baseurl + first_letter + "/" + player_url_code + ".htm"
    return [player_name, full_url]
a = nfl.apply(split_player,axis=1)
```


```python
# converted the lists into numpy arrays and then added them into the dataframe
nfl["Player"] = np.array([row[0] for row in a])
nfl["PFR_URL"] = np.array([row[1] for row in a])
```


```python
nfl.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Year</th>
      <th>Rnd</th>
      <th>Pick</th>
      <th>Player</th>
      <th>Pos</th>
      <th>DrAge</th>
      <th>Tm</th>
      <th>From</th>
      <th>To</th>
      <th>AP1</th>
      <th>...</th>
      <th>G</th>
      <th>GS</th>
      <th>Att</th>
      <th>Yds</th>
      <th>TD</th>
      <th>Rec</th>
      <th>Yds.1</th>
      <th>TD.1</th>
      <th>College/Univ</th>
      <th>PFR_URL</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>35</th>
      <td>2015</td>
      <td>5</td>
      <td>138</td>
      <td>David Cobb</td>
      <td>RB</td>
      <td>22.0</td>
      <td>TEN</td>
      <td>2015.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>7.0</td>
      <td>1.0</td>
      <td>52.0</td>
      <td>146.0</td>
      <td>1.0</td>
      <td>1.0</td>
      <td>-2.0</td>
      <td>0.0</td>
      <td>Minnesota</td>
      <td>http://www.pro-football-reference.com/players/...</td>
    </tr>
    <tr>
      <th>37</th>
      <td>2015</td>
      <td>5</td>
      <td>155</td>
      <td>Karlos Williams</td>
      <td>RB</td>
      <td>22.0</td>
      <td>BUF</td>
      <td>2015.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>11.0</td>
      <td>3.0</td>
      <td>93.0</td>
      <td>517.0</td>
      <td>7.0</td>
      <td>11.0</td>
      <td>96.0</td>
      <td>2.0</td>
      <td>Florida St.</td>
      <td>http://www.pro-football-reference.com/players/...</td>
    </tr>
    <tr>
      <th>40</th>
      <td>2015</td>
      <td>6</td>
      <td>205</td>
      <td>Josh Robinson</td>
      <td>RB</td>
      <td>23.0</td>
      <td>IND</td>
      <td>2015.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>5.0</td>
      <td>0.0</td>
      <td>17.0</td>
      <td>39.0</td>
      <td>0.0</td>
      <td>6.0</td>
      <td>33.0</td>
      <td>0.0</td>
      <td>Mississippi St.</td>
      <td>http://www.pro-football-reference.com/players/...</td>
    </tr>
    <tr>
      <th>43</th>
      <td>2015</td>
      <td>7</td>
      <td>231</td>
      <td>Joey Iosefa</td>
      <td>FB</td>
      <td>24.0</td>
      <td>TAM</td>
      <td>2015.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>2.0</td>
      <td>0.0</td>
      <td>15.0</td>
      <td>51.0</td>
      <td>0.0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>Hawaii</td>
      <td>http://www.pro-football-reference.com/players/...</td>
    </tr>
    <tr>
      <th>45</th>
      <td>2014</td>
      <td>2</td>
      <td>54</td>
      <td>Bishop Sankey</td>
      <td>RB</td>
      <td>21.0</td>
      <td>TEN</td>
      <td>2014.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>29.0</td>
      <td>12.0</td>
      <td>199.0</td>
      <td>762.0</td>
      <td>3.0</td>
      <td>32.0</td>
      <td>272.0</td>
      <td>1.0</td>
      <td>Washington</td>
      <td>http://www.pro-football-reference.com/players/...</td>
    </tr>
  </tbody>
</table>
<p>5 rows x 23 columns</p>
</div>



Since the original .csv file did not contain the players' height and weight, this function was created to take in a player's respective URL and parse the website to find their height and weight using BeautifulSoup4. If the info could not be found, it would be assigned a missing data value using an error exception. 


```python
def player_info(row):
    response = requests.get(row["PFR_URL"])
    content = response.content
    parser = BeautifulSoup(content, 'html.parser')
    try:
        height = parser.find_all(itemprop="height")[0].text
        weight = parser.find_all(itemprop="weight")[0].text
    except IndexError:
        height=weight=None
    return height, weight

a = nfl.apply(player_info, axis=1)
print(a.head())
```

    35    (5-11, 229lb)
    37     (6-1, 225lb)
    40     (5-9, 215lb)
    43     (6-0, 245lb)
    45    (5-10, 209lb)
    dtype: object



```python
nfl["Height"] = np.array([row[0] for row in a])
nfl["Weight"] = np.array([row[1] for row in a])
```


```python
## deleting the observations where no height or weight could be parsed
nfl = nfl[nfl["Height"].isnull() == False]
nfl = nfl[nfl["Weight"].isnull() == False]
```


```python
## converting the height from character to integer 
def convert_height(row):
    height = row["Height"].split("-")
    converted_height = 12*int(height[0]) + int(height[1])
    return converted_height
nfl["Height"] = nfl.apply(convert_height,axis=1)
```


```python
## converting the weight from character to integer
def convert_weight(row):
    weight = int(row["Weight"][:3])
    return weight
nfl["Weight"] = nfl.apply(convert_weight, axis=1)
```


```python
nfl.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Year</th>
      <th>Rnd</th>
      <th>Pick</th>
      <th>Player</th>
      <th>Pos</th>
      <th>DrAge</th>
      <th>Tm</th>
      <th>From</th>
      <th>To</th>
      <th>AP1</th>
      <th>...</th>
      <th>Att</th>
      <th>Yds</th>
      <th>TD</th>
      <th>Rec</th>
      <th>Yds.1</th>
      <th>TD.1</th>
      <th>College/Univ</th>
      <th>PFR_URL</th>
      <th>Height</th>
      <th>Weight</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>35</th>
      <td>2015</td>
      <td>5</td>
      <td>138</td>
      <td>David Cobb</td>
      <td>RB</td>
      <td>22.0</td>
      <td>TEN</td>
      <td>2015.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>52.0</td>
      <td>146.0</td>
      <td>1.0</td>
      <td>1.0</td>
      <td>-2.0</td>
      <td>0.0</td>
      <td>Minnesota</td>
      <td>http://www.pro-football-reference.com/players/...</td>
      <td>71</td>
      <td>229</td>
    </tr>
    <tr>
      <th>37</th>
      <td>2015</td>
      <td>5</td>
      <td>155</td>
      <td>Karlos Williams</td>
      <td>RB</td>
      <td>22.0</td>
      <td>BUF</td>
      <td>2015.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>93.0</td>
      <td>517.0</td>
      <td>7.0</td>
      <td>11.0</td>
      <td>96.0</td>
      <td>2.0</td>
      <td>Florida St.</td>
      <td>http://www.pro-football-reference.com/players/...</td>
      <td>73</td>
      <td>225</td>
    </tr>
    <tr>
      <th>40</th>
      <td>2015</td>
      <td>6</td>
      <td>205</td>
      <td>Josh Robinson</td>
      <td>RB</td>
      <td>23.0</td>
      <td>IND</td>
      <td>2015.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>17.0</td>
      <td>39.0</td>
      <td>0.0</td>
      <td>6.0</td>
      <td>33.0</td>
      <td>0.0</td>
      <td>Mississippi St.</td>
      <td>http://www.pro-football-reference.com/players/...</td>
      <td>69</td>
      <td>215</td>
    </tr>
    <tr>
      <th>43</th>
      <td>2015</td>
      <td>7</td>
      <td>231</td>
      <td>Joey Iosefa</td>
      <td>FB</td>
      <td>24.0</td>
      <td>TAM</td>
      <td>2015.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>15.0</td>
      <td>51.0</td>
      <td>0.0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>Hawaii</td>
      <td>http://www.pro-football-reference.com/players/...</td>
      <td>72</td>
      <td>245</td>
    </tr>
    <tr>
      <th>45</th>
      <td>2014</td>
      <td>2</td>
      <td>54</td>
      <td>Bishop Sankey</td>
      <td>RB</td>
      <td>21.0</td>
      <td>TEN</td>
      <td>2014.0</td>
      <td>2015.0</td>
      <td>0</td>
      <td>...</td>
      <td>199.0</td>
      <td>762.0</td>
      <td>3.0</td>
      <td>32.0</td>
      <td>272.0</td>
      <td>1.0</td>
      <td>Washington</td>
      <td>http://www.pro-football-reference.com/players/...</td>
      <td>70</td>
      <td>209</td>
    </tr>
  </tbody>
</table>
<p>5 rows x 25 columns</p>
</div>




```python
## Output the new dataframe into a new .csv file 
nfl.to_csv("nfl.csv")
```


Methodology- Analyis
====================

Our analysis will employ the theory of Survival Analysis, which measures
survival probability and instantaneous rate of hazard for an event of
interest over a given time period.

We are interested in the amount of games (our time variable) it takes
for an NFL runningback's professional career to end (our event of
interest). Thanks to our web scraping process, we now have a large,
informative and (somewhat) tidy dataset. It is now time to read our
finished product (nfl.csv) from our Python program into R.

    nfl <- read.csv("filepath/nfl.csv")

To install necessary packages, use:

    install.packages("package")

To access the installed package:

    library(package)
    
Here are the packages we used for our analysis:

    survival
    ggplot2
    KMSurv
    flexsurv
    survminer

We also make use of the ggsurv funtion, documented here:
<https://www.r-statistics.com/2013/07/creating-good-looking-survival-curves-the-ggsurv-function/>

Further Tidying
---------------

As it turns out, our dataset is still a bit on the messy side. We have
some measures associated to each player that cannot be of use in
survival analysis. We also do not have a variable set to represent our
event of interest, retirement. We need to make a few adjustments before
we can start our analysis.

Tidying up:

A few averages, and other stats:

    nfl$YPC <- nfl$Yds / nfl$Att
    nfl$Years <- nfl$To - nfl$From
    nfl$PB.1 <- ifelse(nfl$PB >= 1, 1, 0) #binary predictor
    nfl$AP1.1 <- ifelse(nfl$AP1 >= 1, 1, 0)
    nfl$BMI <- (nfl$Weight / (nfl$Height * nfl$Height)) * 703

We are now ready to begin performing survival analysis on the career
lengths of NFL running backs.

A Brief Overview of Survival Analysis
-------------------------------------

-   Two primary variables of interest for building models:
    -   Duration of time until event or censoring
    -   Binary indicator of event for each observation
        -   0; censored (left the study or did not experience event
            during study)
        -   1; experienced the event
-   Let T = Failure time (in the context of our study, T = games played
    until retirement)
-   Let *t*<sub>*i*</sub> denote a given time
-   Then we can define our HAZARD FUNCTION as:

*h*(*t*<sub>*i*</sub>)=*P**r*(*T* = *t*<sub>*i*</sub>|*T* ≥ *t*<sub>*i*</sub>)

-   Our SURVIVAL FUNCTION is thus defined as:

*S*(*T*)=∏<sub>*t*<sub>*i*</sub> ≤ *T*</sub>(1 − *h*(*t*<sub>*i*</sub>))

Kaplan-Meier Estimates:
-----------------------

We estimate the survival function using Kaplan-Meier Estimation, which
computes $\\hat{S}(T)$ as a function of each
*t*<sub>*i*</sub> ∈ \[0, 1, ...239\]. These are best used when
considering the entire subject population's aggregate survival with no
additional covariates, or with a few discrete valued covariate levels.
We make use of the ggsurv function here to create aesthetically pleasing
survival plots:

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/unnamed-chunk-10-1.png' >

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/unnamed-chunk-10-2.png' >

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/unnamed-chunk-10-3.png' >

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/unnamed-chunk-10-4.png' >

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/unnamed-chunk-10-5.png' >



Cox Models:
-----------

The KM Estimator is limited because it only considers a single
homogenous population at a time. We use the Cox Proportional Hazards
model to measure the effects of particular covariates on career
survival, or more specifically, the instantaneous rates of hazard. With
this very handy tool, we are able to judge the level at which covariates
such as BMI influence a player's career length. Some theory of note:

-   Let X be a vector of data values associated to a given observation

-   The Cox Model is given by:

$h(t,X) = h\_0(t) \* exp( \\sum\_{i = 1}^n \\beta\_i X\_i )$

-   Baseline hazard rate as a function of time (if all
    *X*<sub>*i*</sub> = 0 for a given observation, then
    *h*<sub>0</sub>(*t*) is the actual hazard rate)

<!-- -->

    cox <- coxph(Surv(G,Retired)~BMI+YPC+DrAge, data = nfl.ret)
    summary(cox)

    ## Call:
    ## coxph(formula = Surv(G, Retired) ~ BMI + YPC + DrAge, data = nfl.ret)
    ## 
    ##   n= 932, number of events= 932 
    ##    (82 observations deleted due to missingness)
    ## 
    ##           coef exp(coef) se(coef)      z Pr(>|z|)    
    ## BMI   -0.07703   0.92586  0.01439 -5.352 8.71e-08 ***
    ## YPC   -0.20421   0.81529  0.02986 -6.838 8.02e-12 ***
    ## DrAge  0.17489   1.19111  0.04337  4.033 5.52e-05 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ##       exp(coef) exp(-coef) lower .95 upper .95
    ## BMI      0.9259     1.0801    0.9001    0.9524
    ## YPC      0.8153     1.2266    0.7689    0.8644
    ## DrAge    1.1911     0.8396    1.0941    1.2968
    ## 
    ## Concordance= 0.591  (se = 0.011 )
    ## Rsquare= 0.078   (max possible= 1 )
    ## Likelihood ratio test= 75.55  on 3 df,   p=2.22e-16
    ## Wald test            = 92.89  on 3 df,   p=0
    ## Score (logrank) test = 87.74  on 3 df,   p=0

Using AIC/BIC as a criterion for our model we find that our three most
significant covariates are BMI, Yards/Carry and Draft Age. Our model is
given by:

*h*(*t*, *X*)=*h*<sub>0</sub>(*t*)\**e**x**p*(( − .0770 \* *B**M**I*)+(−.2042 \* *Y**P**C*)+(.1749 \* *D**r**a**f**t**A**g**e*))

The Proportional Hazards Assumption
-----------------------------------

The key assumption for the Cox Model is that covariate effects on
survival are independent of time. We can test this using Schoenfeld
Residuals. We are looking for a mean of 0 for the entire time duration,
which suggests that errors are evenly distributed over time. Further,
there is a p-value associated to each covariate. The hypotheses yielding
each probability measure are:

*H*<sub>0</sub>: The covariate's effect is independent of time
*H*<sub>1</sub>: The covariate's effect exhibits time-dependency

A low p-value indicates that we should consider omitting the associated
covariate.
<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/unnamed-chunk-12-1.png' >

We are thrilled with these results. Our model very much aligns with the
Proportional Hazards assumption.

Examining Our Model's Fit
-------------------------

Now that we have a legitimate model in our hands, we can visualize the
effects of different covariate levels on career survival:

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/bmi.png' >
<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/npc.png' >
<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/drage.png' >

Fun With Our Model: A Tale of 3 RBs
-----------------------------------

We can use our model to estimate real-life career survival probability.
Here is a Kaplan-Meier estimate for SD Chargers legend Ladainian
Tomlinson made from our Cox model:

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/lt.png' >

The black vertical line denotes the actual number of games LT played in
his NFL career. 

For Ezekiel Elliott, we can provide an estimate for the
probability he is still in the league after a given amount of games. He
has only played 1 season (16 games), and given his measurements it is no
surprise that he has made it this far:

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/zeke.png' >

Here is the estimated career survival probability for Bo Jackson,
arguably the greatest pure athlete in American history:

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/bojax.png' >

Bo Jackson only played in three seasons, although he moonlighted as a
star MLB player as well. His career was tragically ended by a catastrophic
hip injury; the allegation is that the injury was worsened by Bo's prior
steroid abuse. It is important to note here that statistical models such as
KM estimates and Cox PH models are mere approximations of reality, and
cannot in any way reliably predict real-life as it unfolds, but can be very
useful to elucidate interesting relationships between two or more phenomena.

Bonus: All-Pro vs. Pro-Bowl
---------------------------

We figured that the Pro-Bowl and All-Pro covariates were likely highly
significant in explaining career lengths amongst NFL players. However,
these did not meet the Proportional Hazards assumption. Still seeking to
employ the power of these covariates, we seek to find which accolade is
more associated to a lengthy professional career. It should be noted
that the presence of both accolades is the best indicator of a long
playing career.


<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/appb1.png' >
<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/appb2.png' >

The second plot is incomplete. We find that All-Pro status seems to
imply being a Pro-Bowler as well. Generally, an All-Pro will not go long
without being selected to a Pro-Bowl.

Fitting a Distribution to Our Estimate:
---------------------------------------

We can fit a parametric distribution to our overall survival curve.
Observe:

    ## Call:
    ## flexsurvreg(formula = Surv(G, Retired) ~ 1, data = nfl.ret, dist = "gengamma")
    ## 
    ## Estimates: 
    ##        est     L95%    U95%    se    
    ## mu     4.3805  4.2774  4.4837  0.0526
    ## sigma  0.7168  0.6541  0.7856  0.0335
    ## Q      1.6940  1.4332  1.9548  0.1331
    ## 
    ## N = 1014,  Events: 1014,  Censored: 0
    ## Total time at risk: 58734
    ## Log-likelihood = -5101.664, df = 3
    ## AIC = 10209.33

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/unnamed-chunk-16-1.png' >

We are impressed by the goodness of this fit. Our parameters for the
distribution were estimated to be: (mu = 4.3805, sigma = .7168, Q =
1.694)

More on the Generalized Gamma distribution can be found here:
<https://en.wikipedia.org/wiki/Generalized_gamma_distribution>

Summary and Resources
---------------------

For this project, our goal was to examine the statistical effects of
career statistics, accolades and physical measurements on the career
lengths of runningbacks in the NFL. Upon obtaining the dataset via
Python methods, we switched to R and implemented theoretical tools of survival
analysis such as the Kaplan Meier estimator and the Cox Proportional
Hazards model. We found that there are three highly significant and
time-independent covariates which can tell us a great deal about an NFL
running back's potential career length: the age at which a player was
drafted, the player's BMI, and the player's Yards per Carry statistic.

Key Results
--------------------------

1.  Our estimated career survival curve for NFL RBs fits a Generalized
    Gamma Distribution with parameters (mu = 4.3805, sigma = .7168, Q
    = 1.694).

2.  BMI is highly significant in predicting career length, having the
    largest magnitude of the three predictors in our model. Players with
    a higher computed BMI will last longer in the league. Since BMI
    loses predictive power in terms of indicating obesity when
    considering extremely muscular and athletic individuals (such as
    NFL RBs) the measure becomes one of body density. Specifically, the
    stockier a RB's build is, the longer we can expect them to last in
    the league.

3.  Draft Age is highly significant in predicting career length. On
    average, the earlier a player enters the NFL, the longer it will
    take for their athletic ability to decrease to the point of seeking
    retirement from the league.

4.  Yards per carry is also very significant. As an average measure, it
    is a prime indicator of how *good* an NFL RB is in their career. Of
    course, players with higher YPC can be expected to have lasted
    longer in the league.

5.  All-Pro and Pro-Bowl status are indicators of a player's quality of
    play through their career. Perhaps trivially, players with these
    accolades lasted far longer than those who never acheived them. We
    found that All-Pro was a significantly better predictor of career
    longevity than Pro-Bowl.



Acknowledgments
---------------

<http://stackoverflow.com/questions/26296020/github-displays-all-code-chunks-from-readme-rmd-despite-include-false>

<https://www.r-statistics.com/2013/07/creating-good-looking-survival-curves-the-ggsurv-function/>

<https://www.stat.ubc.ca/~rollin/teach/643w04/lec/node69.html>
