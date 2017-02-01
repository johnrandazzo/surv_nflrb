# surv_nflrb
Survival Analysis of NFL Running Backs. More info to come. A function of Data Science at UCSB.

This README file is subject to change. Last update 2/1/17.

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
