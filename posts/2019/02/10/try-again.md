## Here is some stuff

<pre><code>
#!/bin/bash

if [ "$1" = '-h' ] || [ "$1" = '-help' ] || [ "$1" = '--help' ];then

  echo
  echo 'This script gets the repo URLs listed in /etc/apt/sources.list and '
  echo '/etc/apt/sources.list.d/<name>.list then passes them to `ppa2pup`, '
  echo 'which creates a Puppy-compatible repo from the repo URLs it receives '
  echo '(if possible).'
  echo
  echo 'More info:'
  echo
  echo '/etc/apt/sources.list usually contains lines like:'
  echo
  echo '    deb     https://deb.nodesource.com/node_8.x      trusty       main'
  echo '    deb     http://apt.postgresql.org/pub/repos/apt  trusty-pgdg  main'
  echo '    deb-src http://apt.postgresql.org/pub/repos/apt  trusty-pgdg  main'
  echo
  echo 'The first bit refers to package type (regular or source), the second'
  echo 'is the URL where the packages are, the third is OS version, and '
  echo 'the last is the "repo stream" - often main, contrib, or non-free.'
  echo
  echo 'This script will ignore "deb-src" entries, and parse the others'
  exit 0

fi

if [ ! -f /etc/apt/sources.list ] && [ ! -d /etc/apt/sources.list.d/ ];then
  [ ! -f /etc/apt/sources.list    ] && echo 'File /etc/apt/sources.list     not found'
  [ ! -d /etc/apt/sources.list.d/ ] && echo 'Dir  /etc/apt/sources.list.d/  not found'
  echo 'Exiting'
  exit 1
fi

# search inside /etc/apt/sources.list /etc/apt/sources.list.d/*.list
# ...look for lines starting with 'deb ', ignore others
# ...(use grep -h, to remove the preppended filenames if grepping multiple files)
# ...remove any arch stuff from the entries, ppa2pup will handle that,
# ...convert spaces to | chars, so we can process each line as a whole later

echo "Repos to process:"
echo
echo "${apt_sources_list//|/ }"


# for each repo in $apt_sources_list, use `ppa2pup` to install the repo
for line in $apt_sources_list
do
  [ "$line" = "" ] && continue
  [ "$line" = "
" ] && continue
  echo
  echo "Processing:  ${line//|/ }"
  echo

  # ask user to update repo

  if [ "$ANSWER" = 'y' ] || [ "$ANSWER" = 'Y' ];then
    echo
    ppa2pup ${line//|/ }
    retval=$?
  fi
  echo
done

exit $retval
</code></pre>

^ Added those HTML tags manually... Hopefully that works..
