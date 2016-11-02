# ReadMe: UCI Human Activity Recognition Data Tidying and Analysis
The R script contained in `run_analysis.R` does multiple tasks:
 1.  Loads packages for data tidying/analysis, installing from CRAN if unavailable in host R library.
 2.  Downloads UCI archive with Human Activity Recognition data.
 3.  Unzips archive.
 4.  Reads feature names from archive. Builds vector of indices for features of interest. 
 5.  Transforms feature names into consistent, readable format. See [Google R Style Guide](https://google.github.io/styleguide/Rguide.xml).
 6.  Reads feature data, using indices from (4) to select subset of interest. Assigns 'tidy' feature names to columns.
 7.  Reads activity labels, transforming to format like (5). Reads numbered activity data and substitutes labels for numbers.
 8.  Reads in subject data.
 9.  Creates tidy dataset: merges subject, activity, and feature data, and writes result to working directory.
 10. Creates tidy summary: averages rows in (9) for each unique subject-activity pair. Writes result to disk.
 11. Loads tidy data and tiday summary to global environment.
 
 Performs analysis on tidy data to create a tidy summary
 7. Writes the data and its summary to disk as text files, and loads it into the global environment within R
 
Steps 1 through 3 may be skipped if the user wants to do them manually.  That is done by setting one or more of the three variables in the function call at the bottom of the file to FALSE.  However, even if not set to FALSE, the script does a check on the necessity of each of steps 1 through 3. In step 1, although the packages must be loaded for the function to operate, they are not installed if they can be loaded from the library. In step 2, the archive is not downloaded if a file of the appropriate name is already present in the working directory.  And in step 3, the archive is not unzipped if a set of directories of the appropriate names already exists. 

After the preliminaries of steps 1 through 3 are done, the main data processing is done in steps 4 through 6.  In step 4, the subject, activity, and feature data are read into memory using function `read_table` from `readr` (a package utilized for speed and ease of use). Each of these exists in two parts (test and training data), and these parts are combined before the subject, activity, feature data are merged to form a single tidy dataset.  Before the merging is done, the appropriate features are identified and extracted (just the 66 containing `mean()` and `std()` in their names - a subset of the total 561).  An vector of column numbers is created as part of the feature name identification (this is later used to extract the corresponding feature data). After identification of the desired feature names, the names are tidied for readability.  These names come initially in a combination of formats, including a 'camelcase' segment (each word fragment startig with a capital followed by lower-case letters), a hyphenated segment, parentheses associated with the variable type (such as those in `mean()` and `std()`), and capitalized coordinate directions `X`, `Y`, and `Z` as suffixes.  The names are tidied according to the following protocol: they hyphens are removed, all characters are lower-cased, periods (".") are inserted between all word fragments, and all numbers are removed (note: no features involving `mean()` or `std()` rely on numbers as part of their names - for those variables, the numbers are just used like row names).

In step 5, the data is merged based.  Before merging, the activity names are substituted for activity numbers (1 through 6). The activity names are also tidied, according to a similar protocol to that used for the feature names.  Because all the data rows and columns are (assumed to be!) in the same order across the various text files, the merger itself is not complicated.  `cbind` is used to assemble the column-oriented components, and the column names are set equal to the tidied feature names via the `names()` function.  This results in a dataframe which is 68 columns wide. It has 2 initial columns for the subject and activity factor information, and 66 remaining columns for the selected numeric features.  The number of rows is 10,299.

In step 6, the data is summarized by taking averages of the rows corresponding to each unique subject-activity pair.  With 30 subjects and 6 activities, this results in 180 averages for each of the 66 columns.  Functions from `tidyr` and `dplyr` are used to do the summary.

Finally, in step 7, the data and corresponding summary is written to the working directory in the form of two text files described in the CodeBook, and loaded into the memory as a list of two dataframes, as well.
 
