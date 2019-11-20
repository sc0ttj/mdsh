# this script is sourced by 'create_page.sh'

#
# functions
#

# the general purpose of these functions is to create and make available
# as '$page_foo' variables all of the page data for the page being built,
# so that they can be used by the templates in .app/templates/

function get_page_data {
  get_page_data_from_yml_frontmatter "$1"

  # now clean up and set any missing values to fall back to site defaults
  page_type="${page_type:-post}"
  page_title="${page_title:-$site_title}"
  page_slug="${page_slug:-$(echo "$page_title" | slugify)}"
  page_fonts="${page_fonts:-$site_fonts}"
  page_author="${page_author:-$site_author}"
  page_category="${page_category:-$site_category}"
  page_keywords="${page_keywords:-$site_keywords}"
  page_stylesheet="${page_stylesheet:-$site_stylesheet}"
  page_code_stylesheet="${page_code_stylesheet:-$site_code_stylesheet}"
  page_lang="${site_language:-en}"
  page_descr="${page_descr:-$site_descr}"

  # try to get the creation date if we didn't get it already, as will happen
  # when running `rebuild posts/*/*/*/some-post.mdsh > some-file.html`
  if [ "$page_created" = "" ];then
    page_created="$(get_page_creation_date "$1")"
  fi

  page_modified="${page_modified:-$current_date}"
  page_time_to_read="${page_time_to_read:-$site_time_to_read}"
  page_keywords="${page_tags:-$site_keywords}"
  unset page_tags
  for tag in ${page_keywords//,/ }
  do
    [ ! -z "$tag" ] && page_tags+=("$tag")
  done
  page_author="${page_author:-$site_author}"
  page_author_slug="$(echo "${page_author}" | slugify)"
  page_twitter="${page_twitter:-$site_twitter}"
  # for each JS dep from unpkg, (also inc post specific deps, if any)
  unset page_js_deps
  for pkgname in ${page_js_deps//, /}
  do
    [ ! -z "$pkgname" ] && page_js_deps+=("$pkgname")
  done
  page_google_analytics_id="${page_google_analytics_id:-$site_google_analytics_id}"
  page_url="${page_url:-$site_url}"

  # set whether or not the page being generated is a blog post (or custom page)
  case "$page_url" in
  */posts/*/*/*) is_blog_post=true ;;
  *)  is_blog_post='' ;;
  esac
}

# Usage:  get_page_data_from_frontmatter path/to/post.mdsh
#
#         Used by other functions to set the post info used in various
#         bits of generated HTML.

