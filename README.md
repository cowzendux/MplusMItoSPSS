#MplusMItoSPSS

SPSS Python Extension function to combine imputed datasets created by Mplus into a single multiple-imputation dataset in SPSS.

This and other SPSS Python Extension functions can be found at http://www.stat-help.com/python.html

##Usage
**MplusMItoSPSS(imputeloc)**
* "imputeloc" is a string that indicates the directory and root filename of the imputed data sets. All files that start with the root filename and have the extension .dat will be combined into the new spss data set. If the root filename is excluded (i.e., if imputeloc ends with a forward slash), then the program will include all .dat files in the directory in the new spss data set.
* The program will add a variable to the data set to indicate the number of the imputation file.
* Creates a subdirectory called SPSS that contains copies of each imputed dataset in SPSS format, as well as a data set called "0 impute.sav" that has them all merged together with an indicator for imputation.
* To work with the imputed data in SPSS, load the 0 impute.sav data set, then split the file based on the imputation_ variable.
 
##Example
**MplusMItoSPSS("C:/Users/Jamie/Dropbox/Implicit IC/Data/imputation/model_1")**
* Will find all of the imputation data files starting with "model_1" in the "C:/Users/Jamie/Dropbox/Implicit IC/Data/imputation" directory and merge them into a single SPSS data file. 
* The merged data set (along with SPSS versions of the individual imputation data sets) will be saved in the file "C:/Users/Jamie/Dropbox/Implicit IC/Data/imputation/SPSS/0 impute.sav". SPSS versions of all of the individual imputation data sets will be saved in the same directory.
