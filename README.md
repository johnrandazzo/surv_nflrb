# surv_nflrb
Survival Analysis of NFL Running Backs. More info to come. A function of Data Science at UCSB.

This README file is subject to change, and is badly fragmented as of this past update. Last update 2/24/17.

# Abstract

This project focuses on using basic survival analysis techniques to determine factors influencing career length of NFL running backs, employing Kaplan-Meier esimates and Cox Proportional Hazards modeling procedures with the aid of RStudio and its [survival](https://github.com/cran/survival) library. We extract data from pro-football-reference.com using .csv files for career statistics and [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/) for physical measurements. Combined with the [pandas](http://pandas.pydata.org/) library, we were able to the excruciating tedium of manual data entry. We present our results in a visually appealing and easily comprehensible manner through the use of [ggplot2](https://github.com/tidyverse/ggplot2).

# Contributors

* Brian Luu
* Kevin Wang
* John Randazzo

# Requirements

Here are the packages you should have installed in Python to ensure this runs smoothly.
```
bs4
pandas
numpy
string
```
Be sure to pay attention to the names we use in reference, such as np for numpy or pd for pandas.

In R, so far we have used:
```
survival
ggplot2
KMSurv
Zelig
simPH
```

# Methodology- Web Scraping

##Getting started with the .csv file
1. Start by going here (http://www.pro-football-reference.com/draft/) and selecting RB in the drop-down menu for Position. We are deeply grateful to be able to scrape their data without much consequence.
2. Next to the "Drafted Players" heading, there is an option labeled "Share & more" which we will click, yielding an option to generate a .csv file that is suitable for Microsoft Excel. This is the compressed data of 300 NFL running backs. You can literally cut and paste this whole file into your text processor of choice. (We use TextWrangler)
3. To get more observations from previous generations of NFL players, we go to the bottom of the table on the website and click "Next Page" and then repeat step 2 with one caveat: when cutting and pasting the raw data file, omit the first line with all of the columns' names.
4. With Step 3 in mind, repeat Step 2, 4 more times. You should have 1500 observations total.
5. Save your file as a .csv file and read into Python. We save it as nflrb_data.csv and that is the name we use in height_weight.py.
Yay! We are ready to plug this baby into Python.

Run height_weight.py, making sure that you have all libraries mentioned above installed in your Python environment. This will take a while... in the mean time, why not go outside? 

# Methodology- Analyis

Our analysis will employ the theory of Survival Analysis, which measures survival probability and instantaneous rate of hazard for an event of interest over a given time period. We are interested in the amount of games (our time variable) it takes for an NFL runningback's professional career to end (our event of interest). Thanks to our web scraping process, we now have a large, informative and (somewhat) tidy dataset. It is now time to read our finished product (nfl.csv) from our Python program into R.
```
nfl <- read.csv("filepath/nfl.csv")
```
To install necessary packages, use:
```
install.packages("package")
```
To access the installed package:
```
library(package)
```

# Further Tidying
As it turns out, our dataset is still a bit on the messy side. We have some measures associated to each player that cannot be of use in survival analysis. We also do not have a variable set to represent our event of interest, retirement. We need to make a few adjustments before we can start our analysis.
```
this will come later.
```



We are now ready to begin performing survival analysis on NFL running backs. 

# Kaplan-Meier Estimates for Survival Probability

We use the Kaplan-Meier estimate to depict survival probability over time. These are best used when considering the entire subject population's aggregate survival with no additional covariates, or with a few discrete valued covariate levels.


# Cox Proportional Hazards Modeling and Building a Hazard Model







# End of update!
Here is everything from 2/1/17:

General idea of our project: Collect data on NFL RBs, career metrics, physical measures, accolade status, (MVP, All-Pro, etc.) and most importantly, whether or not the player in question is indeed retired.
This is the main challenge of this project. We will need to devise a systematic method of collecting very specific data from a large quantity of pages on the internet. 

We already have access to the following covariate values after a quick piecemeal CSV scrape off of pro-football-reference.com: Year drafted, Round Drafted, Pick number in draft, Position (HB or FB),Age when drafted, Team, Start year, End year (2016 if not retired), AP1 (First Team All-Pro Selections), Pro Bowl selections, Years spent as primary starter for team, Weighted Career Approximate Value (an advanced metric regarding a player's worth, weighing his better seasons more heavily than his worse ones), Games played, Games started, Career Rush Att, Career Rush Yds, Career Rush TD, Career Receptions, Career Receiving Yds, Career Receiving TD, College Team.

These existing data may be enough for a satisfactory survival analysis. However, I would like for this one to consider physical attributes of the players, as this must have some sort of effect on career length for runningbacks. You don't see 5'9, 170-pounders make it in the NFL for very long: we suspect bigger and more durable runningbacks to have longer careers, on average.

We will need to refer to data scraping methods in order to systematically collect and organize data regarding physical attributes. By using the Beautiful Soup library in Python, we will parse each runningback's page on pro-football-reference.com and find their height and weight, and then add that to their existing career statistics. This is the largest challenge in our project.

After the data collection process, we will load the dataset into R to perform analysis, primarily employing the survival library. We will create Kaplan Meier estimates and build a Cox Proportional Hazards model using our dataset. The Cox PH model is unintelligible to a layman in survival analysis but we can present hazard ratios (the output parameters of the model) visually to really wow our readers. We will become very, very familiar with plotting in R and building other visual aids. As time permits, we may build predictive models, or run other analyses which pique our curiousity.

Here is an early version of our abstract, which is also subject to change:

##Abstract 

This project focuses on using basic survival analysis techniques to determine factors influencing career length of NFL running backs, employing Kaplan-Meier esimates and Cox Proportional Hazards modeling procedures with the aid of RStudio and its [survival](https://github.com/cran/survival) library. We extract data from pro-football-reference.com using .csv files for career statistics and Beautiful Soup for physical measurements. The pandas library in Python was used to manage our dataset and aided us in averting the excruciating tedium of manual data entry. We present our results in a visually appealing and easily comprehensible manner through the use of (some library in R... IDK yet).


Thanks for reading!!!! (-:
