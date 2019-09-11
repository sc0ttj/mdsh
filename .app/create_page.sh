#!/bin/bash

# Script for creating HTML pages from markdown files or HTML strings

# we will write to file if $2 is a file, else to stdout
if [ -f "$2" ];then
  output_file="$2"
fi

# set some dates to use later
current_date="$(LANG=C LC_ALL=C LC_CTYPE=C date -u +"%Y-%m-%dT%H:%M:%SZ")"
current_year="$(date -u +"%Y")"
timestamp=$(date +%s)

# load the local config file
[ -f .site_config ] && source .site_config

is_blog_post=''
AUTO_APPEND=''

################################################################################


#
# Begin main script
#

# begin processing the given file or string (or generate homepage if none)
body_html=''
markdown=''

# set the data used by the templates:
# - get data from post front matter
# - or fallback to site defaults ($site_)
get_page_data "$1"
get_linked_data
get_css_meta
get_js_meta
if [ "$is_blog_post" = true ];then
  get_prev_and_next_pages
fi

echo '' > /tmp/${page_slug}_itemlist

# also get data from data folder (assets/data/<page-slug>/<file>)
if [ -d "assets/data/${page_slug}/" ];then
  # source sh files
  for sh_file in assets/data/${page_slug}/*.sh
  do
    [ ! -z "$sh_file" ] && [ -f "$sh_file" ] && source "$sh_file"
  done
  # parse yml files
  for yaml_file in assets/data/${page_slug}/*.yml
  do
    [ ! -z "$yaml_file" ] && [ -f "$yaml_file" ] && eval $(yay "$yaml_file")
  done
  # parse CSV files (they must contain headers!)
  for csv_file in assets/data/${page_slug}/*.csv
  do
    [ ! -f "$csv_file" ] && continue
    arrayName="$(basename "$csv_file" .csv)"
    csv_data="$(cat "$csv_file" | csv_to_data $arrayName)"
    eval "$csv_data"
  done
fi

# get the source HTML/markdown from STDIN (file or string)


# if given an mdsh file, then build its markdown file,
# then grab the markdown from that new file
if [ "$1" != "" ] && [ -f "${1//.mdsh/}.mdsh" ];then
  .app/mdsh2md.sh "${1//.mdsh/}.mdsh" &>/dev/null
  markdown="$(cat "${1//.mdsh/}.md")"

# if given a markdown file, just grab that markdown
elif [ "$1" != "" ] && [ -f "${1//.md/}.md" ];then
  markdown="$(cat "${1//.md/}.md")"

# get html from string
elif [ "$1" != "" ] && [ "$1" != "-all" ] && [ "$1" != "-ALL" ];then
  body_html="$(echo -e "$1")"

# no input, or doing all pages, so generate default homepage
elif [ -z "$1" ] || [ "$1" = "-all" ] || [ "$1" = "-ALL" ];then
  body_html="$(generate_homepage)"
fi


# if we have markdown, not html, we need to convert it
if [ "$markdown" != "" ];then

  [ ! "$1" ] && return 1

  # do some pre-processing of the markdown before converting to html
  echo "$markdown" > /tmp/markdown
  echo -n '' > /tmp/fixed_markdown

  process_markdown # writes to /tmp/fixed_markdown

  # get the pre-processed markdown, we will convert that to html
  [ -s /tmp/fixed_markdown ] && markdown="$(cat /tmp/fixed_markdown)"
  rm /tmp/markdown /tmp/fixed_markdown &>/dev/null

  #body_html="$(md2html.sh /tmp/markdown)" # uses github API

  # check our HTML is not empty or an error (from GitHub API)
  if [ "$body_html" = "" ] || \
     [ "$(echo "$body_html" | grep 'Problems parsing JSON')" != "" ] || \
     [ "$(echo "$body_html" ] grep 'API rate limit exceeded')" != "" ];then
    # convert the markdown to HTML
    # available markdown parsers:
    #  - markdown.pl - the original
    #  - gf-markdown.pl - supports gitHub flavoured markdown (based on the above)
    #  - markdown.sh - a bash only alternative
    body_html="$(echo -e "$markdown" | .app/gf-markdown.pl)"
  fi

fi


#
# at this point, we have $body_html, and we can build our page
#

# set {{page_body}} - used in the main.mustache template
page_body="${body_html}"
# render the main template
render ${page_layout:-main} 1>/tmp/htmlfile

# use minified CSS if it exists
if [ "$(grep -m1 "main.min.css?v=" /tmp/htmlfile)" = "" ] && \
   [ -f assets/css/main.min.css ];then
  sed -i "s|main.css?v=|main.min.css?v=|g" /tmp/htmlfile
fi

# finally, return the finished HTML page
if [ -f "$output_file" ];then
  cat /tmp/htmlfile > "$output_file"
else
  cat /tmp/htmlfile
fi

# create a permalink
if [ "$page_permalink" != "" ];then
  generate_page_permalink "$page_permalink"
fi

# clean up
rm    /tmp/htmlfile
unset is_blog_post
unset page_file
unset site_title
unset page_fonts
unset page_header
unset page_lang
unset page_title
unset page_slug
unset page_descr
unset page_category
unset page_permalink
unset page_created
unset page_modified
unset page_time_to_read
unset page_keywords
unset page_author
unset page_author_slug
unset page_twitter
unset page_js_deps
unset page_google_analytics_id
unset page_url
unset markdown
unset markdown_meta
unset markdown_body
unset body_html
unset output_file
