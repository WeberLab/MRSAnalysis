# MRSAnalysis

## Tarquin analysis

```
autotarq.sh
```

Assumes you are in a parent directly with subdirectories that contain .P and header files.
Script is supposed to:
- search for P files and their headers
- analyze using Tarquin command line
- spit out a master .csv file with all the info you want

## FSL_MRS

```
fsl_mrs_proc.sh
```

example usage:

```
fsl_mrs_proc.sh P38400 fsl_mrs_proc_new
```

Assumes you are in the directory with the Pfile

Script will run fsl_mrs_proc steps

[note: you should have the most up-to-date version of fsl_mrs installed... usually through a conda virtual env and remove what was installed with fsl installation]