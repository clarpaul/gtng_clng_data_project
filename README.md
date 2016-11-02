# ReadMe: 
# UCI Human Activity Recognition Data Tidying and Analysis
The R script contained in `run_analysis.R` performs the following:
 1.  Loads packages for data tidying/analysis, installing from CRAN if unavailable in host R library.
 2.  Downloads UCI archive with Human Activity Recognition data.
 3.  Unzips archive.
 4.  Reads feature names from archive, building a vector of indices for features of interest. 
 5.  Transforms feature names of interest into consistent, readable format. See [Google R Style Guide](https://google.github.io/styleguide/Rguide.xml).
 6.  Reads feature data, using indices from (4) to subset columns of interest. Assigns feature names to columns.
 7.  Reads table of activity labels and names, transforming to format like (5); reads numbered activity data and substitutes labels for numbers.
 8.  Reads in subject data.
 9.  Creates tidy data by merging subject, activity, and feature data; then writes result to working directory.
 10. Creates tidy summary by averaging rows in (9) for each unique subject-activity pair; then writes result to disk.
 11. Loads tidy data and tiday summary to global environment.

The function relies on packages `readr`, `tidyr`, and `dplyr` to operate. Package `readr` is used for speed and progress bars while reading all data files into `tbl_df` formats, which print to the console in a convenient, summary manner. Packages `tidyr` and `dplyr` are used for speed and concise code in step 10, creating a tidy summary.

Steps 1 through 3 may be skipped if the user does them manually.  That is done by setting one or more of the three variables in the function call at the bottom of the file to FALSE (`inst_pkgs_if_needed`, `dwnld_zip_if_needed`, `unzip_if_needed`).  However, even if not set to FALSE, the script does a check on the necessity of these steps. In step 1, the packages are not installed if they can be loaded from the host library. In step 2, the archive is not downloaded if a file of the appropriate name is already present in the working directory (`UCI_HAR_Dataset.zip`).  And in step 3, the archive is not unzipped if a set of directories of the appropriate names already exists (`./UCI_Data/UCI_HAR_Dataset.zip`).

After the preliminaries of steps 1 through 3 are done, data pre-processing is done in steps 4 through 8.  In step 4, the 561 feature names are read and subsetted so as to extract only the 66 containing `mean()` and `std()`. In step 5, the feature names are tidied.  See file `CodeBook.md` in this repo for details of transformation and for final format. In steps 6 through 8, the feature, activity, and subject data are read, merging test and training data for each.

In step 9, since rows of the subject, activity, and feature data are in the same order, merging to form a tidy dataframe requires only a straightforward `cbind`. The resulting dataframe is 68 columns wide. Columns 1 and 2 provide the subject and activity identifiers as factor data.  The remaining 66 columns contain the selected numeric feature values.  There are 10,299 rows/observations.  See `CodeBook.md` in this repo for more detail on what each observation represents. At the end of step 9, the tidy dataframe is written to disk as `tidy_data.txt`, a space delimited file.

In step 10, the actual analysis takes place. The data is summarized by taking averages of the rows/observations corresponding to each unique subject-activity pair.  With 30 subjects and 6 activities, this results in 180 averages for each of the 66 columns.  Functions from `dplyr` and `tidyr` are used here. At the conclusion of this step, the tidy data summary is written to disk as `tidy_summary.txt`, another space-delimited file.

Finally, in step 11, the data and corresponding summary are loaded into the global environment of the host as a list of two `tbl_df` dataframes. Dataframe `tidy_list[[1]]` is the tidy data, `tidy_data`. Dataframe `tidy_list[[2]]` is the tidy summary, `tidy_summary`.

For more documentation of the data-processing and analysis, written according to the structure above but also including commentary on specific functions used, please see the analysis script in this repo, `run_analysis.R`.
 
