#!/bin/bash

show_help(){
  echo "Usage:  unpublish path/to/file.html"
  echo
  echo "This will remove a page/post from all index pages, "
  echo "and re-publish your site."
  exit 1
}

[ ! "$1" ] && show_help

# get the HTML file to unpublish
post="$(basename "$1")"
post="${post//.html/}"
post="${post//.mdsh/}"
post="${post//.md/}"

# set the name of the relevant filea
page_mdsh="${post}.mdsh"
page_md="${post}.md"
page_html="${post}.html"

page_file="$(find . -type f -name "${page_html}")"

# if the post html file doesn't exist, exit
if [ ! -f "$page_file" ];then
  echo "Cannot find \"$1\""
  exit 1
fi

# set the date of the post from posts.csv
page_date="$(grep -m1 "|${page_mdsh}|" posts.csv | cut -f1 -d'|')"


echo "Unpublish: ${page_html}"
# comment out the post and remove the html file
sed -i "s:${page_date}|${page_mdsh}:#${page_date}|${page_mdsh}:g" posts.csv
rm "$page_file"

.app/update_pages.sh -all

