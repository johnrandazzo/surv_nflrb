# R code for analysis/visualization of NFL RB Survival Analysis
# John Randazzo


nfl <- read.csv("/Users/johnrandazzo/Downloads/nfl.csv")
library(survival)
library(KMsurv)
library(ggplot2)
library(simPH)
library(flexsurv)
library(survminer)
library(visreg)

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


nfl$Rk <- NULL
nfl$College.Univ <- NULL
nfl$Unnamed..23 <- NULL
nfl$Retired <- ifelse(nfl$To == 2016, 0, 1)
nfl[is.na(nfl)] <- 0
nfl <- nfl[!nfl$From == 0,]
nfl <- nfl[!nfl$Weight == 0,]
# too few observations
nfl <- nfl[!nfl$DrAge == 20,]
nfl <- nfl[!nfl$DrAge == 26,]
nfl <- nfl[!nfl$DrAge == 25,]

nfl$YPC <- nfl$Yds / nfl$Att
nfl$Years <- nfl$To - nfl$From
nfl$Years <- ifelse(nfl$Years == 0, 1, nfl$Years) #for rookies this yr
nfl$PB.1 <- ifelse(nfl$PB >= 1, 1, 0) #binary predictor
nfl$AP1.1 <- ifelse(nfl$AP1 >= 1, 1, 0)
nfl$BMI <- (nfl$Weight / (nfl$Height * nfl$Height)) * 703
nfl$bmi.cat <- ifelse(nfl$BMI >= median(nfl$BMI), 1, 0)

nfl.ret <- nfl[!nfl$Retired == 0,]


nfl.fit.ret <- survfit(Surv(G,Retired)~1,data = nfl.ret)


km.pb.ret <- survfit(Surv(G,Retired)~PB.1, data = nfl.ret)


km.ap.ret <- survfit(Surv(G,Retired)~AP1.1, data = nfl.ret)


km.age.ret <- survfit(Surv(G,Retired)~DrAge, data = nfl)


km.bmi.ret <- survfit(Surv(G,Retired)~bmi.cat, data = nfl.ret)


ggsurv(nfl.fit.ret, xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's")+
  geom_vline(xintercept = 45, color = "black")+
  geom_vline(xintercept = 57.92308, color = "purple")

ggsurv(km.bmi.ret,xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's, Contingent on BMI") +
  guides(linetype = F) +
  scale_colour_discrete(name = 'BMI Level', breaks = c(0,1,2), labels=c('Lightest 25%', 'Middle 50%', 'Heaviest 25%'))

ggsurv(km.age.ret, plot.cens = FALSE, xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's, Contingent on Draft Age") +
  guides(linetype = F) +
  scale_colour_discrete(name = 'Age Drafted', breaks = c(21,22,23,24), labels=c('21','22','23','24'))

ggsurv(km.ap.ret,xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's, All-Pros vs. Never an All-Pro")+
  guides(linetype = F) +
  scale_colour_discrete(name = 'All-Pro?', breaks = c(0,1), labels=c('No','Yes'))

ggsurv(km.pb.ret,xlab = "Games Played", ylab = "Survival Probability", main = "KM Estimate for Career Survival of NFL RB's, Pro-Bowlers vs. Never a Pro-Bowler")+
  guides(linetype = F) +
  scale_colour_discrete(name = 'Pro-Bowler?', breaks = c(0,1), labels=c('No','Yes'))

cox <- coxph(Surv(G,Retired)~BMI+YPC+DrAge, data = nfl.ret)
summary(cox)
ggcoxzph(cox.zph(cox))


bmi_df <-  with(nfl.ret,
                data.frame(BMI = c(27, 29, 31, 33,35,37), YPC = rep(mean(YPC, na.rm = TRUE),6),
                           DrAge = rep(21,6))
)

bmi_fit <- survfit(cox, newdata = bmi_df)
ggsurvplot(bmi_fit, data = nfl.ret,legend.title = "Predicted Survival, Contingent on BMI:", legend.labs = c("27","29","31","33","35","37"))+
  geom_vline(xintercept = 57.92308)

age_df <-  with(nfl.ret,
                data.frame(BMI = rep(mean(BMI, na.rm = TRUE),4), YPC = rep(mean(YPC, na.rm = TRUE),4),
                           DrAge = c(21, 22, 23, 24))
)

age_fit <- survfit(cox, newdata = age_df)
ggsurvplot(age_fit, data = nfl.ret,legend.title = "Predicted Survival, Contingent on Draft Age:", legend.labs = c("21","22","23","24"))+
  geom_vline(xintercept = 57.92308)

ypc_df <-  with(nfl.ret,
                data.frame(BMI = rep(mean(BMI, na.rm = TRUE),5), YPC =c(1,2,3,4,5),
                           DrAge = rep(21,5)))
ypc_fit <- survfit(cox, newdata = ypc_df)
ggsurvplot(ypc_fit, data = nfl.ret,legend.title = "Predicted Survival, Contingent on YPC:", legend.labs = c("1.0","2.0","3.0","4.0","5.0"))+
  geom_vline(xintercept = 57.92308)

lt_df <-  with(nfl,
               data.frame(BMI = 31.70673, YPC = 4.311279, DrAge = 22
               )
)
lt_fit <- survfit(cox, newdata = lt_df)
ggsurv(lt_fit,main = "Estimated Survival Curve for Ladainian Tomlinson",xlab = "Games Played", ylab = "Survival Probability")+
  geom_vline(xintercept = 170, color = "black")

zeke_df <- with(nfl,
                data.frame(BMI = 30.51215, YPC = 5.065217, DrAge = 21
                )
)
zeke_fit <- survfit(cox, newdata = zeke_df)
ggsurv(zeke_fit,main = "Estimated Survival Curve for Ezekiel Elliot",xlab = "Games Played", ylab = "Survival Probability")+
  geom_vline(xintercept = 16, color = "black")

bo_df <-  with(nfl,
               data.frame(BMI = 29.94577, YPC = 5.401942, DrAge = 23
               )
)

bo_fit <- survfit(cox, newdata = bo_df)
ggsurv(bo_fit, main = "Estimated Survival Curve for Bo Jackson", ,xlab = "Games Played", ylab = "Survival Probability")+
  geom_vline(xintercept = 38, color = "black")

nfl.pb <- nfl.ret[nfl.ret$PB.1 > 0,]
nfl.ap <- nfl.ret[nfl.ret$AP1.1 > 0,]
pb.ap.km <- survfit(Surv(G,Retired)~AP1.1, data = nfl.pb)
ggsurv(pb.ap.km, main = "All-Pro vs Not All-Pro, Amongst Pro-Bowlers")+
  guides(linetype = F) +
  scale_colour_discrete(name = 'All-Pro?', breaks = c(0,1), labels=c('No','Yes'))

ap.pb.km <- survfit(Surv(G,Retired)~PB.1, data = nfl.ap)
ggsurv(ap.pb.km, main = "Pro-Bowl vs Not Pro-Bowl, Amongst All-Pros")+
  guides(linetype = F) +
  scale_colour_discrete(name = 'Pro-Bowler?', breaks = c(0,1), labels=c('No','Yes'))

nfl.fit.ret <- survfit(Surv(G,Retired)~1,data = nfl.ret)
f1 <- flexsurvreg(Surv(G,Retired)~1,data = nfl.ret, dist = "gengamma")
f1
plot(f1, xlab = "Games Played", ylab = "Survival Probability", main = "Generalized Gamma fitted to Kaplan-Meier Estimate")