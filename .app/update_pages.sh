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

# set some vars
partial_build=false
source_file=''
relevant_year=''
relevant_month=''
relevant_day=''
relevant_author=''
relevant_category=''
relevant_tags=''
relevant_author_filter=''
relevant_category_filter=''
previous_page=''

# clean up posts.csv
cp posts.csv /tmp/posts.csv
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
  fi
done


############################## functions ##################################

function rebuild_posts {
  cut -f1-2 -d'|' posts.csv | sort -r | head -${LIMIT:-99999} | while read line
  do
    mdshfile="${line//|//}"
    mdshfile="${mdshfile//#/}"
    if [ -f "posts/$mdshfile" ];then
      source_file="$mdshfile"
      html_file="${mdshfile//.mdsh/.html}"
      [ "$2" = "mdonly" ] && source_file="posts/${mdshfile//.mdsh/.md}"
      [ ! -f "posts/$source_file" ] && continue
      # update (rebuild) all posts pages
      echo "Updating: posts/$html_file"
      .app/create_page.sh "posts/$source_file" > "posts/$html_file"
    fi
  done
}

function rebuild_custom_pages {
  local pages="$(grep -v '^#' pages.csv | sort -u | sort -r)"
  local source_file page_dir page_source
  local IFS="
"
  for page in $pages
  do
    # get dir of page
    page_dir="$(echo "$page"      | cut -f1 -d'|')"
    page_dir="${page_dir:-.}"
    # get slug without extension
    page_source="$(echo "$page"   | cut -f2 -d'|')"
    page_source="${page_source//.html/}"
    page_source="${page_source//.mdsh/}"
    page_source="${page_source//.md/}"
    # get meta info
    page_title="$(echo "$page"    | cut -f3 -d'|')"
    page_html="$(echo "$page"   | cut -f4 -d'|')"
    page_slug="${page_html//.html/}"
    page_author="$(echo "$page"   | cut -f5 -d'|')"
    page_category="$(echo "$page" | cut -f6 -d'|')"
    page_keywords="$(echo "$page" | cut -f7 -d'|')"
    # set source file
    for file in "${page_source}.mdsh" "${page_source}.md"
    do
      [ -f "${page_dir}/${file}" ] && source_file="${page_dir}/${file}"
      [ -f "$source_file" ] && break
    done
    # build page
    echo "Updating: ${page_html}"
    page_title="$page_title"       \
    page_slug="$page_slug"         \
    page_author="$page_author"     \
    page_category="$page_category" \
    page_keywords="$page_keywords" \
      .app/create_page.sh "${source_file}" > "${page_dir}/${page_html}"
  done
}

function rebuild_homepage {
  echo "Updating: index.html"
  page_title="Homepage" .app/create_page.sh > index.html
}

function rebuild_monthly_indexes {
  local year="$1"
  # if no year given, assume current year
  [ -z "$year" ] && year="$(date +"%Y")"
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
}

function rebuild_yearly_indexes {
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

    [ "$1" != "only" ] && rebuild_monthly_indexes $year
  done
}

function rebuild_404_page {
  echo "Updating: 404.html"
  body_html="$(cat .app/templates/html/_404.mustache | mo)"
  # build the page
  page_title="Page not found" \
    page_slug="404" \
    page_descr="The page you are looking for could not be found." \
    page_url="${site_url}/404.html" \
    .app/create_page.sh "${body_html}" > 404.html
}

function rebuild_archive_page {
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
}

