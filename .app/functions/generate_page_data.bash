# this script is sourced by 'create_page.sh'

#
# functions for setting page data
#

# the general purpose of these functions is to create and make available
# as '$page_foo' variables all of the page data for the page being built,
# so that they can be used by the templates in .app/templates/

# Usage:  set_post_info path/to/post.mdsh
#
#         Used by other functions to set the post info used in various
#         bits of generated HTML.

function set_post_info {
  [ ! -f "$1" ] && return

  local md_meta
  # get the meta info from the .mdsh file
  if [ -f "${1//.mdsh/}.mdsh" ];then
    md_meta="$(cat "${1//.mdsh/}.mdsh" 2>/dev/null)"
  elif [ -f "${1//.md/}.mdsh" ];then
    md_meta="$(cat "${1//.md/}.mdsh" 2>/dev/null)"
  else
    return 1
  fi

  # remove post meta data and keep only the body
  md_meta="${md_meta%---*}"

  # if we have no data, exit
  [ "${md_meta}" = "" ] && return 1

  # set some page/post specific meta info that will end up in the HTML
  post_title="$(echo "$md_meta"        | grep -E -m1 "^#? ?title"       | cut -f2-99 -d':' | sed 's/^ *//')"
  post_slug="$(echo "$md_meta"         | grep -E -m1 "^#? ?slug"        | cut -f2-99 -d':' | sed 's/^ *//')"
  post_descr="$(echo "$md_meta"        | grep -E -m1 "^#? ?description" | cut -f2-99 -d':' | sed 's/^ *//')"
  post_category="$(echo "$md_meta"     | grep -E -m1 "^#? ?category"    | cut -f2-99 -d':' | sed 's/^ *//' | cut -f1 -d',')"
  post_created="$(echo "$md_meta"      | grep -E -m1 "^#? ?created"     | cut -f2-99 -d':' | sed 's/^ *//')"
  post_time_to_read="$(echo "$md_meta" | grep -E -m1 "^#? ?time to read"| cut -f2-99 -d':' | sed 's/^ *//')"
  post_tags="$(echo "$md_meta"         | grep -E -m1 "^#? ?tags"        | cut -f2-99 -d':' | sed 's/^ *//')"
  post_language="$(echo "$md_meta"     | grep -E -m1 "^#? ?language"    | cut -f2-99 -d':' | sed 's/^ *//')"
  post_author="$(echo "$md_meta"       | grep -E -m1 "^#? ?author"      | cut -f2-99 -d':' | sed 's/^ *//')"
  post_twitter="$(echo "$md_meta"      | grep -E -m1 "^#? ?twitter"     | cut -f2-99 -d':' | sed 's/^ *//')"
  post_js_deps="$(echo "$md_meta"      | grep -E -m1 "^#? ?JS deps"     | cut -f2-99 -d':' | sed 's/^ *//')"

  # limit to first category (remove all after first comma)
  post_category="${post_category//,*/}"
  # get current date as modified date, as we are updating this file now
  post_modified="$current_date"
  # get date from folder name (for url below)
  post_date="$(grep -v "^#" posts.csv | grep -m1 "|${post_slug}.mdsh|$post_title|" | cut -f1 -d'|')"
  # create post URL
  post_url="${blog_url}/posts/$post_date/${post_slug}.html"

  # set whether or not the page being generated is a blog post (or custom page)
  [ "$post_created" != "" ] && is_blog_post=true || is_blog_post=false

  # set the page data used by the templates:
  # use data passed in by user or post source ($post_*),
  # or fallback to site defaults ($blog_)
  set_page_data
}

function set_page_data {
  site_title="${blog_title}"
  page_fonts="${post_fonts:-$blog_fonts}"
  page_lang="${blog_language:-en}"
  page_title="${post_title:-$blog_title}"
  page_slug="${post_slug:-$(.app/slugify.sh "$post_title")}"
  page_descr="${post_descr:-$blog_descr}"
  page_category="${post_category}"
  page_date="${post_date//\//-}"
  page_created="${post_created:-$current_date}"
  page_modified="${post_modified:-$current_date}"
  page_time_to_read="${post_time_to_read:-$blog_time_to_read}"
  page_keywords="${post_tags:-$blog_keywords}"
  page_author="${post_author:-$blog_author}"
  page_author_slug="$(.app/slugify.sh "${page_author}")"
  page_twitter="${post_twitter:-$blog_twitter}"
  page_js_deps="${post_js_deps:-$blog_js_deps}" # becomes array later
  page_google_analytics_id="${post_google_analytics_id:-$blog_google_analytics_id}"
  page_url="${post_url:-$blog_url}"
}

# ITEMS():  A custom mustache iterator called ITEMS:
#           Uses special keywords ITEMS and ITEM.
#
# Usage:
#
# Set an array of hashes, which must be called ITEMS:
#
#   declare -A archive=([url]="archive.html" [name]="Archive page")
#   declare -A contact=([url]="contact.html" [name]="Contact page")
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


# this next function populates the ITEMS array with all post/page info..
# it takes no arguments, but expects (at least some of) the following
# vars to be set before it is executed:
#
# item_title
# item_heading
# item_slug
# item_url
# item_descr
# item_category
# item_created
# item_modified
# item_datetime
# item_time_to_read
# item_keywords
# item_author
# item_author_slug
# item_twitter
# item_position
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
  echo "$hash_name"+=\( [title]="$item_title" \)
  echo "$hash_name"+=\( [heading]="$item_heading" \)
  echo "$hash_name"+=\( [slug]="$item_slug" \)
  echo "$hash_name"+=\( [url]="$item_url" \)
  echo "$hash_name"+=\( [descr]="${item_descr//\`/\'}" \)
  echo "$hash_name"+=\( [category]="$item_category" \)
  echo "$hash_name"+=\( [created]="'$item_created'" \)
  echo "$hash_name"+=\( [modified]="'$item_modified'" \)
  echo "$hash_name"+=\( [datetime]="'$item_datetime'" \)
  echo "$hash_name"+=\( [time_to_read]="'$item_time_to_read'" \)
  echo "$hash_name"+=\( [keywords]="\"$item_keywords\"" \)
  echo "$hash_name"+=\( [author]="\"$item_author\"" \)
  echo "$hash_name"+=\( [author_slug]="$item_author_slug" \)
  echo "$hash_name"+=\( [twitter]="$item_twitter" \)
  echo "$hash_name"+=\( [position]="$item_position" \)
  echo "$hash_name"+=\( [before]="'$item_before'" \)
  echo "$hash_name"+=\( [after]="'$item_after'" \)
  echo "$hash_name"+=\( [tags]="\"$item_tags\"" \)
  # add the hash to the ITEMS array
  echo ITEMS+=\( "$hash_name" \)
}

