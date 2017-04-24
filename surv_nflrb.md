Abstract
--------

This project focuses on using basic survival analysis techniques to
determine factors influencing career length of NFL running backs,
employing Kaplan-Meier esimates and Cox Proportional Hazards modeling
procedures with the aid of RStudio and its
[survival](https://github.com/cran/survival) library. We extract data
from pro-football-reference.com using .csv files for career statistics
and [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/) for
physical measurements. Combined with the
[pandas](http://pandas.pydata.org/) library, we were able to the
excruciating tedium of manual data entry. We present our results in a
visually appealing and easily comprehensible manner through the use of
[ggplot2](https://github.com/tidyverse/ggplot2).

Contributors
------------

-   Brian Luu
-   Kevin Wang
-   John Randazzo

Requirements
------------

Here are the packages you should have installed in Python to ensure this
runs smoothly.

    bs4
    pandas
    numpy
    string

Be sure to pay attention to the names we use in reference, such as np
for numpy or pd for pandas.

In R, these packages need to be installed:

    survival
    ggplot2
    KMSurv
    flexsurv
    survminer

We also make use of the ggsurv funtion, documented here:
<https://www.r-statistics.com/2013/07/creating-good-looking-survival-curves-the-ggsurv-function/>

Motivation
==========

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/giphy-downsized.gif' >

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

Run the code in RB.ipynb, making sure that you have all libraries
mentioned above installed in your Python environment. This will take a
while... in the mean time, why not go outside?

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

Further Tidying
---------------

As it turns out, our dataset is still a bit on the messy side. We have
some measures associated to each player that cannot be of use in
survival analysis. We also do not have a variable set to represent our
event of interest, retirement. We need to make a few adjustments before
we can start our analysis.

Tidying up:

    nfl$Rk <- NULL
    nfl$College.Univ <- NULL
    nfl$Unnamed..23 <- NULL
    nfl$Retired <- ifelse(nfl$To == 2016, 0, 1)
    nfl[is.na(nfl)] <- 0
    nfl <- nfl[!nfl$From == 0,]
    nfl <- nfl[!nfl$Weight == 0,]

A few averages, and other stats:

    nfl$YPC <- nfl$Yds / nfl$Att
    nfl$Years <- nfl$To - nfl$From
    nfl$Years <- ifelse(nfl$Years == 0, 1, nfl$Years) #for rookies this yr
    nfl$PB.1 <- ifelse(nfl$PB >= 1, 1, 0) #binary predictor
    nfl$AP1.1 <- ifelse(nfl$AP1 >= 1, 1, 0)
    nfl$BMI <- (nfl$Weight / (nfl$Height * nfl$Height)) * 703
    nfl$bmi.cat <- ifelse(nfl$BMI >= median(nfl$BMI), 1, 0)

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

A little bit about censoring moving forward
-------------------------------------------

From <https://www.stat.ubc.ca/~rollin/teach/643w04/lec/node69.html>

"First and foremost is the issue of non-informative censoring. To
satisfy this assumption, the design of the underlying study must ensure
that the mechanisms giving rise to censoring of individual subjects are
not related to the probability of an event occurring...Violation of this
assumption can invalidate just about any sort of survival analysis, from
Kaplan-Meier estimation to the Cox model."

The value of our event of interest (retirement: 0 for Not Retired (still
active in NFL today) and 1 for Retired) is directly related to when the
player enters the league. If we move forward with the analysis including
these censored observations, we will confound our results, and even
worse, we will violate a key assumption of survival analysis. Data
values for a player that is still in the NFL will not yield any
information for our purposes of estimating the effects of certain
covariates on time to retirement. Therefore, we will throw out all
currently active players from our data set. Now, we have no censored
observations.

So, our new dataset, nfl.ret, is generated by:

    nfl.ret <- nfl[!nfl$Retired == 0,]

Kaplan-Meier Estimates:
-----------------------

We estimate the survival function using Kaplan-Meier Estimation, which
computes $\\hat{S}(T)$ as a function of each
*t*<sub>*i*</sub> ∈ \[0, 1, ...239\]. These are best used when
considering the entire subject population's aggregate survival with no
additional covariates, or with a few discrete valued covariate levels.
We make use of the ggsurv function here to create aesthetically pleasing
survival plots:

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-10-1.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-10-2.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-10-3.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-10-4.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-10-5.png)

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
    cox

    ## Call:
    ## coxph(formula = Surv(G, Retired) ~ BMI + YPC + DrAge, data = nfl.ret)
    ## 
    ##          coef exp(coef) se(coef)     z       p
    ## BMI   -0.0770    0.9259   0.0144 -5.35 8.7e-08
    ## YPC   -0.2042    0.8153   0.0299 -6.84 8.0e-12
    ## DrAge  0.1749    1.1911   0.0434  4.03 5.5e-05
    ## 
    ## Likelihood ratio test=75.5  on 3 df, p=2.22e-16
    ## n= 932, number of events= 932 
    ##    (82 observations deleted due to missingness)

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

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-12-1.png)

We are thrilled by these results. Our model very much aligns with the
Proportional Hazards assumption.

Examining Our Model's Fit
-------------------------

Now that we have a legitimate model in our hands, we can visualize the
effects of different covariate levels on career survival:

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-13-1.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-13-2.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-13-3.png)

Bonus: All-Pro vs. Pro-Bowl
---------------------------

We figured that the Pro-Bowl and All-Pro covariates were likely highly
significant in explaining career lengths amongst NFL players. However,
these did not meet the Proportional Hazards assumption. Still seeking to
employ the power of these covariates, we seek to find which accolade is
more associated to a lengthy professional career. It should be noted
that the presence of both accolades is the best indicator of a long
playing career.

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-15-1.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-15-2.png)

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

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-16-1.png)

We are impressed by the goodness of this fit. Our parameters for the
distribution were estimated to be: (mu = 4.3805, sigma = .7168, Q =
1.694)

More on the Generalized Gamma distribution can be found here:
<https://en.wikipedia.org/wiki/Generalized_gamma_distribution>

Summary and Resources
---------------------

For this project, our goal was to examine the statistical effects of
career statistics, accolades and physical measurements on the career
lengths of runningbacks in the NFL. We employed the theory of survival
analysis, making use of such tools as the Kaplan Meier estimator and the
Cox Proportional Hazards model. We found that there are three highly
significant time-independent covariates which can tell us a great deal
about an NFL running back's career length: the age at which a player was
drafted, the player's BMI, and the player's Yards per Carry statistic.

Key Results (to be edited)
--------------------------

1.  Our estimated career survival curve for NFL RBs fits a Generalized
    Gamma Distribution with parameters (mu = 4.3805, sigma = .7168, Q
    = 1.694).

2.  BMI is highly significant in prediction of career length, having the
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

<img src='https://github.com/johnrandazzo/surv_nflrb/blob/markdown/figure-markdown_strict/giphy-downsized.gif' >

Acknowledgments
---------------

<http://stackoverflow.com/questions/26296020/github-displays-all-code-chunks-from-readme-rmd-despite-include-false>
