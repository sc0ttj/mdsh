# this script is sourced by 'create_page.sh'

#
# functions for listing posts in various ways
#

function list_posts_in_dir {
  [ -z "$1" ] && return 1
  echo -n '' > /tmp/itemlist
  local posts_dir="$1"
  local classes="posts"
  local all_items="$(grep "^$posts_dir/" posts.csv | grep -v "^#" | cut -f1,2 -d'|' | tr '|' '/' | sort -r)"
  local datetime=''
  ITEMS=()
  for item in $all_items
  do
    # skip post if it's commented out in posts.csv
    [ "$(grep "${item}|" posts.csv | grep "^#" )" ] && continue
    local item_url="${blog_url}/posts/${item//.mdsh/.html}"
    local item_title="'$(grep -m1 "|$(basename $item)|" posts.csv | grep -v "^#" | cut -f3 -d'|')'"
    # update itemlist tmp file
    echo "${item_url}" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done

  render _list
}

function list_recent_posts {
  echo -n '' > /tmp/itemlist
  local limit="$1"
  local classes="recent-posts posts"
  local all_items="$(cut -f1,2 -d'|' ./posts.csv | sort -r | head -${limit:-18} | tr '|' '/' | grep -v "^#")"
  ITEMS=()
  for item in $all_items
  do
    # skip post if it's commented out in posts.csv
    [ "$(grep "${item}|" posts.csv | grep "^#" )" ] && continue
    local item_url="${blog_url}/posts/${item//.mdsh/.html}"
    local item_title="'$(grep -m1 "|$(basename $item)|" posts.csv | grep -v "^#" | cut -f3 -d'|')'"
    # update itemlist tmp file
    echo "${item_url}" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done

  render _list
}

function list_posts_by_author {
  [ -z "$1" ] && return 1
  echo -n '' > /tmp/itemlist
  local author="$1"
  local classes="posts-by-author posts"
  local datetime=''
  local all_items="$(grep -lRE "#? ?author.*$author[, ]?" posts/*/*/*/*.mdsh | sort -u | sort -r | uniq)"
  ITEMS=()
  for item in $all_items
  do
    # skip post if it's commented out in posts.csv
    [ "$(grep "${item}|" posts.csv | grep "^#" )" ] && continue
    local item_url="${blog_url}/${item//.mdsh/.html}"
    local item_title="'$(grep -m1 "|$(basename $item)|" posts.csv | grep -v "^#" | cut -f3 -d'|')'"
    # update itemlist tmp file
    echo "${item_url}" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done

  render _list
}

function list_posts_matching_tag {
  [ -z "$1" ] && return 1
  echo -n '' > /tmp/itemlist
  local tag="$1"
  local classes="posts-matching-tag posts"
  local datetime=''
  local all_items="$(grep -lRE "#? ?tags.*$tag[, ]?" posts/*/*/*/*.mdsh | sort -u | sort -r | uniq)"
  local OLDIFS=$IFS
  IFS="
"
  ITEMS=()
  for item in $all_items
  do
    local item_url="${blog_url}/${item//.mdsh/.html}"
    local item_title="'$(grep -m1 "|$(basename $item)|" posts.csv | grep -v "^#" | cut -f3 -d'|')'"
    # update itemlist tmp file
    echo "${item_url}" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done
  IFS=$OLDIFS

  render _list
}

function list_posts_in_category {
  [ -z "$1" ] && return 1
  echo -n '' > /tmp/itemlist
  local category="$1"
  local classes="posts-in-category posts"
  local datetime=''
  local all_items="$(grep "|$category|" ./posts.csv | cut -f1,3 -d'|' | grep -v "^#" | sort -u | sort -r | uniq | cut -f2 -d'|')"
  local OLDIFS=$IFS
  IFS="
"
  ITEMS=()
  for item in $all_items
  do
    local item_created="$(grep -m1 "|$item|" ./posts.csv | cut -f1 -d'|')"
    local item_slug="$(grep -m1 "|$item|" ./posts.csv | cut -f2 -d'|')"
    local item_url="${blog_url}/posts/$item_created/${item_slug//.mdsh/}.html"
    local item_title="'$(grep -m1 "|$item|" ./posts.csv | cut -f3 -d'|')'"
    # update itemlist tmp file
    echo "$item_url" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done
  IFS=$OLDIFS

  render _list
}

function list_search_results {
  echo -n '' > /tmp/itemlist
  local all_posts="$(cut -f1,2 -d'|' posts.csv | grep -v "^#" | tr '|' '/' | sort -r)"
  ITEMS=()
  for post in $all_posts
  do
    local item_title="'$(grep -E "^#? ?title" "posts/$post" | cut -f2-99 -d':'| sed 's/^ *//')'"
    local item_descr="\"$(grep -E "^#? ?descr" "posts/$post" | cut -f2-99 -d':'| sed 's/^ *//')\""
    local item_url="${blog_url}/posts/${post//.mdsh/.html}"
    local item_tags="'$(grep  -E "^#? ?tags"  "posts/$post" | cut -f2-99 -d':'| sed -e 's/^ *//' -e 's/,/, /g')'"
    # update itemlist tmp file
    echo "${item_url}" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done
  render _search_results
}
