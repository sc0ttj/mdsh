#!/bin/bash

# generate an XML sitemap for this site

# script adapted from: http://www.lostsaloon.com/technology/how-to-create-an-xml-sitemap-using-wget-and-shell-script/

[ -f .site_config ] && . .site_config

sitedomain=https://${blog_domain}${blog_url}

mv sitemap.xml sitemap_prev.xml

echo "Generating sitemap.xml, please wait.."

wget --spider --recursive --level=inf --no-verbose --output-file=linklist.txt "$sitedomain"
grep -i URL linklist.txt | awk -F 'URL:' '
{print $2}' | awk '{$1=$1};1' | awk '{print $1}' | sort -u | sed '/^$/d' > sortedurls.txt

header='<?xml version="1.0" encoding="UTF-8"?><urlset
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">'

echo $header > sitemap.xml

while read p; do
  case "$p" in
  */ | *.html | *.htm)
    echo '<url><loc>'$p'</loc></url>' >> sitemap.xml
    ;;
  *)
    ;;
 esac
done < sortedurls.txt

echo "</urlset>" >> sitemap.xml

rm linklist.txt sortedurls.txt &>/dev/null

[ ! -f sitemap.xml ] && exit 1

rm sitemap_prev.xml

current_branch=$(git branch | grep ^\* | cut -f2 -d' ')

echo "Publishing sitemap.."
echo
git add sitemap.xml
git commit -m 'Updated sitemap'
git push origin $current_branch

exit 0
