#!/bin/bash

#list all directories
find -maxdepth 1 -type d > tmp.txt
#delete the first line as it just says "."
sed -e '1d' tmp.txt > directories.txt
rm tmp.txt

while IFS= read -r line
do
	cd "$line"
	find -maxdepth 1 -type f -name "P*.shf" > shffiles.txt
	while IFS= read -r line2
	do
		#if [grep -q 'TE  35' "$line2"] -a [! grep -q 'num_pts    12' "$line2"];
		if ! grep -q 'num_pts    12' "$line2" && grep -q 'TE  35' "$line2"; 
		then 
			pfile=${line2::-6}
			echo $line $pfile
			tarquin --input ${pfile}.7 --format ge --output_pdf ${pfile}_35TE.pdf --output_txt ${pfile}_35TE.txt
			
		fi
	done < "./shffiles.txt"
	rm shffiles.txt
	cd ..
done < "./directories.txt"
