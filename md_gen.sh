#!/bin/bash
#echo $1
#$ooutput_name = 
pandoc -o $1.html $1 -s --template markdown-pandoc-template-bootstrap/template.html --css markdown-pandoc-template-bootstrap/template.css --toc --toc-depth 2 --self-contained
