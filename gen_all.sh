#!/bin/bash
# echo $#
# echo $*
mkdir -p pub
cp -fr markdown-pandoc-template-bootstrap pub/

if [ $# -gt 0 ]
then
	doc_dirs=$*
else
	doc_dirs=*/
fi

echo ${doc_dirs}

for dir in ${doc_dirs}
do
	if test -d $dir
	then
		if [[ $dir != "pub/" && $dir != "markdown-pandoc-template-bootstrap/" ]]
		then
			mkdir -p pub/$dir
			if test -d ${dir}/media
			then
				cp -fr ${dir}/media pub/${dir}/
			fi
			echo ${dir}
			cd ${dir}
			for mdfile in *.md
			do
				echo $mdfile
				pandoc -o ../pub/${dir}/${mdfile}.html ${mdfile} -s --template ../markdown-pandoc-template-bootstrap/template.html --css ../markdown-pandoc-template-bootstrap/template.css --toc --toc-depth 2
				pandoc -o ../pub/${dir}/${mdfile}.pdf ${mdfile} --latex-engine=xelatex -V CJKmainfont='Microsoft YaHei' --toc --toc-depth 2
				# pandoc -o ../pub/${dir}/${mdfile}.pdf ${mdfile} --listings -H ../listings-setup.tex --latex-engine=xelatex -V CJKmainfont='STKaiti' --toc --toc-depth 2
			done
			cd ..
			#pandoc 

		# else
			# echo ${dir} not exist
		fi
	fi
 # do something on $file
 # [ -f "$file" ] && cat "$file"
done