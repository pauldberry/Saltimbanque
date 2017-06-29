presidential.poll.data <- read.csv("C:/Users/pberry/Desktop/My Docs/Presidential Poll/presidential poll data.csv", header=TRUE)
View(presidential.poll.data)

set.seed(4462)
goodies <- presidential.poll.data[presidential.poll.data$q8 == 1 | presidential.poll.data$q8 == 2,]
goodies <- goodies[!is.na(goodies$enterprise_id),]
goodies$dv <- as.factor(ifelse(goodies$q8==1,'BHRC','ATrump'))
goodies$q8 <- NULL
trainIndex <- createDataPartition(goodies$dv, p = .7,  list = FALSE)
fitControl <-trainControl("repeatedcv", number = 10, repeats = 5, classProbs = T, summaryFunction = twoClassSummary, verboseIter = T)

train <- goodies[trainIndex,]
test <- goodies[-trainIndex,]

ok <- colnames(goodies) %in% c('enterprise_id')

paulsfit1 <- train(dv ~ ., data = train[!ok], method = "glmnet", tuneGrid = expand.grid(.alpha=1, .lambda = seq(0.01, 0.2, length=15)), trControl = fitControl, metric = 'ROC')

f1_imp <- varImp(paulsfit0)
f1_coef <- as.data.frame(coef(paulsfit1$finalModel, paulsfit1$finalModel$lambdaOpt)[which(coef(paulsfit1$finalModel, paulsfit1$finalModel$lambdaOpt) !=0),])