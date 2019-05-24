# this script is sourced by 'create_page.sh'

#
# functions for building HTML of the current page
#

# This function renders HTML, JSON (etc) and takes two options:
#
# $1 - the mustache template filename
# $2 - the renderer. Defaults to 'html' if none given
#
# Examples:
#
# render _contact
# render _list html
# render _ld_article json-ld
#
function render {
  # for debugging
  #[ ! -z "$ITEMS" ] && xmessage "ITEMS: $(declare -p ITEMS)"

  local template_file=".app/templates/${2:-html}/${1//.mustache/}.mustache"
  if [ -f "$template_file" ];then
    cat "$template_file" | mo
  else
    return 1
  fi
}


# create an HTML page
function create_page_html {
  # set body content
  local page_content="${body_html}"
  # build page
  render main
}

# creates a default homepage
function homepage {
  echo -n '' > /tmp/itemlist
  local post_file=''
  local body_html=''
  local recent_posts="$(cut -f1,2 -d'|' ./posts.csv | sort -r | head -18 | grep -v "^#")"
  for post in $recent_posts
  do
    post_file="posts/${post//|//}"
    body_html="${body_html}$(post_preview "$post_file")"
    echo "${blog_url}/$post_file" >> /tmp/itemlist
  done
  echo -e "$body_html"
}

function site_meta {
  # linked data
  local ld_website=''
  local ld_article=''
  local ld_breadcrumb=''
  local ld_item_list=''
  # add site search json-ld (requires site.com/$blog_url/search.html?s=search+term)
  if [ "${page_title}" = "$blog_title - Homepage" ];then
    ld_website="$(render _ld_website 'json-ld')"
  fi
  # main linked data - has info about the main content (article)
  ld_article="$(render _ld_article 'json-ld')"
  ld_breadcrumb="$(.app/breadcrumb.sh "${post_url:-$blog_url}")"
  # only add item lists to index pages
  if [ "$post_created" = "" ];then
    itemlist="$(cat /tmp/itemlist 2>/dev/null && rm /tmp/itemlist 2>/dev/null)"
    ld_itemlist="$(.app/itemlist.sh "$itemlist")"
  else
    ld_itemlist=''
    rm /tmp/itemlist 2>/dev/null
  fi

  # CSS
  local inline_css="$(cat assets/css/inline.css 2>/dev/null)"
  local page_specific_css_file="assets/css/$(basename "$output_file" 2>/dev/null | sed "s/\.html$/.css/")"
  if [ -f "$page_specific_css_file" ];then
    page_specific_css_file="${blog_url}/${page_specific_css_file}?v=$timestamp"
  else
    page_specific_css_file=''
  fi

  # Pygments
  local pygments=''
  local pygments_theme=''
  if [ "$(which pygmentize)" != "" ] && \
     [ -f "assets/css/pygments-${blog_code_highlight_theme}.css" ]
  then
    pygments=true
    pygments_theme="${blog_code_highlight_theme:-monokai}"
  fi

  # JS
  local page_js_deps=()
  local site_js=''
  # for each JS dep from unpkg, (also inc post specific deps, if any)
  for pkgname in $(echo "$post_js_deps $blog_js_deps" | tr ' ' '\n' | tr ',' '\n' | uniq)
  do
    page_js_deps+=("$pkgname")
  done
  # add site-wide app.js, if it exists
  if [ -f ./assets/js/app.js ];then
    site_js=true
  fi

  # custom JS for each page
  local page_specific_js_file="assets/js/$(basename "$output_file" 2>/dev/null | sed "s/\.html$/\.css/")"
  if [ -f "$page_specific_js_file" ];then
    page_specific_js_file="${blog_url}/${page_specific_js_file}?v=$timestamp"
  else
    page_specific_js_file=''
  fi

  # optional google analytics JS
  local page_google_analytics_js=''
  if [ "$page_google_analytics_id" != '' ];then
    page_google_analytics_js=true
  fi

  render _site_meta
}


function site_header {
  local enable_search=false
  if [ "$(echo "${post_js_deps:-$blog_js_deps}" | grep 'jets')" != "" ];then
    enable_search=true
  fi
  # get list of files, each on a new line
  local list="$(ls -1 *.html | grep -vE 'index.html|404.html|^_*.html')"

  ITEMS=()
  for item in $list
  do
    # get the page name (without .html)
    local item_title="${item//.html/}"
    local item_url="${blog_url}/${item}"
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done

  render _site_header
}


function post_header {
  post_meta "header"
}

function post_footer {
  post_meta "footer"
}

