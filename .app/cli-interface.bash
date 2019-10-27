# define the command-line interface (CLI)

# mo must be in $PATH to work, so add its parent dir to $PATH, if needed
if [ "$(echo $PATH | grep '.app/functions')" = "" ];then
  export PATH=$PATH:.app/functions
fi

# source functions used by mdsh
libs="
.app/functions/mdsh_functions.bash
.app/functions/liquid_filters.bash
.app/functions/yay
.app/functions/mo
.app/functions/mo-addons.bash
.app/functions/generate_page_data.bash
.app/functions/generate_site_data.bash
.app/functions/generate_page_content.bash
"
for script in $libs
do
  [ ! -z "$script" ] && [ -f "$script" ] && source "$script"
done

oembed_filters="$(get_oembed_filters)"

# define CLI below

# new:   create a new page or post, follow the on-screen
#        instructions to choose title, description, etc
#
# Usage: new <post|page>
#
function new {
  [ "$1" != "page" ] && [ "$1" != "post" ] && return 1
  ${PWD}/.app/create_${1}.sh $2 $3 $4 $5
}

# rebuild: Rebuild an HTML file from its source file. The source
#          file should be a .mdsh or .md file.
#
# Usage:   rebuild path/to/file.md[sh] [> path/to/file.html]
#
function rebuild {
  if [ -f "$1" ];then
    ${PWD}/.app/create_page.sh $1 $2
    return 0
  fi
  # $1 might be a parameter, like 'tags', 'year:2019', 'authors:foo,bar', '-all', ...
  ${PWD}/.app/update_pages.sh $@
}

function help {
  echo
  echo "Available commands:"
  echo
  echo "  setup                            # set site defaults, settings and options"
  echo
  echo "  server [start|stop]              # start/stop a local web server"
  echo
  echo "  new post                         # create a new post or page, using default site settings"
  echo
  echo "  new post -all                    # create a new post or page, asks to override various site settings"
  echo
  echo "  new page "file.md" > file.html     # create a page from a Markdown file"
  echo
  echo "  new page "file.mdsh" > file.html   # create a page from a .mdsh file"
  echo
  echo "  new page \"\$html\" > file.html     # create a page from an HTML string"
  echo
  echo "  rebuild                          # rebuild all index pages (authors, categories, tags, etc)"
  echo
  echo "  rebuild -all                     # re-build all posts from their Markdown files"
  echo
  echo "  rebuild -ALL                     # re-build all posts from their .mdsh files"
  echo
  echo "  rebuild file.md file.html        # build a specific page"
  echo
  echo "  rebuild file.mdsh file.html      # re-build a specific page from a .mdsh file"
  echo
  echo "  rebuild homepage                 # re-build the main index.html file"
  echo
  echo "  rebuild rss                      # re-build and update the RSS feed (feed.rss)"
  echo
  echo "  rebuild sitemap                  # re-build and update sitemap.xml"
  echo
  echo "  rebuild 404                      # re-build 404.html"
  echo
  echo "  rebuild search                   # re-build search.html"
  echo
  echo "  rebuild authors                  # re-build all pages in authors/"
  echo
  echo "  rebuild authors:foo,bar          # re-build pages authors/foo.html and tags/bar.html"
  echo
  echo "  rebuild categories               # re-build all pages in categories/"
  echo
  echo "  rebuild categories:foo,bar       # re-build pages categories/foo.html and tags/bar.html"
  echo
  echo "  rebuild tags                     # re-build all pages in tags/"
  echo
  echo "  rebuild tags:foo,bar             # re-build pages tags/foo.html and tags/bar.html"
  echo
  echo "  rebuild years                    # re-build all posts/<years>/index.html index pages"
  echo
  echo "  rebuild years:foo                # re-build posts/foo/index.html specifically"
  echo
  echo "  rebuild months <year>            # re-build all monthly index pages in posts/<year>/"
  echo
  echo "  rebuild months:foo <year>        # re-build posts/<year>/foo/index.html specifically"
  echo
  echo "  unpublish file.html              # remove a page from site, inc all indexes, publish changes"
}

# make the scripts available themselves, just in case the user wants them
alias create_page="${PWD}/.app/create_page.sh"
alias create_post="${PWD}/.app/create_post.sh"
alias create_rss="${PWD}/.app/create_rss.sh"
alias generate_sitemap="${PWD}/.app/generate_sitemap.sh"
alias update="${PWD}/.app/update_pages.sh"
alias publish="${PWD}/.app/publish.sh"
alias unpublish="${PWD}/.app/unpublish.sh"
alias server="${PWD}/.app/server.sh"
alias setup="${PWD}/.app/setup.sh"
alias minify="${PWD}/.app/minify.sh"
alias mdshell="${PWD}/.app/mdshell.sh"
alias mdsh2md="${PWD}/.app/mdsh2md.sh"
