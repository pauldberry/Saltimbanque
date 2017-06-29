#AFSCME gender model

#Install all the packs

install.packages('schoRsch')
install.packages('useful')
install.packages('RPostgreSQL')
install.packages('useful')
install.packages('sqldf')
install.packages('Amelia')
install.packages('caret')
install.packages('Hmisc')
install.packages('glmnet')
install.packages('missForest')
install.packages('C50')
install.packages('randomForest')
install.packages('rJava')
install.packages('bartMachine')
install.packages('pROC')
install.packages('plyr')
install.packages('corrplot')
install.packages('Rtsne')
install.packages('xgboost')
install.packages('stats')
install.packages('knitr')
install.packages('ggplot2')
install.packages('RJDBC')
install.packages('rJava')
install.packages('data.table')
install.packages('doMC')
install.packages('multicore')
install.packages('kernlab')
install.packages('RPushbullet')
install.packages('DMwR')
install.packages('jsonlite')

#Call their libraries
library(doSNOW)
library(schoRsch)
library(useful)
library(RPostgreSQL)
library(useful)
library(sqldf)
library(Amelia)
library(caret)
library(Hmisc)
library(glmnet)
library(missForest)
library(C50)
library(randomForest)
library(rJava)
library(bartMachine)
library(pROC)
library(plyr)
require(corrplot)
require(Rtsne)
require(xgboost)
require(stats)
require(knitr)
require(ggplot2)
require(RJDBC)
require(rJava)
library(data.table)
# library(doMC)
# library(multicore)
library(kernlab)
# registerDoMC(16)
library(RPushbullet)
library(DMwR)
library(jsonlite)

#set seed
set.seed(3456)


# Initialize --------------------------------------------------------------
stopCluster(cl)
remove(list=objects())
gc()
setwd("C:/Users/pberry/Desktop/My Docs/R")
options( java.parameters = "-Xmx6g" )
options(scipen=999)
cl<-makeCluster(2) # 2 cores yo
registerDoSNOW(cl)

'%!in%' <- function(x,y)!('%in%'(x,y))

viewna <- function(dataframe){
  View(as.data.frame(sapply(dataframe, function(x){sum(is.na(x))})))
  
  #Communicating with your phone
  fromJSON(pbGetDevices())$devices[,c("iden", "nickname")]
  
  {    "key": "o.AuOzaQDke20tyRjgYJU27rWUTCMoUXmX"
    , "devices": ['ujxUTrvIyYKsjAiVsKnSTs']
    , "names": ["P's Blower"]
  }  
  
}

interactioncorrs <- function(dependent1,dataset,subset1,correlation1) {
  interactionspart1<-which(colnames(dataset) %in% (subset1))
  n <- length(dependent1)
  n.inter.vars <- length(interactionspart1)
  interaction.cors <- as.matrix(array(NA,c(n.inter.vars*n.inter.vars,3)))
  ix <- 1
  for (i1 in 1:n.inter.vars) 
  {
    print(i1)
    for (i2 in i1:n.inter.vars) 
    {
      col1 <- interactionspart1[i1]
      col2 <- interactionspart1[i2]
      x <- dataset[,col1]*dataset[,col2]
      interaction.cors[ix,1] <- col1
      interaction.cors[ix,2] <- col2
      interaction.cors[ix,3] <- cor(x,correlation1,use='pairwise.complete.obs')
      ix <- ix + 1
    }
  }
  interaction.cors<-as.data.frame(interaction.cors)
  ok <- apply(is.na(interaction.cors),1,sum)==0
  interaction.cors <- interaction.cors[ok,]
  abs(interaction.cors$V3)->interaction.cors[,4]
  interaction.cors<-interaction.cors[order(interaction.cors$V4,decreasing=T),]
  for (i in 1:2) interaction.cors[,i+4] <- colnames(dataset)[as.numeric(interaction.cors[,i])]
  interaction.cors[,7]<-paste(interaction.cors$V5,interaction.cors$V6,sep="*")
  colnames(interaction.cors)<-c("v1","v2","corrs","abscorrs","v1name","v2name","fullname")
  return(interaction.cors)
}

