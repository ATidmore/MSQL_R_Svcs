"C:/Users/AustinT/Documents/MS SQL Server/2016 R Services etc/Lending Club/MSQL_R_Svcs"

LoanStats <- readRDS("LoanStats.loc.RDS")

library(dplyr)
library(ggplot2)

LoanStats$is_good <- ifelse(LoanStats$loan_status %in% c("Fully Paid", "Current") , 1, 0)

LoanStats$home_ownership <- as.factor(LoanStats$home_ownership)

g.dtiDensity <- ggplot(aes(x=dti, group=is_good, colour=factor(is_good)), data=LoanStats[which(LoanStats$dti < 150) ,]) + geom_density() 

g.dtiDensity

g.HO <- ggplot(aes(x = home_ownership, fill = factor(is_good)), data = LoanStats)
g.HO <- g.HO + geom_bar(position = "fill")

g.HO

# What is funky about home-ownership factor?
