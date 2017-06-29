#AFSCME HRC V2 Model

# Initialize --------------------------------------------------------------
stopCluster(cl)
remove(list=objects())
gc()
setwd("C:/Users/pberry/Desktop/hrc_model_v2/")
options( java.parameters = "-Xmx6g" )
options(scipen=999)
library(doSNOW)
cl<-makeCluster(4) # fo cores yo
registerDoSNOW(cl)
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
set.seed(3456)
'%!in%' <- function(x,y)!('%in%'(x,y))

viewna <- function(dataframe){
  View(as.data.frame(sapply(dataframe, function(x){sum(is.na(x))})))
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
driver <- JDBC("com.amazon.redshift.jdbc41.Driver", "C:/Users/pberry/Documents/DBViz Drivers/RedshiftJDBC42-1.1.17.1017.jar", identifier.quote="`")
url <- "jdbc:redshift://afscme.czya7l2xahuq.us-east-1.redshift.amazonaws.com:5439/analytics?ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory&user=pberry&password=T4FruPR6huHe"
conn <- dbConnect(driver, url)
data <- dbGetQuery(conn,
                   "select 
                   b.*
                   -- , a.q7
                   , a.q8
                   from twhittaker.hrc_model_v2_completes a 
                   inner join modeling.modeling_dev b using (enterprise_id)
                   ")
# places data into a dataframe so you don't have to repeatedly call it
data_bak <- data

#Throw out non-HRC responses
data <- data[!is.na(data$q8),]
data <- data[data$q8==1|data$q8==2,]

data$dv1 <- as.factor(ifelse(data$q8 == '1', 'BHRC', 'ATRUMP'))

# Now Train & Test
fitControl <- trainControl("repeatedcv", number = 10, repeats = 5, classProbs = TRUE, summaryFunction = twoClassSummary, verboseIter = T)

trainIndex <- createDataPartition(data$dv1, p = 3/4,
                                  list = FALSE,
                                  times = 1)
train <- data[ trainIndex,]
test <- data[-trainIndex,]

# # Ok Go
# ok <- colnames(data) %in% c('q7','q8','enterprise_id')
# f1_glmnet <- train(dv1 ~ ., data = train[,!ok],
#                    method = 'glmnet',
#                    # tuneGrid = expand.grid(.alpha=seq(0, 1, by=0.1),.lambda=seq(0.01,0.2, length=15)),
#                    trControl=fitControl,
#                    metric="ROC"
# )
# 
# f1_imp <- varImp(f1_glmnet)
# 
# f1_auc <- roc(test$dv1 ~ predict(f1_glmnet, test, "prob")[,2])
# 
# f1_coef <- as.data.frame(coef(f1_glmnet$finalModel, f1_glmnet$finalModel$lambdaOpt)[(which(coef(f1_glmnet$finalModel, f1_glmnet$finalModel$lambdaOpt) != 0)),])
# 
# pbPost("note", 'R Has Finished', 'R has finished processing f1_glmnet', apikey = 'o.pXEDyIHGbWGTjiwNtEOmE9VUcioOXrv0')

# trainIndex <- createDataPartition(data$dv1, p = 3/4,
#                                   list = FALSE,
#                                   times = 1)
# train <- data[ trainIndex,]
# test <- data[-trainIndex,]

# Ok Go
ok <- colnames(data) %in% c('q7','q8','enterprise_id')
f2_lasso <- train(dv1 ~ ., data = train[,!ok],
                   method = 'glmnet',
                   tuneGrid = expand.grid(.alpha=1,.lambda=seq(0.01,0.3, length=40)),
                   trControl=fitControl,
                   metric="ROC"
)

f2_imp <- varImp(f2_lasso)

f2_auc <- roc(test$dv1 ~ predict(f2_lasso, test, "prob")[,2])

f2_coef <- as.data.frame(coef(f2_lasso$finalModel, f2_lasso$finalModel$lambdaOpt)[(which(coef(f2_lasso$finalModel, f2_lasso$finalModel$lambdaOpt) != 0)),])

pbPost("note", 'R Has Finished', 'R has finished processing f1', apikey = 'o.AuOzaQDke20tyRjgYJU27rWUTCMoUXmX')


trainIndex <- createDataPartition(data$dv1, p = 3/4,
                                  list = FALSE,
                                  times = 1)
train <- data[ trainIndex,]
test <- data[-trainIndex,]

# Ok Go
ok <- colnames(data) %in% c(row.names(f2_coef), 'dv1')
f3_lasso <- train(dv1 ~ ., data = train[,ok],
                  method = 'glmnet',
                  tuneGrid = expand.grid(.alpha=seq(0,1,length=10),.lambda=seq(0.0025,0.3, length=40)),
                  trControl=fitControl,
                  metric="ROC"
)

f3_imp <- varImp(f3_lasso)

f3_auc <- roc(test$dv1 ~ predict(f3_lasso, test, "prob")[,2])

f3_coef <- as.data.frame(coef(f3_lasso$finalModel, f3_lasso$finalModel$lambdaOpt)[(which(coef(f3_lasso$finalModel, f3_lasso$finalModel$lambdaOpt) != 0)),])

pbPost("note", 'R Has Finished', 'R has finished processing f1', apikey = 'o.AuOzaQDke20tyRjgYJU27rWUTCMoUXmX')
