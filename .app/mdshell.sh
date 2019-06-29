#!/bin/bash

# sc0ttj
# Based on an example script by Stéphane Chazelas.

if [ ! "$1" ] || [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ];then
cat << HELP_MSG

 An interactive shell for writing Markdown documents, with
 support for embedding bash sub-shells \$() in your Markdown!

 Usage:  mdshell <path-to-file> # creates the file if it doesn't exist

 Note backtick subshells (\`\`) not supported, only \$()

 Example:   Add \$(uname) in your Markdown and the saved
            file will contain your system info.

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

function evaluate_command {
  # To save/protect quotes within the code, use the method in this
  # StackEx answer: https://stackoverflow.com/a/16938013/5479837
  c=`cat <<EOF
${cmd_only}
EOF`
  # run the code, get the output as $result
  case $language in
    bash|python|python2*|python3*|ash|dash)
      result="$($language -c "$c" 2>/dev/null)"
      retval=$?
      ;;
    node|ruby|ruby1*|ruby2*|ruby-1*|ruby-2*|nodejs|perl|perl4*|perl5*)
      result="$($language -e "$c" 2>/dev/null)"
      retval=$?
      ;;
    php|php4*|php5*|php6*|php7*|php-4*|php-5*|php-6*|php-7*)
      result="$($language -r "$c" 2>/dev/null)"
      retval=$?
      ;;
    c|tcc)
      result="$(echo "$c" | tcc -run - 2>/dev/null)"
      retval=$?
      ;;
    awk|gawk)
      # awk requires $ to be escaped when using eval ()
      result="$(  awk -e $(eval ${cmd_only//$/\\$} 2>/dev/null)  )"
      retval=$?
      ;;
  esac
  if [ ! -z "$retval" ] && [ ! -z "$result" ];then
    [ ${retval:-1} -eq 0 ] && echo "$result"
  fi
}

while :
do
  # the user just hit ENTER, so read the line they input
  #  -e  use readline
  #  -r  dont escape backslashes include them as literals chars
  IFS= read -er line

  # if line starts with ``` we know it's a markdown line, not part of a sub-shell
  [ "$(echo "$line" | grep '^```')" != "" ] && subshell_has_started=false

  # if line starts with ~~~ we know it's a markdown line, not part of a sub-shell
  [ "$(echo "$line" | grep '^~~~')" != "" ] && subshell_has_started=false

  # lets get the language of any sub-shell (bash, python, php, etc)
  language="$(echo "$line" | sed -e 's/.*<?/<?/' -e 's/;?>.*/;?>/' -e 's/ .* ;?>//' -e 's/<?//')"

  # if the line contains "<?$language" then the user is starting a sub-shell on this line
  [ "$(echo "$line" | grep -m1 "<?${language:-bash}")" != "" ] && subshell_has_started=true

  # how many "<?$language .. ;?>" occurances do we have on the current line
  subshell_count="$(echo "$line" | grep -o "<?$language " | wc -l)"

  # the the line given was a sub-shell, not markdown, we need to interpret it
  if [ "$subshell_has_started" = true ];then

    # while we are in a sub-shell, lets save each line in the $command var
    if [ "$command" = "" ];then
      command="${line}"
    else
      command="$command
$line"
    fi
    command_line_count=$(($command_line_count + 1))

    # check if the sub-shell has ended (look for ';?>')
    subshell_has_ended="$(echo "$command" | grep -m1 -Eq ';?>' && echo true || echo false)"

    # lets get the language of any sub-shell (bash, python, php, etc) from $command
    language="$(echo $command | sed -e 's/.*<?/<?/' -e 's/;?>.*/;?>/' -e 's/ .* ;?>//' -e 's/<?//')"

    if [ "$subshell_has_ended" = true ];then

      # strip any leading chars up to the sub-shell invocation '$(' and
      # strip any chars after the sub-shell, and
      # keep only the command
      pre_text="$(echo -e "$command" | sed -e "s/<?$language.*//" -e 's/;?>//')"
      post_text="$(echo -e "$command" | sed "s/.*<?$language.*;?>//")"

      # grab the text preceding the sub-shell on this line, we'll use it later
      pre_text1="$(echo "${command//<?$language */}")"

      # if either pre text or post text are not empty
      if [ "$pre_text"  != "" ] || [ "$post_text"  != "" ];then
        # get command without pre/post text around it
        command="$(echo -e "$command" | sed -e "s/^$pre_text//g" -e "s/$post_text&//")"
        command="${command//\\/\\\\}"
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

          # lets get the language of the sub-shell (bash, python, php, etc)
          language="$(echo $subline | sed -e 's/.*<?/<?/' -e 's/;?>.*/;?>/' -e 's/ .* ;?>//' -e 's/<?//')"

          # if we already used $pre_text1, grab it again form the current line,
          # (because we have split this line into multiple sub-lines)
          [ "$pre_text1" = "$prev_pre_text" ] && pre_text1="$(echo "${subline//<?$language */}")"

          # get the text before/after the command
          pre_text="$(echo -e "$subline" | sed -e "s/<?$language.*//" -e "s/;?>//")"
          post_text="$(echo -e "$subline" | sed "s/.*<?$language.*;?>//")"
          # at this point, post text may equal the whole line.. if so, reset it
          [ "$post_text" = "$subline" ] && post_text=""
          # remove <?$language ;?> to be sure we have only the command left
          cmd_only="${subline//*$language /}"
          cmd_only="${cmd_only//;?>*/}"

          # if command is empty, skip
          [ "$cmd_only" = "" ] && continue

          # evaulate the commmand
          result="$(evaluate_command)"
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
            # the sub-shell must have ended, so next line is markdown (by default)
            subshell_has_started=false
          fi
        done
        IFS=$OLD_IFS
      else
        cmd_only="${command//<?$language /}"
        cmd_only="${cmd_only/<?$language/}"
        cmd_only="${cmd_only//;?>*/}"
        cmd_only="$(echo "$cmd_only" | sed -e "s/<?$language//" -e 's/;?>//')"
        result="$(evaluate_command)"
        retval=$?
      fi

      # if the command was successful
      if [ $retval -eq 0 -a $subshell_count -lt 2 ];then
        # save its results to the markdown
        markdown="$markdown\n$pre_text$result$post_text"
        # save the literal input in $source
        source="${source}${command}"
        # the sub-shell must have ended, so next line is markdown (by default)
        subshell_has_started=false
      fi
    fi

  elif [ "$subshell_has_started" = false ];then

      command_line_count=0
      command=""
      markdown="$markdown\n$line"
      source="$source\n$line"
      [ -z "${prev_line}" ] && [ -z "$line" ] && break

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
done

# append body to the source file
mdsh_file="${1}"
echo -e "$source" >> "$mdsh_file"

# append to the markdown file
markdown_file="${1//.mdsh/}.md"
echo -e "$markdown" >> "$markdown_file"

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

