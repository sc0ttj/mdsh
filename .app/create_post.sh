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
# if -all given, ask for all meta info
if [ "$1" = "-all" ];then
  echo -n "Author:       "
  read -er -i "$blog_author" author
  echo -n "Email:        "
  read -er -i "$blog_email" email
  echo -n "Twitter:      "
  read -er -i "$blog_twitter" twitter
  echo -n "Language:     "
  read -er -i "$blog_language" language
  echo -n "JS deps (comma separated package names): "
  read -er -i "$blog_js_deps" js_deps
fi

# slugiy the tags
OLDIFS=$IFS
IFS=","
for tag in $tags
do
  fixed_tags="$fixed_tags $(.app/slugify.sh $tag | sed 's/^-//'),"
done
IFS=$OLD_IFS
fixed_tags="$(echo "$fixed_tags" | sed -e 's/^ //' -e 's/,$//')"
tags="$fixed_tags"

# generate some more meta info
slug=$(slugify.sh "$title")
date_dir="$(date -u +"%Y/%m/%d")"
date_created="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
date_modified="$date_created"

# set meta info
meta_data="# title:        $title
# slug name:    $slug
# description:  $description
# time to read: $time_to_read
# category:     $category
# tags:         $tags
# author:       ${author:-$blog_author}
# email:        ${email:-$blog_email}
# twitter:      ${twitter:-$blog_twitter}
# language:     ${language:-$blog_language}
# JS deps:      ${js_deps:-$blog_js_deps}
# created:      $date_created
# modified:     $date_modified"


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

# update the main database of posts for the site
echo "$date_dir|${slug}.mdsh|$title|$author|$category|$tags" >> posts.csv
sort -u posts.csv | uniq >> posts_sorted.csv
mv posts_sorted.csv posts.csv

# pass the source file to update_pages.sh, so it knows to only
# rebuild index pages relevant to that post
.app/update_pages.sh posts/$date_dir/${slug}.mdsh

exit 0
