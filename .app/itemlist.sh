#!/bin/bash

[ ! "$1" ] || [ -z "$1" ] && exit 1

source .site_config
source .app/functions/mo # mustache lib

# get the list of items (URLs)
list_items="$1"

# set vars used in loop below
i=1;

# for each item in URL, build ListItem
for item in $list_items
do
  # create the hash for the current page in the loop
  declare -A "hash${i}"

  item_url="${item//.mdsh/.html}"

  # add key/value pairs to the hash
  eval "$(echo "hash${i}"+=\( [position]="$i" \))"
  eval "$(echo "hash${i}"+=\( [url]="${item_url}" \))"

  # add the hash to ITEMS array
  ITEMS+=("hash${i}")

  i=$(($i + 1))
done

AUTO_APPEND=','
cat .app/templates/json-ld/_ld_itemlist.mustache | mo
AUTO_APPEND=''
