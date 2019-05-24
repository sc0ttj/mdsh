#!/bin/bash

# Usage:  update_pages [-all|-ALL]

# Update all index pages across the site which list posts, tags and categories
# because a new post may have been added.

# can rebuild .html files from .md files (-all), and can also rebuild .md
# files from .mdsh files (-ALL)

# if -all is given, all HTML pages will be re-built, not just the index
# pages (categories, tags, archive, home/recent posts, etc)

# if -ALL is given, all .md files will be rebuilt (from .mdsh), and then
# all pages will be rebuilt as above.

# load the local config file
[ -f .site_config ] && source .site_config

# clean up posts.csv (remove any entries that have missing files)
cp posts.csv /tmp/posts.csv

# read all posts
cut -f1-2 -d'|' /tmp/posts.csv | sort -r | while read line
  do

    # remove the HTML files of unpublished posts
    if [ "$(echo "$line" | grep "^#")" != "" ];then
      html_file=${line//|//}
      html_file=${html_file//#/}
      html_file=posts/${html_file//.mdsh/.html}
      [ -f $html_file ] && rm $html_file &>/dev/null
      continue
    fi

    # get the file name
    mdshfile="${line//|//}"
    mdshfile="${mdshfile//#/}"

    if [ ! -f "posts/$mdshfile" ];then
      # the .mdsh file doesnt exist, remove post from posts list
      echo "Removing: posts/$mdshfile"
      grep -v "^$line" posts.csv > /tmp/posts.csv
      mv /tmp/posts.csv posts.csv

    else
      # mdsh file exists
      #
      # if -all, ....         md -> html
      # if -ALL, .... mdsh -> md -> html
      #
      if [ "$1" = "-all" ] || [ "$1" = "-ALL" ];then
        source_file="$mdshfile"
        html_file="${mdshfile//.mdsh/.html}"
        [ "$1" = "-all" ] && source_file="${mdshfile//.mdsh/.md}"
        # update (rebuild) all posts pages
        echo "Updating: posts/$html_file"
        .app/create_page.sh "posts/$source_file" > "posts/$html_file"
      fi
    fi

  done

# update the homepage
echo "Updating: index.html"
post_title="Homepage" . .app/create_page.sh > index.html

# update the yearly indexe pages
for year in $(ls -1 posts)
do
  [ ! -d posts/$year ] && continue
  yearly_posts="$(list_posts_in_dir "$year")"
  [ "$yearly_posts" = "" ] && continue
  echo "Updating: posts/$year/index.html"
  touch posts/$year/index.html
  # build the page
  post_title="Posts from $year" \
    post_descr="Here's a list of blog posts written in $year" \
    post_url="$blog_url/posts/$year/index.html" \
    .app/create_page.sh "$yearly_posts" posts/$year/index.html

  # update monthly indexes
  for month in $(ls -1 posts/$year)
  do
    [ ! -d posts/$year/$month ] && continue
    monthly_posts="$(list_posts_in_dir "$year/$month" 2>/dev/null)"
    [ "$monthly_posts" = "" ] && continue
    month_name="$(date -d $year-$month-01 '+%B')"
    #
    echo "Updating: posts/$year/$month/index.html"
    touch posts/$year/$month/index.html
    # build the page
    post_title="Posts from ${month_name} $year" \
      post_descr="Here's a list of blog posts written in ${month_name} $year" \
      post_url="$blog_url/posts/$year/$month/index.html" \
      .app/create_page.sh "$monthly_posts" > posts/$year/$month/index.html
  done
done


# update 404 page
echo "Updating: 404.html"
body_html="$(cat .app/templates/html/_404.mustache | mo)"
# build the page
post_title="Page not found" \
  post_descr="The page you are looking for could not be found." \
  post_url="${blog_url}/404.html" \
  .app/create_page.sh "${body_html}" > 404.html


# update the archive page
all_posts="$(cut -f1,2 -d'|' ./posts.csv | grep -v "^#" | tr '|' '/' | sort -u | sort -r)"
if [ "$all_posts" != "" ];then
  echo "Updating: archive.html"
  echo -n '' > /tmp/itemlist
  touch archive.html
  classes="archive-posts posts"
  datetime=true
  ITEMS=()
  for item in $all_posts
  do
    item_title="'$(grep -m1 "|$(basename $item)|" posts.csv | grep -v "^#" | cut -f3 -d'|')'"
    item_date=$(dirname "$item" | tr '/' '-')
    item_date="${item_date//posts\//}"
    item_datetime="${item_date//\//-}"
    item_url="${blog_url}/posts/${item//.mdsh/.html}"
    item_file="posts/$item"
    [ ! -f "$item_file" ] && continue
    # update itemlist tmp file
    echo "${item_url}" >> /tmp/itemlist
    # set hash name
    hash_name="hash_${RANDOM}"
    # create the hash for the current page in the loop
    declare -A "$hash_name"
    eval $(add_keys_to_hash)
  done
  body_html="$(render _list)"
  # build the page
  post_title="Archive" \
    post_descr="Here's a list of all posts on this blog, listed newest to oldest." \
    post_url="$blog_url/archive.html" \
    .app/create_page.sh "$body_html" > archive.html
  # add archive page as posts/index.html  too)
  (cd posts &>/dev/null; ln -s ../archive.html index.html &>/dev/null)

fi


# update authors index page
echo "Updating: authors/index.html"
touch authors/index.html
# build page
post_title="Authors" \
  post_descr="Here's a list of authors who've written for this site." \
  post_url="$blog_url/authors/index.html" \
  .app/create_page.sh "$(list_authors)" > authors/index.html

# update authors pages
[ ! -d ./authors/ ] && mkdir ./authors/
all_authors="$(grep -v "^#" ./posts.csv | cut -f4 -d'|' | tr ',' '\n' | grep -v "^$" | sort -u)"
for author in $all_authors
do
  file="authors/$(.app/slugify.sh "$author").html"
  echo "Updating: $file"
  [ ! -f $file ] && touch $file
  # build the page
  post_title="Posts by $author" \
    post_descr="Here's a list of posts written by $author." \
    post_url="$blog_url/authors/${author}.html" \
    .app/create_page.sh "$(list_posts_by_author "$author")" > $file
done


# update categories index page
echo "Updating: categories/index.html"
touch categories/index.html
# build the page
post_title="Categories" \
  post_descr="Here's a list of posts categories" \
  post_url="$blog_url/categories/index.html" \
  .app/create_page.sh "$(list_categories)" > categories/index.html

# update category pages
category_posts=''
site_categories="$(grep -v "^#" ./posts.csv | cut -f5 -d'|' ./posts.csv | tr ',' '\n'| tr -d ' ' | sort -u)"
for category in $site_categories
do
  [ "$category" = "" ] && continue
  category_posts="$(list_posts_in_category "${category}")"
  [ "$category_posts" = "" ] && continue
  echo "Updating: categories/$category.html"
  touch categories/$category.html
  # build the page
  post_title="Posts in category '$category'" \
    post_descr="Here's a list of posts in the category '$category'" \
    post_url="$blog_url/categories/${category}.html" \
    .app/create_page.sh "$category_posts" > categories/$category.html
done



# update contact page
if [ "$blog_email" != "" ];then
  echo "Updating: contact.html"
  blog_email_safe="${blog_email//@/__ __}"
  body_html="$(cat .app/templates/html/_contact.mustache | mo)"
  # build the page
  post_title="Contact" \
    post_descr="Contact us to send a message, question, some feedback or whatever." \
    post_url="$blog_url/contact.html" \
    .app/create_page.sh "${body_html}" > contact.html
fi


# search page
echo "Updating: search.html"
search_results="$(list_search_results)"
# build the page
post_title="Search" \
  post_descr="Search this website for relevant post and articles" \
  post_url="$blog_url/search.html" \
  .app/create_page.sh "${search_results}" > search.html


# update tags index page
echo "Updating: tags/index.html"
touch tags/index.html
# build the page
post_title="Tags" \
  post_descr="Here's a list of all tags on the site, to help you find some relevant content." \
  post_url="$blog_url/tags/index.html" \
  .app/create_page.sh "$(list_tags)" > tags/index.html

# update tags pages
site_tags="$(grep -v "^#" ./posts.csv | cut -f6 -d'|' | tr ',' '\n'| tr -d ' ' | sort -u)"
for tag in $site_tags
do
  [ "$tag" = "" ] && continue
  tagged_posts="$(list_posts_matching_tag "$tag")"
  [ "$tagged_posts" = "" ] && continue
  echo "Updating: tags/$tag.html"
  touch tags/$tag.html
  # build the page
  post_title="Posts matching '$tag'" \
    post_descr="Here's a list of posts matching the tag '$tag'" \
    post_url="$blog_url/tags/${tag}.html" \
    .app/create_page.sh "$tagged_posts" > tags/$tag.html
done

# minify the HTML and CSS
echo
.app/minify.sh

echo
echo "Finished."

exit 0
