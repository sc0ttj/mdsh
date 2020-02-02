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
if [ "$(lookup page_types.${page_type_name}.date_in_path)" = true ];then
  grep -lRE "^#? ?$1:.*$2[, ]?" posts/*/*/*/*.mdsh 2>/dev/null \
    | sort -u \
    | while read file
    do
      cut -f1,2 -d'|' posts.csv \
      | grep "$(basename "${file}")" \
      | grep -v "^#"
    done \
    | wc -l 2>/dev/null | tr -d ' ' 2>/dev/null
else
  grep -lRE "^#? ?$1:.*$2[, ]?" posts/*.mdsh 2>/dev/null \
    | sort -u \
    | while read file
    do
      cut -f1,2 -d'|' posts.csv \
      | grep "$(basename "${file}")" \
      | grep -v "^#"
    done \
    | wc -l 2>/dev/null | tr -d ' ' 2>/dev/null
fi
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
  [ -z "$3" ] && return 1
  local page_type_plural="${1//page_types_}"
  local page_type_singular="$(get_page_type_name ${page_type_plural})"
  local taxonomy_name="$(get_taxonomy_name ${2//taxonomies_})"
  local taxonomy_plural="$(get_taxonomy_plural $taxonomy_name)"
  local taxonomy_value="$3"
  local item_list=''
  local all_items=''

  if [ "$(lookup page_types.${page_type_singular}.date_in_path)" = true ];then
    all_items="$(grep -lRE "#? ?${taxonomy_name}:.*${taxonomy_value}[, ]?" ${page_type_plural}/*/*/*/*.mdsh)"
    [ -z "$all_items" ] && all_items="$(grep -lRE "#? ?${taxonomy_plural}:.*${taxonomy_value}[, ]?" ${page_type_plural}/*/*/*/*.mdsh)"
  else
    all_items="$(grep -lRE "#? ?${taxonomy_name}:.*${taxonomy_value}[, ]?" ${page_type_plural}/*.mdsh)"
    [ -z "$all_items" ] && all_items="$(grep -lRE "#? ?${taxonomy_plural}:.*${taxonomy_value}[, ]?" ${page_type_plural}/*.mdsh)"
  fi

  [ -z "$all_items" ] && return 1

  all_items="$(echo "$all_items" | sort -u | sort -r | uniq)"
  classes="${page_type_plural} ${page_type_plural}-${taxonomy_name}-${taxonomy_value}"
  has_date=$(lookup "taxonomies.${taxonomy_name}.show_date")
  ITEMS=()
  for item in $all_items
  do
    # skip post if it's commented out in posts.csv
    local filename="$(basename "${item}")"
    [ "$(grep "^#" ${page_type_plural}.csv | grep -m1 "|$filename|")" != "" ] && continue
    item_title="'$(grep -m1 "|$(basename $item)|" ${page_type_plural}.csv | grep -v "^#" | cut -f3 -d'|')'"
    [ -z "$item_title" ] && continue
    item_url="${site_url}/${item//.mdsh/.html}"
    item_created="$(get_page_creation_date $item)"
    post_count=''
    item_post_count=''
    item_after=''
    add_item_to 'ITEMS'
    item_list="${item_list}\n${item_url}"
  done
  # update itemlist tmp file
  echo -e "$item_list" > /tmp/${page_type_singular}_${taxonomy_name}_${taxonomy_value}_itemlist
}


#
# page types
#
function get_page_types {
  for x in ${page_types[@]}
  do
    echo "${x//page_types_/}"
  done
}

function get_page_type_name   { get_page_types | while read line; do echo -n "$line|"; lookup page_types.$line.plural; done | grep -E "^$1|\|$1" | cut -f1 -d'|'; }
function get_page_type_plural { get_page_types | while read line; do echo -n "$line|"; lookup page_types.$line.plural; done | grep -E "^$1|\|$1" | cut -f2 -d'|'; }

function page_type_is_valid {
  local page_types="$(lookup page_types.* | sed 's/page_types_//g')"
  local valid_type=false
  for type in $page_types
  do
    [ "$1" = "$type" ] && valid_type=true
  done
  echo $valid_type
}

################################################################################

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

# for each page type
for page_type in $(lookup page_types.* | sed 's/page_types_//g')
do
  page_type_name="$(lookup page_types.${page_type}.name)"
  page_type_plural="$(lookup page_types.${page_type}.plural)"
  [ ! -d "${page_type_plural}/" ] && continue
  [ ! -f "${page_type_plural}.csv" ] && continue

  # build an array for each page type, containing the list of pages of that type
  eval '
  # declare the array to populate: site_posts, site_events, etc
  unset site_$page_type_plural
  declare -ag site_$page_type_plural

  # for each page listed of the current type in its relevant csv file
  for page in $(grep -v "^#" ${page_type_plural}.csv | cut -f1,2 -d"|" | sort -u | sort -r | grep -v "^$")
  do
    # skip page if its commented out in ${page_type_plural}.csv
    [ "$(grep -m1 "${page}|" ${page_type_plural}.csv | grep "^#" )" ] && continue

    # build array of page details, which will be listed by name in site_$page_type_plural
    post_count=""
    item_post_count=""
    item_before=""
    item_after=""
    item_type="$page_type"
    item_slug="${page//*|/}"
    item_slug="${item_slug//.mdsh/}"
    item_entry="$(grep -m1 "|${item_slug}.mdsh|" ${page_type_plural}.csv)"
    item_title="\"$(echo "$item_entry" | grep -m1 "|${item_slug}.mdsh|" | cut -f3 -d"|")\""
    [ -z "$item_title" ] && continue
    item_date="${page//|*/}"
    item_tags="$(echo "$item_entry" | grep -m1 "|${item_slug}.mdsh|" | cut -f6 -d"|" | tr "," " ")"
    item_url="${site_url}/${page_type_plural}/${item_date}/${item_slug}.html"
    item_created="$(get_page_creation_date ${page_type_plural}/${page//|//})"
    item_descr="\"$(get_page_descr ${page_type_plural}/${page//|//})\""

    # add the page to the site_$page_type_plural  array
    add_item_to "site_${page_type_plural}"

    # update itemlist tmp file
    item_list="${item_list}\n${item_url}"
  done
  echo -e "${item_list}" | grep -v "^$" > /tmp/${page_type}_itemlist
  # finally, add the generated site data to the "site" array
  # generated from assets/data/site.yml
  site+=(site_$page_type_plural)


  #
  # generate the taxonomies data associated with this $page_type
  #
  taxonomies_list="$(lookup page_types.${page_type_name}.taxonomies)"
  [ -z "${taxonomies_list[@]}" ] && continue

  # for each taxonomy associated with $page_type
  for taxonomy in ${taxonomies_list[@]}
  do
    # get proper taxonomy name, values
    item_list=""
    taxonomy="${taxonomy//taxonomies_/}"
    taxonomy="${taxonomy//,/}"
    taxonomy_name="${taxonomy}"
    taxonomy_plural="$(get_taxonomy_plural ${taxonomy})"
    [ "$taxonomy_name" = "" ] && continue
    [ "$taxonomy_plural" = "" ] && continue

    # get all items (pages) in this taxonomy
    if [ "$(lookup page_types.${page_type_name}.date_in_path)" = true ];then
      all_items="$(grep -hRE "^#? ?${taxonomy_plural}:.*[, ]" ${page_type_plural}/*/*/*/*.mdsh 2>/dev/null)"
      [ "$all_items" = "" ] && all_items="$(grep -hRE "^#? ?${taxonomy_name}:.*[, ]" ${page_type_plural}/*/*/*/*.mdsh 2>/dev/null)"
    else
      all_items="$(grep -hRE "^#? ?${taxonomy_plural}:.*[, ]" ${page_type_plural}/*.mdsh 2>/dev/null)"
      [ "$all_items" = "" ] && all_items="$(grep -hRE "^#? ?${taxonomy_name}:.*[, ]" ${page_type_plural}/*.mdsh 2>/dev/null)"
    fi

    [ "$all_items" = "" ] && continue

    all_items="$(echo "$all_items" | sed "s/ .*  //g" | cut -f2 -d":" | tr "," "\n" | grep -v ^$ | lstrip | sort -u)"

    # set the array (example, "events_categories")
    array_name="${page_type_plural}_$taxonomy_plural"
    unset $(eval "echo $array_name")
    declare -ag $(eval "echo $array_name")

    # add each item in this taxonomy to $array_name
    OLD_IFS=$IFS
    IFS="
