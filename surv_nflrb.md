---
title: "Survival Analysis - NFL RBs"
author: "John Randazzo"
date: "2/24/2017"
output: md_document
---

##Abstract

This project focuses on using basic survival analysis techniques to determine factors influencing career length of NFL running backs, employing Kaplan-Meier esimates and Cox Proportional Hazards modeling procedures with the aid of RStudio and its [survival](https://github.com/cran/survival) library. We extract data from pro-football-reference.com using .csv files for career statistics and [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/) for physical measurements. Combined with the [pandas](http://pandas.pydata.org/) library, we were able to the excruciating tedium of manual data entry. We present our results in a visually appealing and easily comprehensible manner through the use of [ggplot2](https://github.com/tidyverse/ggplot2).

##Contributors

* Brian Luu
* Kevin Wang
* John Randazzo


##Requirements

Here are the packages you should have installed in Python to ensure this runs smoothly.
```
bs4
pandas
numpy
string
```
Be sure to pay attention to the names we use in reference, such as np for numpy or pd for pandas.

In R, these packages need to be installed:
```
survival
ggplot2
KMSurv
flexsurv
simPH
```
We also make use of the ggsurv funtion, documented here: https://www.r-statistics.com/2013/07/creating-good-looking-survival-curves-the-ggsurv-function/

# Methodology- Web Scraping

##Getting started with the .csv file

1. Start by going here (http://www.pro-football-reference.com/draft/) and selecting RB in the drop-down menu for Position. We are deeply grateful to be able to scrape their data without much consequence.
2. Next to the "Drafted Players" heading, there is an option labeled "Share & more" which we will click, yielding an option to generate a .csv file that is suitable for Microsoft Excel. This is the compressed data of 300 NFL running backs. You can literally cut and paste this whole file into your text processor of choice. (We use TextWrangler)
3. To get more observations from previous generations of NFL players, we go to the bottom of the table on the website and click "Next Page" and then repeat step 2 with one caveat: when cutting and pasting the raw data file, omit the first line with all of the columns' names.
4. With Step 3 in mind, repeat Step 2, 4 more times. You should have 1500 observations total.
5. Save your file as a .csv file and read into Python. We save it as nflrb_data.csv and that is the name we use in the Python part.
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

##Further Tidying
As it turns out, our dataset is still a bit on the messy side. We have some measures associated to each player that cannot be of use in survival analysis. We also do not have a variable set to represent our event of interest, retirement. We need to make a few adjustments before we can start our analysis.

```{r, echo = FALSE}
nfl <- read.csv("/Users/johnrandazzo/Downloads/nfl.csv")
library(survival)
library(KMsurv)
library(ggplot2)
library(simPH)
library(flexsurv)
#knit(input="readme.rmd", output = "readme.md")

```
http://stackoverflow.com/questions/26296020/github-displays-all-code-chunks-from-readme-rmd-despite-include-false

We also make use of the ggsurv function, documented here:
https://www.r-statistics.com/2013/07/creating-good-looking-survival-curves-the-ggsurv-function/

```{r, echo = FALSE}
ggsurv <- function(s, CI = 'def', plot.cens = T, surv.col = 'gg.def',
                   cens.col = 'red', lty.est = 1, lty.ci = 2,
                   cens.shape = 3, back.white = F, xlab = 'Time',
                   ylab = 'Survival', main = ''){
 
  library(ggplot2)
  strata <- ifelse(is.null(s$strata) ==T, 1, length(s$strata))
  stopifnot(length(surv.col) == 1 | length(surv.col) == strata)
  stopifnot(length(lty.est) == 1 | length(lty.est) == strata)
 
  ggsurv.s <- function(s, CI = 'def', plot.cens = T, surv.col = 'gg.def',
                       cens.col = 'red', lty.est = 1, lty.ci = 2,
                       cens.shape = 3, back.white = F, xlab = 'Time',
                       ylab = 'Survival', main = ''){
 
    dat <- data.frame(time = c(0, s$time),
                      surv = c(1, s$surv),
                      up = c(1, s$upper),
                      low = c(1, s$lower),
                      cens = c(0, s$n.censor))
    dat.cens <- subset(dat, cens != 0)
 
    col <- ifelse(surv.col == 'gg.def', 'black', surv.col)
 
    pl <- ggplot(dat, aes(x = time, y = surv)) +
      xlab(xlab) + ylab(ylab) + ggtitle(main) +
      geom_step(col = col, lty = lty.est)
 
    pl <- if(CI == T | CI == 'def') {
      pl + geom_step(aes(y = up), color = col, lty = lty.ci) +
        geom_step(aes(y = low), color = col, lty = lty.ci)
    } else (pl)
 
    pl <- if(plot.cens == T & length(dat.cens) > 0){
      pl + geom_point(data = dat.cens, aes(y = surv), shape = cens.shape,
                       col = cens.col)
    } else if (plot.cens == T & length(dat.cens) == 0){
      stop ('There are no censored observations')
    } else(pl)
 
    pl <- if(back.white == T) {pl + theme_bw()
    } else (pl)
    pl
  }
 
  ggsurv.m <- function(s, CI = 'def', plot.cens = T, surv.col = 'gg.def',
                       cens.col = 'red', lty.est = 1, lty.ci = 2,
                       cens.shape = 3, back.white = F, xlab = 'Time',
                       ylab = 'Survival', main = '') {
    n <- s$strata
 
    groups <- factor(unlist(strsplit(names
                                     (s$strata), '='))[seq(2, 2*strata, by = 2)])
    gr.name <-  unlist(strsplit(names(s$strata), '='))[1]
    gr.df <- vector('list', strata)
    ind <- vector('list', strata)
    n.ind <- c(0,n); n.ind <- cumsum(n.ind)
    for(i in 1:strata) ind[[i]] <- (n.ind[i]+1):n.ind[i+1]
 
    for(i in 1:strata){
      gr.df[[i]] <- data.frame(
        time = c(0, s$time[ ind[[i]] ]),
        surv = c(1, s$surv[ ind[[i]] ]),
        up = c(1, s$upper[ ind[[i]] ]),
        low = c(1, s$lower[ ind[[i]] ]),
        cens = c(0, s$n.censor[ ind[[i]] ]),
        group = rep(groups[i], n[i] + 1))
    }
 
    dat <- do.call(rbind, gr.df)
    dat.cens <- subset(dat, cens != 0)
 
    pl <- ggplot(dat, aes(x = time, y = surv, group = group)) +
      xlab(xlab) + ylab(ylab) + ggtitle(main) +
      geom_step(aes(col = group, lty = group))
 
    col <- if(length(surv.col == 1)){
      scale_colour_manual(name = gr.name, values = rep(surv.col, strata))
    } else{
      scale_colour_manual(name = gr.name, values = surv.col)
    }
 
    pl <- if(surv.col[1] != 'gg.def'){
      pl + col
    } else {pl + scale_colour_discrete(name = gr.name)}
 
    line <- if(length(lty.est) == 1){
      scale_linetype_manual(name = gr.name, values = rep(lty.est, strata))
    } else {scale_linetype_manual(name = gr.name, values = lty.est)}
 
    pl <- pl + line
 
    pl <- if(CI == T) {
      if(length(surv.col) > 1 && length(lty.est) > 1){
        stop('Either surv.col or lty.est should be of length 1 in order
             to plot 95% CI with multiple strata')
      }else if((length(surv.col) > 1 | surv.col == 'gg.def')[1]){
        pl + geom_step(aes(y = up, color = group), lty = lty.ci) +
          geom_step(aes(y = low, color = group), lty = lty.ci)
      } else{pl +  geom_step(aes(y = up, lty = group), col = surv.col) +
               geom_step(aes(y = low,lty = group), col = surv.col)}
    } else {pl}
 
 
    pl <- if(plot.cens == T & length(dat.cens) > 0){
      pl + geom_point(data = dat.cens, aes(y = surv), shape = cens.shape,
                      col = cens.col)
    } else if (plot.cens == T & length(dat.cens) == 0){
      stop ('There are no censored observations')
    } else(pl)
 
    pl <- if(back.white == T) {pl + theme_bw()
    } else (pl)
    pl
  }
  pl <- if(strata == 1) {ggsurv.s(s, CI , plot.cens, surv.col ,
                                  cens.col, lty.est, lty.ci,
                                  cens.shape, back.white, xlab,
                                  ylab, main)
  } else {ggsurv.m(s, CI, plot.cens, surv.col ,
                   cens.col, lty.est, lty.ci,
                   cens.shape, back.white, xlab,
                   ylab, main)}
  pl
}
```

Tidying up:

```{r, echo = FALSE}
nfl$Rk <- NULL
nfl$College.Univ <- NULL
nfl$Unnamed..23 <- NULL
nfl$Retired <- ifelse(nfl$To == 2016, 0, 1)
nfl[is.na(nfl)] <- 0
nfl <- nfl[!nfl$From == 0,]
nfl <- nfl[!nfl$Weight == 0,]
```

A few averages, and other stats:

```{r, echo = FALSE}
nfl$YPC <- nfl$Yds / nfl$Att
nfl$Years <- nfl$To - nfl$From
nfl$Years <- ifelse(nfl$Years == 0, 1, nfl$Years) #for rookies this yr
nfl$PB.1 <- ifelse(nfl$PB >= 1, 1, 0) #binary predictor
nfl$AP1.1 <- ifelse(nfl$AP1 >= 1, 1, 0)
nfl$BMI <- (nfl$Weight / (nfl$Height * nfl$Height)) * 703
nfl$BMI.cat <- ifelse(nfl$BMI >= median(nfl$BMI), 1, 0)
```

We are now ready to begin performing survival analysis on the career lengths of NFL running backs.

##A little bit about censoring moving forward

From https://www.stat.ubc.ca/~rollin/teach/643w04/lec/node69.html

"First and foremost is the issue of non-informative censoring. To satisfy this assumption, the design of the underlying study must ensure that the mechanisms giving rise to censoring of individual subjects are not related to the probability of an event occurring...Violation of this assumption can invalidate just about any sort of survival analysis, from Kaplan-Meier estimation to the Cox model."

The value of our event of interest (retirement: 0 for Not Retired (still active in NFL today) and 1 for Retired) is directly related to when the player enters the league. If we move forward with the analysis including these censored observations, we will confound our results, and even worse, we will violate a key assumption of survival analysis. Data values for a player that is still in the NFL will not yield any information for our purposes of estimating the effects of certain covariates on time to retirement. Therefore, we will throw out all currently active players from our data set. Now, we have no censored observations. 

So, our new dataset, nfl.ret, is generated by:

```{r}
nfl.ret <- nfl[!nfl$Retired == 0,]
```

##Kaplan-Meier Estimates:

There will be a lowdown on the theory of KM estimates here. Shout out to Jason.

We use the Kaplan-Meier estimate to depict survival probability over time. These are best used when considering the entire subject population's aggregate survival with no additional covariates, or with a few discrete valued covariate levels. We make use of the ggsurv function here to create aesthetically pleasing survival plots, for although the survival library is highly useful, the default plots leave a bit to be desired. 

```{r, include = FALSE}
nfl.fit <- survfit(Surv(G,Retired)~1,data = nfl)
plot(nfl.fit)

km.pb <- survfit(Surv(G,Retired)~PB.1, data = nfl)
plot(km.pb)

km.ap <- survfit(Surv(G,Retired)~AP1.1, data = nfl)
plot(km.ap)

nfl <- nfl[!nfl$DrAge == 26,]
nfl <- nfl[!nfl$DrAge == 25,]
nfl <- nfl[!nfl$DrAge == 20,]
km.age <- survfit(Surv(G,Retired)~DrAge, data = nfl)
plot(km.age)

quantile(nfl$BMI)
nfl$bmi.cat[nfl$BMI <= 28.04896] <- 0
nfl$bmi.cat[nfl$BMI > 28.04896 & nfl$BMI <= 31.00819] <- 1
nfl$bmi.cat[nfl$BMI > 31.00819] <- 2
km.bmi <- survfit(Surv(G,Retired)~bmi.cat, data = nfl)
plot(km.bmi)

```

```{r, include = FALSE}
ggsurv(km.bmi)
ggsurv(km.age)
ggsurv(km.ap)
ggsurv(km.pb)
```

```{r}
nfl.ret <- nfl[!nfl$Retired == 0,]

nfl.fit.ret <- survfit(Surv(G,Retired)~1,data = nfl.ret)


km.pb.ret <- survfit(Surv(G,Retired)~PB.1, data = nfl.ret)


km.ap.ret <- survfit(Surv(G,Retired)~AP1.1, data = nfl.ret)


km.age.ret <- survfit(Surv(G,Retired)~DrAge, data = nfl.ret)


km.bmi.ret <- survfit(Surv(G,Retired)~bmi.cat, data = nfl.ret)
```

```{r, echo = FALSE}

ggsurv(nfl.fit.ret, xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's")

ggsurv(km.bmi.ret,xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's, Contingent on BMI")

ggsurv(km.age.ret,xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's, Contingent on Draft Age") # we exclude 20,25,26 as there are too few observations.

ggsurv(km.ap.ret,xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's, All-Pros vs. Never an All-Pro")

ggsurv(km.pb.ret,xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's, Pro-Bowlers vs. Never a Pro-Bowler")
```

##Cox Models:

We use the Cox Proportional Hazards model to measure the effects of particular covariates on career survival, or more specifically, the instantaneous rates of hazard. With this very handy tool, we are able to judge the level at which covariates such as BMI influence a player's career length. 

```{r, include = FALSE}

bmi.cox <- coxph(Surv(G,Retired)~BMI, data = nfl.ret)
summary(bmi.cox)
cox.zph(bmi.cox)

ypc.cox <- coxph(Surv(G,Retired)~YPC, data = nfl.ret)
summary(ypc.cox)
cox.zph(ypc.cox)

age.cox <- coxph(Surv(G,Retired)~DrAge, data = nfl.ret)
summary(age.cox)
cox.zph(age.cox)
```

```{r, echo = FALSE}
big.cox <- coxph(Surv(G,Retired)~BMI+YPC+DrAge, data = nfl.ret)
big.cox
cox.zph(big.cox)

csl.only.bmi <- coxsimLinear(big.cox, b = "BMI", Xj = seq(23.84,37.4,by = .1))

simGG(csl.only.bmi)

csl.only.ypc <- coxsimLinear(big.cox, b = "YPC", Xj = seq(0,5,by = .1))

simGG(csl.only.ypc)

csl.only.drage <- coxsimLinear(big.cox, b = "DrAge", Xj = seq(21,24, by = 1))

simGG(csl.only.drage)
```

##Stratified Models: All-Pro and Pro-Bowl

We figured that the Pro-Bowl and All-Pro covariates were likely highly significant in explaining career lengths amongst NFL players. However, these did not meet the Proportional Hazards assumption. Still seeking to employ the power of these covariates, we created stratified models. 

Again, I will cite Jason's project or use it in some way as he explains the theory of stratified cox models. The guy is a madman.

```{r}
#stratify pro bowl
pb.cox <- coxph(Surv(G,Retired)~strata(PB)+DrAge+BMI+YPC, data = nfl.ret)
summary(pb.cox)
cox.zph(pb.cox)

#stratify all pro
ap1.cox <- coxph(Surv(G,Retired)~strata(AP1.1)+DrAge+BMI+YPC, data = nfl.ret)
summary(ap1.cox)
cox.zph(ap1.cox)

```

We are intrigued by the change in these results. To investigate further, we perform a couple quick analyses consisting of pro-bowlers and all-pro players:

```{r}
nfl.pb <- nfl.ret[nfl.ret$PB.1 > 0,]
nfl.ap <- nfl.ret[nfl.ret$AP1.1 > 0,]
```

```{r, echo = FALSE}
pb.ap.km <- survfit(Surv(G,Retired)~AP1.1, data = nfl.pb)
ggsurv(pb.ap.km, main = "All-Pro vs Not All-Pro, Amongst Pro-Bowlers")
ap.pb.km <- survfit(Surv(G,Retired)~PB.1, data = nfl.ap)
ggsurv(ap.pb.km, main = "Pro-Bowl vs Not Pro-Bowl, Amongst All-Pros")
```

The second plot is incomplete. We find that All-Pro status seems to imply being a Pro-Bowler as well. Generally, an All-Pro will not go long without being selected to a Pro-Bowl.

```{r}
pb.only.cox <- coxph(Surv(G,Retired)~BMI+YPC+DrAge, data = nfl.pb)
pb.only.cox
cox.zph(pb.only.cox)
ap.only.cox <- coxph(Surv(G,Retired)~BMI+YPC+DrAge, data = nfl.ap)
ap.only.cox
cox.zph(ap.only.cox)
```

All-Pro selections and Pro-Bowl selections are both prime indicators that a player is very good, which implies that they will remain in the league for a long time. However, NFL fans vote for Pro-Bowl selections, while the Associated Press selects the All-Pro teams.
We take it by faith that the All-Pro teams selected under the auspices of the AP is more indicative of higher player quality than the Pro Bowl selections made by the *slightly* biased fans of the NFL. 
In terms of our analysis, we find that being an All-Pro is certainly more meaningful than being named to the Pro-Bowl.
But how much more meaningful is it?
To find out, we take a subset of the data consisting of all players who ever had a pro-bowl selection. 
We then make a Cox Model to assess the effect of All-Pro selections compared to a player who had Pro-Bowl selections, but not All-Pro selections.

```{r}
cox.ap.v.pb <- coxph(Surv(G,Retired)~AP1, data = nfl.pb)
cox.ap.v.pb
cox.zph(cox.ap.v.pb)
csl.ap.pb <- coxsimLinear(cox.ap.v.pb, b = "AP1", Xj = seq(0,6, by = 1))

simGG(csl.ap.pb)
```

Although this model passes the test for the proportional hazards assumption, there is lingering suspicion that the number of All-Pro selections is inherently time-dependent. Because of this and the small number of 2-year, 3-year, etc. All-Pro runningbacks, we categorize the All-Pro selection values to compensate for the variation in number of All-Pro selections. Therefore we use a binary measure: 0 for never an All-Pro, and 1 for at least one All-Pro selection.

```{r}
cox.ap.mod.v.pb <- coxph(Surv(G,Retired)~AP1.1, data = nfl.pb)
cox.ap.mod.v.pb
cox.zph(cox.ap.mod.v.pb)

csl.ap.mod.pb <- coxsimLinear(cox.ap.mod.v.pb, b = "AP1.1", Xj = seq(0,1, by = 1))

simGG(csl.ap.mod.pb)
```

```{r, include = FALSE}
quantile(nfl.pb$AP1)

quantile(nfl.ap$PB)
```

Clearly, All-Pro selection trumps Pro-Bowl selections in terms of predicting a runningback's longevity. 


##Parametric models:

We can fit a parametric distribution to our survival curve. Observe:

```{r}
nfl.fit.ret <- survfit(Surv(G,Retired)~1,data = nfl.ret)
f1 <- flexsurvreg(Surv(G,Retired)~1,data = nfl.ret, dist = "gengamma")
f1
plot(f1, xlab = "Games Played", ylab = "Survival Probability", main = "Generalized Gamma fitted to Kaplan-Meier Estimate")
```

We are impressed by the goodness of this fit. Our parameters for the distribution were estimated to be:
(mu = 4.3805, sigma = .7168, Q = 1.694)

More on the Generalized Gamma distribution can be found here:
https://en.wikipedia.org/wiki/Generalized_gamma_distribution

##Summary and Resources
For this project, our goal was to examine the statistical effects of career statistics, accolades and physical measurements on the career lengths of runningbacks in the NFL. We employed the theory of survival analysis, making use of such tools as the Kaplan Meier estimator and the Cox Proportional Hazards model. We found that there are three extremely significant covariates which can tell us a great deal about an NFL running back's career length: the age at which a player was drafted, the player's BMI, and the player's Yards per Carry statistic. Additionally, we stratified our dataset in order to examine the effects of two yearly accolades as indicators of expected career length: Pro-Bowl and All-Pro selection. We found that a player named to All-Pro was more likely to have been named to the Pro Bowl, and that All-Pro is a significantly better indicator of player career length than Pro Bowl status. 

As sports fans, we found the results to be quite intuitive, but not particularly startling: 

*A player that is younger upon entering the league has much more of his athletic prime in front of him and should be expected to last longer in the league than a player drafted at a more advanced age. Therefore, draft age exhibits an inverse relation with a player's career survival probability. Our results from our Cox Model indicate that on average, with all other covariates at the exact same level, that a player entering the league at an age X is about 119.11% as likely to retire at any moment compared to a player entering the league at age X-1.

*Players with higher BMI was found to have better chances of lasting longer in the league than those with lower ones. Although BMI loses its power of identifying obese or underweight individuals when computing a value for extremely muscular humans (such as NFL players) it is still a viable measure of physical density when comparing a large set of athletes. When comparing all of the runningbacks in our dataset, we found that the denser ones had better career survival, since runningbacks are subjected to many harsh tackles by the hands of massive defensive linemen and linebackers. Namely, we found that a single unit increase in BMI decreases the instantaneous likelihood of retirement by about 8%, with all other covariates held equal. We were pleased at the significance of this result, since we toiled for a good deal of time to obtain and systematically store our players' height and weight measurements in order to compute each one's BMI. 

*Players with a higher career YPC (Yards per Carry) very trivially have a better chance of lasting longer in the league than those with lower career YPC. YPC is likely the greatest indicator of a runningback's quality of play. If a player has a poor average, they will lose their role as a starter, play less games throughout their career, and ultimately retire earlier. Specifically, we found that a one unit increase in YPC (an additional yard per carry) reduced the likelihood of retirement by 19% on average. 

*Players selected to a Pro-Bowl but never to an All-Pro team generally had worse career survival. We find that players fitting this criteria are popular amongst fans for reasons outside of play quality, since fans select the Pro-Bowl teams but the All-Pro teams are chosen by the Associated Press, whom we can assume to be less biased in their selections. Although an All-Pro selection is superior in predicting a player having a longer career, both are nonetheless indicative of a good quality player that can be expected to remain in the league for a longer time. 



##Key Results (to be edited)

1) Our estimated career survival curve for NFL RBs follows a Generalized Gamma Distribution with parameters (mu = 4.3805, sigma = .7168, Q = 1.694).

2) Draft Age is highly significant in predicting career length. On average, the earlier a player enters the NFL, the longer it will take for their athletic ability to decrease to the point of seeking retirement from the league.

