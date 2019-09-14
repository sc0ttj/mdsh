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

# set some site defaults
site_title="mdsh"
site_language="en"
site_descr="mdsh - a simple static site generator for modern websites, written in Bash."
site_keywords="mdsh, static site generator, project page, open source, blog, news, feed"
site_domain="<USERNAME>.github.io"
site_url="/mdsh" # no trailing slash
site_author="YOUR NAME"
site_email="foo@bar.com"
site_twitter="@foobar"
site_fonts='Ubuntu:400,400i,700|Inconsolata:400,400i,700|Monaco:400,400i,700&subset=latin,latin-ext'
site_js_deps="cash-dom@2.3.9/dist/cash.min.js jets@0.14.1/jets.min.js"
site_google_analytics_id=""
site_code_stylesheet="monokai"
site_search_enabled=true

# let user set site info
echo
read -e -i "$site_title" -p "Enter a blog name:  " site_title
echo
read -e -i "$site_language" -p "Enter a blog language (en, de, etc):  " site_language
echo
read -e -i "$site_descr" -p "Enter a blog description (~ 80 words):  " site_descr
echo
read -e -i "$site_keywords" -p "Enter some blog keywords (comma separated):  " site_keywords
echo
read -e -i "$site_domain" -p "Enter the blog domain:  " site_domain
echo
read -e -i "$site_url" -p "Enter the blog url (no trailing slash):  " site_url
echo
read -e -i "$site_author" -p "Enter the blog author (name or username):  " site_author
echo
read -e -i "$site_email" -p "Enter the blog authors email:  " site_email
echo
read -e -i "$site_twitter" -p "Enter the blog authors twitter handle:  " site_twitter
echo
read -e -i "$site_fonts" -p "Enter the Google fonts to use (blank for none):  " site_fonts
echo
read -e -i "$site_js_deps" -p "Enter the JS deps (space separated NPM package names):  " site_js_deps
echo
read -e -i "$site_code_stylesheet" -p "Enter the code syntax highlighter theme (requires Pygments):  " site_code_stylesheet
echo
read -e -i "$site_google_analytics_id" -p "Enter your Google Analytics ID (blank for none):  " site_google_analytics_id


#
# write site info to assets/data/site.yml

# Note:
# Any values containing spaces, pipe chars and colons
# must be wrapped in single quotes

echo "site_title: '$site_title'
site_language: $site_language
site_descr: '$site_descr'
site_keywords: '$site_keywords'
site_domain: $site_domain
site_url: $site_url
site_author: $site_author
site_email: $site_email
site_twitter: $site_twitter
site_fonts: '$site_fonts'
site_google_analytics_id: $site_google_analytics_id
site_code_stylesheet: $site_code_stylesheet
search_enabled: $site_search_enabled
header_pages:
  link1:
    title: About
    url: $site_url/about.html
  link2:
    title: Archive
    url: $site_url/archive.html
  link3:
    title: Contact
    url: $site_url/contact.html
  link4:
    title: Search
    url: $site_url/search.html
analytics_id:
css: assets/css/main.css
js_deps:
  cashjs: cash-dom@2.3.9/dist/cash.min.js
  jets: jets@0.14.1/jets.min.js
js: assets/js/app.js
" > assets/data/site.yml

source .app/cli-interface

echo
echo
echo -e "Success: Site config updated."
