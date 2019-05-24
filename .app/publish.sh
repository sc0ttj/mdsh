#!/bin/bash

current_branch=$(git branch | grep ^\* | cut -f2 -d' ')

# save and publish site changes
git add .
git commit -m "${1:-committed files}"
git push origin $current_branch

sleep 0.5

# update RSS feed
echo "Updating: feed.rss"
.app/create_rss.sh posts/ > feed.rss

# update sitemap
.app/generate_sitemap.sh

# commit to Git
git add feed.rss sitemap.xml
git commit -m "Updated RSS feed and XML sitemap"
git push origin $current_branch
