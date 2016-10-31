# 
# Assembles 2 dataframes of tidy data from data provided by UCI
#
# ->> Depends on 2 packages. The script attempts to load these when needed, and if unable, installs
#     them from the default CRAN repository:
#
#     "readr" (for speed of data-loading and progress bars)
#     "dplyr" (for creation of tidy data summary) 
#              The script attempts to load these packages when needed, 
#              and if unable to do so, installs them from CRAN
#
# ->> Before tidying, downloads and extract the zipped data from the URL specified for the project
#

run_analysis <- function()
{
#
# Function 'pkgLoad' checks if package is able to load and installs it if not. 
# If function still not able to load, stops execution with an error message. Used when 
# needed for the two packages specified above
#
pkgLoad <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x)  # Regarding argument "dependencies =", the default, NA, means 
                         # c("Depends", "Imports", "LinkingTo").
                         # "Depends" indicates that the depedency is required to be in the
                         # environment search path. "Imports" indicates the namespace, and
                         # "LinkingTo" indicates that the dependency is on C++ code in the other
                         # package.
    if(!require(x,character.only = TRUE)) stop("Error installing or loading package")
  }
}

#
# Download UCI data to current working directory ('WD'), create directory "UCI_Data" in WD,
# and unzip data into "UCI_Data" directory
#
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","UCI_HAR_Dataset.zip")
unzip("UCI_HAR_Dataset.zip", exdir = "UCI_Data", unzip = getOption("unzip"))
basepath <- file.path("UCI_Data","UCI HAR Dataset")

# Load package for fast data read and write
pkgLoad("readr")

# Read in, select, and create vector of indices and feature names associated with 'mean()' and 'std()'
# 
features <- read_table(file.path(basepath, "features.txt"), col_names = "feature")
features <- features$feature          # Changes 'feature' from a dataframe to a vector
indices <- sort(c(grep("mean\\(\\)", features), grep("std\\(\\)", features)))
features <- features[indices]

# Process feature names according to 'tidy' principles
features <- sub("[0-9]+","",features) # Removes all sequences of numbers
features <- trimws(features, "left")  # Trims whitespace present on left
features <- gsub("-","",features)     # Removes hyphens
features <- sub("\\(\\)","",features) # Removes parentheses associated with mean() & std()
# Replaces single uppercase letters or words "mean" or "std" with lowercase letters
# preceded by a dot. Specifying Perl-style regex enables the 'replace' argument to 
# 'remember' the matched pattern that is stored via grouping notation "(...)" and referred to
# via "\\1" (the "\\1" specificies group number 1; in this case we have only 1 group). The matched
# pattern is changed to lower-case using "\\L", and the preceding dot is added via "\\."
features <- gsub("([A-Z]|mean|std)","\\.\\L\\1",features, perl = TRUE)

# Read in feature data, use indices to select only means and std dev's, and assign tidy feature names
# consistent with the Google R Style Guide (see: https://google.github.io/styleguide/Rguide.xml)

testdata <- file.path(basepath,"test","X_test.txt")
traindata <- file.path(basepath,"train","X_train.txt")
inertial_data <- rbind(read_table(testdata, 
              col_types = cols(.default = col_double()), col_names = FALSE),
              read_table(traindata, col_types = cols(.default = col_double()), 
              col_names = FALSE))[,indices]
names(inertial_data) <- features

# Read in activity labels and data, and assign tidy names
activity_labels <- file.path(basepath,"activity_labels.txt")
activity_names <- read_table(activity_labels,col_names = c("activity_no","activity"))
activity_names$activity <- sub("_","\\.",tolower(activity_names$activity))
y_test <- file.path(basepath,"test","y_test.txt")
y_train <- file.path(basepath,"train","y_train.txt")
activities <- rbind(read_table(y_test, col_names = "activity_no"),
                    read_table(y_train, col_names = "activity_no"))
activity <- activity_names$activity[activities$activity_no]

# Read in subject data
subject_test <- file.path(basepath,"test","subject_test.txt")
subject_train <- file.path(basepath,"train","subject_train.txt")
subjects <- rbind(read_table(subject_test, col_names = "subject"), 
                  read_table(subject_train, col_names = "subject"))

# Load package to help with tidy data summary
pkgLoad("dplyr")

# Merge subject, activity, and feature data into a tidy data-set
inertial_data <- tbl_df(cbind(subjects, activity, inertial_data))
inertial_data <- arrange(inertial_data, subject, activity)
inertial_data$subject <- as.factor(inertial_data$subject)

# Create a tidy summary containing the average value for each combination of 'subject' & 'activity'
data_summary <- inertial_data %>% unite(subject_activity, subject, activity) %>% 
      group_by(subject_activity) %>% summarise_each(funs(mean)) %>%
      separate(subject_activity,c("subject","activity"),sep="_")
data_summary$subject <- as.integer(data_summary$subject)
data_summary <- data_summary %>% arrange(subject, activity)
names(data_summary) <- c("subject", "activity", paste0("avg.", features))
data_summary$subject <- as.factor(data_summary$subject)
data_summary$activity <- as.factor(data_summary$activity)

tidy_list <- list(tidy_data_summary = data_summary, tidy_data = inertial_data)

tidy_list
}

tidy_list <- run_analysis()
