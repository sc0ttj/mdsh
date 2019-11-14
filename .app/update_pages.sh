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
REBUILD_TYPE=${REBUILD_TYPE:-indexes}
partial_build=false
source_file=''
relevant_year=''
relevant_month=''
relevant_day=''
relevant_taxonomy=''
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

#function rebuild_posts_OLD {
#  cut -f1-2 -d'|' posts.csv | sort -r | head -${LIMIT:-99999} | while read line
#  do
#    mdshfile="${line//|//}"
#    mdshfile="${mdshfile//#/}"
#    if [ -f "posts/$mdshfile" ];then
#      source_file="$mdshfile"
#      html_file="${mdshfile//.mdsh/.html}"
#      [ "$2" = "mdonly" ] && source_file="posts/${mdshfile//.mdsh/.md}"
#      [ ! -f "posts/$source_file" ] && continue
#      # update (rebuild) all posts pages
#      echo "Updating: posts/$html_file"
#      .app/create_page.sh "posts/$source_file" > "posts/$html_file"
#    fi
#  done
#}

function rebuild_pages_of_type {
  local page_type="$(lookup page_types.${1}.plural)"
  [ -z "${page_type}" ] && return 1
  [ ! -f "${page_type}.csv" ] && return 1
  cut -f1-2 -d'|' ${page_type}.csv | sort -r | head -${LIMIT:-99999} | while read line
  do
    mdshfile="${line//|//}"
    mdshfile="${mdshfile//#/}"
    # skip current type if not in $relevant_item
    [ "$partial_build" = true ] && [ "__$(echo ${page_type} | slugify)__" != "__$(echo ${relevant_item} | slugify)__" ] && continue
    if [ -f "$page_type/$mdshfile" ];then
      source_file="$mdshfile"
      html_file="${mdshfile//.mdsh/.html}"
      [ "$2" = "mdonly" ] && source_file="$page_type/${mdshfile//.mdsh/.md}"
      [ ! -f "$page_type/$source_file" ] && continue
      # update (rebuild) all posts/pages
      echo "Updating: $page_type/$html_file"
      .app/create_page.sh "$page_type/$source_file" > "$page_type/$html_file"
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
    html_file="$(echo "$page"     | cut -f4 -d'|')"
    page_slug="${html_file//.html/}"
    page_author="$(echo "$page"   | cut -f5 -d'|')"
    page_category="$(echo "$page" | cut -f6 -d'|')"
    page_keywords="$(echo "$page" | cut -f7 -d'|')"
    # set source file
    for file in "${page_source}.mdsh" "${page_source}.md"
    do
      if [ -f "${page_dir}/${file}" ];then
        source_file="${page_dir}/${file}"
        break
      fi
    done
    # build page
    echo "Updating: ${html_file}"
    page_title="$page_title"       \
    page_slug="$page_slug"         \
    page_author="$page_author"     \
    page_category="$page_category" \
    page_keywords="$page_keywords" \
      .app/create_page.sh "${source_file}" > "${page_dir}/${html_file}"
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
  [ -z "$1" ] && return 1
  [ -z "$2" ] && return 1
  local page_type="$1"
  local taxonomy_name="$2"
  local taxonomy_item="$3"
  local taxonomies_list
  local file
  local page_slug
  local has_date

  # we need the plural version too
  page_type_plural="$(get_page_type_plural $page_type)"

  # limit the taxonomies we parse to the ones given by the user
  [ "$taxonomy_name" != '' ] && taxonomies_list="$taxonomy_name" || taxonomies_list="${taxonomies[@]}"
  [ -z "${taxonomies_list[@]}" ] && return 1

  # for each taxonomy we need to parse
  for taxonomy in ${taxonomies_list[@]}
  do
    # get vars
    local taxonomy="${taxonomy//taxonomies_}"
    local taxonomy_name="$(get_taxonomy_name "$taxonomy")"
    # if we still don't have it, skip it
    [ -z "$taxonomy_name" ] && continue

    local taxonomy_plural="$(get_taxonomy_plural "$taxonomy")"
    local taxonomy_descr="$(lookup "taxonomies.${taxonomy}.descr")"
    local taxonomy_items_header="$(lookup "taxonomies.${taxonomy}.items_header")"
    local taxonomy_items_descr="$(lookup "taxonomies.${taxonomy}.items_descr")"

    if [ "$partial_build" != true ];then
      # build page - (posts/authors/index.html)
      file="${page_type_plural}/${taxonomy_plural}/index.html"
      echo "Updating: $file"
      mkdir -p "${page_type_plural}/${taxonomy_plural}/"
      touch "$file"
      has_date=''
      page_title="$(echo "${taxonomy_plural}" | titlecase)" \
        page_descr="${taxonomy_descr}" \
        page_slug="${taxonomy_plural}" \
        page_url="$site_url/$file" \
        .app/create_page.sh "$(render _$taxonomy_plural)" > "$file"
    fi

    # build index item pages (posts/authors/bob.html, etc)

    # first, get all terms/items in current taxonomy:
    # for example. get all authors in "author"
    all_taxonomy_items="$(grep -hRE "^#? ?${taxonomy_name}:.*[, ]" ${page_type_plural}/*/*/*/*.mdsh \
      | sed 's/ .*  //g'\
      | cut -f2 -d':' \
      | tr ',' '\n' \
      | lstrip \
      | sort -u)"

