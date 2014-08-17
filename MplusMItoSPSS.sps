* Program to combine imputed datasets created by Mplus
* into a single multiple-imputation dataset in SPSS

* Written by Jamie DeCoster

*************
* Version History
*************
* 2012-07-11 Created
* 2012-07-12 Changed split function
* 2012-07-12a Reverted split function change
   Now the program saves individual imputation data sets
* 2012-07-13 Made sure that the program doesn't try to include the list file
   Adds each file with a separate add files statement

* Use: MplusMItoSPSS(imputeloc)

* imputeloc is a string, provided in quotes, that indicates the directory and root
* filename of the imputed data sets. When giving the directory, make sure that
* you use forward slashes (/) instead of backslashes (\) when indicating subdirectories.
* All files that start with the root filename and have the extension .dat will be
* combined into the new spss data set. If the root filename is excluded (i.e., if imputeloc
* ends with a forward slash), then the program will include all .dat files in the 
* directory in the new spss data set. 

* The program will add a variable to the data set to indicate the number of the imputation file

* Creates a subdirectory called SPSS that contains copies of each imputed dataset in
* SPSS format, as well as a data set called "0 impute.sav" that has them all merged
* together with an indicator for imputation.

* To work with the imputed data in SPSS, load the 0 impute.sav data set, then
* split the file based on the imputation_ variable

set printback = off.
begin program python.
import spss, os

def SPSSNameSplit(splitstring):
   curstring = splitstring
   finished = 0
   returnstring = "'"
   while (finished == 0):
      if (len(curstring) < 60):
         returnstring = returnstring + curstring + "'"
         finished = 1
      else:
         returnstring = returnstring + curstring[:60] + "'+\n '"
         curstring = curstring[60:]
   return returnstring

def MplusMItoSPSS(imputeloc):
   lastchar = imputeloc[len(imputeloc)-1]
   if (lastchar <> "/"):
      slashspot = -9
      for t in range(len(imputeloc)):
         if (imputeloc[len(imputeloc)-t-1] == "/"):
            slashspot = len(imputeloc)-t
            datapath = imputeloc[:slashspot]
            imputeroot =  imputeloc[slashspot:]
            break
      if (slashspot == -9):
         print("Incorrect file location")
         return
   else:
      datapath = imputeloc
      imputeroot = ""

# Get a list of all imputed data files in the directory

   allfiles=[os.path.normcase(f)
   for f in os.listdir(datapath)]
   imputefiles=[]
   for f in allfiles:
      fname, fext = os.path.splitext(f)
      if ((fname.startswith(imputeroot) or (imputeroot == "")) and ('.dat' == fext) and (not fname.endswith("list"))):
         imputefiles.append(fname)

   print imputefiles

# Create SPSS subdirectory if it does not exist
   if not os.path.exists(datapath + "/SPSS"):
      os.mkdir(datapath + "/SPSS")

####
# Read in data and write individual files
####

   # Open first file just to determine the number of variables

   f = open(datapath + imputefiles[0] + ".dat", "r")
   lines = f.readlines()
   i = lines[0].split()
   varnum = len(i)
   f.close()

# Open the files and add data to dataset
   
   datasetnum = 0
   for filename in imputefiles:

# Clear out current file
      submitstring = """NEW FILE.
   DATASET NAME $DataSet WINDOW=FRONT."""
      print submitstring
      spss.Submit(submitstring)

# File definition
      submitstring = """data list free 
/imputation_
"""
      for t in range(varnum):
         submitstring = submitstring + "var" + str(t+1) + "\n"
      submitstring = submitstring + """.
begin data"""

      datasetnum = datasetnum + 1
      print datapath + filename + ".dat"
      f = open(datapath + filename + ".dat", "r")
      lines = f.readlines()
      for t in lines:
         submitstring = submitstring + "\n" + str(datasetnum)
         i = t.split()
         for j in i:
            submitstring = submitstring + "\n" + str(j)
      f.close()

      submitstring = submitstring + """\nend data.
DATASET NAME $DataSet WINDOW=FRONT.

variable labels imputation_ 'Imputation Number'.

SAVE OUTFILE='%sSPSS/%s.sav'
  /COMPRESSED.""" %(datapath, filename)
      spss.Submit(submitstring)

######
# Merge files
######
# Last file is already loaded
   
   for filename in imputefiles[:len(imputefiles)-1]:
      submitstring = """ADD FILES
 /file=*"""
      submitstring = submitstring + "\n /file=" + SPSSNameSplit(datapath + "SPSS/" + filename + ".sav")
      submitstring = submitstring + """.
EXECUTE.
DATASET NAME $DataSet WINDOW=FRONT."""
      print submitstring
      spss.Submit(submitstring)

   submitstring = "SAVE OUTFILE=" + SPSSNameSplit(datapath + "SPSS/" + "0 impute.sav") + """
  /COMPRESSED.

GET
  FILE=%s.
DATASET NAME $DataSet WINDOW=FRONT.
SORT CASES  BY imputation_.
SPLIT FILE LAYERED BY imputation_.""" %(SPSSNameSplit(datapath + "SPSS/" + "0 impute.sav"))
   print submitstring
   spss.Submit(submitstring)

end program python.
set printback = on.
