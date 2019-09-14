#!/bin/bash

# minifies HTML and CSS files,  requires no arguments

# usage: minify [css-file]

# The script will then find all html and css files in the
# current dir (recursively) and replace them with minified
# versions

# load the local config file
[ -f .site_config ] && source .site_config

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

  for css_file in $css_file_list
  do
    minified_file="${css_file//.css/.min.css}";
    # create a minified version of our new CSS file
    grep -v '/\*' "$css_file" \
      | tr -d '\n' \
      | sed -e 's/  / /g' \
            -e 's/ {/{/g' \
            -e 's/{ /{/g' \
            -e 's/ }/}/g' \
            -e 's/: /:/g' \
            -e 's/; /;/g' > "$minified_file"

    add_google_font_css_to "$css_file"

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
  # get google fonts CSS, so we dont need to download it on page load
  if [ "${site_fonts}" != "" ];then
    if [ ! -f assets/css/google_fonts.css ];then
      curl "https://fonts.googleapis.com/css?family=${site_fonts}" 2>/dev/null > assets/css/google_fonts.css
      # create a minified version
      grep -v '/\*' assets/css/google_fonts.css \
        | tr -d '\n' \
        | sed -e 's/  / /g' \
              -e 's/ {/{/g' \
              -e 's/{ /{/g' \
              -e 's/ }/}/g' \
              -e 's/: /:/g' \
              -e 's/; /;/g' > assets/css/google_fonts.min.css
    fi
    [ ! -f assets/css/${css_file}.min.css ] && css_file='main'
    cat assets/css/google_fonts.min.css assets/css/${css_file}.min.css > /tmp/cssfile.min
    mv /tmp/cssfile.min assets/css/${css_file}.min.css
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
css_files="$(find  assets/css/ -type f -name "*.css"  | grep -v '.min.css' | sort -r)"
css_file_to_minify="$(echo  "$css_files"  | grep -m1 "/${1}")"
html_file_to_minify="$(echo "$html_files" | grep -m1 "/${2}")"

[ ! -f "$css_file_to_minify" ] && css_file_to_minify=""
[ ! -f "$html_file_to_minify" ] && html_file_to_minify=""

# minify CSS and add google font imports inline
echo "Minifying CSS.."
minify_css "$css_file_to_minify" "$html_file_to_minify"

# minify the HTML
#echo "Minifying HTML.."
minify_html

