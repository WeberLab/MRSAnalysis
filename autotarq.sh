#!/bin/bash

### Tarquin analysis
### Just run the script in a parent directory with subfolders that contain your pfiles and header files
### Written by Alex Weber July 2019

#list all sub-directories
#find -maxdepth 1 -type d > tmp.txt
find -maxdepth 1 -type d > directories.txt
#delete the first line as it just says "."
sed -i -e '1d' directories.txt

#Create master .csv file, and check if one already exists
#If a file exists, create a new one with the same title but with a new number

#Name of CSV file
csvfile=Results

if [[ -e "$csvfile".csv ]] ; then
    i=0
    while [[ -e "$csvfile"-$i.csv ]] ; do
        let i++
    done
    csvfile="$csvfile"-$i
fi
touch "$csvfile".csv

####################
##TARQUIN ANALYSIS##
####################
while IFS= read -r line
do
	cd "$line"
	#Find header files
	find -maxdepth 1 -type f -name "P*.7_c0.shf" > shffiles.txt
	while IFS= read -r line2
	do
		if ! grep -q 'num_pts    12' "$line2"; #Ignore CSI data
		then
			pfile=${line2:2:-9}
			echo $line $pfile
			tarquin --input ${pfile}.7_c0.shf --output_pdf ${pfile}_analysis.pdf --output_txt ${pfile}_analysis.txt ###Tarquin command line###
			cat ${pfile}_analysis.txt | tr -s '[:blank:]' ',' > tmp.txt
			awk '/^$/{exit} {print $0}' tmp.txt > ${pfile}_analysis.csv
			sed -i -e '1,2d' ${pfile}_analysis.csv
			subject=${PWD##*/}
			quality="$(grep "Q                : " ${pfile}_analysis.txt | sed 's/Q                : //')"
			metabppm="$(grep "Metab FWHM (PPM) : " ${pfile}_analysis.txt | sed 's/Metab FWHM (PPM) : //')"
			snrresid="$(grep "SNR residual     : " ${pfile}_analysis.txt | sed 's/SNR residual     : //')"
			snrmax="$(grep "SNR max          : " ${pfile}_analysis.txt | sed 's/SNR max          : //')"
			waterconc="$(grep "Water conc       : " ${pfile}_analysis.txt | sed 's/Water conc       : //')"
			tetime="$(grep "TE (s)  : " ${pfile}_analysis.txt | sed 's/TE (s)  : //')"
			sed -i -e "s&^&${subject},${pfile},${tetime},${quality},${metabppm},${snrresid},${snrmax},${waterconc},&" "${pfile}_analysis.csv"
			cat "${pfile}_analysis.csv" >> ../"${csvfile}".csv
		fi
	done < "./shffiles.txt"
	#rm shffiles.txt
	cd ..
done < "./directories.txt"

#Sort CSV file
sort -o "$csvfile".csv "$csvfile".csv
#Add Column Titles
sed -i '1iSubject,File,TE,Q,Metabolite_FWHM_PPM,Residual_SNR,Max_SNR,Water_Conc,Metabolite,Conc,SDpercent,SD' "$csvfile".csv
