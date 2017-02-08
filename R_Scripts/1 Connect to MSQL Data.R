.libPaths(c(.libPaths(),"C:/Program Files/Microsoft SQL Server/MSSQL13.MSSQLSERVER/R_SERVICES/library"))
library(RevoScaleR)

setwd("~/MS SQL Server/2016 R Services etc/Lending Club/MSQL_R_Svcs")


#Connection via Windows Auth
sqlConnString.loc <- "Driver=SQL Server;Server=21695-E6440;Database=LendingData;Trusted_Connection=True"

#sqlConnString.rmt <- "Driver=SQL Server;Server=13.67.219.174;Database=LendingData;Uid=DBadministrator;Pwd=""

# MSQL Tables in Question 
sqlLoanStats.tbl <- "LoanStats"


sqlRowsToRead <- 10000 # No. of rows to process per iteration
sqlWait <- TRUE #when TRUE jobs will be blocking and not return until they complete or fail 
sqlConsoleOutput <- FALSE # i.e. do not return output to the console from remote computations

# Define MSQL Data location/connection with remote Table
sqlLoanStats.ds <- RxSqlServerData(connectionString = sqlConnString.rmt, table = sqlLoanStats.tbl, rowsPerRead = sqlRowsToRead)

# Shift Compute Context from Local Client to Remove DB Server - yes, it does happen to be the same here
sqlCompute <- RxInSqlServer(connectionString = sqlConnString.loc, wait = sqlWait, consoleOutput = sqlConsoleOutput)

rxSetComputeContext(sqlCompute)  # use the string "local" to shift back to Local CC

# Collect variable names from tables 
LoanStats.vars <- rxGetVarInfo(sqlLoanStats.ds)


### Load data into Memory - Be Careful!
#rxSetComputeContext("local")  
#sqlRejectStats.local <- RxSqlServerData(connectionString = sqlConnString, table = sqlRejectStats.tbl)
#RejStats.df <- rxImport(sqlRejectStats.ds) # Took about 2 minutes

#importQuery <- paste("SELECT top 1000 * FROM LoanApp_train")
importQuery <- paste("SELECT top 100 * FROM LoanHist where id not in (select id from LoanApp_train)")

rxSetComputeContext("local")

msqlImportDS <- RxSqlServerData(connectionString = sqlConnString.loc, sqlQuery = importQuery)

############ Local import steps: 
#import to local data frame
LoanStats.loc <- rxImport(inData = msqlImportDS, overwrite = T)

LoanStats.tst <- rxImport(inData = msqlImportDS, overwrite = T)

# import to local XDF file
LoanStats.xdf <- rxImport(inData = msqlImportDS,  outFile = "LoanStatsloc.xdf" , numRows = 100, overwrite = T)



