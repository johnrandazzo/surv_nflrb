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
    simPH

We also make use of the ggsurv funtion, documented here:
<https://www.r-statistics.com/2013/07/creating-good-looking-survival-curves-the-ggsurv-function/>

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

Run height\_weight.py, making sure that you have all libraries mentioned
above installed in your Python environment. This will take a while... in
the mean time, why not go outside?

Methodology- Analyis
====================

Our analysis will employ the theory of Survival Analysis, which measures
survival probability and instantaneous rate of hazard for an event of
interest over a given time period. We are interested in the amount of
games (our time variable) it takes for an NFL runningback's professional
career to end (our event of interest). Thanks to our web scraping
process, we now have a large, informative and (somewhat) tidy dataset.
It is now time to read our finished product (nfl.csv) from our Python
program into R.

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

    ## Warning: package 'ggplot2' was built under R version 3.3.2

<http://stackoverflow.com/questions/26296020/github-displays-all-code-chunks-from-readme-rmd-despite-include-false>

We also make use of the ggsurv function, documented here:
<https://www.r-statistics.com/2013/07/creating-good-looking-survival-curves-the-ggsurv-function/>

Tidying up:

A few averages, and other stats:

We are now ready to begin performing survival analysis on the career
lengths of NFL running backs.

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

There will be a lowdown on the theory of KM estimates here. Shout out to
Jason.

We use the Kaplan-Meier estimate to depict survival probability over
time. These are best used when considering the entire subject
population's aggregate survival with no additional covariates, or with a
few discrete valued covariate levels. We make use of the ggsurv function
here to create aesthetically pleasing survival plots, for although the
survival library is highly useful, the default plots leave a bit to be
desired.

    nfl.ret <- nfl[!nfl$Retired == 0,]

    nfl.fit.ret <- survfit(Surv(G,Retired)~1,data = nfl.ret)


    km.pb.ret <- survfit(Surv(G,Retired)~PB.1, data = nfl.ret)


    km.ap.ret <- survfit(Surv(G,Retired)~AP1.1, data = nfl.ret)


    km.age.ret <- survfit(Surv(G,Retired)~DrAge, data = nfl.ret)


    km.bmi.ret <- survfit(Surv(G,Retired)~bmi.cat, data = nfl.ret)

    ## Warning: Removed 1 rows containing missing values (geom_path).

    ## Warning: Removed 1 rows containing missing values (geom_path).

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-9-1.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-9-2.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-9-3.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-9-4.png)![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-9-5.png)

Cox Models:
-----------

We use the Cox Proportional Hazards model to measure the effects of
particular covariates on career survival, or more specifically, the
instantaneous rates of hazard. With this very handy tool, we are able to
judge the level at which covariates such as BMI influence a player's
career length.

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

    ##             rho  chisq     p
    ## BMI     0.01590 0.2124 0.645
    ## YPC     0.00831 0.0613 0.805
    ## DrAge  -0.01475 0.2099 0.647
    ## GLOBAL       NA 0.4703 0.925

    ## All Xl set to 0.

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-11-1.png)

    ## All Xl set to 0.

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-11-2.png)

    ## All Xl set to 0.

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-11-3.png)

Stratified Models: All-Pro and Pro-Bowl
---------------------------------------

We figured that the Pro-Bowl and All-Pro covariates were likely highly
significant in explaining career lengths amongst NFL players. However,
these did not meet the Proportional Hazards assumption. Still seeking to
employ the power of these covariates, we created stratified models.

