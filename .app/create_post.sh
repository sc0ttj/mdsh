#!/bin/bash

# create a blog post by writing markdown and shell in your terminal

# Just follow the on screen instructions, enter the required post
# meta information, then add your markdown content in the terminal.
#
# Usage:   create_post.sh <page_type> [-all]
#
#          Follow the instructions to create your page meta info.
#          You can give `-all` to set all meta info, allowing you
#          to override site defaults.


# load the local config file
[ -f .site_config ] && source .site_config

page_type="$1"
page_type="${page_type//-all/post}"
page_type="${page_type//-ALL/post}"

if [ "$(page_type_is_valid $page_type)" != true ];then
  echo "Invalid page type '$page_type'. Must be one of these:"
  echo "$(lookup page_types.* | sed 's/page_types_//g')"
  return 1
fi

page_type_plural="$(lookup page_types.${page_type}.plural)"
page_type_plural="${page_type_plural:-posts}"

# begin user input
echo
echo "Enter the meta info for your ${page_type}:"
echo

# get user input to create the meta data
echo -n "Title:        "
read -er title
echo -n "Description:  "
read -er description
echo -n "Time to read: "
read -er time_to_read

# based on page type, get the relevant taxonomies
relevant_taxonomies=$(lookup page_types.$page_type.taxonomies)
# Now let the user enter some values for each relevant taxonomy. Example:
#  - taxonomy is "tags"
#  - create var called 'tags_values'
#  - it contains the tags associated with this page/post/item
#  - in front matter will be "tags: $tags_values"
for taxonomy_name in $relevant_taxonomies
do
  input_label="$(lookup taxonomies.${taxonomy_name}.input_label)"
  [ "$input_label" != "" ] && input_label=" (${input_label})"
  echo -n "$(echo "$taxonomy_name" | titlecase)${input_label}:     "
  read -er values
  # now slugify each taxonomy value given
  OLDIFS=$IFS
  IFS=","
  for value in $values
  do
    fixed_values="$fixed_values $(echo $value | slugify | sed 's/^-//'),"
  done
  IFS=$OLD_IFS
  # strip leading spaces and trailing commas
  fixed_values="$(echo "$fixed_values" | sed -e 's/^ //' -e 's/,$//')"
  # create the var to go into the front matter (example, "tags_values")
  eval '${taxonomy_name}_values="$fixed_values"'
done

# set some defaults, based on page type defaults, falling back to site defaults
default_layout="$(lookup page_types.${page_type}.layout)"
default_layout="${layout:-$site_layout}"
default_stylesheet="$(lookup page_types.${page_type}.stylesheet)"
default_stylesheet="${stylesheet:-$site_stylesheet}"
default_code_stylesheet="$(lookup page_types.${page_type}.code_stylesheet)"
default_code_stylesheet="${code_stylesheet:-$site_code_stylesheet}"
# set some defaults, falling back to site defaults
default_permalink=""
default_email="${email:-$site_email}"
default_twitter="${twitter:-$site_twitter}"
default_language="${language:-$site_language}"
default_js_deps="${js_deps:-$site_js_deps}"

# allow user to override site default if -all given
if [ "$1" = "-all" ] || [ "$2" = "-all" ] || [ "$1" = "-ALL" ] || [ "$2" = "-ALL" ];then
  echo -n "Layout:       "
  read -er -i "$default_layout" layout
  echo -n "Stylesheet:       "
  read -er -i "$default_stylesheet" stylesheet
  echo -n "Code stylesheet:       "
  read -er -i "$default_code_stylesheet" code_stylesheet
  echo -n "Permalink:       "
  read -er -i "$default_{page_type}/$(echo "$title" | slugify)" permalink
  echo -n "Email:        "
  read -er -i "$default_email" email
  echo -n "Twitter:      "
  read -er -i "$default_twitter" twitter
  echo -n "Language:     "
  read -er -i "$default_language" language
  echo -n "JS deps (comma separated package names): "
  read -er -i "$default_js_deps" js_deps
fi

# generate some more meta info
slug=$(echo "$title" | slugify)
date_dir="$(LANG=C LC_ALL=C LC_CTYPE=C date -u +"%Y/%m/%d")/"
[ "$(lookup page_types.${page_type}.date_in_path)" = false ] && date_dir=""
date_created="$(LANG=C LC_ALL=C LC_CTYPE=C date -u +"%Y-%m-%dT%H:%M:%SZ")"
date_modified="$date_created"

# set meta info
meta_data="title:            $title
slug:             $slug
descr:            $description
type:             $page_type
permalink:        $permalink
time_to_read:     $time_to_read
created:          $date_created
$(for taxonomy_name in $relevant_taxonomies
do
 echo "$taxonomy_name:      $(eval 'echo ${taxonomy_name}_values')"
done)
layout:           $layout
stylesheet:       $stylesheet
code_stylesheet:  $code_stylesheet
email:            ${email:-$site_email}
twitter:          ${twitter:-$site_twitter}
language:         ${language:-$site_language}
js_deps:          $(echo ${js_deps:-$site_js_deps} | tr ',' '\n' | tr ' ' '\n' | grep -v ^$ | sed "s/^[ .*]//g" | while read line; do [ ! -z "$line" ] && echo "  ${line//@*/}: ${line}"; done)
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
filename="${page_type_plural}/${date_dir}${slug}"
md_file="${filename}.md"
mdsh_file="${md_file}sh"
# write meta info to mdsh file
mkdir -p ./${page_type_plural}/${date_dir}
echo "$meta_data" > "$mdsh_file"
echo ""          >> "$mdsh_file"
echo "---"       >> "$mdsh_file"
# create a matching valid markdown file
echo -n ""       >> "$md_file"

if [ "$USE_EDITOR" != true ];then

  # final message
  echo "Saved meta data in: ${mdsh_file}"
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
  .app/mdshell.sh ${mdsh_file}

else
  $EDITOR ${mdsh_file}

  # create the HTML page
  html_file="${page_type_plural}/${date_dir}${slug}.html"
  markdown_file="${page_type_plural}/${date_dir}${slug}.md"
  rebuild "${mdsh_file}" > "$html_file"

  echo "Saved as:"
  echo
  echo "HTML page:      $html_file"
  echo "Markdown file:  $markdown_file"
  echo "Source file:    ${mdsh_file}"
  echo

fi

# escape backticks in title
title="${title//\`/\\\`}"


# get taxonomy values as pipe separated list
for taxonomy_name in $relevant_taxonomies
do
  taxonomy_values+="$(eval 'echo ${taxonomy_name}_values')|"
done

# update the main database of posts for the site
echo "$date_dir|${slug}.mdsh|$title|${taxonomy_values}" | sed 's/|$//g' >> ${page_type_plural}.csv
sort -u ${page_type_plural}.csv | uniq >> ${page_type_plural}_sorted.csv
mv ${page_type_plural}_sorted.csv ${page_type_plural}.csv

# pass the source file to update_pages.sh, so it knows to only
# rebuild index pages relevant to that page/post
.app/update_pages.sh ${mdsh_file}

exit 0