function get_page_data_from_yml_frontmatter {
  [ ! -f "$1" ] && return

  local frontmatter
  # get the meta info from the .mdsh file
  if [ -f "${1//.mdsh/}.mdsh" ];then
    frontmatter="$(cat "${1//.mdsh/}.mdsh" 2>/dev/null)"
  elif [ -f "${1//.md/}.mdsh" ];then
    frontmatter="$(cat "${1//.md/}.mdsh" 2>/dev/null)"
  else
    return 1
  fi

  frontmatter="${frontmatter//---*/}"
  # if we have no data, exit
  [ "${frontmatter}" = "" ] && return 1

  # We will use 'yay' to process a tmp yaml file, get its contents,
  # then parse it, and return the bash vars and arrays we want.
  echo "${frontmatter}" > /tmp/page
  # NOTE:
  #
  # We set TOP_LEVEL_AS_ASSOC_ARRAY=true, so that yay creates a single
  # assoc array (named after the file being processed) containing all
  # top-level items as keys, instead of creating separate assoc arrays
  # of EACH top-level item (with file name as prefix)
  TOP_LEVEL_AS_ASSOC_ARRAY=false yay /tmp/page 2>/dev/null > /tmp/page_data

  if [ "$DEBUG_DATA" = true ];then
    echo >&2
    cat /tmp/page_data >&2
    echo >&2
  fi

  # IMPORTANT: bring the page data into the current environment
  eval "$(cat /tmp/page_data 2>/dev/null)"

  # delete the tmp files
  rm /tmp/page /tmp/page_data &>/dev/null

  # now lets add to and clean up the returned page data

  # limit to first category (remove all after first comma)
  page_category="${page_category//,*/}"
  # get current date as modified date, as we are updating this file now
  page_modified="$current_date"
  # get path to the file, to use in for url below
  page_dir="$(dirname "${1//.md/}.mdsh")"
  # create page URL
  page_url="${site_url}/$page_dir/${page_slug}.html"

  # set whether or not the page being generated is a blog post (or custom page)
  case "$page_url" in
  */posts/*/*/*) is_blog_post=true ;;
  *)  is_blog_post='' ;;
  esac
}

function get_page_creation_date {
  local file="${1//.mdsh/}.mdsh"
  [ ! -f "$file" ] && return 1
  cat "$file" | grep -E -m1 "^#? ?created"| cut -f2-99 -d':' | sed 's/^ *//'
}

function get_page_descr {
  local file="${1//.mdsh/}.mdsh"
  [ ! -f "$file" ] && return 1
  cat "$file" | grep -E -m1 "^#? ?descr"| cut -f2-99 -d':' | sed 's/^ *//'
}

function relative_path_from_to() {
  # strip trailing slashes
  path1="${1%\/}"
  path2="${2%\/}"
  # common part of both paths
  common=$(printf '%s\x0%s' "${path1}" "${path2}" | sed 's/\(.*\).*\x0\1.*/\1/')
  # how many directories we have to go up to the common part
  up=$(grep -o "/" <<< ${path1#$common} | wc -l)
  # create a prefix in the form of ../../ ...
  prefix=""; for ((i=0; i<=$up; i++)); do prefix="$prefix../"; done
  # return prefix plus second path without common
  printf "$prefix${2#$common}"
}

function generate_page_permalink {
  local permalink="$(echo "${1// /-}" | lowercase)"
  local file="$(find ${page_dir}/ -type f -name "$page_slug.html")"
  local path_from_symlink_to_file

  # delete all symlinks to current page
  find -L . -xtype l -samefile "$page_dir/$page_slug.html" -delete
  # create permalink
  mkdir -p "$(dirname "$permalink")" &>/dev/null

  (
   builtin cd $(dirname "$permalink") &>/dev/null
   path_from_symlink_to_file="$(relative_path_from_to "." "$file")"
   rm "$(basename "$permalink")" &>/dev/null
   ln -s "${path_from_symlink_to_file}" "$(basename "$permalink")"
  )
}

# linked data
function get_linked_data {
  ld_website=''
  ld_article=''
  ld_breadcrumb=''
  ld_itemlist=''

  unset is_homepage
  if [ "${page_title}" = "Homepage" ];then
    is_homepage=true
    # create site search json-ld (requires site.com/$site_url/search.html?s=search+term)
    ld_website="$(render _ld_website 'json-ld')"
  fi

  # create main content as linked data
  ld_article="$(render _ld_article 'json-ld')"

  # create the breadcrumb
  ld_breadcrumb="$(generate_ld_breadcrumb "${page_url:-$site_url}")"

  page_taxonomy="${page_taxonomy:-post}"
  # add item lists to index pages (including homepage, archive & search)
  if [ "$page_taxonomy" = "post" ];then
    ld_itemlist=''
    rm "/tmp/$page_itemlist" 2>/dev/null
  else
    itemlist="$(cat "/tmp/$page_itemlist" 2>/dev/null)"
    [ ! -z "$itemlist" ] && rm /tmp/$page_itemlist 2>/dev/null
    ld_itemlist="$(generate_ld_itemlist "$itemlist")"
  fi
}

function generate_ld_breadcrumb {
  # get URL of page - we will generate the breadcrumb from the URL
  url="$1"
  # set vars used in loop below
  crumb=''
  year=''
  month=''
  local i=1;

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

    # if we don't have a name, skip it
    [ -z "$name" ] && continue

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
    item_url="${site_domain}${crumb}"
    item_title="${title_case_name}"

    # create the hash for the current page in the loop
    declare -Ag "hash${i}"

    # add key/value pairs to the hash
    eval "$(echo "hash${i}"+=\( [position]="$item_position" \))"
    eval "$(echo "hash${i}"+=\( [title]="\"$item_title\"" \))" #"
    eval "$(echo "hash${i}"+=\( [url]="$item_url" \))"

    # add the hash to ITEMS array
    ITEMS+=("hash${i}")

    i=$(($i + 1))
  done

  AUTO_APPEND=','
  cat .app/templates/json-ld/_ld_breadcrumb.mustache | mo
  AUTO_APPEND=''
}

function generate_ld_itemlist {
  # get the list of items (URLs)
  list_items="$1"
  # set vars used in loop below
  local i=1;

  # for each item in URL, build ListItem
  for item in $list_items
  do
    # create the hash for the current page in the loop
    declare -Ag "hash${i}"

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
}

# CSS
function get_css_meta {
  inline_css="$(cat assets/css/inline.css 2>/dev/null)"
  page_specific_stylesheet="assets/css/$(basename "$output_file" 2>/dev/null | sed "s/\.html$/.css/")"
  if [ -f "$page_specific_stylesheet" ];then
    page_specific_stylesheet="${site_url}/${page_specific_stylesheet}?v=$timestamp"
  else
    page_specific_stylesheet=''
  fi
  # Pygments
  pygments=''
  pygments_theme=''
  if [ "$(which pygmentize)" != "" ] && \
     [ -f "assets/css/pygments-${page_code_stylesheet}.css" ]
  then
    pygments=true
    pygments_theme="${page_code_stylesheet:-monokai}"
  fi

}

# JS
function get_js_meta {
  # custom JS for each page
  page_specific_js_file="assets/js/$(basename "$output_file" 2>/dev/null | sed "s/\.html$/\.css/")"
  if [ -f "$page_specific_js_file" ];then
    page_specific_js_file="${site_url}/${page_specific_js_file}?v=$timestamp"
  else
    page_specific_js_file=''
  fi
  # optional google analytics JS
  page_google_analytics_js=''
  if [ "$page_google_analytics_id" != '' ];then
    page_google_analytics_js=true
  fi
}



#
# generate onwards journeys for current page
#

function get_prev_and_next_pages {
  unset page_next
  unset page_prev
  unset next_slug
  unset prev_slug

  # get list of posts, not including current post
  local prev_and_next_pages="$(grep -v "^#" posts.csv \
    | grep -A1 -B1 "|${page_slug//.mdsh/}.mdsh|" \
    | grep -v "|${page_slug//.mdsh/}.mdsh|")"

  [ "$prev_and_next_pages" = "" ] && return 1

  unset page_prev page_next prev_slug next_slug

  page_prev=$(echo "$prev_and_next_pages" | head -1)
  page_next=$(echo "$prev_and_next_pages" | tail -1)

  [ "$page_next" = "$page_prev" ] && unset page_next

  if [ ! -z "$page_prev" ];then
    prev_date="$(echo "$page_prev" | cut -f1 -d'|')"
    prev_slug="$(echo "$page_prev" | cut -f2 -d'|' | sed 's/.mdsh//')"
    prev_title="$(echo "$page_prev" | cut -f3 -d'|')"
    if [ "$prev_slug" != "" ];then
      declare -Ag page_prev
      page_prev=(
        [date]="$prev_date"
        [slug]="$prev_slug"
        [title]="$prev_title"
      )
    fi
  fi

  if [ ! -z "$page_next" ];then
    next_date="$(echo "$page_next" | cut -f1 -d'|')"
    next_slug="$(echo "$page_next" | cut -f2 -d'|' | sed 's/.mdsh//')"
    next_title="$(echo "$page_next" | cut -f3 -d'|')"
    if [ "$next_slug" != "" ];then
      declare -Ag page_next
      page_next=(
        [date]="$next_date"
        [slug]="$next_slug"
        [title]="$next_title"
      )
    fi
  fi
}

###############################################################################


# ITEMS():  A custom mustache iterator called ITEMS:
#           Uses special keywords ITEMS and ITEM.
#
# Usage:
#
# Set an array of hashes, which must be called ITEMS:
#
#   declare -Ag archive=([url]="archive.html" [name]="Archive page")
#   declare -Ag contact=([url]="contact.html" [name]="Contact page")
#   ITEMS=(archive contact)
#
# You can then use nested array data in your mustache templates like so:
#
#   {{#ITEMS}}
#     {{ITEM.name}} is at {{ITEM.url}}
#   {{/ITEMS}}
#
# Finally, build the output like so:
#
#   cat path/to/some-file.mustache | mo > some-file.html
#
function ITEMS {
  # The block contents come in through standard input. Capture it here.
  local content="$(cat)"
  local length=${#ITEMS[@]}
  local i=0
  # Get list of items
  for ITEM in "${ITEMS[@]}"; do
    # String replace ITEM_ with the name
    # This changes everything in the content block of the template.
    # It rewrites {{ITEM.name}} into {{foo.name}}, for example - where
    # 'foo' is a hash with they key 'name'.
    # You can prefix your environment variables and do other things as well.
    echo -ne "$content" | sed "s/{{ITEM/{{${ITEM}/g"
    i=$(($i + 1))
    # if not last item in array, add comma
    if [ "$AUTO_APPEND" != '' ];then
      [ "$i" != "$length" ] && echo "$AUTO_APPEND" || echo ''
    fi
  done
}
# export the function so `mo` can use it
export -f ITEMS


# Adds all supported `$item_foo` vars to a tmp
# hash, then adds that hash to the given array
#
# usage:
#
#  unset myarray
#  myarray=()
#  item_name="foo"
#  item_price="100"
#  add_item_to "myarray"
#
# $1 must be the name of an indexed array
#
function add_item_to {
  parent_array="${1//-/_}"
  hash_name="key_${RANDOM}"
  # create the hash name as an assoc array
  declare -Ag "$hash_name"
  # add items to current tmp hash,
  # and add the names of the hash to given parent array
  eval $(add_keys_to_hash "$parent_array")
}


# this next function populates the ITEMS array with all post/page/taxonomy
# info, it takes no arguments, but expects (at least some of) the following
# vars to be set before it is executed:
#
# item_title
# item_slug
# item_url
# item_descr
# item_category
# item_created
# item_modified
# item_time_to_read
# item_keywords
# item_author
# item_author_slug
# item_twitter
# item_position
# item_post_count    <- if item is a tag or category, holds the number of related posts
#
# And here some some extras, specific to particular templates
#
# datetime    <-- empty or true, if empty $item_datetime will not be shown in post lists
# item_tags   <-- comma separated list of tags (string), used in _search.mustache
# item_before <-- preppends stuff before posts links in <li> lists, used in _list.mustache
# item_after  <-- appends  stuff after post links in <li> lists, used in _list.mustache
#
# All these variables above are set in other functions, which then call
# add_keys_to_hash
#
function add_keys_to_hash {
  # add keys to hash
  echo "$hash_name"+=\( [type]="$item_type" \)
  echo "$hash_name"+=\( [title]="$item_title" \)
  echo "$hash_name"+=\( [slug]="$item_slug" \)
  echo "$hash_name"+=\( [url]="$item_url" \)
  echo "$hash_name"+=\( [descr]="${item_descr//\`/\'}" \)
  echo "$hash_name"+=\( [category]="$item_category" \)
  echo "$hash_name"+=\( [created]="'$item_created'" \)
  echo "$hash_name"+=\( [modified]="'$item_modified'" \)
  echo "$hash_name"+=\( [datetime]="'$item_datetime'" \)
  echo "$hash_name"+=\( [time_to_read]="'$item_time_to_read'" \)
  echo "$hash_name"+=\( [keywords]="\"$item_keywords\"" \)
  echo "$hash_name"+=\( [price]="\"$item_price\"" \)
  echo "$hash_name"+=\( [author]="\"$item_author\"" \)
  echo "$hash_name"+=\( [author_slug]="$item_author_slug" \)
  echo "$hash_name"+=\( [twitter]="$item_twitter" \)
  echo "$hash_name"+=\( [position]="$item_position" \)
  echo "$hash_name"+=\( [post_count]="'$item_post_count'" \)
  echo "$hash_name"+=\( [before]="'$item_before'" \)
  echo "$hash_name"+=\( [after]="'$item_after'" \)
  echo "$hash_name"+=\( [tags]="\"$item_tags\"" \)
  # add the hash to the ITEMS array
  echo ${1:-ITEMS}+=\( "$hash_name" \)
}
