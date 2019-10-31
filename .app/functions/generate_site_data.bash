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

function get_post_count {
  grep -lRE "^#? ?$1:.*$2[, ]?" posts/*/*/*/*.mdsh 2>/dev/null \
    | sort -u \
    | while read file
    do
      cut -f1,2 -d'|' posts.csv \
      | grep "$(basename "${file}")" \
      | grep -v "^#"
    done \
    | wc -l 2>/dev/null | tr -d ' ' 2>/dev/null
}

function get_taxonomies {
  for x in ${taxonomies[@]}
  do
    echo "${x//taxonomies_/}"
  done
}

function get_taxonomy_name   { get_taxonomies | while read line; do echo -n "$line|"; lookup taxonomies.$line.plural; done | grep -E "^$1|\|$1" | cut -f1 -d'|'; }
function get_taxonomy_plural { get_taxonomies | while read line; do echo -n "$line|"; lookup taxonomies.$line.plural; done | grep -E "^$1|\|$1" | cut -f2 -d'|'; }

function get_pages_in_taxonomy {
  [ -z "$1" ] && return 1
  [ -z "$2" ] && return 1
  local taxonomy_name="${1//taxonomies_}"
  local taxonomy_value="$2"
  local item_list=''
  local all_items="$(grep -lRE "#? ?${taxonomy_name}.*${taxonomy_value}[, ]?" posts/*/*/*/*.mdsh | sort -u | sort -r | uniq)"
  [ -z "$all_items" ] && all_items="$(grep -lRE "#? ?${taxonomy_plural}.*${taxonomy_value}[, ]?" posts/*/*/*/*.mdsh | sort -u | sort -r | uniq)"
  [ -z "$all_items" ] && return 1

  classes="posts posts-${taxonomy_name}-${taxonomy_value}"
  has_date=$(lookup "taxonomies.${taxonomy_name}.show_date")
  ITEMS=()
  for item in $all_items
  do
    # skip post if it's commented out in posts.csv
    local filename="$(basename "${item}")"
    [ "$(grep "^#" posts.csv | grep -m1 "|$filename|")" != "" ] && continue
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

#
# parse the data folder:
#
for sh_file in assets/data/*.sh
do
  [ ! -z "$sh_file" ] && [ -f "$sh_file" ] && source "$sh_file"
  if [ "$DEBUG_DATA" = true ];then
    echo >&2
    \cat "$sh_file" >&2
    echo >&2
  fi
done

for yaml_file in assets/data/*.yml
do
  [ ! -z "$yaml_file" ] && [ -f "$yaml_file" ] && echo "$(TOP_LEVEL_AS_ASSOC_ARRAY=false yay "$yaml_file")" > /tmp/all_site_yml_data
  eval "$(\cat /tmp/all_site_yml_data)"
  if [ "$DEBUG_DATA" = true ];then
    echo >&2
    \cat  /tmp/all_site_yml_data >&2
    echo >&2
  fi
done
rm /tmp/all_site_yml_data

# parse CSV files (they must contain headers!)
for csv_file in assets/data/*.csv
do
  [ ! -f "$csv_file" ] && continue
  arrayName="$(basename "$csv_file" .csv)"
  csv_data="$(cat "$csv_file" | csv_to_data $arrayName)"
  eval "$csv_data"
  if [ "$DEBUG_DATA" = true ];then
    echo >&2
    echo "$csv_data" >&2
    echo >&2
  fi
done

# declare and populate site_posts
rm /tmp/archive_itemlist &>/dev/null
unset item_list
unset site_posts
declare -ag site_posts
for post in $(grep -v "^#" posts.csv | cut -f1,2 -d'|' | sort -u | sort -r | grep -v "^$")
do
  # skip post if it's commented out in posts.csv
  [ "$(grep -m1 "${post}|" posts.csv | grep "^#" )" ] && continue

  item_before=''
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
site+=(site_posts)

taxonomies_list="${taxonomies[@]}"
[ -z "${taxonomies_list[@]}" ] && return 1

for taxonomy in ${taxonomies_list[@]}
do
  # get vars
  item_list=''
  taxonomy="${taxonomy//taxonomies_}"
  taxonomy_plural="$(lookup "taxonomies.${taxonomy}.plural")"
  [ "$taxonomy_plural" = '' ] && continue
  all_items="$(grep -hRE "^#? ?${taxonomy}:.*[, ]" posts/*/*/*/*.mdsh|sed 's/ .*  //g'|cut -f2 -d':' | tr ',' '\n' | lstrip | sort -u)"
  [ "$all_items" = '' ] && continue
  array_name="site_$taxonomy_plural"

  unset $(eval 'echo $array_name')
  declare -ag $(eval 'echo $array_name')

  # add to $site_* arrays (like $site_tags, $site_categories, etc)
  OLD_IFS=$IFS
  IFS=$'\n'
  for item in $all_items
  do
    post_count="$(get_post_count $taxonomy $item)"
    [ "$post_count" = ''  ] && continue
    [ "$post_count" = '0' ] && continue
    # set the item vars to be printed
    item_title="'${item}'"
    item_slug="$(echo "${item}" | slugify)"
    item_url="${site_url}/$taxonomy_plural/${item_slug}.html"
    item_post_count="$post_count"
    add_item_to "$array_name"
    # update itemlist tmp file
    item_list="${item_list}\n${item_url}"
  done
  IFS=$OLD_IFS
  export $(eval 'echo $array_name')
  site+=($array_name)
  # update itemlist tmp file
  echo -e "$item_list" > /tmp/itemlist
done
