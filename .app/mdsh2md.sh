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

# define run-time vars used by this program
prev_line=none
subshell_has_started=false
command=''
command_line_count=0

if [ ! -f "$1" ] && [ "$1" != "-all" ];then
  mkdir -p "$(dirname "$1")"
  touch "$1"
fi

if [ ! -f "$1" ];then
  exit 1
fi


# get contents only (ignoring meta/front matter)
mdsh_contents="$(cat "$1")"     # get file contents
md_body="${mdsh_contents#*---}" # remove everything before (and including) ---

# write markdown body to temp file
echo "$md_body" > /tmp/markdown

# we will read the file line by line and process it...

#  IFS=  preserve whitespace
#  -e    use readline
#  -r    dont escape backslashes include them as literals chars
while IFS= read -r line
do

  # if line starts with ``` we know it's a markdown line, not part of a bash sub-shell
  [ "$(echo "$line" | grep '^```')" != "" ] && subshell_has_started=false

  # if line starts with ~~~ we know it's a markdown line, not part of a bash sub-shell
  [ "$(echo "$line" | grep '^~~~')" != "" ] && subshell_has_started=false

  # if the line contains $( then the user is starting a bash sub-shell on this line
  [ "$(echo "$line" | grep -m1 '<?bash')" != "" ] && subshell_has_started=true

  # how many "<?bash .. ;?>" occurances do we have on the current line
  subshell_count="$(echo "$line" | grep -o '<?bash ' | wc -l)"

  # the the line given was bash, not markdown, we need to interpret it
  if [ "$subshell_has_started" = true ];then

    # at this point, we are 'inside' the <?bash ... ;?> sub-shell..

    # while we are in a bash sub-shell, lets save each line in the $command var
    if [ "$command" = "" ];then
      command="${line}"
    else
      command="$command
$line"
    fi
    command_line_count=$(($command_line_count + 1))

    # check if the sub-shell has ended (look for ';?>')
    subshell_has_ended="$(echo "$command" | grep -m1 -Eq ';?>' && echo true || echo false)"

    if [ "$subshell_has_ended" = true ];then

      # strip any leading chars up to the sub-shell invocation '$(' and
      # strip any chars after the sub-shell, and
      # keep only the command
      pre_text="$(echo -e "$command" | sed -e 's/<?bash.*//' -e 's/;?>//')"
      post_text="$(echo -e "$command" | sed 's/.*<?bash.*;?>//')"

      # grab the text preceding the sub-shell on this line, we'll use it later
      pre_text1="$(echo "${command//<?bash */}")"

      # if either pre text or post text are not empty
      if [ "$pre_text"  != "" ] || [ "$post_text"  != "" ];then
        # get command without pre/post text around it
        command="$(echo -e "${command//\\/\\\\}" | sed -e "s/^$pre_text//g" -e "s/$post_text//")"
        # sometimes (for some reason) the post text IS the command, in that case set post text to nothing
        [ "$post_text" = "$command" ] && post_text=""
      fi

      # if pre text is more than one line, it is the command
      if [ $(echo "$pre_text" | wc -l ) -gt 1 ];then
        # so, set the command to pre text, unset pre/post text
        command="$pre_text"
        cmd_only="$pre_text"
        pre_text=''
        post_text=''
      fi

      # if we have more than one sub-shell invocation on this line,
      if [ $subshell_count -gt 1 ];then

        # then break it up in to multiple lines
        OLD_IFS=$IFS
        IFS="
"
        for subline in $(echo "${command//;?>/;?>
}")
        do

          # no need to do anything if no sub-shell on this line
          [ "$( echo "$subline" | grep ';?>')" = "" ] && continue

          # if we already used $pre_text1, grab it again form the current line,
          # (because we have split this line into multiple sub-lines)
          [ "$pre_text1" = "$prev_pre_text" ] && pre_text1="$(echo "${subline//<?bash */}")"

          # get the text before/after the command
          pre_text="$(echo -e "$subline" | sed -e 's/<?bash.*//' -e 's/;?>//')"
          post_text="$(echo -e "$subline" | sed 's/.*<?bash.*;?>//')"
          # at this point, post text may equal the whole line.. if so, reset it
          [ "$post_text" = "$subline" ] && post_text=""
          # remove <?bash ;?> to be sure we have only the command left
          cmd_only="${subline//*ash /}"
          cmd_only="${cmd_only//;?>*/}"

          # if command is empty, skip
          [ "$cmd_only" = "" ] && continue

          # evaulate the commmand
          result="$(eval $cmd_only 2>/dev/null)"
          retval=$?
          # if it didnt evaulate, command not yet finished, continue to next line
          [ "$result" = "" ] && continue
          # if the command was successful (it DID evaulate)
          if [ $retval -eq 0 ];then
            # set the correct pre text for this sub line (dont re-use pre text of $line)
            pre_text="$pre_text1"
            prev_pre_text="$pre_text1"
            # save its results to the markdown
            markdown="$markdown\n$pre_text$result$post_text"
            # save the literal input in $source
            source="${source}${command}"
            # the sub-shell must have ended, so next line is not bash (by default)
            subshell_has_started=false
          fi
        done
        IFS=$OLD_IFS
      else
        # each line is a separate command, so replace newlines with semi-colons
        cmd_only="${command//*bash /}"
        cmd_only="${cmd_only//;?>*/}"
        result="$(eval $cmd_only)"
        retval=$?
      fi

      # if the command was successful
      if [ $retval -eq 0 -a $subshell_count -lt 2 ];then
        # save its results to the markdown
        markdown="$markdown\n$pre_text$result$post_text"
        # save the literal input in $source
        source="${source}${command}"
        # the sub-shell must have ended, so next line is not bash (by default)
        subshell_has_started=false
      fi
    fi

  elif [ "$subshell_has_started" = false ];then

      command_line_count=0
      command=""
      markdown="$markdown\n$line"
      source="$source\n$line"
      #[ -z "${prev_line}" ] && [ -z "$line" ] && break

  fi

  ###### done working out what was in $line #######

#  xmessage "
#  subshell_has_started:          $subshell_has_started
#  command line count:    '${command_line_count}'
#  command:               '${command//\\/\\\\}'
#  result:                '${result}'
#  "

  prev_line="$line"
  [ ${retval:-1} -eq 0 ] && result=''
done < /tmp/markdown

# rebuild the markdown file
markdown_file="${1//.mdsh/}.md"

echo -e "${markdown}" > "$markdown_file"

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

