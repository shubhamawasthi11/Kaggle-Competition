# Read data

NewsTrain = read.csv("NYTimesBlogTrain.csv", stringsAsFactors=FALSE)
NewsTest = read.csv("NYTimesBlogTest.csv", stringsAsFactors=FALSE)

# Load the "tm" package

library(tm)

# Pre-processing of Headline text

CorpusHead = Corpus(VectorSource(c(NewsTrain$Headline, NewsTest$Headline)))

CorpusHead = tm_map(CorpusHead, tolower)

CorpusHead = tm_map(CorpusHead, PlainTextDocument)

CorpusHead = tm_map(CorpusHead, removePunctuation)

CorpusHead = tm_map(CorpusHead, removeWords, stopwords("english"))

CorpusHead = tm_map(CorpusHead, stemDocument)

dtm = DocumentTermMatrix(CorpusHead)

# Change the proportion in removeSparseTerms

sparse = removeSparseTerms(dtm, 0.995)

HeadlineWords = as.data.frame(as.matrix(sparse))

colnames(HeadlineWords) = make.names(colnames(HeadlineWords))

HeadlineWordsTrain = head(HeadlineWords, nrow(NewsTrain))

HeadlineWordsTest = tail(HeadlineWords, nrow(NewsTest))

HeadlineWordsTrain$Popular = NewsTrain$Popular 

# Change variable WordCount value

HeadlineWordsTrain$WordCount = log(NewsTrain$WordCount+1)
HeadlineWordsTest$WordCount = log(NewsTest$WordCount+1)

# load lubridate library for adding time

library(lubridate)

NewsTrain$PubDate = strptime(NewsTrain$PubDate, format="%Y-%m-%d %H:%M:%S")
NewsTest$PubDate = strptime(NewsTest$PubDate, format="%Y-%m-%d %H:%M:%S")

HeadlineWordsTrain$Weekdays = as.factor(weekdays(NewsTrain$PubDate))
HeadlineWordsTrain$Hour = as.factor(hour(NewsTrain$PubDate))

HeadlineWordsTest$Weekdays = as.factor(weekdays(NewsTest$PubDate))
HeadlineWordsTest$Hour = as.factor(hour(NewsTest$PubDate))

# Add category for blog

NewsTrain$NewsDesk = as.factor(NewsTrain$NewsDesk)

NewsTrain$SectionName = as.factor(NewsTrain$SectionName)

NewsTrain$SubsectionName = as.factor(NewsTrain$SubsectionName)

NewsTest$NewsDesk = as.factor(NewsTest$NewsDesk)

NewsTest$SectionName = as.factor(NewsTest$SectionName)

NewsTest$SubsectionName = as.factor(NewsTest$SubsectionName)

NewsTest$NewsDesk = factor(NewsTest$NewsDesk, levels(NewsTrain$NewsDesk))

NewsTest$SectionName = factor(NewsTest$SectionName, levels(NewsTrain$SectionName))

NewsTest$SubsectionName = factor(NewsTest$SubsectionName, levels(NewsTrain$SubsectionName))

HeadlineWordsTrain$NewsDesk = NewsTrain$NewsDesk

HeadlineWordsTrain$SectionName = NewsTrain$SectionName

HeadlineWordsTrain$SubsectionName = NewsTrain$SubsectionName

HeadlineWordsTest$NewsDesk = NewsTest$NewsDesk

HeadlineWordsTest$SectionName = NewsTest$SectionName

HeadlineWordsTest$SubsectionName = NewsTest$SubsectionName

# Use RandomForest model
# Use Parallel computing packages
library(foreach)
library(doParallel)
library(randomForest)

registerDoParallel(4)

HeadlineWordsrf = foreach(ntree=rep(1667, 4), .combine=combine, .packages = "randomForest") %dopar%
        
randomForest(Popular ~ ., data=HeadlineWordsTrain,mtry = 8,ntree=ntree,allowParallel=TRUE)

# use logistic model

HeadlineWordslog = glm(Popular ~ ., data=HeadlineWordsTrain,family="binomial")

# use gbm model 

library(gbm)
HeadlineWordsgbm = gbm(Popular ~.  ,data=HeadlineWordsTrain,n.tree= 10000, shrinkage = 0.001, n.core = 4)

# Make predictions on test set

PredTest1 = predict(HeadlineWordsgbm, newdata=HeadlineWordsTest, type="response",n.tree = 10000)

PredTest2 = predict(HeadlineWordsrf, newdata=HeadlineWordsTest, type="response")

PredTest3 = predict(HeadlineWordslog, newdata=HeadlineWordsTest, type="response")

newpredict = (0.15*PredTest1 + 0.7*PredTest2 +0.15*PredTest3)

MySubmission = data.frame(UniqueID = NewsTest$UniqueID, Probability1 = newpredict)

write.csv(MySubmission, "SubmissionKaggleBlog.csv", row.names=FALSE)

# AUC = 0.92830  
