#!/bin/bash

# sc0ttj
# Based on an example script by Stéphane Chazelas.
# ...hacked into a horrific mess...

# Usage:
#
# This script takes a file as the first argument, example:
#
#    mdhsell.sh posts/$date_dir/${slug}.mdsh

if [ ! "$1" ] || [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ];then
cat << HELP_MSG

 An interactive shell for writing Markdown documents, with support for
 embedding bash sub-shells in your Markdown, using: <?bash ... ;?>

 Usage:  mdshell <path-to-file> # creates the file if it doesn't exist

 Example:   Add <?bash uname ;?> in your Markdown and the saved
            file will contain your system info.

HELP_MSG
exit
fi

# load the local config file
[ -f .site_config ] && source .site_config

# source the functions needed by this script
if [ -f .app/functions/mdsh_functions.bash ];then
  source .app/functions/mdsh_functions.bash
else
  echo 'Functions required by this script not found in .app/functions/mdsh_functions.bash.. exiting..' >&2
  exit 1
fi

# define run-time vars used by this program
prev_line=none
subshell_has_started=false
command=''
command_line_count=0

# make sure the output file path exists
check_output_file_and_path "$1"

# we will run as interactive shell (not process a file line by line)
mdshell=true

while :
do
  # the user just hit ENTER, so read the line they input
  #  -e  use readline
  #  -r  dont escape backslashes include them as literals chars
  IFS= read -er line
  # parse $line, evaluating any sub-shells inline,
  # then add $line to $markdown, to be saved into
  # a Markdown file, and $source to be saved into
  # a .msdh file
  process_line
  [ "$break_here" = true ] && echo -e "Saving...\n" && break
done

# (re)build the markdown file
markdown_file="${1//.mdsh/}.md"
echo -e "$markdown" > "$markdown_file"

# append body to the source file (append cos it has front matter)
mdsh_file="${1}"
echo -e "$source" >> "$mdsh_file"

# create the HTML page
html_file="${1//.mdsh/}.html"
rebuild "$1" > "$html_file"

echo "Saved as:"
echo
echo "HTML page:      $html_file"
echo "Markdown file:  $markdown_file"
echo "Source file:    $1"
echo

unset prev_line
unset subshell_has_started
unset file
unset text
unset command
unset command_line_count
unset result
unset retval
