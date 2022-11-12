#!/bin/bash

set -e

if [[ $# -eq 0 ]]
  then
    echo "No arguments supplied"
    echo "Try: fsl_mrs_proc.sh Pnumber.7 output-folder-name"
    exit 1
  elif [[ $# -gt 2 ]]
  then
    echo "Too many arguments supplied"
    exit 1
fi
pfile=$1
outp=$2

#Average the water ref data:
echo "Averaging wref"
fsl_mrs_proc average --file ${pfile}.nii.gz --dim DIM_DYN --output $outp --filename press_wref_tmp
#Coil Combine
echo "Coil Combining"
fsl_mrs_proc coilcombine --file ${pfile}.nii.gz --reference $outp/press_wref_tmp.nii.gz --filename press_metab_comb --output $outp -r
fsl_mrs_proc coilcombine --file ${pfile}_ref.nii.gz --reference $outp/press_wref_tmp.nii.gz --filename press_wref_comb --output $outp
#Phase and freq align
echo "Phase and Freq Align"
fsl_mrs_proc align --file $outp/press_metab_comb.nii.gz --ppm 0.2 4.2 --output $outp -r --filename press_metab_align --apod 20 
fsl_mrs_proc align --file $outp/press_wref_comb.nii.gz --ppm 0 9 --output $outp --filename press_wref_align
#data averaging
echo "Averaging Data"
fsl_mrs_proc average --file $outp/press_metab_align.nii.gz --dim DIM_DYN  --output $outp -r --filename press_metab_avg
fsl_mrs_proc average --file $outp/press_wref_align.nii.gz --dim DIM_DYN  --output $outp --filename press_wref_avg
#ECC
echo "Eddy Current Correcting"
fsl_mrs_proc ecc --file $outp/press_metab_avg.nii.gz --reference $outp/press_wref_avg.nii.gz  --output $outp -r --filename press_metab_ecc
fsl_mrs_proc ecc --file $outp/press_wref_avg.nii.gz --reference $outp/press_wref_avg.nii.gz  --output $outp --filename press_wref_ecc
#Centring the echo
echo "Centering the echo"
fsl_mrs_proc truncate --file $outp/press_metab_ecc.nii.gz --points -1 --pos first --filename press_metab_trunc --output $outp -r
fsl_mrs_proc truncate --file $outp/press_wref_ecc.nii.gz --points -1 --pos first --filename press_wref_trunc --output $outp
#Residual Water removal
echo "Residual Water removal"
fsl_mrs_proc remove --file $outp/press_metab_trunc.nii.gz --output $outp -r --filename press_metab_hlsvd
#Phase Correction
echo "Phase Correction"
fsl_mrs_proc phase --file $outp/press_metab_hlsvd.nii.gz --output $outp -r --filename metab
fsl_mrs_proc phase --ppm 4.6 4.7 --file $outp/press_wref_trunc.nii.gz --output $outp -r --filename wref
#Merge Reports
echo "Merging Reports"
merge_mrs_reports -d "FSL-MRS pre-processing practical." -o $outp --delete $outp/report*.html 