Again, I will cite Jason's project or use it in some way as he explains
the theory of stratified cox models. The guy is a madman.

    #stratify pro bowl
    pb.cox <- coxph(Surv(G,Retired)~strata(PB)+DrAge+BMI+YPC, data = nfl.ret)
    summary(pb.cox)

    ## Call:
    ## coxph(formula = Surv(G, Retired) ~ strata(PB) + DrAge + BMI + 
    ##     YPC, data = nfl.ret)
    ## 
    ##   n= 932, number of events= 932 
    ##    (82 observations deleted due to missingness)
    ## 
    ##           coef exp(coef) se(coef)      z Pr(>|z|)    
    ## DrAge  0.08358   1.08717  0.04539  1.841   0.0656 .  
    ## BMI   -0.07464   0.92808  0.01483 -5.031 4.87e-07 ***
    ## YPC   -0.13375   0.87480  0.03416 -3.916 9.01e-05 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ##       exp(coef) exp(-coef) lower .95 upper .95
    ## DrAge    1.0872     0.9198    0.9946    1.1883
    ## BMI      0.9281     1.0775    0.9015    0.9555
    ## YPC      0.8748     1.1431    0.8182    0.9354
    ## 
    ## Concordance= 0.568  (se = 0.012 )
    ## Rsquare= 0.038   (max possible= 1 )
    ## Likelihood ratio test= 36.41  on 3 df,   p=6.131e-08
    ## Wald test            = 40.1  on 3 df,   p=1.017e-08
    ## Score (logrank) test = 38.99  on 3 df,   p=1.745e-08

    cox.zph(pb.cox)

    ##            rho chisq      p
    ## DrAge  -0.0393 1.598 0.2061
    ## BMI     0.0199 0.344 0.5575
    ## YPC     0.0492 2.774 0.0958
    ## GLOBAL      NA 4.966 0.1743

    #stratify all pro
    ap1.cox <- coxph(Surv(G,Retired)~strata(AP1.1)+DrAge+BMI+YPC, data = nfl.ret)
    summary(ap1.cox)

    ## Call:
    ## coxph(formula = Surv(G, Retired) ~ strata(AP1.1) + DrAge + BMI + 
    ##     YPC, data = nfl.ret)
    ## 
    ##   n= 932, number of events= 932 
    ##    (82 observations deleted due to missingness)
    ## 
    ##           coef exp(coef) se(coef)      z Pr(>|z|)    
    ## DrAge  0.14670   1.15800  0.04450  3.297 0.000977 ***
    ## BMI   -0.07546   0.92732  0.01470 -5.133 2.85e-07 ***
    ## YPC   -0.17764   0.83725  0.03172 -5.600 2.14e-08 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ##       exp(coef) exp(-coef) lower .95 upper .95
    ## DrAge    1.1580     0.8636    1.0613    1.2635
    ## BMI      0.9273     1.0784    0.9010    0.9544
    ## YPC      0.8372     1.1944    0.7868    0.8909
    ## 
    ## Concordance= 0.581  (se = 0.012 )
    ## Rsquare= 0.058   (max possible= 1 )
    ## Likelihood ratio test= 55.49  on 3 df,   p=5.402e-12
    ## Wald test            = 65.78  on 3 df,   p=3.419e-14
    ## Score (logrank) test = 62.79  on 3 df,   p=1.491e-13

    cox.zph(ap1.cox)

    ##            rho chisq     p
    ## DrAge  -0.0148 0.221 0.638
    ## BMI     0.0183 0.293 0.588
    ## YPC     0.0288 0.824 0.364
    ## GLOBAL      NA 1.339 0.720

We are intrigued by the change in these results. To investigate further,
we perform a couple quick analyses consisting of pro-bowlers and all-pro
players:

    nfl.pb <- nfl.ret[nfl.ret$PB.1 > 0,]
    nfl.ap <- nfl.ret[nfl.ret$AP1.1 > 0,]
    pb.ap.km <- survfit(Surv(G,Retired)~AP1.1, data = nfl.pb)
    ggsurv(pb.ap.km, main = "All-Pro vs Not All-Pro, Amongst Pro-Bowlers")

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-13-1.png)

    ap.pb.km <- survfit(Surv(G,Retired)~PB.1, data = nfl.ap)
    ggsurv(ap.pb.km, main = "Pro-Bowl vs Not Pro-Bowl, Amongst All-Pros")

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-13-2.png)

As can be seen, the second plot is incomplete. This is because All-Pro
status seems to imply being a Pro-Bowler as well, while the converse is
not supported. Generally, an All-Pro will not go long without being
selected to a Pro-Bowl.

    pb.only.cox <- coxph(Surv(G,Retired)~BMI+YPC+DrAge, data = nfl.pb)
    pb.only.cox

    ## Call:
    ## coxph(formula = Surv(G, Retired) ~ BMI + YPC + DrAge, data = nfl.pb)
    ## 
    ##          coef exp(coef) se(coef)     z     p
    ## BMI   -0.0808    0.9224   0.0402 -2.01 0.044
    ## YPC   -0.0484    0.9527   0.2141 -0.23 0.821
    ## DrAge  0.1132    1.1198   0.1167  0.97 0.332
    ## 
    ## Likelihood ratio test=5.54  on 3 df, p=0.136
    ## n= 130, number of events= 130

    cox.zph(pb.only.cox)

    ##             rho   chisq     p
    ## BMI     0.00540 0.00384 0.951
    ## YPC     0.01085 0.01591 0.900
    ## DrAge  -0.00542 0.00402 0.949
    ## GLOBAL       NA 0.02479 0.999

    ap.only.cox <- coxph(Surv(G,Retired)~BMI+YPC+DrAge, data = nfl.ap)
    ap.only.cox

    ## Call:
    ## coxph(formula = Surv(G, Retired) ~ BMI + YPC + DrAge, data = nfl.ap)
    ## 
    ##          coef exp(coef) se(coef)     z     p
    ## BMI   -0.0992    0.9056   0.0597 -1.66 0.097
    ## YPC    0.0785    1.0817   0.3367  0.23 0.816
    ## DrAge  0.1444    1.1553   0.1834  0.79 0.431
    ## 
    ## Likelihood ratio test=3.71  on 3 df, p=0.294
    ## n= 47, number of events= 47

    cox.zph(ap.only.cox)

    ##            rho chisq     p
    ## BMI    -0.1029 0.459 0.498
    ## YPC     0.0779 0.292 0.589
    ## DrAge   0.0791 0.314 0.575
    ## GLOBAL      NA 1.078 0.782

