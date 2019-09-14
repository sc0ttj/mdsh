#!/bin/bash

# create a blog post by writing markdown and shell in your terminal

# Just follow the on screen instructions, enter the required post
# meta information, then add your markdown content in the terminal.
# When finished writing your Markdown, hit ENTER 3 times to exit
# and save the file.
#
# Usage:   create_post [-all]
#
#          Follow the instructions to create your page meta info.
#          You can give `-all` to set all meta info, allowing you
#          to override site defaults.


# load the local config file
[ -f .site_config ] && source .site_config

echo
echo "Enter the meta info for your page:"
echo

# get user input to create the meta data
echo -n "Title:        "
read -er title
echo -n "Description:  "
read -er description
echo -n "Time to read: "
read -er time_to_read
echo -n "Category:     "
read -er category
echo -n "Tags (comma separated words or phrases): "
read -er tags
echo -n "Layout:       "
read -er -i main layout

# set some defaults, based on site defaults
permalink=""
author="${author:-$site_author}"
email="${email:-$site_email}"
twitter="${twitter:-$site_twitter}"
language="${language:-$site_language}"
js_deps="${js_deps:-$site_js_deps}"

# allow user to override site default if -all given
if [ "$1" = "-all" ];then
  echo -n "Permalink:       "
  read -er -i "posts/$(echo "$title" | slugify)" permalink
  echo -n "Author:       "
  read -er -i "$site_author" author
  echo -n "Email:        "
  read -er -i "$site_email" email
  echo -n "Twitter:      "
  read -er -i "$site_twitter" twitter
  echo -n "Language:     "
  read -er -i "$site_language" language
  echo -n "JS deps (comma separated package names): "
  read -er -i "$site_js_deps" js_deps
fi

# slugiy the tags
OLDIFS=$IFS
IFS=","
for tag in $tags
do
  fixed_tags="$fixed_tags $(echo $tag | slugify | sed 's/^-//'),"
done
IFS=$OLD_IFS

fixed_tags="$(echo "$fixed_tags" | sed -e 's/^ //' -e 's/,$//')"
tags="$fixed_tags"

# generate some more meta info
slug=$(echo "$title" | slugify)
date_dir="$(LANG=C LC_ALL=C LC_CTYPE=C date -u +"%Y/%m/%d")"
date_created="$(LANG=C LC_ALL=C LC_CTYPE=C date -u +"%Y-%m-%dT%H:%M:%SZ")"
date_modified="$date_created"

# set meta info
meta_data="title:            $title
slug:             $slug
descr:            $description
permalink:        $permalink
time_to_read:     $time_to_read
created:          $date_created
category:         $category
tags:             $tags
layout:           $layout
author:           ${author:-$site_author}
email:            ${email:-$site_email}
twitter:          ${twitter:-$site_twitter}
language:         ${language:-$site_language}
js_deps:          $(echo ${js_deps:-$site_js_deps} | tr ',' '\n' | sed "s/^[ .*]//g" | while read line; do [ ! -z "$line" ] && echo "  ${line//@*/}: ${line}"; done)
modified:         $date_modified"

# show meta info
echo
echo "Meta data:

$meta_data"


# ask to continue
echo
echo -n "Continue (Y/n)? "
read -n1 answer
echo

# quit if not 'y' or 'Y'
if [ "$answer" = 'n' ] || [ "$answer" = 'N' ];then
  echo
  echo "Exiting..."
  exit 1
fi

# set the output files
md_file="./posts/$date_dir/${slug}.md"
mdsh_file="${md_file}sh"
# write meta info to mdsh file
mkdir -p ./posts/$date_dir/
echo "$meta_data" > "$mdsh_file"
echo ""          >> "$mdsh_file"
echo "---"       >> "$mdsh_file"
# create a matching valid markdown file
echo -n ""       >> "$md_file"

if [ "$USE_EDITOR" != true ];then

  # final message
  echo "Saved meta data in: posts/$date_dir/${slug}.mdsh"
  echo
  echo "Now write your markdown below, line by line.
   * supports TAB completion (of file names, etc)
   * supports terminal hotkeys (skip words with Alt-f, Alt-b, etc)
   * supports embedding executable commands in your markdown
   * just start a sub-shell using <?bash //some code ;?> and
     the results will be in the final markdown.
   * Hit ENTER 3 times to exit and save the file. "
  echo


  #
  # begin interactive mdshell (user can create the markdown document line by line)
  #

  echo "## $title"
  echo
  # run interactive shell for writing the content itself, in markdown
  .app/mdshell.sh posts/$date_dir/${slug}.mdsh

else
  $EDITOR posts/$date_dir/${slug}.mdsh

  # create the HTML page
  html_file="posts/$date_dir/${slug}.html"
  markdown_file="posts/$date_dir/${slug}.md"
  rebuild "posts/$date_dir/${slug}.mdsh" > "$html_file"

  echo "Saved as:"
  echo
  echo "HTML page:      $html_file"
  echo "Markdown file:  $markdown_file"
  echo "Source file:    posts/$date_dir/${slug}.mdsh"
  echo

fi

# update the main database of posts for the site
echo "$date_dir|${slug}.mdsh|$title|$author|$category|$tags" >> posts.csv
sort -u posts.csv | uniq >> posts_sorted.csv
mv posts_sorted.csv posts.csv

# pass the source file to update_pages.sh, so it knows to only
# rebuild index pages relevant to that post
.app/update_pages.sh posts/$date_dir/${slug}.mdsh

exit 0
