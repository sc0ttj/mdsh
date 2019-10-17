# this script is sourced by 'create_page.sh'

#
# functions for building HTML of the current page
#

# This function renders HTML, JSON (etc) and takes two options:
#
# $1 - the mustache template filename
# $2 - the format. Defaults to 'html' if none given
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

  local template_name="${1//.mustache}.mustache"

  if [ -f "$template_name" ];then
    cat "$template_name" | mo | html_decode
    return 0
  fi

  local format="${2:-html}"
  local template_file=".app/templates/${format}/${template_name}"

  if [ -z "$MO_PARTIAL_DIR" ];then
    local MO_PARTIAL_DIR=".app/templates/${format}/"
  fi

  if [ -f "$template_file" ];then
    cat "$template_file" | mo | html_decode
  elif [ -f "${MO_PARTIAL_DIR}${template_file}" ];then
    cat "${MO_PARTIAL_DIR}${template_file}" | mo | html_decode
  else
    return 1
  fi
}


# generate the <html> tag at top of page
function html_tag {
  if [ -f /tmp/_site_html_tag.html ];then
   cat /tmp/_site_html_tag.html
   return 0
  fi
  render _html_tag > /tmp/_site_html_tag.html
  cat /tmp/_site_html_tag.html
}

# creates a default homepage
function generate_homepage {
  echo -n '' > /tmp/itemlist
  local page_file=''
  local body_html=''
  local recent_posts="$(cut -f1,2 -d'|' ./posts.csv | sort -r | head -${recent_limit:-10} | grep -v "^#")"
  for post in $recent_posts
  do
    page_file="posts/${post//|//}"
    body_html="${body_html}$(post_preview "$page_file")"
    echo "${site_url}/$page_file" >> /tmp/itemlist
  done
  echo -e "$body_html"
}

function post_preview {
  # exit if we are not building a blog post
  [ "$is_blog_post" = false ] && return 1
  [ ! "$1" ] && return 1

  # $1 is the mdsh file of the post (or page) we want to preview
  get_page_data "$1"

  local tags=()
  for tag in ${page_keywords//,/ }
  do
    tags+=("$tag")
  done

  # get the post markdown, convert to HTML, then return it
  page_excerpt="$(
    process_markdown "${1//.mdsh/}.md"
    [ -s /tmp/fixed_markdown ] && markdown="$(cat /tmp/fixed_markdown 2>/dev/null)"
    rm /tmp/markdown /tmp/fixed_markdown &>/dev/null
    if [ "$markdown" != '' ];then
      # keep only the stuff before <!-- more -->
      if [ "$(echo -e "$markdown" | grep -m1 '<!-- more -->')" != '' ];then
        markdown="${markdown//<\!-- more -->*/$(render _read_more)}"
      fi
      echo -e "$markdown" | mo 2>/dev/null | .app/markdown.pl 2>/dev/null | sed "s/<h2>.*//"
    fi
  )"

  render _post_preview
}


#
# function to convert the post markdown to HTML
#
function process_markdown {
  local in_code_block=false

  # the -er option is needed to preserve newlines in the code blocks, IFS= preserves whitespace
  while IFS= read -er line
  do
    # oembed - if line contains a supported URL, convert to oembed HTML
    if [ "$(echo "$line" | grep -E "$oembed_filters")" != "" ];then
      oembed_html="$(get_oembed_html "${line/ */}")"
      [ "$oembed_html" != "" ] && line=""
      echo -e "<div class=\"oembed-container\" style=\"max-width: 100% !important; overflow: hidden;\">$oembed_html</div>" >> /tmp/fixed_markdown
    fi

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


function get_oembed_filters {
  ls -1 .app/functions/providers \
    | sed -e 's/^/^http(s?):\/\/(www.|)/g' \
    | tr '\n' '|' \
    | sed '$ s/.$//'
}


function get_oembed_html {
  local url="$1"
  local oembed_html="$(.app/functions/oembed "$url" 2>/dev/null \
    | python -m json.tool \
    | grep -m1 '"html": "' \
    | cut -f4- -d'"' \
    | sed -e 's/\\"/"/g' -e '$ s/.$//' -e '$ s/"$//'
  )" #'
  echo -e "$oembed_html"
}
