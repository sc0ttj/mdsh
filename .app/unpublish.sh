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

# set the name of the markdown file
post_mdsh="${post}.mdsh"
post_md="${post}.md"
post_html="${post}.html"

post_file="$(find . -type f -name "${post_html}")"

# if the post html file doesn't exist, exit
if [ ! -f "$post_file" ];then
  echo "Cannot find \"$1\""
  exit 1
fi

# set the date of the post from posts.csv
post_date="$(grep -m1 "|${post_mdsh}|" posts.csv | cut -f1 -d'|')"


echo "Unpublish: ${post}"
# comment out the post and remove the html file
sed -i "s:${post_date}|${post_mdsh}:#${post_date}|${post_mdsh}:g" posts.csv
rm "$post_file"

.app/update_pages.sh -all

