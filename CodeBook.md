# Code Book: UCI Human Activity Recognition Data Set
The data produced by the analysis script is written to disk as two data files:
 1. `tidy_data.txt`, which contains selected data from the original UCI analysis itself, in space delimited format
 2. `tidy_summary.txt`, which contains summary metrics for the feature data calculated in the UCI analysis, in space delimited format 

The analysis script also loads the data into the global environment in the form of a list (`tidy_list`) of two tbl_df dataframes corresponding to the above files (`tidy_data` and `tidy_summary`). For details on tbl_df's, see the documentation for packages `tidyr` or `dplyr`.

To produce the dataset from which (1) was selected, investigators used Samsung cell phones to record gyroscopic and accelerometer sensor readings of 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz.  The cell phones were worn on the belts of 30 subjects while they engaged in six, video-recorded acitvities (see list below). From the sensor readings, 561 different features were calculated, of which 66 were selected for this analysis. Each observation of 66 features corresponds to a row in (1), calculated based on 128 readings taken during a 2.56 sec time window.  The 66 features selected for this analysis correspond to signal means and standard deviations: original feature names containing `mean()` or `std()`. Other features not selected for this analysis include `max()`, `min()`, `correlation()`, and many more.

Each row of feature values in (1) was calculated based on readings taken while a specific `subject` engaged in a specific `activity`. Column 1, numbered 1 to 30, contains the subject ID number, and is encoded as a factor variable in the loaded dataframes. Each row of column 2 takes on one of the six values below, and is also encoded as a factor variable. The values below are transformed from those in the original dataset by lower-casing and substitution of a "." for hyphens between words.
````
laying
sitting
standing
walking
walking.upstairs
walking.downstairs
````
Columns 3 through 68 of the files contain the original feature data (file 1) and summary metrics (file 2). In the data of file (1), all features were normalized and bounded within [-1,1]. This data consists of 10,299 rows, each corresponding to data collection over a specific 2.56 sec window for a specific subject-activity pair. The summary metrics in file (2) are averages across all time windows (rows of 1) associated with a given subject-activity pair, resulting in just 180 rows (`6 activities * 30 subjects`).

For detail on the exact features and the experimental setup, see the files `features_info.txt` and `README.txt`, both included in the UCI archive for the experiment. The archive was first downloaded by this author  on 10/31/16, but it is also downloaded by the script `run_analysis.R` from a [Cloudfront server (here)] (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). It was originally obtained from a [UCI Website (here)] (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).  

The names of the variables selected for the dataset in (1) are listed below alongside their column number in files (1) and (2). Note that `t` is used to denote time domain, and `f` is used to denote frequency domain; `acc`, `gyro`, and `mag` stand for acceleration, gyroscope, and magnitude; and `x`, `y`, and `z` stand for the three axial directions. 

The variable names shown here are transformed for readability from those used in `features.txt` in the original data archive. All letters were lower-cased; all non-alphanumerics, white-space, and variable numbers were removed; and a dot (".") was placed between each pair of word fragments.  For the averages in file (2), the variable names below are prefixed with the characters `avg.`
````
 [3] "t.body.acc.mean.x"              "t.body.acc.mean.y"              "t.body.acc.mean.z"             
 [6] "t.body.acc.std.x"               "t.body.acc.std.y"               "t.body.acc.std.z"              
 [9] "t.gravity.acc.mean.x"           "t.gravity.acc.mean.y"           "t.gravity.acc.mean.z"          
[12] "t.gravity.acc.std.x"            "t.gravity.acc.std.y"            "t.gravity.acc.std.z"           
[15] "t.body.acc.jerk.mean.x"         "t.body.acc.jerk.mean.y"         "t.body.acc.jerk.mean.z"        
[18] "t.body.acc.jerk.std.x"          "t.body.acc.jerk.std.y"          "t.body.acc.jerk.std.z"         
[21] "t.body.gyro.mean.x"             "t.body.gyro.mean.y"             "t.body.gyro.mean.z"            
[24] "t.body.gyro.std.x"              "t.body.gyro.std.y"              "t.body.gyro.std.z"             
[27] "t.body.gyro.jerk.mean.x"        "t.body.gyro.jerk.mean.y"        "t.body.gyro.jerk.mean.z"       
[30] "t.body.gyro.jerk.std.x"         "t.body.gyro.jerk.std.y"         "t.body.gyro.jerk.std.z"        
[33] "t.body.acc.mag.mean"            "t.body.acc.mag.std"             "t.gravity.acc.mag.mean"        
[36] "t.gravity.acc.mag.std"          "t.body.acc.jerk.mag.mean"       "t.body.acc.jerk.mag.std"       
[39] "t.body.gyro.mag.mean"           "t.body.gyro.mag.std"            "t.body.gyro.jerk.mag.mean"     
[42] "t.body.gyro.jerk.mag.std"       "f.body.acc.mean.x"              "f.body.acc.mean.y"             
[45] "f.body.acc.mean.z"              "f.body.acc.std.x"               "f.body.acc.std.y"              
[48] "f.body.acc.std.z"               "f.body.acc.jerk.mean.x"         "f.body.acc.jerk.mean.y"        
[51] "f.body.acc.jerk.mean.z"         "f.body.acc.jerk.std.x"          "f.body.acc.jerk.std.y"         
[54] "f.body.acc.jerk.std.z"          "f.body.gyro.mean.x"             "f.body.gyro.mean.y"            
[57] "f.body.gyro.mean.z"             "f.body.gyro.std.x"              "f.body.gyro.std.y"             
[60] "f.body.gyro.std.z"              "f.body.acc.mag.mean"            "f.body.acc.mag.std"            
[63] "f.body.body.acc.jerk.mag.mean"  "f.body.body.acc.jerk.mag.std"   "f.body.body.gyro.mag.mean"     
[66] "f.body.body.gyro.mag.std"       "f.body.body.gyro.jerk.mag.mean" "f.body.body.gyro.jerk.mag.std"
````