"
    for item in $all_items
    do
      if [ "$page_type" = "$post" ];then
        # if no posts in this taxonomy item (no posts in category "foo", or tagged "bar")
        # then skip it
        post_count="$(get_post_count $taxonomy_name $item)"
        [ "$post_count" = ""  ] && continue
        [ "$post_count" = "0" ] && continue
      else
        post_count=""
      fi
      # else, set the assoc array containing details of the item
      item_type="${taxonomy_name}"
      item_title="\"${item}\""
      item_slug="$(echo "${item}" | slugify)"
      item_url="${site_url}/${page_type_plural}/$taxonomy_plural/${item_slug}.html"
      item_post_count="$post_count"
      [ ! -z "$post_count" ] && item_after="($post_count)" || item_after=""
      # now add item to $array_name (example, add page to events_categories)
      add_item_to "$array_name"
      # update itemlist tmp file
      item_list="${item_list}\n${item_url}"
    done
    IFS="$OLD_IFS"
    # export the array and add to site array
    export $(eval "echo $array_name")
    site+=($array_name)
    # update itemlist tmp file
    echo -e "$item_list" > /tmp/${page_type}_${taxonomy_name}_itemlist
  done'
done

# usage: get_taxonomies_of_page_type  $type
function get_taxonomies_of_page_type {
  [ -z "$1" ] && return 1
  lookup page_types.${1}.taxonomies \
    | tr ',' ' ' \
    | tr ' ' '\n' \
    | grep -v ^$
}

function set_default_index_pages {
  local page_type=${site_default_page_type:-posts}
  local page_type_plural=$(get_page_type_plural $page_type)
  # Based on the default page type for this site ($site_default_page_type),
  # get the sites default taxonomies.
  local default_taxonomies="$(get_taxonomies_of_page_type $page_type)"

  # For each taxonomy dir, symlink it to the site root
  #
  # Example:
  #
  #  symlink  posts/authors/    -> authors/
  #  symlink  posts/categories/ -> categories/
  #  symlink  posts/tags/    -   > tags/

  for taxonomy in ${default_taxonomies}
  do
    [ -z "${taxonomy}" ] && continue
    local taxonomy_plural="$(get_taxonomy_plural "$taxonomy" | slugify)"
    [ ! -d "${page_type_plural}/${taxonomy_plural}/" ] && continue
    rm -rf ${taxonomy_plural}/ 2>/dev/null
    ln -s ${page_type_plural}/${taxonomy_plural} ${taxonomy_plural}/
  done
}

