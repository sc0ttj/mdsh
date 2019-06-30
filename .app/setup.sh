#!/bin/bash

# dirs
# shared site assets
mkdir -p ./assets/{css,icons,img,js}
# authors pages
mkdir -p ./authors/
# categories pages
mkdir -p ./categories/
# tags pages
mkdir -p ./tags/

# colours
yellow="\033[38;5;3m"
nc="\033[0m"

# site defaults
blog_title="mdsh"
blog_language="en"
blog_descr="mdsh - a simple static site generator for modern websites, written in Bash."
blog_keywords="mdsh, static site generator, project page, open source, blog, news, feed"
blog_categories="blog, bash, shell, javascript, css, programming, puppy linux, test, games"
blog_domain="<USERNAME>.github.io"
blog_url="/mdsh" # no trailing slash
blog_author="YOUR NAME"
blog_email="foo@bar.com"
blog_twitter="@foobar"
blog_fonts='Ubuntu:400,400i,700|Inconsolata:400,400i,700|Monaco:400,400i,700&subset=latin,latin-ext'
blog_js_deps="cash-dom@2.3.9/dist/cash.min.js jets@0.14.1/jets.min.js"
blog_google_analytics_id=""
blog_code_highlight_theme="monokai"
blog_footer="© ${blog_title} $(date -u +"%Y"). Powered by <a href=\"https://sc0ttj.github.io/mdsh/\">mdsh</a>"

# let user set site info
echo
read -e -i "$blog_title" -p "Enter a blog name:  " blog_title
echo
read -e -i "$blog_language" -p "Enter a blog language (en, de, etc):  " blog_language
echo
read -e -i "$blog_descr" -p "Enter a blog description (~ 80 words):  " blog_descr
echo
read -e -i "$blog_keywords" -p "Enter some blog keywords (comma separated):  " blog_keywords
echo
read -e -i "$blog_categories" -p "Enter some blog categories (comma separated):  " blog_categories
echo
read -e -i "$blog_domain" -p "Enter the blog domain:  " blog_domain
echo
read -e -i "$blog_url" -p "Enter the blog url (no trailing slash):  " blog_url
echo
read -e -i "$blog_author" -p "Enter the blog author (name or username):  " blog_author
echo
read -e -i "$blog_email" -p "Enter the blog authors email:  " blog_email
echo
read -e -i "$blog_twitter" -p "Enter the blog authors twitter handle:  " blog_twitter
echo
read -e -i "$blog_fonts" -p "Enter the Google fonts to use (blank for none):  " blog_fonts
echo
read -e -i "$blog_js_deps" -p "Enter the JS deps (space separated NPM package names):  " blog_js_deps
echo
read -e -i "$blog_code_highlight_theme" -p "Enter the code syntax highlighter theme (requires Pygments):  " blog_code_highlight_theme
echo
read -e -i "$blog_google_analytics_id" -p "Enter your Google Analytics ID (blank for none):  " blog_google_analytics_id


#
# write site info to .site_config
#

echo "##################################################################

# site defaults

blog_title=\"$blog_title\"
blog_language=\"$blog_language\"
blog_descr=\"$blog_descr\"
blog_keywords=\"$blog_keywords\"
blog_categories=\"$blog_categories\"
blog_domain=\"$blog_domain\"
blog_url=\"$blog_url\" # no trailing slash
blog_author=\"$blog_author\"
blog_email=\"$blog_email\"
blog_twitter=\"$blog_twitter\"
blog_fonts='$blog_fonts'
blog_js_deps=\"$blog_js_deps\"
blog_google_analytics_id=\"\"
blog_code_highlight_theme=\"$blog_code_highlight_theme\"
blog_footer=\"© \${blog_title} \$(date -u +\"%Y\"). Powered by <a href=\"https://sc0ttj.github.io/mdsh/\">mdsh</a>\"

##################################################################

source .app/cli-interface
" > .site_config

echo
echo
echo -e "Success: File ${yellow}.site_config updated."