# run_analysis.R
# Get the data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

path_rf <- file.path("./data","UCI HAR Dataset")

activityTest <- read.table(file.path(path_rf,"test","Y_test.txt"), header = FALSE)
activityTrain <- read.table(file.path(path_rf,"train","Y_train.txt"), header = FALSE)
subjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
subjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
featuresTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
featuresTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

# 1. Merges the training and the test sets to create one data set
Activity<- rbind(activityTrain, activityTest)
Subject <- rbind(subjectTrain, subjectTest)
Features<- rbind(featuresTrain, featuresTest)
names(Subject) <- c("subject")
names(Activity) <- c("activity")
FeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(Features)<- FeaturesNames$V2
subjecActivityCombine <- cbind(Subject, Activity)
Data <- cbind(Features, subjecActivityCombine)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement
subFeaturesNames<-FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
selectedNames<-c(as.character(subFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

# 3. Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
Data$activity <- factor(Data$activity, levels = activityLabels[,1], labels = activityLabels[,2])

# 4. Appropriately labels the data set with descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# create data set as a txt file created with write.table() using row.name=FALSE
library(plyr)
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]

write.table(Data2, file = "tidydata.txt",row.name=FALSE)