All-Pro selections and Pro-Bowl selections are both prime indicators
that a player is very good, which implies that they will remain in the
league for a long time. However, there is a subtle yet significant
distinction between the two: NFL fans vote for Pro-Bowl selections,
while the Associated Press selects the All-Pro teams. We take it by
faith that the the selection of the All-Pro teams under the auspices of
the AP is more indicative of higher player quality than the Pro Bowl
selections made by the highly biased fans of the NFL. In terms of our
analysis, we find that being an All-Pro is certainly more meaningful
than being named to the Pro-Bowl. But how much more meaningful is it? To
find out, we take a subset of the data consisting of all players who
ever had a pro-bowl selection. We then make a Cox Model to assess the
effect of All-Pro selections compared to a player who had Pro-Bowl
selections, but not All-Pro selections.

    cox.ap.v.pb <- coxph(Surv(G,Retired)~AP1, data = nfl.pb)
    cox.ap.v.pb

    ## Call:
    ## coxph(formula = Surv(G, Retired) ~ AP1, data = nfl.pb)
    ## 
    ##        coef exp(coef) se(coef)    z      p
    ## AP1 -0.2882    0.7496   0.0929 -3.1 0.0019
    ## 
    ## Likelihood ratio test=12.1  on 1 df, p=0.000503
    ## n= 130, number of events= 130

    cox.zph(cox.ap.v.pb)

    ##      rho chisq     p
    ## AP1 0.12  2.13 0.145

    csl.ap.pb <- coxsimLinear(cox.ap.v.pb, b = "AP1", Xj = seq(0,6, by = 1))

    ## All Xl set to 0.

    simGG(csl.ap.pb)

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-15-1.png)

Although this model passes the test for the proportional hazards
assumption, there is lingering suspicion that the number of All-Pro
selections is inherently time-dependent. Because of this and the small
number of 2-year, 3-year, etc. All-Pro runningbacks, we categorize the
All-Pro selection values to compensate for the variation in number of
All-Pro selections. Therefore we use a binary measure: 0 for never an
All-Pro, and 1 for at least one All-Pro selection.

    cox.ap.mod.v.pb <- coxph(Surv(G,Retired)~AP1.1, data = nfl.pb)
    cox.ap.mod.v.pb

    ## Call:
    ## coxph(formula = Surv(G, Retired) ~ AP1.1, data = nfl.pb)
    ## 
    ##         coef exp(coef) se(coef)     z      p
    ## AP1.1 -0.532     0.588    0.191 -2.78 0.0054
    ## 
    ## Likelihood ratio test=8.12  on 1 df, p=0.00437
    ## n= 130, number of events= 130

    cox.zph(cox.ap.mod.v.pb)

    ##          rho chisq     p
    ## AP1.1 0.0654  0.55 0.458

    csl.ap.mod.pb <- coxsimLinear(cox.ap.mod.v.pb, b = "AP1.1", Xj = seq(0,1, by = 1))

    ## All Xl set to 0.

    simGG(csl.ap.mod.pb)

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-16-1.png)

Clearly, All-Pro selection trumps Pro-Bowl selections in terms of
predicting a runningback's longevity.

Parametric models:
------------------

We can fit a parametric distribution to our survival curve. Observe:

    nfl.fit.ret <- survfit(Surv(G,Retired)~1,data = nfl.ret)
    f1 <- flexsurvreg(Surv(G,Retired)~1,data = nfl.ret, dist = "gengamma")
    f1

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

    plot(f1, xlab = "Games Played", ylab = "Survival Probability", main = "Generalized Gamma fitted to Kaplan-Meier Estimate")

