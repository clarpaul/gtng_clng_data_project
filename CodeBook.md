# Code Book: UCI Human Activity Recognition Data Set
The data produced by the analysis script is written to disk as two data files, `tidy_summary.txt`, which contains a summary of the feature data calculated in the UCI analysis, and `tidy_data.txt`, which contains selected data from the original UCI analysis itself. The data extracted from the original UCI analysis was produced by taking the means and standard deviations in short time windows of signals calculated from gyroscopic and accelerometer output of Samsung cell-phones worn on the belts of 30 subjects (numbered 1 through 30 in column 1 of the files, and described as factors in the dataframes loaded into the workspace by `run_analysis.R`) while they performed 6 acitvities denoted by the following activity names (contained in column 2 of the files, and also described as factors in the dataframes loaded into the workspace by `run_analysis.R`):
````
laying
sitting
standing
walking
walking.upstairs
walking.downstairs
````
Columns 3 through 68 of the files contain the original feature data (file `tidy_data.txt`) and summary metrics (file `tidy_summary.txt`) corresponding to  every combination of subject and activity (`6 * 30 = 180` in all). The original feature data consists of 10,299 rows, representing data collection over different, short windows of time for each subject-activity pair, whereas the summary metrics are averages across all time windows over the entire course of data collection, resulting in just 180 rows, one for each subject-activity pair.

The derivation and description of the exact features used are described in the file `features_info.txt`, included in the UCI archive described at <http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>, and downloaded from <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip> on 10/31/16.  Note: Below, `t` is used to denote time domain, and `f` is used to denote frequency domain.  Also, the signal and variable names listed are in the notation used in the `data` and `summary` text files available in this repo after transformation via `run_analysis.txt`, not those used in the original data archive. The transformation of variable naming notation involved changing all characters to lower-case, removing all symbols, and placing a dot (".") between each pair of word fragments.

> ### Feature Selection 

> The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals `t.acc.x|y|z` and `t.gyro.x|y|z` [here, `x|y|z` is used to denote a 3-axial signal in the X, Y or Z direction]. These time domain signals were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (`t.body.acc.x|y|z` and `t.gravity.acc.x|y|z`) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

> Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (`t.body.acc.jerk.x|y|z` and `t.body.gyro.jerk.x|y|z`). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (`t.body.acc.mag, t.gravity.acc.mag, t.body.acc.jerk.mag, t.body.gyro.mag, t.body.gyro.jerk.mag`). 

> Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing `f.body.acc.x|y|z`, `f.body.acc.jerk.x|y|z`, `f.body.gyro.x|y|z`, `f.body.acc.jerk.mag`, `f.body.gyro.mag`, `f.body.gyro.jerk.mag`. 

The above signals were used to estimate variables of the feature vector for each pattern. Means (`mean`) and standard deviations (`std`) were estimated by averaging the signals in a signal window sample.  These resulted in the following variables collected in file `tidy_data.txt`.
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
By averaging across signal windows within each subject-activity combination for each of the above variables, `run_analysis.R` produces variables for `tidy_summary.txt` that are named by prefixing each of the above with `avg.`
