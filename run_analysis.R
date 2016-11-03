
run_analysis <- function(inst_pkgs_if_needed = TRUE, dwnld_zip_if_needed = TRUE, unzip_if_needed = TRUE)
{
    # TRANSFORMS & ASSEMBLES cell-phone sensor data from UCI into two tidy data-sets, loading them into
    # the workspace as a list of two tbl_df's (tidyr dataframes, which print well to the console) and
    # writing them to the working directory as space-delimited text files
    #
    # list element    element name  filename          Description
    # -------------   ------------  --------          -----------
    # tidy_list[[1]]  tidy_data     tidy_data.txt     Data for variables extracted from UCI data set
    # tidy_list[[2]]  tidy_summary  tidy_summary.txt  Averages of data for extracted variables
    #
    #
    #
    # NOTES:
    # 
    # (A) The analysis script depends on < THREE > packages. The script attempts to load these, and if 
    #     unable to do so, installs them from the default CRAN repository.  The packages are:
    #
    #         Package             Purpose
    #         -------             -------
    #         "readr"             Data-loading into tbl_df's; progress bars
    #         "dplyr" & "tidyr"   Creation of tidy data summary
    #
    # (B) Before tidying, downloads and extracts the zipped data from the URL specified for the project
    #     Note: Doesn't download if zip-file of same name already exists in working directory
    #           Doesn't unzip if target directory for unzipped archive already exists
    #####
    
    #####
    #
    # (1) Load necessary packages.
    # 
    #     Function 'pkgLoad' checks if package is able to load and installs it if not. 
    #     If installation attempted and package still unable to load, stops execution with error message. 
    #
    ####
    pkgLoad <- function(pkgName, inst_pkgs_if_needed = inst_pkgs_if_needed)
    {
        if (!require(pkgName,character.only = TRUE) && inst_pkgs_if_needed)
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
    pkgLoad("readr")
    pkgLoad("dplyr")
    pkgLoad("tidyr")
    #####
    
    #####
    # (2) Download UCI data to working directory.
    ####
    if(!file.exists("UCI_HAR_Dataset.zip") && dwnld_zip_if_needed)
    {
        status <- download.file(paste0("https://d396qusza40orc.cloudfront.net/", 
                             "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"),"UCI_HAR_Dataset.zip")
       
        # if error not thrown but download.file fails, some non-zero integer is returned 
        if(status!=0) stop(paste("Download of zip archive failed.",
                    "Try again or download archive manually into your working directory.",                                     "Name downloaded file 'UCI_HAR_Dataset.zip'")) # Use single quotes inside double quotes
    }
    
    ####
    # (3) Create directory "UCI_Data" in working directory and unzip data into "UCI_Data" directory.
    ####
    basepath <- file.path("UCI_Data","UCI HAR Dataset") # set platform-independent path for 
                                                        # reading files in unzipped archive
    if(!file.exists(basepath) && unzip_if_needed)
    {
        unzip("UCI_HAR_Dataset.zip", exdir = "UCI_Data") # left out arg 'unzip = getOption("unzip")'
                                                         # because it can throw Windows-specific errors
                                                         # on some non-Windows platforms; also,
                                                         # native method appears to be faster
    }
    ####
    
    ####
    # (4) Read & select feature names containing 'mean()' and 'std()'.
    #     Create vector of indices of associated columns to be used later for selection of feature data. 
    ### 
    cat("\nReading feature names: columns read from 'features.txt' with following data type(s):\n\n")
    features <- read_table(file.path(basepath, "features.txt"), col_names = "feature")
    features <- features$feature          # Changes 'feature' from a dataframe to a vector
    indices <- sort(c(grep("mean\\(\\)", features), grep("std\\(\\)", features)))
    features <- features[indices]
    #####
    
    #####
    # (5) Transform feature names into more standard, readable format
    #     Note - transformed features names are consistent with the 'Google R Style Guide'
    #            see: https://google.github.io/styleguide/Rguide.xml
    #####
    features <- sub("[0-9]+","",features) # sub() removes the first sequences of numbers encountered in
                                          # each element of the vector; i.e., removes only the row number that 
                                          # gets read in by read_table as part of each feature name
    features <- trimws(features, "left")  # Trims whitespace present on left
    features <- gsub("-","",features)     # Removes hyphens
    features <- sub("\\(\\)","",features) # Removes parentheses associated with mean() & std()
    #
    # Below call to gsub():
    # --------------------
    # Replaces single uppercase letters w/lowercase letters preceded by a dot, or, if 'mean' or 'std'
    # are found, places a dot in front of those. 
    #
    # The preceding dot is added using "\\." in the replacement argument. The backreference "\1"
    # refers to and remembers the 1st parenthesized subexpression (group) within the matched pattern
    # (use "\2" or "\3" for the 2nd or 3rd parenthesized subexpression, etc.). 
    # Only because 'perl = TRUE', "\L" can be used to convert the rest of the replacement to upper or
    # lower case. An "\E" could be used to end the case conversion. See help page for grep, 'replacement'   
    # argument, regarding backreferences and perl-style replacement operators "\L", "\U", and "\E".
    features <- gsub(pattern = "([A-Z]|mean|std)", replacement = "\\.\\L\\1", features, perl = TRUE)

    ######
    # (6) Read feature data, use indices to select subset, and assign feature names to columns of data
    ######
    testdata <- file.path(basepath,"test","X_test.txt")
    traindata <- file.path(basepath,"train","X_train.txt")
    cat("\nReading feature data: columns read from test and training data with following data types:\n\n")
    inertial_data <- rbind(read_table(testdata, col_types = cols(.default = col_double()), 
                                      col_names = FALSE, progress = TRUE),
              read_table(traindata, col_types = cols(.default = col_double()), 
                         col_names = FALSE, progress = TRUE))[,indices]
    names(inertial_data) <- features
    #####
    
    #####
    # (7) Read in activity labels and reformat to lower-case with "." separating word fragments.
    #     Read activity data and substitute labels for numbers.
    #####
    cat("\nReading activity data: columns read from activity labels and activity data w/ data types:\n\n")
    activity_labels <- file.path(basepath,"activity_labels.txt")
    activity_names <- read_table(activity_labels,col_names = c("activity_no","activity"))
    activity_names$activity <- sub("_","\\.",tolower(activity_names$activity))
    y_test <- file.path(basepath,"test","y_test.txt")
    y_train <- file.path(basepath,"train","y_train.txt")
    activities <- rbind(read_table(y_test, col_names = "activity_no"),
                    read_table(y_train, col_names = "activity_no"))
    activity <- activity_names$activity[activities$activity_no]
    #####
    
    #####
    # (8) Read in subject data and assign suitable column name
    #####
    cat("\nReading subject data: Columns read from subject data with following data types:\n\n")
    subject_test <- file.path(basepath,"test","subject_test.txt")
    subject_train <- file.path(basepath,"train","subject_train.txt")
    subjects <- rbind(read_table(subject_test, col_names = "subject"), 
                  read_table(subject_train, col_names = "subject"))
    ####
    
    ####
    # (9) Merge subject, activity, and feature data into a tidy data-set, and write it to disk.
    ####
    inertial_data <- tbl_df(cbind(subjects, activity, inertial_data))
    inertial_data <- arrange(inertial_data, subject, activity)
    inertial_data$subject <- as.factor(inertial_data$subject)
    if (!file.exists("tidy_data.txt"))
    {
        write_delim(inertial_data,"tidy_data.txt")
    }
    ####
    
    ####
    # (10) Create a tidy summary containing the average value for each combination of 'subject' & 'activity'
    #      Use packages 'dplyr' and 'tidyr' to do it. Afterward, write it to disk.
    ####
    data_summary <- inertial_data %>% unite(subject_activity, subject, activity) %>% 
          group_by(subject_activity) %>% summarise_each(funs(mean)) %>%
          separate(subject_activity,c("subject","activity"),sep="_")
    data_summary$subject <- as.integer(data_summary$subject)
    data_summary <- data_summary %>% arrange(subject, activity)
    names(data_summary) <- c("subject", "activity", paste0("avg.", features))
    data_summary$subject <- as.factor(data_summary$subject)
    data_summary$activity <- as.factor(data_summary$activity)
    if (!file.exists("tidy_summary.txt"))
    {
        write_delim(data_summary,"tidy_summary.txt")
    }
    #####
    
    #####
    # (11) Return tidy_summary and tidy_data tbl_df's as a list
    #####
    tidy_list <- list(tidy_data = inertial_data, tidy_summary = data_summary)
    tidy_list
    #####
    
    # function ends here
}

#####
# 
# Function call below causes function 'run_analysis' to be executed when script is sourced.
#
# Notes on arguments for function:
#
# Set 'inst_pkgs_if_needed = FALSE' if you need to manually install necessary packages specified above.
#      I.e. "readr", "tidyr", "dplyr"
# Set 'dwnld_zip = FALSE' if you need to download zip archive manually.
#      URL is "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#      Zipfile must be downloaded to working directory and named "UCI_HAR_Dataset.zip"
# Set 'unzip_archive = FALSE' if you need to unzip archive manually.
#      Archive must be unzipped into a target directory named "UCI_Data" in your working directory.
#
# Note that even if these arguments are TRUE, specified operations will only be performed if necessary.
#####

tidy_list <- run_analysis(inst_pkgs_if_needed = TRUE, dwnld_zip_if_needed = TRUE, unzip_if_needed = TRUE)
