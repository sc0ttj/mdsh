#!/bin/bash

# minifies HTML and CSS files,  requires no arguments

# usage: minify [css-file]

# The script will then find all html and css files in the
# current dir (recursively) and replace them with minified
# versions

# load the local config file
[ -f .site_config ] && source .site_config

# get our google site fonts
if [ "$site_fonts" != "" ];then
  rm assets/css/google_fonts.css &>/dev/null
  curl "https://fonts.googleapis.com/css?family=${site_fonts}" 2>/dev/null > assets/css/google_fonts.css
fi

#
# define functions
#

function minify_css {
  # limit to the given css file (if any)
  local css_file_list="$css_files"
  if [ ! -z "$1" ] && [ "$css_file_to_minify" != "" ];then
    css_file_list="$css_file_to_minify"
  fi
  # limit to the given html file (if any)
  local html_file_list="$html_files"
  if [ ! -z "$2" ] && [ "$html_file_to_minify" != "" ];then
    html_file_list="$html_file_to_minify"
  fi

  # delete the file we will build
  rm assets/css/_core.min.css 2>/dev/null
  # add any CSS file starting with _ to a minified core CSS file,
  # which will be prepended to the CSS stylesheet we're generating
  #
  # /_*[^\.min].css       get css file starting with underscore, not minified
  # sort -r               list '__core.css' first
  #
  #  tr -d '\n'           remove new lines
  #  sed '/\/\*/,/\*\//d' remove comments
  #  sed...               remove spaces
  cat $(ls -1 assets/css/_*[^\.min].css | sort -r) \
    | grep -v '/\*' \
    | tr -d '\n' \
    | sed -e '/\/\*/,/\*\//d' \
          -e 's/  / /g' \
          -e 's/ {/{/g' \
          -e 's/{ /{/g' \
          -e 's/ }/}/g' \
          -e 's/: /:/g' \
          -e 's/; /;/g' > "assets/css/_core.min.css"

  for css_file in $css_file_list
  do
    css_bundle="assets/css/_core.min.css $css_file"

    # if a pygments file, we want to minify it, but not prepend the _*.css files
    [ "$(echo $css_file | grep '/pygments')" != "" ] && css_bundle="$css_file"
    # if a google fonts file, we want to minify it, but not prepend the _*.css files
    [ "$(echo $css_file | grep '/google_font')" != "" ] && css_bundle="$css_file"

    # create a minified version of our new CSS file
    #
    #  tr -d '\n'           remove new lines
    #  sed '/\/\*/,/\*\//d' remove comments
    #  ...                  remove spaces
    cat $css_bundle \
      | grep -v '/\*' \
      | tr -d '\n' \
      | sed -e '/\/\*/,/\*\//d' \
            -e 's/  / /g' \
            -e 's/ {/{/g' \
            -e 's/{ /{/g' \
            -e 's/ }/}/g' \
            -e 's/: /:/g' \
            -e 's/; /;/g' > "${css_file//.css/.min.css}"

    # add google fonts to css file (not including pygments themes)
    if [ "$(echo "${css_file//.css/.min.css}" | grep '/pygments')" = "" ] && \
       [ "$(echo "${css_file//.css/.min.css}" | grep '/google_font')" = "" ];then
      add_google_font_css_to "${css_file//.css/.min.css}"
    fi

    # for each html file
    for html_file in $html_file_list
    do
      # if the current $html_file uses the current $css_file
      contains_css_file="$(grep -q -m1 "${css_file}.css?v=" "$html_file")"
      contains_mincss_file="$(grep -q -m1 "${css_file}.min.css?v=" "$html_file")"
      contains_pygcss_file="$(grep -q -m1 "pygments-${page_code_stylesheet}.css?v=" "$html_file")"

      # used the minified pygments css file in $html_file
      if [ $contains_pygcss_file ];then
        sed -i "s|pygments-${page_code_stylesheet}.css?v=|pygments-${page_code_stylesheet}.min.css?v=|g" "$html_file"
      fi
      # skip $html_file if it uses a different stylesheet than $css_file
      if [ ! $contains_css_file ] && [ ! $contains_mincss_file ];then
        continue
      # else, used the minified $css_file in $html_file
      elif [ $contains_css_file ] && [ ! $contains_mincss_file ];then
        sed -i "s|${css_file}.css?v=|${css_file}.min.css?v=|g" "$html_file"
      fi
    done

  done
}


function add_google_font_css_to {
  local css_file="$1"
  css_file="${css_file//.min.css/}"
  css_file="${css_file//.css/}"
  css_file="${css_file:-main}"

  [ "$(echo "${css_file}" | grep '/pygments')" != "" ] && return
  [ "$(echo "${css_file}" | grep '/google_fonts')" != "" ] && return
  [ "$(echo "${css_file}" | grep '/inline')" != "" ] && return

  # get google fonts CSS, so we dont need to download it on page load
  if [ "${site_fonts}" != "" ] && [ -f assets/css/google_fonts.css ];then
    [ ! -f ${css_file}.min.css ] && css_file=assets/css/main.min.css
    cat assets/css/google_fonts.css \
      | grep -v '/\*' \
      | tr -d '\n' \
      | sed -e '/\/\*/,/\*\//d' \
            -e 's/  / /g' \
            -e 's/ {/{/g' \
            -e 's/{ /{/g' \
            -e 's/ }/}/g' \
            -e 's/: /:/g' \
            -e 's/; /;/g' > assets/css/google_fonts.min.css

    cat assets/css/google_fonts.min.css ${css_file}.min.css > /tmp/cssfile
    mv /tmp/cssfile ${css_file}.min.css
  fi
}


function minify_html {
  # temp fix to IFS, just in case the hmtl files contain spaces
  OLD_IFS=$IFS
  IFS="
  "
  for html_file in $html_files
  do
    :
    # dont minify HTML until we can skip contents of <pre>..</pre>
    #sed ':a;N;$!ba;/<div class="highlight"><pre>\.*<\/pre><\/div>/! s@>\s*<@><@g' $html_file > ${html_file//.html/.minhtml}
    #mv ${html_file//.html/.minhtml} ${html_file}
  done
  IFS=$OLD_IFS
}


###############################################################################

# get list of all css and html files we want to process
html_files="$(find assets/css/ -type f -name "*.html" | grep -v 'min.html' | sort -u | uniq)"
css_files="$(find  assets/css/ -type f -name "*.css"  | grep -vE '.min.css|/_' | sort -r)"

css_file_to_minify=''
[ ! -z "$1" ] && css_file_to_minify="$(echo  "$css_files"  | grep -m1 "/${1}")"

html_file_to_minify=''
[ ! -z "$2" ] && html_file_to_minify="$(echo "$html_files" | grep -m1 "/${2}")"

[ ! -f "$css_file_to_minify" ] && css_file_to_minify=""
[ ! -f "$html_file_to_minify" ] && html_file_to_minify=""

# minify CSS and add google font imports inline
echo "Minifying CSS.."
minify_css $css_file_to_minify $html_file_to_minify

# minify the HTML
#echo "Minifying HTML.."
minify_html

