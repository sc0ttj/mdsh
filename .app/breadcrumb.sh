#!/bin/bash

[ ! "$1" ] || [ -z "$1" ] && exit 1

source .site_config
source .app/functions/mo # mustache lib

# get URL of page - we will generate the breadcrumb from the URL
url="$1"

# set vars used in loop below
crumb=''
year=''
month=''
i=1;

# for each item in URL, build ListItem
item_count=$(echo "$url" | tr '/' '\n' | wc -l)

for item in $(echo "$url" | tr '/' '\n')
do
  text="$item"
  # build proper date strings, for nice titles
  case "$item" in
    # year
    [0-9][0-9][0-9][0-9])
      year=$item; text="$item"
    ;;
    # month and day
    [0-1][0-9])
      month=$item
      new_date="$(date -d $year-$month-01 '+%B' 2>/dev/null)"
      text="$new_date"
    ;;
  esac

  # build the path
  crumb="${crumb}/${item}"
  name="${text//.html/}"
  name="${name//-/ }"
  name="${name//_/ }"

  # title case the the name
  string="$name"
  first_char="$(echo "$string"  | cut -c1 |tr [:lower:] [:upper:])"
  rest_of_sentence="$(echo "$string" | cut -c2-)"
  title_case_name="$first_char$rest_of_sentence"

  # set some nice title names
  [ "$title_case_name" = "Archive" ] && title_case_name="Archives"
  [ "$prev_name" = "Authors" ] && title_case_name="$name"
  [ "$prev_name" = "Categories" ] && title_case_name="$name"
  [ "$prev_name" = "Tags" ] && title_case_name="$name"

  prev_name="$title_case_name"

  # set the items for the hash
  item_position="${i}"
  item_url="${blog_domain}${crumb}"
  item_name="${title_case_name}"

  # create the hash for the current page in the loop
  declare -A "hash${i}"

  # add key/value pairs to the hash
  eval "$(echo "hash${i}"+=\( [position]="$item_position" \))"
  eval "$(echo "hash${i}"+=\( [name]="\"$item_name\"" \))" #"
  eval "$(echo "hash${i}"+=\( [url]="$item_url" \))"

  # add the hash to ITEMS array
  ITEMS+=("hash${i}")

  i=$(($i + 1))
done

AUTO_APPEND=','
cat .app/templates/json-ld/_ld_breadcrumb.mustache | mo
AUTO_APPEND=''
