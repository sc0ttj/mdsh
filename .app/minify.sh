#!/bin/bash

# minifies HTML and CSS files,  requires no arguments

# usage: minify

# The script will then find all html and css files in the
# current dir (recursively) and replace them with minified
# versions

# load the local config file
[ -f .site_config ] && source .site_config

# minify CSS
echo "Minifying CSS.."

# add google fonts CSS to main.min.css, so we dont need to include it separately
if [ "${blog_fonts}" != "" ];then
  if [ ! -f assets/css/google_fonts.css ];then
    curl "https://fonts.googleapis.com/css?family=${blog_fonts}" 2>/dev/null > assets/css/google_fonts.css
  fi
fi

css_files="$(find . -type f -name "*.css" | grep -v '.min.css' | sort -r)"
for css_file in $css_files
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
done

if [ "${blog_fonts}" != "" ];then
  echo "Adding Google Font CSS.."
  cat assets/css/google_fonts.min.css assets/css/main.min.css > /tmp/cssfile.min
  mv /tmp/cssfile.min assets/css/main.min.css
fi

# minify HTML
#echo "Minifying HTML.."

html_files="$(find . -type f -name "*.html" | grep -v 'min.html' | sort -u)"
for html_file in $html_files
do
  if [ "$(grep "main.min.css?v=" "$html_file")" = "" ];then
    sed -i "s|main.css?v=|main.min.css?v=|g" "$html_file"
  fi
  if [ "$(grep "pygments-${blog_code_highlight_theme}.min.css?v=" "$html_file")" = "" ];then
    sed -i "s|pygments-${blog_code_highlight_theme}.css?v=|pygments-${blog_code_highlight_theme}.min.css?v=|g" "$html_file"
  fi
  # dont minify HTML until we can skip contents of <pre>..</pre>
  #sed ':a;N;$!ba;/<div class="highlight"><pre>\.*<\/pre><\/div>/! s@>\s*<@><@g' $html_file > ${html_file//.html/.minhtml}
  #mv ${html_file//.html/.minhtml} ${html_file}
done


