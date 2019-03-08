#!/bin/bash

# usage: slugify.sh "some string"

# converts strings to santised, lower case, dash separated strings with
# whitespace and special characters removed.

# See these links for more info:
#  https://automatthias.wordpress.com/2007/05/21/slugify-in-a-shell-script/
#  https://stackoverflow.com/questions/47050589/create-url-friendly-slug-with-pure-bash
#  https://gist.github.com/oneohthree/f528c7ae1e701ad990e6

slugified="$(echo -n "${@}" | sed -e 's/[^[:alnum:]]/-/g' 2>/dev/null | tr -s '-' | tr A-Z a-z | sed -e 's/-$//g' 2>/dev/null)"
RETVAL=$?

if [ "$slugified" = "" ] || [ $RETVAL -gt 0 ]
then
  slugified="$(echo "$1" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)"
  RETVAL=$?
fi

[ "$slugified" != "" ] && echo "$slugified"

exit $RETVAL