3) BMI is highly significant in prediction of career length. Players with a higher computed BMI will last longer in the league. Since BMI loses predictive power in terms of indicating obesity when considering extremely muscular and athletic individuals (such as NFL RBs) the measure becomes one of body density. Specifically, the stockier a RB's build is, the longer we can expect them to last in the league.

4) Yards per carry is also very significant. As an average measure, it is a prime indicator of how *good* an NFL RB is in their career. Of course, players with higher YPC can be expected to have lasted longer in the league.

5) All-Pro and Pro-Bowl status are also indicators of a player's quality of play through their career. Perhaps trivially, players with these accolades lasted longer than those who never acheived them. Furthermore, we found that All-Pro was a significantly better predictor of career longevity than Pro-Bowl. 


##What needs to be done:
*Include lowdown on theory behind surv analysis, KM estimates, cox model, stratified model
*Make it neat and visually appealing to layman viewers; need lots of plots and visualizations that are understandable, labeled perfectly
*Find some more results; our current ones are pretty underwhelming
*Fumbles? more web scraping
*better visualization of relative risk in cox model: the plots are shit

<img src='https://raw.githubusercontent.com/johnrandazzo/surv_nflrb/markdown/figure-markdown_strict/unnamed-chunk-10-1.png' > 

##Acknowledgments

http://stackoverflow.com/questions/26296020/github-displays-all-code-chunks-from-readme-rmd-despite-include-false
