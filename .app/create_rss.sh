#!/bin/bash

# Generate an RSS 2.0 feed directly from your existing web site

# Author    - Pádraig Brady P@draigBrady.com
# Licence   - LGPLV2
# Releases  -
#   1.0     - Jun 19 2006 - Initial release
#   1.1     - Jun 26 2006 - Exclude files with "Exclude from bashfeed"
#                           HTML comment within the first 10 lines.
#   1.2     - May 01 2007 - Add author elements (from html if present)
#   1.4     - May 04 2011
#    https://github.com/pixelb/scripts/commits/master/scripts/bashfeed

# Just run this script from the root directory of your web site and
# it will generate feed items for the newest files. Generally I do this
# just before I sync my local web site copy to my public server.

# One can generate a feed for a subset of the site by still running
# from the root directory, and passing a subdirectory to start at.

# To change the feed TITLE and DESCRIPTION, set those environment
# variables before running the script.

# Which files are selected and excluded can be configured below.
# Note for html files it will extract the following elements if present
#   <head>
#     <title>Item title</title>
#     <meta name="description" content="One line item description">
#     <meta name="keywords" content="Item tags">
#   </head>

# Note this script will keep the same item guid for an updated file.
# Just updating the pubDate will not cause liferea 1.0.11 at least
# to mark the item as updated (or update the timestamp even).
# One must change the description or title also, and so
# I set the (hidden) description to the file timestamp.
#
# Testing with thunderbird 1.0.8 shows that it indexes on link
# and so wont ever show updates to other fields. Therefore I append #seconds
# to the link to force it to create a new entry for an updated item.
#
# Note you may find the https://www.pixelbeat.org/scripts/fix script
# useful for doing edits to files that you don't want to show up
# as updated content in the feed, or generally edit a file without
# changing the modification date.

if [ -f .site_config ];then
  source .site_config
fi

num_files=18
TITLE="${site_title}"
site="${site_domain}${site_url}"
email="${site_email}"
author="${site_author}"
suggested_update_freq=1440 #mins

: ${TITLE=$site}
: ${DESCRIPTION="latest from $site"}

# get OS type (Linux, Darwin, ??)
os_type="$(uname)"

buildDate=`date +"%a, %d %b %Y %T %z"`

echo '<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/css" href="rss2.css" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<atom:link href="http://'"$site"'/feed.rss" rel="self" type="application/rss+xml" />'

echo "
<title>$TITLE</title>
<ttl>$suggested_update_freq</ttl>
<link>https://$site/$1</link>
<generator>https://$site/create_rss</generator>
<description>$DESCRIPTION</description>
<managingEditor>$email ($author)</managingEditor>
<lastBuildDate>$buildDate</lastBuildDate>
<language>`echo $LANG | sed 's/\(..\)_.*/\1/'`</language>
"

xml_unescaped() { sed 's/&amp;//g; s/&[lg]t;//g; s/&quot;//g' | grep -q "[&<>]"; }

find ./posts -type f -name "*.html" | grep -v "index.html" | sort -r |
sed 's/^\.\///' | # strip leading ./ when "$1" is empty
while read file; do
  mdshfile="${file//.html/.mdsh}"
  if ! head "$file" | grep -Fiq '<!--Exclude from bashfeed-->'; then
      echo "$file"
      i=$((i+1))
      [ $i -eq $num_files ] && break
  fi
done |
while read file; do
  if [ "$os_type" = "Linux" ];then
    # use GNU date
    pubDate=`date -r "$file" +"%a, %d %b %Y %T %z"`
    force_update=`date -r "$file" "+%s"`
  else # Mac, BSD
    # use BSD date
    timestamp=$(stat -f "%m" "$file")
    pubDate=`date -r "$timestamp" +"%a, %d %b %Y %T %z"`
    force_update=`date -r "$timestamp" "+%s"`
  fi
  title=""; keywords=""; description=""
  if echo "$file" | grep -Eq '\.(html|shtml|php)$'; then
    if [ -f "$mdshfile" ];then
      md_meta="$(cat "$mdshfile")"
      md_meta="${md_meta%---*}"
      title="$(echo "$md_meta"       | grep -m1 '# title'       | cut -f2 -d':' | sed 's/^ *//')"
      keywords="$(echo "$md_meta"    | grep -m1 '# tags'        | cut -f2 -d':' | sed 's/^ *//')"
      description="$(echo "$md_meta" | grep -m1 '# description' | cut -f2 -d':' | sed 's/^ *//')"
      page_author="$(echo "$md_meta" | grep -m1 '# author'      | cut -f2 -d':' | sed 's/^ *//')"
    else
      title="`grep '<title>' "$file" | sed -e 's|.*<title>||' -e 's|</title>.*||'`"
      keywords="`grep -i '<meta name="keywords"' "$file" | sed -e 's|.*<meta name="keywords" content="||' -e 's|".*||'`"
      description="`grep -i '<meta name="description"' "$file" | sed -e 's|.*<meta name="description" content="||' -e 's|".*||'`"
      page_author="`grep -i '<meta name="author"' "$file" | sed -e 's|.*<meta name="author" content="||' -e 's|".*||'`"
    fi

    extracted_text="$title $keywords $description$ $page_author"
    if echo "$extracted_text" | xml_unescaped; then
      echo "Error: HTML metadata in $file will not produce a valid XML feed" >&2
      exit 1
    fi
  fi
  [ -z "$title" ] && title="$file"
  tags=""
  if [ ! -z "$keywords" ]; then
    for keyword in ${keywords//,/ }; do
      [ "$keyword" = "" ] && continue
      tags=`echo -ne "$tags<category>$keyword</category>\n    "`
    done
  fi
  if [ "$page_author" ]; then
    if [ "$page_author" = "$author" ]; then
      page_author=""
    else
      page_author=`echo -ne "<author>$page_author</author>\n    "`
    fi
  fi
echo "
<item>
    <title>$title</title>
    <guid>https://$site/$file</guid>
    <pubDate>$pubDate</pubDate>
    <link>https://$site/$file#$force_update</link>
    $page_author$tags<description><![CDATA[$description<!--$force_update-->]]></description>
</item>
"
done &&
echo '</channel>
</rss>'
