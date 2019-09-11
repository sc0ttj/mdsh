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

# if $1 is a .mdsh file, then we will get the author, category, tags (etc)
# of that post, and only rebuild the relevant index pages.

# remove cached template output from lasdt build
rm /tmp/_site_*.html &>/dev/null

# load the local config file
[ -f .site_config ] && source .site_config

# clean up posts.csv (remove any entries that have missing files)
cp posts.csv /tmp/posts.csv

source_file=''
partial_build=false
# if $1 is a source file (mdsh)
if [ -f "${1//.mdsh}.mdsh" ];then
  # we have a source file, so lets do a partial rebuild, which skips
  # rebuilding pages that haven't changed.
  partial_build=true
  source_file="${1//.mdsh}.mdsh"
  relevant_year=''
  relevant_month=''
  relevant_day=''
  relevant_author=''
  relevant_category=''
  relevant_tags=''
  relevant_author_filter="" # no filter by default
  relevant_category_filter="" # no filter by default
  previous_page=""


  get_vars(){
  	local IFS="$1"
  	shift
  	read $@
  }

  # lets filter our all the irrelevant years, months, tags, categories
  # before we rebuild our pages - so we dont have to rebuild any pages
  # which haven't actually changed
	while get_vars "/" dir relevant_year relevant_month relevant_day ; do
    [ ! -f "$source_file" ] && continue
    relevant_author="$(grep -m1 'author: '     "$source_file" | sed -e 's/.*: //' -e 's/^ *//')"
    relevant_category="$(grep -m1 'category: ' "$source_file" | sed -e 's/.*: //' -e 's/,.*//' -e 's/^ *//' -e 's/ *$//')"
    relevant_tags="$(grep -m1 'tags: '         "$source_file" | sed -e 's/.*: //' -e 's/^ *//' -e 's/,/ /g' -e 's/  / /g')"

    # fix page day = cut off "/<somefile>.mdsh" (trailing filename)
    relevant_day="${relevant_day//\/*/}"

    # set some filters to filter out irrelevant tags, categories, etc
    # during our partial rebuilds
    relevant_author_filter="grep $relevant_author"
    relevant_category_filter="grep $relevant_category"

    echo "relevant_year=$relevant_year"                            > /tmp/relevant_meta_details
    echo "relevant_month=$relevant_month"                         >> /tmp/relevant_meta_details
    echo "relevant_day=$relevant_day"                             >> /tmp/relevant_meta_details
    echo "relevant_author=$relevant_author"                       >> /tmp/relevant_meta_details
    echo "relevant_category=$relevant_category"                   >> /tmp/relevant_meta_details
    echo "relevant_tags='$relevant_tags'"                         >> /tmp/relevant_meta_details
    echo "relevant_author_filter=\"$relevant_author_filter\""     >> /tmp/relevant_meta_details
    echo "relevant_category_filter=\"$relevant_category_filter\"" >> /tmp/relevant_meta_details
	  #break # we just need to test 1 line
	done <<< "$source_file"

  # get the posts meta info we just processed
  source /tmp/relevant_meta_details

  # get the previous post
  previous_page="$(grep -v "^#" posts.csv | grep -B1 "$(basename "|$source_file|")" | head -1 | cut -f1,2 -d'|' | tr '|' '/')"

  # if a partial rebuild update the previous post, as it's prev/next links may have changed
  if [ -f "posts/$previous_page" ];then
    echo "Updating: posts/${previous_page//.mdsh/.html}"
    .app/create_page.sh "posts/${previous_page//.mdsh/.md}" > "posts/${previous_page//.mdsh/.html}"
  fi

fi


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
page_title="Homepage" .app/create_page.sh > index.html

# update the relevant yearly index pages
for year in $(ls -1 posts/)
do
  [ ! -d posts/$year ] && continue
  # if a partial build, skip irrelevant years
  [ "$partial_build" = true ] && [ "$year" != "$relevant_year" ] && continue
  yearly_posts="$(list_posts_in_dir "$year")"
  [ "$yearly_posts" = "" ] && continue
  echo "Updating: posts/$year/index.html"
  touch posts/$year/index.html
  # build the page
  page_title="Posts from $year" \
    page_descr="Here's a list of blog posts written in $year" \
    page_url="$site_url/posts/$year/index.html" \
    .app/create_page.sh "$yearly_posts" posts/$year/index.html

  # update monthly indexes
  for month in $(ls -1 posts/$year/)
  do
    [ ! -d posts/$year/$month ] && continue
    # if a partial build, skip irrelevant months
    [ "$partial_build" = true ] && [ "$month" != "$relevant_month" ] && continue
    monthly_posts="$(list_posts_in_dir "$year/$month" 2>/dev/null)"
    [ "$monthly_posts" = "" ] && continue
    month_name="$(date -d $year-$month-01 '+%B')"
    #
    echo "Updating: posts/$year/$month/index.html"
    touch posts/$year/$month/index.html
    # build the page
    page_title="Posts from ${month_name} $year" \
      page_descr="Here's a list of blog posts written in ${month_name} $year" \
      page_url="$site_url/posts/$year/$month/index.html" \
      .app/create_page.sh "$monthly_posts" > posts/$year/$month/index.html
  done
done