function rebuild_index_pages {
  for name in ${taxonomies[@]}
  do
    # get vars
    local name="${name//taxonomies_}"
    local taxonomy_name="$(lookup taxonomies.${name}.name)"
    local taxonomy_header="$(lookup taxonomies.${name}.header)"
    local taxonomy_plural=$(lookup "taxonomies.${name}.plural")
    local taxonomy_descr=$(lookup "taxonomies.${name}.descr")

    # get all items in taxonomy (example, each category in categories)
    local taxonomy_items="$(get_taxonomy_items "${taxonomy_name}")"
    [ -z "$taxonomy_items" ] && taxonomy_items="$(get_taxonomy_items "${taxonomy_plural}")"
    [ -z "$taxonomy_items" ] && return 1

    # build page
    file="${taxonomy_plural}/index.html"
    echo "Updating: $file"
    touch "$file"
    page_title="$(echo "${taxonomy_plural}" | titlecase)" \
      page_slug="${taxonomy_plural}" \
      page_descr="${taxonomy_descr}" \
      page_url="$site_url/$file" \
      .app/create_page.sh "$(render _$taxonomy_plural)" > "$file"

    OLD_IFS=$IFS
    local IFS=$'\n'
    for value in $taxonomy_items
    do
      # get all page info in matching taxonomy item
      # (where it matches $value, and is a specific category, author, etc)
      get_pages_in_taxonomy "$name" "$value"
      [ ${#ITEMS[@]} -lt 1 ] && continue
      local page_slug="$(echo "$value" | slugify)"
      local file="${taxonomy_plural}/${page_slug}.html"
      has_date=false
      # rebuild index of taxonomy item (categories/foo.html, etc)
      echo "Updating: $file"
      touch "$file"
      # build page
      page_title="${taxonomy_header} $value" \
        page_slug="${page_slug}" \
        page_descr="${taxonomy_descr}" \
        page_url="$site_url/${file}" \
        .app/create_page.sh "$(render _list)" > "$file"
    done
    IFS=$OLD_IFS
  done
}

function rebuild_author_index {
  echo "Updating: authors/index.html"
  touch authors/index.html
  # build page
  page_title="Authors" \
    page_slug="authors" \
    page_descr="Here's a list of authors who've written for this site." \
    page_url="$site_url/authors/index.html" \
    .app/create_page.sh "$(render _authors)" > authors/index.html
}


function rebuild_author_pages {
  [ ! -d ./authors/ ] && mkdir ./authors/
  for author_hash in ${site_authors[@]}
  do
    author="$(eval "echo \${$author_hash[title]}")"
    [ -z "$author" ] && continue
    # skip current author if not in $relevant_authors
    [ "$partial_build" = true ] && [ "__${author}__" != "__${relevant_author}__" ] && continue
    # else carry on
    author_slug="$(echo "$author" | slugify)"
    [ -z "$author_slug" ] && continue
    file="authors/${author_slug}.html"
    touch $file
    echo "Updating: $file"
    get_posts_by_author "$author"
    # build the page
    page_title="Posts by $author" \
      page_descr="Here's a list of posts written by $author." \
      page_url="$site_url/authors/${author}.html" \
      .app/create_page.sh "$(render _list)" > $file
  done
}

function rebuild_category_index {
  echo "Updating: categories/index.html"
  touch categories/index.html
  # build the page
  page_title="Categories" \
    page_slug="categories" \
    page_descr="Here's a list of posts categories" \
    page_url="$site_url/categories/index.html" \
    .app/create_page.sh "$(render _categories)" > categories/index.html
}


function rebuild_category_pages {
  for category_hash in ${site_categories[@]}
  do
    category="$(eval "echo \${$category_hash[title]}")"
    [ -z "$category"      ] && continue
    # skip current category if not in $relevant_categories
    [ "$partial_build" = true ] && [ "__${category}__" != "__${relevant_category}__" ] && continue
    # else carry on
    category_slug="$(echo "$category" | slugify)"
    [ -z "$category_slug" ] && continue
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
}


function rebuild_contact_page {
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
}


function rebuild_search_page {
  echo "Updating: search.html"
  touch search.html
  # build the page
  page_title="Search" \
    page_slug="search" \
    page_descr="Search this website for relevant post and articles (by title, description, category, tag)" \
    page_url="$site_url/search.html" \
    .app/create_page.sh "$(render _search_results)" > search.html
}


function rebuild_tag_index {
  echo "Updating: tags/index.html"
  touch tags/index.html
  # build the page
  page_title="Tags" \
    page_slug="tags" \
    page_descr="Here's a list of all tags on the site, to help you find some relevant content." \
    page_url="$site_url/tags/index.html" \
    .app/create_page.sh "$(render _tags)" > tags/index.html
}

function rebuild_tag_pages {
  # update tags pages
  for tag_hash in ${site_tags[@]}
  do
    tag="$(eval "echo \${$tag_hash[title]}")"
    [ "$tag" = "" ] && continue
    # if doing a partial rebuild, skip current tag if not in $page_tags
    [ "$partial_build" = true ] && [ "__${tag}__" != "__${relevant_tag}__" ] && continue
    tag_slug="$(echo "$tag" | slugify)"
    [ -z "$tag_slug" ] && continue
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
}


function rebuild_indexes_of_page {
  # we have a source file, so lets do a partial rebuild, which skips
  # rebuilding pages that haven't changed.
  local source_file="${1//.html}"
  source_file="${source_file//.mdsh}"
  source_file="${source_file//.md}"
  source_file="${source_file}.mdsh"

  function get_vars {
  	local IFS="$1"
  	shift
  	read $@
  }

  # lets filter our all the irrelevant years, months, tags, categories
  # before we rebuild our pages - so we dont have to rebuild any pages
  # which haven't actually changed
	while get_vars "/" dir relevant_year relevant_month relevant_day ; do
    [ ! -f "$source_file" ] && continue
    relevant_author="$(grep -m1 '^author: '     "$source_file" | sed -e 's/.*: //' -e 's/^ *//')"
    relevant_category="$(grep -m1 '^category: ' "$source_file" | sed -e 's/.*: //' -e 's/,.*//' -e 's/^ *//' -e 's/ *$//')"
    relevant_tags="$(grep -m1 '^tags: '         "$source_file" | sed -e 's/.*: //' -e 's/^ *//' -e 's/,/ /g' -e 's/  / /g')"

    # fix page day = cut off "/<somefile>.mdsh" (trailing filename)
    relevant_day="${relevant_day//\/*/}"

    # set some filters to filter out irrelevant tags, categories, etc
    # during our partial rebuilds
    relevant_author_filter="grep $relevant_author"
    relevant_category_filter="grep $relevant_category"

    # we have to write these vars to a file, cos we're in a sub-shell
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

  # out ofthe sub-shell, lets get the posts meta info we just processed
  source /tmp/relevant_meta_details
  rm     /tmp/relevant_meta_details

  # get the previous post
  previous_page="$(grep -v "^#" posts.csv | grep -B1 "$(basename "|$source_file|")" | head -1 | cut -f1,2 -d'|' | tr '|' '/')"

  # if a partial rebuild update the previous post, as it's prev/next links may have changed
  if [ -f "posts/$previous_page" ];then
    echo "Updating: posts/${previous_page//.mdsh/.html}"
    .app/create_page.sh "posts/${previous_page//.mdsh/.md}" > "posts/${previous_page//.mdsh/.html}"
  fi

  # finally, update all the relevant index pages (ignoring ones that don't list this post)
  rebuild authors:$relevant_author categories:$relevant_category tags:$relevant_tags archive search homepage
}

###############################################################################

# allow granular rebuilds - so users can build specifc parts
# of the site only, using commands in the following format:
#
# rebuild homepage            # rebuild index.html (the homepage)
#
# rebuild pages               # rebuild all custom pages
#
# rebuild posts               # rebuild all blog posts
#
# rebuild archive             # rebuild archive.html
#
# rebuild 404                 # rebuild 404.html
#
# rebuild search              # rebuild search.html
#
# rebuild authors             # rebuild all pages in authors/
#
# rebuild authors:foo,bar     # rebuild pages authors/foo.html and tags/bar.html
#
# rebuild categories          # rebuild all pages in categories/
#
# rebuild categories:foo,bar  # rebuild pages categories/foo.html and tags/bar.html
#
# rebuild tags                # rebuild all pages in tags/
#
# rebuild tags:foo,bar        # rebuild pages tags/foo.html and tags/bar.html
#
# rebuild years               # rebuild all posts/<years>/index.html index pages
#
# rebuild years:foo           # rebuild posts/foo/index.html specifically
#
# rebuild months 2019         # rebuild all monthly index pages in posts/2019/
#
# rebuild months:foo 2019     # rebuild posts/2019/foo/index.html specifically

# NOTE: the commands above can also be combined like so:
#
# rebuild tags:foo,bar year:2019 authors:someone search


# if $1 is a source file (passed in from create_post.sh)
if [ -f "${1//.mdsh}.mdsh" ];then
  partial_build=true
  source_file="${1//.mdsh}.mdsh"
  rebuild_indexes_of_page "$source_file"
fi

for option in $@
do
  case "$option" in
    '404')
      rebuild_404_page
      ;;
    archive)
      rebuild_archive_page
      ;;
    contact)
      rebuild_contact_page
      ;;
    homepage)
      rebuild_homepage
      ;;
    pages)
      rebuild_custom_pages
      ;;
    posts)
      rebuild_posts
      ;;
    rss)
      echo "Updating: feed.rss"
      .app/create_rss.sh posts/ > feed.rss
      exit
      ;;
    search)
      rebuild_search_page
      ;;
    sitemap)
      .app/generate_sitemap.sh
      exit
      ;;
    authors*|author*)
      authors_to_build="${option//\//:}"
      authors_to_build="${authors_to_build//*:/}"
      authors_to_build="${authors_to_build//,/ }"
      # build pages
      [ "$authors_to_build" = "authors" ] && rebuild_author_index
      for relevant_author in $authors_to_build
      do
        partial_build=true rebuild_author_pages
      done
    ;;
    categories*|category*)
      category_to_build="${option//*:/}"
      category_to_build="${category_to_build//,*/}"
      # build pages
      [ "$category_to_build" = "categories" ] && rebuild_author_index
      for relevant_category in $category_to_build
      do
        partial_build=true rebuild_category_pages
      done
    ;;
    tags*|tag*)
      tags_to_build="${option//\//:}"
      tags_to_build="${tags_to_build//*:/}"
      tags_to_build="${tags_to_build//,/ }"
      # build pages
      [ "$tags_to_build" = "tags" ] && rebuild_tag_index
      for relevant_tag in $tags_to_build
      do
        partial_build=true rebuild_tag_pages
      done
    ;;
    years*|year*)
      years_to_build="${option//*:}"
      years_to_build="${years_to_build//,/ }"
      [ "$years_to_build" = "years" ] && partial_build=false || partial_build=true
      for relevant_year in $years_to_build
      do
        partial_build=$partial_build rebuild_yearly_indexes only
      done
    ;;
    months*|month*)
      months_to_build="${option//*:}"
      months_to_build="${months_to_build//,/ }"
      [ "$months_to_build" = "months" ] && partial_build=false || partial_build=true
      for relevant_month in $months_to_build
      do
        partial_build=$partial_build rebuild_monthly_indexes ${2:-$(date +"%Y")}
      done
    ;;
  esac
done

if [ -z "$1" ] || [ "$1" = "all" ];then
  # rebuild all index pages
  partial_rebuild=false
  if [ "$1" = "all" ];then
    rebuild_custom_pages
    rebuild_posts
  fi
  rebuild_homepage
  rebuild_yearly_indexes
  rebuild_404_page
  rebuild_archive_page
  rebuild_author_index
  rebuild_author_pages
  rebuild_category_index
  rebuild_category_pages
  rebuild_contact_page
  rebuild_search_page
  rebuild_tag_index
  rebuild_tag_pages
fi


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