function post_meta {
  # exit if we are not building a blog post
  [ "$is_blog_post" = false ] && return 1
  local type=${1:-header}
  local tags=()
  for tag in ${page_keywords//,/ }
  do
    tags+=("$tag")
  done
  render _post_meta
}


function post_preview {
  # exit if we are not building a blog post
  [ "$is_blog_post" = false ] && return 1
  [ ! "$1" ] && return 1
  # $1 is the mdsh file
  set_post_info "$1"

  local tags=()
  for tag in ${page_keywords//,/ }
  do
    tags+=("$tag")
  done

  # get the post markdown, convert to HTML, then return it
  page_excerpt="$(
    process_markdown posts/$post_date/${post_slug}.md
    [ -s /tmp/fixed_markdown ] && markdown="$(cat /tmp/fixed_markdown 2>/dev/null)"
    rm /tmp/markdown /tmp/fixed_markdown &>/dev/null
    if [ "$markdown" != '' ];then
      # keep only the stuff before <!-- more -->
      if [ "$(echo -e "$markdown" | grep -m1 '<!-- more -->')" != '' ];then
        markdown="${markdown//<\!-- more -->*/$(render _read_more)}"
      fi
      echo -e "$markdown" | .app/markdown.pl | sed "s/<h2>.*//"
    fi
  )"

  render _post_preview
}


function onward_journeys {
  [ "$is_blog_post" = false ] && return 1
  local current_post="$(grep -v "^#" ./posts.csv | grep "|${post_slug//.mdsh/}.mdsh|")"
  # exit if no post to check
  [ "$current_post" = "" ] && return 1
  # get list of posts, not including current post
  local prev_current_next_posts="$(grep -A1 -B1 "|${post_slug//.mdsh/}.mdsh|" ./posts.csv | grep -v "$current_post")"
  # check again without the .mds extension
  if [ "$prev_current_next_posts" = "" ];then
    prev_current_next_posts="$(grep -A1 -B1 "|${post_slug//.mdsh/}|" ./posts.csv)"
  fi
  # exit if no posts to list
  [ "$prev_current_next_posts" = "" ] && return 1

  local prev_post=$(echo "$prev_current_next_posts" | head -1)
  local next_post=$(echo "$prev_current_next_posts" | tail -1)

  local prev_date="$(echo "$prev_post" | cut -f1 -d'|')"
  local next_date="$(echo "$next_post" | cut -f1 -d'|')"
  local prev_slug="$(echo "$prev_post" | cut -f2 -d'|')"
  local next_slug="$(echo "$next_post" | cut -f2 -d'|')"
  local prev_title="$(echo "$prev_post" | cut -f3 -d'|')"
  local next_title="$(echo "$next_post" | cut -f3 -d'|')"

  local prev_slug_name="${prev_slug//.mdsh/}"
  local next_slug_name="${next_slug//.mdsh/}"

  if [ "$next_slug_name" = "$prev_slug_name" ];then
    next_slug_name=""
  fi

  render _prev_next_posts
}

#function site_footer {
#  render _site_footer
#}


#
# function to convert the post markdown to HTML
#
process_markdown() {
  local in_code_block=false

  # the -er option is needed to preserve newlines in the code blocks, IFS= preserves whitespace
  while IFS= read -er line
  do
    if [ "$(which pygmentize)" = "" ];then
      if [[ "$line" =~ '```' ]];then
        code_class=''
        code_lang="$(echo ${line//\`\`\`/})"
        [ "$code_lang" != "" ] && code_class=" class=\"${code_lang}\""
        [ "$in_code_block" = true  ] && in_code_block=false  || in_code_block=true
        [ "$in_code_block" = false ] && line="</code></pre>" || line="<pre><code${code_class}>"
      else
        if [ "$in_code_block" = true ];then
          line="$(echo "$line" | sed -e 's|<|\&lt;|g' -e 's|>|\&gt;|g')"
        fi
      fi
      echo -e "$line" >> /tmp/fixed_markdown

    else
      # if entering a code block
      # replace ``` with html pre/code tags, cos the markdown parsers break a lot
      if [[ "$line" =~ '```' ]] && [ "$in_code_block" = false ];then
        local code_lang="$(echo ${line//\`\`\`/})"
        local code_class=" class=\"${code_lang:-shell}\""
        line="<pre><code${code_class}>"
        in_code_block=true

      fi

      if [ "$line" != '```' ]  && [[ ! "$line" =~ '<pre>' ]] && [[ ! "$line" =~ '</code>' ]];then
        if [ "$in_code_block" = true ];then
          echo -e "$line" >> /tmp/code_block
        else
          echo -e "$line" >> /tmp/fixed_markdown
        fi
      fi

      # if leaving a code block
      if [[ "$line" =~ '```' ]] && [ "$in_code_block" = true ];then
        if [ "$(cat /tmp/code_block)" != "" ];then
          pygmentize -f html -l ${code_lang:-shell} -o /tmp/code_block_highlighted /tmp/code_block
          echo "$(cat /tmp/code_block_highlighted)" >> /tmp/fixed_markdown
          echo -n > /tmp/code_block
          in_code_block=false
          line="</code></pre>"
        fi
      fi

    fi

  done<<<"$(cat "${1:-/tmp/markdown}")"
}
