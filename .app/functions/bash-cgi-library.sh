#!/bin/bash

# bash CGI library

# Usage: Source this script near the top of your Bash CGI script and it
#        will provide $GET and $POST arrays, automatic handling of files
#        uploaded to your script, easier user registration and login, plus
#        lots of useful functions for building dynamic web applications.

# This script expects these env vars to be available:

#  DOCUMENT_ROOT              # the top-level dir served by the web server
#  REQUEST_METHOD             # GET or POST
#  CONTENT_TYPE               # 'multipart/form-data' or 'x-www-form-urlencoded'
#  CONTENT_LENGTH             # length in bytes of POST_DATA (stdin)
#  QUERY_STRING               # the query string form the URL (if any)


[ -f config/main ] && . ./config/main

#
#
#
function init {
  mkdir -p ../assets/{css,js,img}
  mkdir -p ../downloads
  mkdir -p ../users
  [ -z "$salt" ] && salt='98s£$-a%1m^4-$7l&2p*hy(-7s-a5a)90k-nm-8d7'
  add_user "admin" "admin"
  echo true > ./config/init_complete
}

#
#
#
function add_user {
  echo -e "$1\n$(echo "$2$salt" | md5sum)" > ../users/"$1"
}


#
#
#
function rm_user {
  rm ../users/"$1"
}


# usage:   login_details_are_valid <user> <pass>
#
# checks file "../users/$user" for md5 encrypted version of $pass
#
function login_details_are_valid {
  local passwd=$(echo "$2$salt" | md5sum)
  if [ "$(grep -q "^${passwd}$" ../users/$1)" ];then
    return 0
  else
    return 1
  fi
}


#
#
#
function urlencode {
  local LC_CTYPE=C
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
      local c="${1:i:1}"
      case $c in
          [a-zA-Z0-9.~_-]) printf "$c" ;;
          *) printf '%%%02X' "'$c"
      esac
  done
}


#
#
#
function urldecode {
  local LC_CTYPE=C
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}


#
#
#
function slugify {
  local string="$(urldecode "${@}")"
  slugified="$(echo -n "$string" \
    | sed -e 's/[^[:alnum:]]/-/g' 2>/dev/null \
    | tr -s '-' \
    | tr A-Z a-z \
    | sed -e 's/-$//g' 2>/dev/null)"
  RETVAL=$?
  if [ "$slugified" = "" ] || [ $RETVAL -gt 0 ]
  then
    slugified="$(echo "$1" \
      | iconv -t ascii//TRANSLIT \
      | sed -r s/[^a-zA-Z0-9]+/-/g \
      | sed -r s/^-+\|-+$//g \
      | tr A-Z a-z)"
    RETVAL=$?
  fi
  [ "$slugified" = "" ] && return 1
  echo "$slugified"
}


#
#
#
function is_text_browser {
  local user_agent="$(echo ${USER_AGENT:-none} | tr [[:upper:]] [[:lower:]] | head -1)"
  case "$user_agent" in
    lynx*|elinks*|w3m*) echo true;;
    *) echo false;;
  esac
}

function is_console {
  local user_agent="$(echo ${USER_AGENT:-none} | tr [[:upper:]] [[:lower:]] | head -1)"
  case "$user_agent" in
    curl*|wget*|aria*|telnet*) echo true;;
    *) echo false;;
  esac
}


#
#
#
function start_background_process {
  local cmd="$1"
  $cmd >&- 2>&- &
}


#
#
#
function redirect {
  local uri
  if [ "$1" != "" ]; then
    uri="$1"
  else
    uri="http://${SERVER_NAME}/${SCRIPT_NAME}"
  fi
  echo "Location: $uri"
  echo
}


#
#
#
function get_content_type {
  if [ "$HTTP_ACCEPT" = '*/*' ] || [ "$HTTP_ACCEPT" = '' ];then
    echo 'text/html'
    return
  fi
  case "$HTTP_ACCEPT" in
    */plain*)       echo 'text/plain';;
    */html*)        echo 'text/html';;
    */csv*)         echo 'text/csv';;
    */xhtml*)       echo 'application/xhtml';;
    */xml*)         echo 'application/xml';;
    */json*)        echo 'application/json';;
    */javascript*)  echo 'application/javascript';;
    */php*)         echo 'application/php';;
    *)              echo 'text/html';;
  esac
}


#
#
#
function print_cache_header {
  if [ "$1" = 'false' ];then
    echo 'Cache-Control: no-cache'
    echo 'Pragma: no-cache'
  else
    echo "Cache-Control:public, max-age=${1:-3600}"
  fi
}

#
#
#
function print_header {
  LC_CTYPE=C
  case "$1" in
    200)  msg="OK" ;;
    301)  msg="Moved Permanently" ;;
    401)  msg="Unauthorized" ;;
    403)  msg="Forbidden" ;;
    404)  msg="Not Found" ;;
    408)  msg="Request Timeout" ;;
    500)  msg="Internal Server Error" ;;
    503)  msg="Service Unavailable" ;;
    *)    msg="Internal Server Error" ;;
  esac
  echo "Content-type: $(get_content_type); charset=UTF-8"
  echo "Status: $1 $msg"
  print_cache_header "${2}"
  echo "Date: $(date -u +%a,\ %d\ %b\ %Y\ %H:%M:%S\ GMT)"
  echo
}


