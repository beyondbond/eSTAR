#===================================================================================#
#- Historical stock prices & financials from YAHOO finance (GOOGLE alternative)
#- Update S&P500 yesterday closing into price history eSTAR prc_hist
#- Last mod. by Ted, Sat Mar 12 01:07:23 EST 2016
#===================================================================================#
setwd("/apps/fafa/github/eSTAR/scripts")
source("_estar_ut.R")
#library(qmao)

#- Batch job of price quote
LoadDailyBatch <- function(tickerNames,mydb,iniFlg) {
	dstTbl="prc_tmp"
	fromDt=as.Date(Sys.Date()-1)
#	dstTbl="prc_hist"
#	fromDt="2000-01-01"
	src="yahoo"
	tG=100     #- elements per group  
	tN=length(tickerNames)
	gN=as.integer(tN/tG)
	if(gN*tG<tN) gN = gN+1
	for(jg in 1:gN) {
		gB=(jg-1)*tG+1
		if(jg==gN)
                        gE = tN
                else
                        gE = gB+tG-1
		tks=tickerNames[gB:gE]
		iniFlg=LoadPrcHistory(tks,mydb,iniFlg,src,dstTbl,fromDt)
	}
	rst <- dbGetQuery(mydb,'DELETE from prc_hist where "pbDate" in (SELECT DISTINCT "pbDate" FROM prc_tmp)')
	rst <- dbGetQuery(mydb,'INSERT INTO prc_hist SELECT * from prc_tmp')
}

#===================================================================================#
#-----      MAIN PROGRAM BEGIN      -----#

#----- SET OPTIONS
options(download.file.method="wget")
options("getSymbols.warning4.0"=FALSE)

#----- SET TICKERS
tickerNames <- readLines("spyLst.dat")
#tickerNames_g <- readLines("spyLst_g.dat")
#tickerNames = tickerNames[500:524] # TEMP INSERT TEST
#tickerNames=c("AWK","CXO","EXR","FRT","CFG","UDR")

#---- DB: PostgresSQL
library("RPostgreSQL")
#mydb<-dbConnect(dbDriver("PostgreSQL"),user='sfdbo',password='sfdbo0',host='bbub2',dbname='eSTAR_2')
mydb<-dbConnect(dbDriver("PostgreSQL"),user='sfdbo',password='sfdbo0',host='localhost',dbname='eSTAR')
#---- DB: MySQL
#library(RMySQL)
#mydb<-dbConnect(MySQL(),user='sfdbo',password='sfdbo0',host='localhost',dbname='eSTAR')

#---- RUN BATCH JOBS
iniFlg=0
LoadDailyBatch(tickerNames,mydb,iniFlg)

dbDisconnect(mydb)
#-----      MAIN PROGRAM END      -----#
#===================================================================================#
