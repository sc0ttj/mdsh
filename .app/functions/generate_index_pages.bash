# this script is sourced by 'create_page.sh'

#
# functions for listing site authors, categories and tags (index pages)
#

function list_categories {
  echo -n '' > /tmp/itemlist
  local classes="categories-list"
  local datetime=''
  local all_items="$(grep -v "^#" posts.csv | cut -f5 -d'|' | tr ',' '\n' | grep -v "^$" |sort -u | uniq)"
  ITEMS=()
  for item in $all_items
  do
    # set the item vars to be printed
    local item_title="'$(.app/slugify.sh "${item}")'"
    local item_url="${blog_url}/categories/${item_title}.html"
    local post_count=$(grep -l "# category: .*$item" posts/*/*/*/*.mdsh 2>/dev/null \
      | sort -u \
      | while read file
      do
        cut -f1,2 -d'|' posts.csv \
        | grep "$(basename "${file}")" \
        | grep -v "^#" \
        | tr '|' '/'
      done \
      | wc -l 2>/dev/null | tr -d ' ' 2>/dev/null)

    local item_after=" &lpar;${post_count}&rpar;"

    # create itemlist tmp file
    echo "${item_url}" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done

  render _list
}

function list_tags {
  echo -n '' > /tmp/itemlist
  local classes="tags-list"
  local all_items="$(grep -v "^#" ./posts.csv | cut -f6 -d'|' | tr ',' ' ' | tr ' ' '\n' | grep -v "^$" | sort -u | uniq)"
  local datetime=''
  ITEMS=()
  for item in $all_items
  do
    # set the item vars to be printed
    local item_title="$(.app/slugify.sh "${item}")"
    local item_url="${blog_url}/tags/${item_title}.html"
    local post_count=$(grep -lRE "# tags:.*$item[, ]?" posts/*/*/*/*.mdsh 2>/dev/null \
      | sort -u \
      | while read file
      do
        cut -f1,2 -d'|' posts.csv \
        | grep "$(basename "${file}")" \
        | grep -v "^#" \
        | tr '|' '/'
      done \
      | wc -l 2>/dev/null | tr -d ' ' 2>/dev/null)

    local item_after=" &lpar;${post_count}&rpar;"

    # create itemlist tmp file
    echo "${item_url}" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done

  render _list
}

function list_authors {
  echo -n '' > /tmp/itemlist
  local classes="authors-list"
  local all_items="$(grep -v "^#" posts.csv | cut -f4 -d'|' | tr ',' '\n' | grep -v "^$" | sort -u | uniq)"
  local datetime=''
  ITEMS=()
  for item in $all_items
  do
    # set the item vars to be printed
    local item_title="$(.app/slugify.sh "${item}")"
    local item_url="${blog_url}/authors/${item_title}.html"
    local post_count=$(grep -lRE "# author:.*$item[,]?" posts/*/*/*/*.mdsh |sort -u| while read file
    do
      cut -f1,2 -d'|' posts.csv | grep "$(basename "${file}")" | grep -v "^#" | tr '|' '/'
    done | wc -l 2>/dev/null)
    local item_after=" &lpar;${post_count}&rpar;"

    # create itemlist tmp file
    echo "${item_url}" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done

  render _list
}