#
#
#
function set_cookie {
  # $1 = name of variable
  # $2 = value of variable
  # $3 = duration (seconds)
  # $4 = path (optional)
  value=$(echo -n "$2" | urlencode)
  if [ -z "$4" ]; then
    path=""
  else
    path="; Path=$4"
  fi
  echo -n "Set-Cookie: $1=$value$path; expires="
  date -u --date="$3 seconds" "+%a, %d-%b-%y %H:%M:%S GMT"
}


#
#
#
function form_or_upload {
  local LC_CTYPE=C
  if [ "$CONTENT_TYPE" = "" ];then
    return 1
  fi
  if [ "$(echo "$CONTENT_TYPE" | grep -m1 'multipart/form-data;')" != '' ];then
    echo upload
    return 0
  fi
  echo form
  return 0
}


#
#
#
function convert_get_and_post_to_vars {
  local LC_CTYPE=C
  # make POST and GET strings
  # available as bash variables
  if [ ! -z $CONTENT_LENGTH ] && [ "$CONTENT_LENGTH" -gt 0 ] && \
     [ $CONTENT_TYPE != "multipart/form-data" ]; then
    read -n $CONTENT_LENGTH POST_STRING <&0
    eval `echo "${POST_STRING//;}"|tr '&' ';'`
  fi
  eval `echo "${QUERY_STRING//;}"|tr '&' ';'`
}


#
#
#
function convert_get_and_post_to_arrays {
  local LC_CTYPE=C
  #declare -a get_array
  #declare -a post_array
  #declare -A GET
  #declare -A POST

  saveIFS=$IFS                    # save IFS (internal field separator)
  IFS='=&'                        # use '=' and '&' as internal field separators
  get_array=($QUERY_STRING)       # create an array from $QUERY_STRING
  post_array=($POST_DATA)         # create an array from std input (POST data)
  IFS=$saveIFS                    # restore IFS to its original state

  # add the key/value pairs to $GET
  for ((i=0; i<${#get_array[@]}; i+=2))
  do
      key=${get_array[i]}
      value=${get_array[i+1]}
      GET[$key]=$value
  done
  # add the key/value pairs to $POST
  for ((i=0; i<${#post_array[@]}; i+=2))
  do
      key=${post_array[i]}
      value=${post_array[i+1]}
      POST[$key]=$value
  done
  # we now have $POST[foo], $GET[bar], etc.. export them
  export POST
  export GET
}


#
#
#
function return_file {
  local LC_CTYPE=C
  local mimetype="$(file --mime-type -b "$1")"
  echo "Content-Type: $mimetype; charset=UTF-8"
  echo 'Content-Disposition: attachment; filename="$1"'
  echo
  unset mimetype
}


#
#
#
function get_file_name {
  local LC_CTYPE=C
  echo -n "$1" | grep --text --max-count=1 -oP "(?<=filename=\")[^\"]*"
}


#
#
#
function get_file_boundary {
  local LC_CTYPE=C
  echo -n "$1" | head -1 | tr -d '\r\n'
}


#
#
#
function get_file_content {
  local LC_CTYPE=C
  local boundary="$(get_file_boundary "$1")"
#  echo -n "$1" \
#    | sed '1,/Content-Type:/d' \
#    | tail -c +3 \
#    | head --lines=-1 \
#    | head --bytes=-4 \
#    | head -n -4
  echo "$1" | sed -n "1,/$boundary/p" | sed '1,4d;$d'
}


#
#
#
function upload_file {
  # a dumb function for handling file uploads..
  # it CANNOT handle binary files!
  local LC_CTYPE=C
  if [ ! -d "${DOCUMENT_ROOT}" ] || \
     [ "$REQUEST_METHOD" != "POST" ] || \
     [ "$(echo "$CONTENT_TYPE" | grep -m1 'multipart/form-data')" = "" ] || \
     [ "$CONTENT_LENGTH" -eq 0 ]; then
    print_header 500
    return 1
  fi
  mkdir ${DOCUMENT_ROOT}/downloads/
  chmod 744 ${DOCUMENT_ROOT}/downloads/
  chown nobody:nobody ${DOCUMENT_ROOT}/downloads/
  # get the file meta info and contents
  local filename="$(get_file_name "$POST_DATA")"
  local file="$(get_file_content "$POST_DATA")"
  # save the file
  echo -e "$file" > ${DOCUMENT_ROOT}/downloads/"$filename" || \
  {
    print_header 500
    return 1
  }
  chmod 755 ${DOCUMENT_ROOT}/downloads/"$filename"
  unset boundary
  unset filename
  unset file
}


###############################################################################

#
#  get post data, handle upload if it's a file, else set $POST and $GET
#

POST_DATA="$(cat)"
content_type=$(form_or_upload) # returns 'upload' or 'form'

if [ "$REQUEST_METHOD" = "POST" ] && \
   [ "$content_type" = "upload" ] && \
   [ "$CONTENT_LENGTH" -gt 0 ]
then
  upload_file
else
  convert_get_and_post_to_vars
  # declare the GET and POST arrays (still empty at this point)
  declare -a get_array
  declare -a post_array
  declare -A GET
  declare -A POST
  convert_get_and_post_to_arrays
fi

#
#
#

##############################################################################

# ..in the script which sources this library
print_header 200

cat << EOS
<!DOCTYPE html>
<html>
  <head>
    <title>${page_title:-Page Title}</title>
  </head>
  <body>
  <h1>${page_title:-Page Title}</h1>

  <pre>
EOS
########
env
########
cat << EOS
  </pre>

  <table>
    <tr>
      <td>one</td>
      <td>two</td>
    </tr>
    <tr>
      <td>three</td>
      <td>four</td>
    </tr>
  </table>
  </body>
</html>
EOS

##############################################################################
