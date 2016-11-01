# 
# PROCESSES cell-phone sensor data provided by UCI and ASSEMBLES two tidy data-sets, loading them into
# the workspace as a list of two tbl_df dataframes:
#
# 1. tidy_list$tidy_summary   A summary of feature data for certain variables in the UCI data set
# 2. tidy_list$tidy_data      Feature data from certain variables in the UCI data set
#
# It also writes both elements of the above list to the wd as space-delimited text files
# "tidy_summary.txt" and "tidy_data.txt"
#
# NOTE
# ->> The analysis script depends on 3 packages. The script attempts to load these when needed, and if 
#     unable, installsthem from the default CRAN repository.  The packages are:
#
#     "readr" (for speed of data-loading and progress bars)
#     "dplyr" & "tidyr" (for creation of tidy data summary) 
#              The script attempts to load these packages when needed, 
#              and if unable to do so, installs them from CRAN
#
# ->> Before tidying, downloads and extract the zipped data from the URL specified for the project
#     Note: does not download if the zip file already exists in the working directory
#           does not unzip if the target data directory for the unzipped archive already exists
#

run_analysis <- function()
{
#
# Function 'pkgLoad' checks if package is able to load and installs it if not. 
# If installation attempted and package still unable to load, stops execution with error message. 
#
    pkgLoad <- function(pkgName)
    {
        if (!require(pkgName,character.only = TRUE))
        {
            install.packages(pkgName)  # Regarding argument "dependencies =" of install.packages(): 
                                # the default, NA, indicates c("Depends", "Imports", "LinkingTo").
                                # "Depends" indicates the dependency is required to be in the
                                # environment search(). "Imports" indicates the package namespace, and
                                # "LinkingTo" indicates dependency is on C++ code in the other package.
      
            if(!require(pkgName,character.only = TRUE)) 
                stop(paste0("Error installing/loading package",pkgName))
        }
    }

    # Package for fast data read and write, with progress/status bars
    pkgLoad("readr")
    # Packages to help with tidy data summary
    pkgLoad("dplyr")
    pkgLoad("tidyr")

    #
    # Download UCI data to current working directory ('WD'), create directory "UCI_Data" in WD,
    # and unzip data into "UCI_Data" directory
    #
    if(!file.exists("UCI_HAR_Dataset.zip"))
    {
        download.file(paste0("https://d396qusza40orc.cloudfront.net/", 
                             "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"),"UCI_HAR_Dataset.zip")
    }
    if(!file.exists("UCI_Data"))
    {
        unzip("UCI_HAR_Dataset.zip", exdir = "UCI_Data", unzip = getOption("unzip"))
    }
    
    basepath <- file.path("UCI_Data","UCI HAR Dataset")
    
    #
    # Get feature names: Read & select features, creating vector of indices for selection of feature data 
    # 
    features <- read_table(file.path(basepath, "features.txt"), col_names = "feature")
    features <- features$feature          # Changes 'feature' from a dataframe to a vector
    indices <- sort(c(grep("mean\\(\\)", features), grep("std\\(\\)", features)))
    features <- features[indices]

    #
    # Process feature names: Transform feature names into more standard, readable format
    # 
    # Note - transformed features names are consistent with the 'Google R Style Guide'
    #        see: https://google.github.io/styleguide/Rguide.xml
    #
    features <- sub("[0-9]+","",features) # Removes all sequences of numbers
    features <- trimws(features, "left")  # Trims whitespace present on left
    features <- gsub("-","",features)     # Removes hyphens
    features <- sub("\\(\\)","",features) # Removes parentheses associated with mean() & std()
    # REGEX explanation: gsub replaces single uppercase lettersw/lowercase letters
    # preceded by a dot, or if "mean" or "std" are found, places a dot in front of those.
    # Specifying Perl-style regex enables the 'replace' argument to 
    # 'remember' the matched pattern that is stored via grouping notation "(...)" and referred to
    # via "\\1" (the "\\1" specificies group number 1; in this case we have only 1 group). The matched
    # pattern is changed to lower-case using "\\L", and the preceding dot is added via "\\."
    features <- gsub("([A-Z]|mean|std)","\\.\\L\\1",features, perl = TRUE)

    #
    # Read feature data, using indices to select subset, and assign feature names to columns of data
    # 
    testdata <- file.path(basepath,"test","X_test.txt")
    traindata <- file.path(basepath,"train","X_train.txt")
    inertial_data <- rbind(read_table(testdata, col_types = cols(.default = col_double()), 
                                      col_names = FALSE),
              read_table(traindata, col_types = cols(.default = col_double()), 
                         col_names = FALSE))[,indices]
    names(inertial_data) <- features

    #
    # Read in activity labels and slightly reformat; read activity data and substitute labels for numbers 
    #
    activity_labels <- file.path(basepath,"activity_labels.txt")
    activity_names <- read_table(activity_labels,col_names = c("activity_no","activity"))
    activity_names$activity <- sub("_","\\.",tolower(activity_names$activity))
    y_test <- file.path(basepath,"test","y_test.txt")
    y_train <- file.path(basepath,"train","y_train.txt")
    activities <- rbind(read_table(y_test, col_names = "activity_no"),
                    read_table(y_train, col_names = "activity_no"))
    activity <- activity_names$activity[activities$activity_no]

    #
    # Read in subject data and assign suitable column name
    #
    subject_test <- file.path(basepath,"test","subject_test.txt")
    subject_train <- file.path(basepath,"train","subject_train.txt")
    subjects <- rbind(read_table(subject_test, col_names = "subject"), 
                  read_table(subject_train, col_names = "subject"))

    #
    # Merge subject, activity, and feature data into a tidy data-set
    #
    inertial_data <- tbl_df(cbind(subjects, activity, inertial_data))
    inertial_data <- arrange(inertial_data, subject, activity)
    inertial_data$subject <- as.factor(inertial_data$subject)

    #
    # Create a tidy summary containing the average value for each combination of 'subject' & 'activity'
    # Use packages 'dplyr' and 'tidyr' to do it
    #
    data_summary <- inertial_data %>% unite(subject_activity, subject, activity) %>% 
          group_by(subject_activity) %>% summarise_each(funs(mean)) %>%
          separate(subject_activity,c("subject","activity"),sep="_")
    data_summary$subject <- as.integer(data_summary$subject)
    data_summary <- data_summary %>% arrange(subject, activity)
    names(data_summary) <- c("subject", "activity", paste0("avg.", features))
    data_summary$subject <- as.factor(data_summary$subject)
    data_summary$activity <- as.factor(data_summary$activity)
    tidy_list <- list(tidy_summary = data_summary, tidy_data = inertial_data)
    if (!file.exists("tidy_summary.txt"))
    {
        write_delim(data_summary,"tidy_summary.txt")
    }
    if (!file.exists("tidy_data.txt"))
    {
        write_delim(data_summary,"tidy_data.txt")
    }
    tidy_list
}

tidy_list <- run_analysis()