# update 404 page
echo "Updating: 404.html"
body_html="$(cat .app/templates/html/_404.mustache | mo)"
# build the page
page_title="Page not found" \
  page_slug="404" \
  page_descr="The page you are looking for could not be found." \
  page_url="${site_url}/404.html" \
  .app/create_page.sh "${body_html}" > 404.html


# update the archive page
echo "Updating: archive.html"
touch archive.html
# build the page
page_title="Archive" \
  page_slug="archive" \
  page_descr="Here's a list of all posts on this blog, listed newest to oldest." \
  page_url="$site_url/archive.html" \
  .app/create_page.sh "$(render _archive)" > archive.html
# add archive page as posts/index.html  too)
(cd posts &>/dev/null && ln -s ../archive.html index.html &>/dev/null)


echo "Updating: authors/index.html"
touch authors/index.html
# get the data (put into ITEMS)
# build page
page_title="Authors" \
  page_slug="authors" \
  page_descr="Here's a list of authors who've written for this site." \
  page_url="$site_url/authors/index.html" \
  .app/create_page.sh "$(render _authors)" > authors/index.html


# update authors pages
[ ! -d ./authors/ ] && mkdir ./authors/
for author_hash in ${site_authors[@]}
do
  author="$(eval "echo \${$author_hash[title]}")"
  author_slug="$(echo "$author" | slugify)"
  [ -z "$author"      ] && continue
  [ -z "$author_slug" ] && continue
  # skip current author if not in $relevant_authors
  [ "$partial_build" = true ] && [ "$(echo "${relevant_author}" | grep "$author")" = "" ] && continue
  # else carry on
  file="authors/${author_slug}.html"
  touch $file
  echo "Updating: $file"
  # get the data (put into ITEMS)
  get_posts_by_author "$author"
  # build the page
  page_title="Posts by $author" \
    page_descr="Here's a list of posts written by $author." \
    page_url="$site_url/authors/${author}.html" \
    .app/create_page.sh "$(render _list)" > $file
done


# update categories index page
echo "Updating: categories/index.html"
touch categories/index.html
# build the page
page_title="Categories" \
  page_slug="categories" \
  page_descr="Here's a list of posts categories" \
  page_url="$site_url/categories/index.html" \
  .app/create_page.sh "$(render _categories)" > categories/index.html


# update each category index page
for category_hash in ${site_categories[@]}
do
  category="$(eval "echo \${$category_hash[title]}")"
  category_slug="$(echo "$category" | slugify)"
  [ -z "$category"      ] && continue
  [ -z "$category_slug" ] && continue
  # skip current category if not in $relevant_categories
  [ "$partial_build" = true ] && [ "$(echo "${relevant_category}" | grep "$category")" = "" ] && continue
  # else carry on
  file="categories/${category_slug}.html"
  touch $file
  echo "Updating: $file"
  # get the data (put into ITEMS)
  get_posts_in_category "$category"
  # build the page
  page_title="Posts in category '$category'" \
    page_descr="Here's a list of posts in the category '$category'" \
    page_url="$site_url/categories/${category}.html" \
    .app/create_page.sh "$(render _list)" > categories/$category.html
done


# update contact page
if [ "$site_email" != "" ];then
  echo "Updating: contact.html"
  site_email_safe="${site_email//@/__ __}"
  body_html="$(cat .app/templates/html/_contact.mustache | mo)"
  # build the page
  page_title="Contact" \
    page_slug="contact" \
    page_descr="Contact us to send a message, question, some feedback or whatever." \
    page_url="$site_url/contact.html" \
    .app/create_page.sh "${body_html}" > contact.html
fi


# search page
echo "Updating: search.html"
# build the page
page_title="Search" \
  page_slug="search" \
  page_descr="Search this website for relevant post and articles (by title, description, category, tag)" \
  page_url="$site_url/search.html" \
  .app/create_page.sh "$(render _search_results)" > search.html

# update tags index page
echo "Updating: tags/index.html"
touch tags/index.html
# build the page
page_title="Tags" \
  page_slug="tags" \
  page_descr="Here's a list of all tags on the site, to help you find some relevant content." \
  page_url="$site_url/tags/index.html" \
  .app/create_page.sh "$(render _tags)" > tags/index.html


# update tags pages
for tag_hash in ${site_tags[@]}
do
  tag="$(eval "echo \${$tag_hash[title]}")"
  [ "$tag" = "" ] && continue
  tag_slug="$(echo "$tag" | slugify)"
  [ -z "$tag"      ] && continue
  [ -z "$tag_slug" ] && continue
  # if doing a partial rebuild, skip current tag if not in $page_tags
  [ "$partial_build" = true ] && [ "$(echo " ${relevant_tags} " | grep " $tag ")" = "" ] && continue
  # else carry on
  echo "Updating: tags/${tag_slug}.html"
  touch tags/$tag_slug.html
  # get the data (put into ITEMS)
  get_posts_matching_tag "$tag"
  # build the page
  page_title="Posts tagged '$tag'" \
    page_descr="Here's a list of posts matching the tag '$tag'" \
    page_url="$site_url/tags/${tag}.html" \
    .app/create_page.sh "$(render _list)" > tags/$tag.html
done


# minify the HTML and CSS
echo
.app/minify.sh

# remove tmp and cache files
rm /tmp/_site_*.html &>/dev/null
rm /tmp/page_meta_details &>/dev/null
rm /tmp/all_site_data &>/dev/null

unset source_file
unset previous_page

echo
echo "Finished."

exit 0
