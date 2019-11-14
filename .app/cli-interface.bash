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
  [ -z "$1" ] && echo "Usage: new <page_type>" && return 1
  if [ "$(page_type_is_valid ${1:-foo})" = true ];then
    ${PWD}/.app/create_post.sh "$@"
    return 0
  fi
  return 1
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
  REBUILD_TYPE=pages ${PWD}/.app/update_pages.sh "$@"
}

# rebuild the index files associated with the given page
# or taxonomy term
function reindex {
  # $1 might be a parameter, like 'tags', 'year:2019', 'authors:foo,bar', '-all', ...
  REBUILD_TYPE=indexes ${PWD}/.app/update_pages.sh "$@"
}

function help {
  echo
  echo "Available commands:"
  echo
  echo "  setup                            # set site defaults, settings and options"
  echo
  echo "  server [start|stop]              # start/stop a local web server"
  echo
  echo "  new <page-type>                  # create a new page, of the given type, using default settings"
  echo
  echo "  new <page-type> -all             # create a new page, asks to override default settings"
  echo
  echo "  rebuild                          # rebuild all index pages (authors, categories, tags, etc)"
  echo
  echo "  rebuild -all                     # re-build all posts from their Markdown files"
  echo
  echo "  rebuild -ALL                     # re-build all posts from their .mdsh files"
  echo
  echo "  rebuild file.md > file.html      # build a specific page"
  echo
  echo "  rebuild file.mdsh > file.html    # re-build a specific page from a .mdsh file"
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
  echo "  rebuild <page-type>              # re-build pages of the given type (post, page, etc)"
  echo
  echo "  rebuild <page-type>:foo          # re-build pages listed in <page-type>/foo/"
  echo
  echo "  rebuild <page-type>:foo:bar      # re-build pages listed in <page-type>/foo/bar.html"
  echo
  echo "  reindex <page-type>              # re-build all INDEX pages in <page-type>/"
  echo
  echo "  reindex <page-type>:foo          # re-build all INDEX pages in <page-type>/foo/"
  echo
  echo "  reindex <page-type>:foo:bar      # re-build INDEX page <page-type>/foo/bar.html"
  echo
  echo "  rebuild years                    # re-build all posts/<years>/index.html index pages"
  echo
  echo "  rebuild years:foo                # re-build posts/foo/index.html specifically"
  echo
  echo "  rebuild months <year>            # re-build all monthly index pages in posts/<year>/"
  echo
  echo "  rebuild months:foo <year>        # re-build posts/<year>/foo/index.html specifically"
  echo
  echo "  unpublish file.html              # remove a page from site, inc all index pages, publish changes"
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