corrmatrix <- function(dependent, data) {
  fullcorrs<-as.data.frame(as.vector(cor(dependent,data,use='pairwise.complete.obs')))
  fullcorrs[,2] <- abs(fullcorrs)
  varMeans <- as.vector(apply(data,2,mean,na.rm=T))
  varSD <- as.vector(apply(data,2,sd,na.rm=T))
  numNAs <- as.vector(sapply(data, function(x) sum(is.na(x))))
  fullcorrs <- cbind(fullcorrs,varMeans,varSD,numNAs)
  fullcorrs<-fullcorrs[order(as.numeric(rownames(fullcorrs))),]
  fullcorrs[,6] <- colnames(data)
  colnames(fullcorrs)<-c('correlations','abscorrelations','varMean','varSD','numNAs','varNames')
  fullcorrs<-fullcorrs[order(-fullcorrs$abscorrelations),]
  return(fullcorrs)
}

interactiondata <- function(dataset, interactionmatrix)   {
  n.inter.vars <- dim(interactionmatrix)[1]
  n <- nrow(dataset)
  training.interactions.final <- as.data.frame(as.matrix(array(NA,c(n, n.inter.vars))))
  for (i1 in 1:n.inter.vars) {
    print(paste(i1, "of", n.inter.vars))
    ix1 <- interaction.cors[i1,1]
    ix2 <- interaction.cors[i1,2]
    training.interactions.final[, i1] <- dataset[, ix1] * dataset[, ix2]
  }
  colnames(training.interactions.final) <- interactionmatrix$fullname
  return(training.interactions.final)
}


# Get Data & Process & New Vars -----------------------------------------------------

# # connect to Amazon Redshift
driver <- JDBC("com.amazon.redshift.jdbc42.Driver", "C:/Users/pberry/Documents/DBViz Drivers/RedshiftJDBC42-1.1.17.1017.jar", identifier.quote="`")
url <- "jdbc:redshift://afscme.czya7l2xahuq.us-east-1.redshift.amazonaws.com:5439/analytics?ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory&user=pberry&password=T4FruPR6huHe"
conn <- dbConnect(driver, url)
new_samp <- dbGetQuery(conn,
                       "select *
                       from gender_basefile_FINAL
                       order by random() limit 7500")

new_samp_bak <- new_samp

#Send yourself a notification

pbPost("note", 'R Has Finished', 'R has finished grabbing data from RedShift', apikey = 'o.Wlgx2xWiKZxkRjkfXept31wJpF3gICMp')


# Now Train & Test
fitControl <- trainControl("repeatedcv", number = 10, repeats = 5, classProbs = TRUE, summaryFunction = twoClassSummary, verboseIter = T)

trainIndex <- createDataPartition(new_samp$dv, p = 3/4,
                                  list = FALSE,
                                  times = 1)
train <- new_samp[ trainIndex,]
test <- new_samp[-trainIndex,]

# Ok Go - For eliminating perfectly correlated variables - blank for now
#ok <- colnames(new_samp) %in% c(
#)


f0_lasso <- train(dv ~ ., data = train[,!ok],
                  tuneGrid = expand.grid(.alpha=1,.lambda=seq(0.01,0.3, length=10)),
                  method = 'glmnet',
                  trControl=fitControl,
                  metric="ROC")

f0_imp <- varImp(f0_lasso)

f0_auc <- roc(test$dv ~ predict(f0_lasso, test, "prob")[,2])

f0_imp
f0_auc

 
pbPost("note", 'R Has Finished', 'R has finished processing f1', apikey = 'o.AuOzaQDke20tyRjgYJU27rWUTCMoUXmX')
