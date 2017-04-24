
# Survival Analysis for Running Backs

The csv file being used in this project was extracted from the site ProFootballReference. It contains a large sample of the desired population of running backs that will be used for the survival analysis of running backs in the NFL based on several attributes. 

## Importing the Required Libraries


```python
import pandas as pd
import numpy as np
from bs4 import BeautifulSoup
import requests
```

## Minor Cleanup of the Dataset


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
<p>5 rows × 24 columns</p>
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
<p>5 rows × 22 columns</p>
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



## Adding New Data 

When the original csv file was extracted, it contained a column that had the player's name along with a snippet of the URL that was part of their ProFootballReference page. This function returns a 2X2 matrix that contains lists of the player's name and respective ProFootballReference URL. 


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
<p>5 rows × 23 columns</p>
</div>



Since the original csv file did not contain the players' height and weight, this function was created to take in a player's respective URL and parse the website to find their height and weight using BeautifulSoup4. If the info could not be found, it would be assigned a missing data value using an error exception. 


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
<p>5 rows × 25 columns</p>
</div>




```python
## Outputted the new dataframe into a new csv file 
nfl.to_csv("new_nflrb_data.csv")
```