#echo "\$all_taxonomy_items '$all_taxonomy_items'"

    # for each item in the current taxonomy group (for each author in authors),
    # create the index pages (which list the relevant pages/posts)
    OLD_IFS=$IFS
    local IFS=$'\n'
    for value in $all_taxonomy_items
    do
      page_slug="$(echo "$value" | slugify)"
      # get all pages and their info for current taxonomy group/item
      # (where it matches $value, and is a specific category, author, etc)
      get_pages_in_taxonomy "$page_type" "$taxonomy" "$page_slug"
      # skip if no pages in this taxonomy group
      [ ${#ITEMS[@]} -lt 1 ] && continue
      # we have items, so set some vars
      has_date=true
      file="${page_type_plural}/${taxonomy_plural}/${page_slug}.html"
      # build page
      echo "Updating: $file"
      mkdir -p "${page_type_plural}/${taxonomy_plural}/"
      touch "$file"
      page_title="${taxonomy_items_header} $value" \
        page_descr="${taxonomy_items_descr} $value" \
        page_slug="${page_slug}" \
        page_url="$site_url/${file}" \
        .app/create_page.sh "$(render _list)" > "$file"
    done
    IFS=$OLD_IFS
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


function rebuild_indexes_of_page {
  # we have a source file, so lets do a partial rebuild, which skips
  # rebuilding pages that haven't changed.
  local source_file="${1//.html}"
  source_file="${source_file//.mdsh}"
  source_file="${source_file//.md}"
  source_file="${source_file}.mdsh"
  rm /tmp/relevant_taxonomies &>/dev/null

  function get_vars {
  	local IFS="$1"
  	shift
  	read $@
  }

  # lets filter our all the irrelevant years, months, tags, categories
  # before we rebuild our pages - so we dont have to rebuild any pages
  # which haven't actually changed
	while get_vars "/" page_type relevant_year relevant_month relevant_day ; do
    [ ! -f "$source_file" ] && continue
    # fix page day = cut off "/<somefile>.mdsh" (trailing filename)
    relevant_day="${relevant_day//\/*/}"
    # we have to write these vars to a file, cos we're in a sub-shell
    echo "page_type=$page_type"            > /tmp/relevant_meta_details
    echo "relevant_year=$relevant_year"   >> /tmp/relevant_meta_details
    echo "relevant_month=$relevant_month" >> /tmp/relevant_meta_details
    echo "relevant_day=$relevant_day"     >> /tmp/relevant_meta_details

    for taxonomy in $(get_taxonomies)
    do
      relevant_item="$(grep -m1 "^${taxonomy}: " "$source_file" | sed -e "s/.*: //" -e "s/^ *//" -e "s/, /,/g")"
      echo -n "${page_type}:${taxonomy}:${relevant_item} " >> /tmp/relevant_taxonomies
    done
	done <<< "$source_file"

  # out of the sub-shell, lets get the posts meta info we just processed
  source /tmp/relevant_meta_details
  rm     /tmp/relevant_meta_details

  if [ "$page_type" = "posts" ];then
    # get the previous post
    previous_page="$(grep -v "^#" posts.csv \
      | grep -B1 "$(basename "|$source_file|")" \
      | head -1 \
      | cut -f1,2 -d'|' \
      | tr '|' '/')"

    # if a partial rebuild update the previous post, as it's prev/next links may have changed
    if [ -f "posts/$previous_page" ];then
      echo "Updating: posts/${previous_page//.mdsh/.html}"
      .app/create_page.sh "posts/${previous_page//.mdsh/.md}" > "posts/${previous_page//.mdsh/.html}"
    fi
  fi

  # finally, update all the relevant index pages (ignoring ones that don't list this post)
  reindex $(cat /tmp/relevant_taxonomies) archive search homepage
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

# get page types as case-friendly list ( like "foo|bar")
page_types="$(lookup page_types.* \
  | sed 's/page_types_//g' \
  | tr ' ' '\n' \
  | while read t; do \
    echo -n "${t//page_types_/}|" && lookup taxonomies.${t//page_types_/}.plural; \
  done \
  | tr '\n' '|' \
  | sed \
    -e 's/|/*|/g' \
    -e 's/^|//g' \
    -e 's/|$//g')"

# get taxonomies as case-friendly list ( like "foo|bar")
site_taxonomies="$(echo ${taxonomies[@]} \
  | tr ' ' '\n' \
  | while read t; do \
    echo -n "${t//taxonomies_/}|" && lookup taxonomies.${t//taxonomies_/}.plural; \
  done \
  | tr '\n' '|' \
  | sed \
    -e 's/|/*|/g' \
    -e 's/^|//g' \
    -e 's/|$//g')"

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
      rebuild_page_of_type posts
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
    'posts:years'*|'posts:year'*|years*|year*)
      years_to_build="${option//*:}"
      years_to_build="${years_to_build//,/ }"
      [ "$years_to_build" = "years" ] && partial_build=false || partial_build=true
      for relevant_year in $years_to_build
      do
        partial_build=$partial_build rebuild_yearly_indexes only
      done
    ;;
    'posts:months'*|'posts:month'*|months*|month*)
      months_to_build="${option//*:}"
      months_to_build="${months_to_build//,/ }"
      [ "$months_to_build" = "months" ] && partial_build=false || partial_build=true
      for relevant_month in $months_to_build
      do
        partial_build=$partial_build rebuild_monthly_indexes ${2:-$(date +"%Y")}
      done
    ;;
    *)
      # $item might be a page_type or taxonomy
      item="$(echo "$option" | tr '/' ':' | cut -f1 -d':')"

      # get list of given page types or taxonomies to build
      pages_to_build="${option//\//:}"
      pages_to_build="${pages_to_build//*:/}"
      pages_to_build="${pages_to_build//,/ }"

      # check if processing page types
      option_is_valid_page_type="$(echo "${item}" | grep -Eq "$page_types" && echo true || echo false)"

      # if launched by `rebuild  command, we will rebuild the matching pages
      rebuild_func='rebuild_pages_of_type'
      if [ "$REBUILD_TYPE" = "indexes" ];then
        # else, rebuild the index pages of given items,
        # not the pages themselves
        rebuild_func='rebuild_index_pages'
      fi

      # If $option is a page_type, we will rebuild pages
      # matching the given page type
      if [ "$option_is_valid_page_type" = true ];then
        # if only given a page type
        if [ "${pages_to_build}" = "${option}" ];then
          $rebuild_func "$item"
        else
          # else, user did NOT give a page type only, so get the
          # page type and taxonomies stuff
          page_type="$(echo "$option" | cut -f1 -d':')"
          taxonomy_name="$(echo "$option" | cut -f2 -d':')"
          taxonomy_values="$(echo "$option" | cut -f3 -d':')"

          # check if processing a valid taxonomy (if not, skip it)
          option_is_valid_taxonomy="$(echo "${taxonomy_name}" | grep -Eq "$site_taxonomies" && echo true || echo false)"

          # If option is a taxonomy name, rebuild the relevant index pages
          if [ "$option_is_valid_taxonomy" = true ];then
            # at this point, $pages_to_build is a list of taxonomies [and items]
            for relevant_item in $pages_to_build
            do
              # if user gave a taxonomy name only
              if [ "$taxonomy_name" = "$relevant_item" ];then
                partial_build=true $rebuild_func "$page_type" $taxonomy_name
              else
                # if user gave a taxonomy name and taxonomy item (brand:somebrand)
                partial_build=true $rebuild_func "$page_type" $taxonomy_name $relevant_item
              fi
            done
          fi
        fi
      fi
    ;;
  esac
done

if [ -z "$1" ] || [ "$1" = "all" ];then
  # rebuild all index pages
  partial_rebuild=false
  if [ "$1" = "all" ];then
    rebuild_custom_pages
    for page_type in $(get_page_types)
    do
      rebuild_pages_of_type $page_type
    done
  fi
  rebuild_homepage
  rebuild_yearly_indexes
  rebuild_404_page
  rebuild_archive_page
  rebuild_contact_page
  rebuild_search_page
  rebuild_index_pages
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
