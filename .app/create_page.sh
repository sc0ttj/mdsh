#!/bin/bash

# Script for creating HTML pages from markdown files or HTML strings

# load the local config file
[ -f .site_config ] && source .site_config

# set some dates to use later
current_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
current_year="$(date -u +"%Y")"
timestamp=$(date +%s)

# set vars for page, globals used by various funcs
site_title=''
page_fonts=''
page_lang=''
page_title=''
page_slug=''
page_descr=''
page_category=''
page_created=''
page_modified=''
page_time_to_read=''
page_keywords=''
page_author=''
page_author_slug=''
page_twitter=''
page_js_deps=''
page_google_analytics_id=''
page_url=''
AUTO_APPEND=''

# we will write to file if $2 is a file, else to stdout
if [ -f "$2" ];then
  output_file="$2"
fi

################################################################################


#
# Begin main script
#

# begin processing the given file or string (or generate homepage if none)
body_html=''
markdown=''

# set the page data used by the templates:
# use data passed in by user or post source ($post_*),
# or fallback to site defaults ($blog_)
set_page_data

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
  body_html="$(homepage)"
fi


# if we have markdown, not html, we need to convert it
if [ "$markdown" != "" ];then

  [ ! "$1" ] && return 1

  # set some variables to put into the post HTML
  set_post_info "$1"

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
    body_html="$(echo -e "$markdown" | .app/markdown.pl)" # or markdown.sh
  fi

fi


#
# at this point, we have $body_html, and we can build our page
#

create_page_html > /tmp/htmlfile

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

# clean up
rm    /tmp/htmlfile
unset post_file
unset post_title
unset post_heading
unset post_slug
unset post_category
unset post_created
unset post_date
unset post_time_to_read
unset post_header
unset post_url
unset site_title
unset page_fonts
unset page_header
unset page_lang
unset page_title
unset page_slug
unset page_descr
unset page_category
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
