#markdown to html
pandoc -o xx.html xx.md -s --template markdown-pandoc-template-bootstrap/template.html --css markdown-pandoc-template-bootstrap/template.css --toc --toc-depth 2 
--self-contained
#using --self-contained can force html to contain css and images

#markdown to docx
pandoc -o xx.docx xx.md --toc --toc-depth 2

#markdown to pdf
#using fc-list :lang=zh-cn to check system fonts installed
#and don't use the font file name as the font name, but the real name
pandoc -o kk.pdf kk.md --latex-engine=xelatex -V CJKmainfont='Songti SC' --toc --toc-depth 2

#docx to markdown
#all images will be extracted in kk-medias
pandoc -o kk.md kk.docx --extract-media=kk-medias
