# define the command-line interface (CLI)

# mo must be in $PATH to work, so add its parent dir to $PATH, if needed
if [ "$(echo $PATH | grep '.app/functions')" = "" ];then
  export PATH=$PATH:.app/functions
fi

# source functions used by mdsh
libs="
.app/functions/mo
.app/functions/yay
.app/functions/mdsh_functions.bash
.app/functions/liquid_filters.bash
.app/functions/mo-addons.bash
.app/functions/generate*.bash
"
for script in $libs
do
  [ ! -z "$script" ] && [ -f "$script" ] && source "$script"
done




# define CLI below

# mdsh:  init program (source scripts, functions, generate site data, etc)
#
# Usage: mdsh
#
function mdsh {
  [ -f .site_config ] && source .site_config
}

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
  if [ "$1" = "homepage" ];then
    post_title="Homepage" ${PWD}/.app/create_page.sh > index.html
    return 0
  fi
  if [ "$1" = "rss" ];then
    .app/create_rss.sh posts/ > feed.rss
    return 0
  fi
  if [ "$1" = "sitemap" ];then
    ${PWD}/.app/generate_sitemap.sh
    return 0
  fi
  # $1 might be a parameter, like -all
  ${PWD}/.app/update_pages.sh $1
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
  echo "  publish                          # save and publish latest changes"
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