![](surv_nflrb_files/figure-markdown_strict/unnamed-chunk-18-1.png)

We are impressed by the goodness of this fit. Our parameters for the
distribution were estimated to be: (mu = 4.3805, sigma = .7168, Q =
1.694) More on the Generalized Gamma distribution can be found here:
<https://en.wikipedia.org/wiki/Generalized_gamma_distribution>

Summary and Resources
---------------------

For this project, our goal was to examine the statistical effects of
career statistics, accolades and physical measurements on the career
lengths of runningbacks in the NFL. We employed the theory of survival
analysis, making use of such tools as the Kaplan Meier estimator and the
Cox Proportional Hazards model. We found that there are three extremely
significant covariates which can tell us a great deal about an NFL
running back's career length: the age at which a player was drafted, the
player's BMI, and the player's Yards per Carry statistic. Additionally,
we stratified our dataset in order to examine the effects of two yearly
accolades as indicators of expected career length: Pro-Bowl and All-Pro
selection. We found that a player named to All-Pro was more likely to
have been named to the Pro Bowl, and that All-Pro is a significantly
better indicator of player career length than Pro Bowl status.

As sports fans, we found the results to be quite intuitive, but not
particularly startling:

\*A player that is younger upon entering the league has much more of his
athletic prime in front of him and should be expected to last longer in
the league than a player drafted at a more advanced age. Therefore,
draft age exhibits an inverse relation with a player's career survival
probability. Our results from our Cox Model indicate that on average,
with all other covariates at the exact same level, that a player
entering the league at an age X is about 119.11% as likely to retire at
any moment compared to a player entering the league at age X-1.

\*Players with higher BMI was found to have better chances of lasting
longer in the league than those with lower ones. Although BMI loses its
power of identifying obese or underweight individuals when computing a
value for extremely muscular humans (such as NFL players) it is still a
viable measure of physical density when comparing a large set of
athletes. When comparing all of the runningbacks in our dataset, we
found that the denser ones had better career survival, since
runningbacks are subjected to many harsh tackles by the hands of massive
defensive linemen and linebackers. Namely, we found that a single unit
increase in BMI decreases the instantaneous likelihood of retirement by
about 8%, with all other covariates held equal. We were pleased at the
significance of this result, since we toiled for a good deal of time to
obtain and systematically store our players' height and weight
measurements in order to compute each one's BMI.

\*Players with a higher career YPC (Yards per Carry) very trivially have
a better chance of lasting longer in the league than those with lower
career YPC. YPC is likely the greatest indicator of a runningback's
quality of play. If a player has a poor average, they will lose their
role as a starter, play less games throughout their career, and
ultimately retire earlier. Specifically, we found that a one unit
increase in YPC (an additional yard per carry) reduced the likelihood of
retirement by 19% on average.

\*Players selected to a Pro-Bowl but never to an All-Pro team generally
had worse career survival. We find that players fitting this criteria
are popular amongst fans for reasons outside of play quality, since fans
select the Pro-Bowl teams but the All-Pro teams are chosen by the
Associated Press, whom we can assume to be less biased in their
selections. Although an All-Pro selection is superior in predicting a
player having a longer career, both are nonetheless indicative of a good
quality player that can be expected to remain in the league for a longer
time.

Key Results (to be edited)
--------------------------

1.  Our estimated career survival curve for NFL RBs follows a
    Generalized Gamma Distribution with parameters (mu = 4.3805, sigma =
    .7168, Q = 1.694).

2.  Draft Age is highly significant in predicting career length. On
    average, the earlier a player enters the NFL, the longer it will
    take for their athletic ability to decrease to the point of seeking
    retirement from the league.

3.  BMI is highly significant in prediction of career length. Players
    with a higher computed BMI will last longer in the league. Since BMI
    loses predictive power in terms of indicating obesity when
    considering extremely muscular and athletic individuals (such as
    NFL RBs) the measure becomes one of body density. Specifically, the
    stockier a RB's build is, the longer we can expect them to last in
    the league.

4.  Yards per carry is also very significant. As an average measure, it
    is a prime indicator of how *good* an NFL RB is in their career. Of
    course, players with higher YPC can be expected to last longer in
    the league.

5.  All-Pro and Pro-Bowl status are also indicators of a player's
    quality of play through their career. Perhaps trivially, players
    with these accolades lasted longer than those who never
    acheived them. Furthermore, we found that All-Pro was a
    significantly better predictor of career longevity than Pro-Bowl.

Acknowledgments
---------------

<http://stackoverflow.com/questions/26296020/github-displays-all-code-chunks-from-readme-rmd-despite-include-false>
