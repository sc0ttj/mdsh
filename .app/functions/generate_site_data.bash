# build site data:

# functions for listing posts in various ways, used by `update_pages.sh` to
# generate index pages with up-to-date lists

#
# TODO:
#
#   - remove _list template, replace with _archive, _categories, etc
#   - reduce functions below that dont take $1 to inline code that
#       - produce an array for each index page
#       - dont render here
#       - render in `update_pages.sh`
#

function list_posts_in_dir {
  [ -z "$1" ] && return 1
  local posts_dir="$1"
  local all_items="$(grep "^$posts_dir/" posts.csv | grep -v "^#" | cut -f1,2 -d'|' | tr '|' '/' | sort -r)"
  local item_list=''
  classes="posts"
  has_date=''
  ITEMS=()
  for item in $all_items
  do
    # skip post if it's commented out in posts.csv
    [ "$(grep "${item}|" posts.csv | grep "^#" )" ] && continue
    item_title="'$(grep -m1 "|$(basename $item)|" posts.csv | grep -v "^#" | cut -f3 -d'|')'"
    [ -z "$item_title" ] && continue
    item_url="${site_url}/posts/${item//.mdsh/.html}"
    item_created=''
    add_item_to 'ITEMS'
    item_list="${item_list}\n${item_url}"
  done
  # update itemlist tmp file
  echo -e "$item_list" > /tmp/itemlist

  render _list
}


function get_posts_by_author {
  [ -z "$1" ] && return 1
  local author="$1"
  local all_items="$(grep -lRE "#? ?author.*$author[, ]?" posts/*/*/*/*.mdsh | sort -u | sort -r)"
  local item_list=''
  classes="posts-by-author posts"
  has_date=true
  ITEMS=()
  for item in $all_items
  do
    # skip post if it's commented out in posts.csv
    [ "$(grep "${item}|" posts.csv | grep "^#" )" ] && continue
    item_title="'$(grep -m1 "|$(basename $item)|" posts.csv | grep -v "^#" | cut -f3 -d'|')'"
    [ -z "$item_title" ] && continue
    item_url="${site_url}/${item//.mdsh/.html}"
    item_created="$(get_page_creation_date $item)"
    add_item_to 'ITEMS'
    item_list="${item_list}\n${item_url}"
  done
  # update itemlist tmp file
  echo -e "$item_list" > /tmp/itemlist
}

function get_posts_in_category {
  [ -z "$1" ] && return 1
  local category="$1"
  local all_items="$(grep "|$category|" ./posts.csv | cut -f1-3 -d'|' | grep -v "^#" | sort -u | sort -r)"
  local item_list=''
  classes="posts-in-category posts"
  has_date=true
  ITEMS=()
  local OLDIFS=$IFS
  IFS="
"
  for item in $all_items
  do
    item_date="$(echo "$item" | cut -f1 -d'|')"
    [ -z "$item_date" ] && continue
    item_slug="$(echo "$item" | cut -f2 -d'|')"
    item_title="'$(echo "$item" | cut -f3 -d'|')'"
    item_url="${site_url}/posts/$item_date/${item_slug//.mdsh/}.html"
    item_created="$(get_page_creation_date posts/$item_date/${item_slug})"
    add_item_to 'ITEMS'
    item_list="${item_list}\n${item_url}"
  done
  IFS=$OLD_IFS
  # update itemlist tmp file
  echo -e "$item_list" > /tmp/itemlist
}

function get_posts_matching_tag {
  [ -z "$1" ] && return 1
  local tag="$1"
  local all_items="$(grep -lRE "#? ?tags.*$tag[, ]?" posts/*/*/*/*.mdsh | sort -u | sort -r | uniq)"
  local item_list=''
  classes="posts-matching-tag posts"
  has_date=true
  ITEMS=()
  local OLDIFS=$IFS
  IFS="
"
  for item in $all_items
  do
    item_entry="$(grep -m1 "|$(basename $item)|" posts.csv | grep -v "^#")"
    [ -z "$item_entry" ] && continue
    item_title="'$(echo "$item_entry" | cut -f3 -d'|')'"
    item_slug="'$(echo "$item_entry" | cut -f2 -d'|')'"
    item_date="$(echo "$item_entry" | cut -f1 -d'|')"
    item_url="${site_url}/posts/${item_date}/${item_slug//.mdsh/.html}"
    item_created="$(get_page_creation_date $item)"
    add_item_to 'ITEMS'
    item_list="${item_list}\n${item_url}"
  done
  IFS=$OLD_IFS
  # update itemlist tmp file
  echo -e "$item_list" > /tmp/itemlist
}


#
# parse the data folder:
#

for sh_file in assets/data/*.sh
do
  [ ! -z "$sh_file" ] && [ -f "$sh_file" ] && source "$sh_file"
done

for yaml_file in assets/data/*.yml
do
  [ ! -z "$yaml_file" ] && [ -f "$yaml_file" ] && echo "$(yay "$yaml_file")" >> /tmp/all_site_yml_data
done
eval "$(\cat /tmp/all_site_yml_data)"
rm /tmp/all_site_yml_data

# parse CSV files (they must contain headers!)
for csv_file in assets/data/*.csv
do
  [ ! -f "$csv_file" ] && continue
  arrayName="$(basename "$csv_file" .csv)"
  csv_data="$(cat "$csv_file" | csv_to_data $arrayName)"
  eval "$csv_data"
done

#
# generate up-to-date data objects of:
#
#  - site authors
#  - site categories
#  - site tags
#

rm /tmp/authors_itemlist &>/dev/null
unset site_authors
declare -ag site_authors
for author in $(grep -v "^#" posts.csv | cut -f4 -d'|' | tr ' ' ',' | tr ',' '\n'| grep -v "^$" | sort -u)
do
  [ -z "$author" ] && continue
  post_count=$(grep -lE "^#? ?author: .*$author" posts/*/*/*/*.mdsh 2>/dev/null \
    | sort -u \
    | while read file
    do
      cut -f1,2 -d'|' posts.csv \
      | grep "$(basename "${file}")" \
      | grep -v "^#" \
      | tr '|' '/'
    done \
    | wc -l 2>/dev/null | tr -d ' ' 2>/dev/null)

  # set the item vars to be printed
  item_title="${author}"
  item_slug="$(echo "${author}" | slugify)"
  item_url="${site_url}/authors/${item_slug}.html"
  item_post_count="$post_count"
  add_item_to 'site_authors'
  # update itemlist tmp file
  echo "${item_url}" >> /tmp/authors_itemlist
done

rm /tmp/categories_itemlist &>/dev/null
unset site_categories
declare -ag site_categories
for category in $(grep -v "^#" ./posts.csv | cut -f5 -d'|' | tr ' ' ',' | tr ',' '\n'| sort -u)
do
  [ -z "$category" ] && continue
  post_count=$(grep -lE "^#? ?category: .*$category" posts/*/*/*/*.mdsh 2>/dev/null \
    | sort -u \
    | while read file
    do
      cut -f1,2 -d'|' posts.csv \
      | grep "$(basename "${file}")" \
      | grep -v "^#" \
      | tr '|' '/'
    done \
    | wc -l 2>/dev/null | tr -d ' ' 2>/dev/null)

  # set the item vars to be printed
  item_title="${category}"
  item_slug="$(echo "${category}" | slugify)"
  item_url="${site_url}/categories/${item_slug}.html"
  item_post_count="$post_count"
  add_item_to 'site_categories'
  # update itemlist tmp file
  echo "${item_url}" >> /tmp/categories_itemlist
done

rm /tmp/tags_itemlist &>/dev/null
unset site_tags
declare -ag site_tags
for tag in $(grep -v "^#" ./posts.csv | cut -f6 -d'|' | tr ' ' ',' | tr ',' '\n'| sort -u)
do
  [ -z "$tag" ] && continue
  post_count=$(grep -lRE "^#? ?tags:.*$tag[, ]?" posts/*/*/*/*.mdsh 2>/dev/null \
    | sort -u \
    | while read file
    do
      cut -f1,2 -d'|' posts.csv \
      | grep "$(basename "${file}")" \
      | grep -v "^#" \
      | tr '|' '/'
    done \
    | wc -l 2>/dev/null | tr -d ' ' 2>/dev/null)

  # set the item vars to be printed
  item_title="${tag}"
  item_slug="$(echo "${tag}" | slugify)"
  item_url="${site_url}/tags/${item_slug}.html"
  item_post_count="$post_count"
  add_item_to 'site_tags'
  # update itemlist tmp file
  echo "${item_url}" >> /tmp/tags_itemlist
done

rm /tmp/archive_itemlist &>/dev/null
unset item_list
unset site_posts
declare -ag site_posts
for post in $(grep -v "^#" posts.csv | cut -f1,2 -d'|' | sort -u | sort -r | grep -v "^$")
do
  # skip post if it's commented out in posts.csv
  [ "$(grep -m1 "${post}|" posts.csv | grep "^#" )" ] && continue

  item_after=''
  item_slug="${post//*|/}"
  item_slug="${item_slug//.mdsh/}"
  item_entry="$(grep -m1 "|${item_slug}.mdsh|" posts.csv)"
  item_title="'$(echo "$item_entry" | grep -m1 "|${item_slug}.mdsh|" | cut -f3 -d'|')'"
  [ -z "$item_title" ] && continue
  item_date="${post//|*/}"
  item_tags="$(echo "$item_entry" | grep -m1 "|${item_slug}.mdsh|" | cut -f6 -d'|' | tr ',' ' ')"
  item_url="${site_url}/posts/${item_date}/${item_slug}.html"
  item_created="$(get_page_creation_date posts/${post//|//})"
  item_descr="\"$(get_page_descr posts/${post//|//})\""

  # update itemlist tmp file
  item_list="${item_list}\n${item_url}"

  add_item_to 'site_posts'
done

echo -e "${item_list}" | grep -v "^$" > /tmp/archive_itemlist

# add the generated site data to the 'site' array
# generated from assets/data/site.yml
site+=(site_authors site_categories site_tags site_posts)

return 0
