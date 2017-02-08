setwd("~/MS SQL Server/2016 R Services etc/Lending Club/MSQL_R_Svcs")
load(file = "1 Connect to MSQL Data.R")

library(ggplot2)
library(caret)

# Consider PBI for EDA; use R to quantify anything in the EDA process
hist(LoanStats.loc$successfully_paid)
table(LoanStats.loc$successfully_paid)


g <- ggplot(LoanStats.loc, aes(as.factor(successfully_paid), annual_inc))
g <- g + geom_boxplot(aes(group= cut_width(successfully_paid,1)))
g

# caret:: feature plot

featurePlot(x = InputDataSet[sample(nrow(InputDataSet), 1000), c("dti", "annual_inc", "purpose", "mort_acc", "inq_last_6mths")], y = InputDataSet$successfully_paid, plot = "pairs", pch = 20, col = c("red","grey"), auto.key = list(columnns = 2))

# Hist of annual_inc
num.cols <- sapply(LoanStats.loc[ ,3:8], is.numeric)

library(reshape2)
train.long <- melt(LoanStats.loc[,num.cols], id="successfully_paid")

#plot the distribution for bads and goods for each variable
p <- ggplot(aes(x=value, group=successfully_paid, colour=factor(successfully_paid)), data=train.long)
#quick and dirty way to figure out if you have any good variables
p <- p + geom_density() + facet_wrap(~ variable, scales="free")
