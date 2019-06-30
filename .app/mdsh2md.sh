#!/bin/bash

# sc0ttj
# Based on an example script by Stéphane Chazelas.
# ...hacked into a horrific mess...

if [ ! "$1" ] || [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ];then
  cat << HELP_MSG

 Process .mdsh files, outputting valid Markdown files (.md)

 Usage:  mdsh2md path/to/file.mdsh # will output path/to/file.md

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

# we will not run as interactive shell (we'll process a file line by line)
mdshell=false

# get the markdown body only (not including front matter)
get_markdown_contents_from_file "$1" > /tmp/markdown

# we will read the file line by line and process it:
#   IFS=  preserve whitespace
#   -e    use readline
#   -r    dont escape backslashes include them as literals chars
while IFS= read -r line
do
  # parse $line, evaluating any sub-shells inline,
  # then add $line to $markdown, to be saved into
  # a Markdown file
  process_line
done < /tmp/markdown

# (re)build the markdown file
markdown_file="${1//.mdsh/}.md"
echo -e "$markdown" > "$markdown_file"

echo "Saved as:"
echo
echo "Markdown file:  $markdown_file"
echo "Source file:    $1"
echo

unset prev_line
unset subshell_has_started
unset subshell_has_ended
unset file
unset text
unset command
unset command_line_count
unset result
unset retval

