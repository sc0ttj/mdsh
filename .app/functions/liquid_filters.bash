# These functions are available within Bash sub-shells, when
# writing your Mustache templates and your Markdown.

# For example, the function 'uppercase' can be used like so
# in your Markdown:
#
#    <?bash echo "$var" | uppercase ;?>
#
# And here's how to use it in your template files:
#
#    {{var | uppercase}}
#
# These functions are intended to mimic some of the liquid
# templating filters, listed here:
# https://github.com/Shopify/liquid/wiki/Liquid-for-Designers

# get the real `bc`, make sure we're not using an alias
bc=$(which bc)

str=''
function get_stdin { read STDIN; }

function timestamp {
  date +%s
}

# date filters

function date_format {
  get_stdin
  case "$1" in
    basic)
      date -d $STDIN -u +"%m/%d/%Y" || echo -n $STDIN
      ;;
    basic_uk)
      date -d $STDIN -u +"%d/%m/%Y" || echo -n $STDIN
      ;;
    iso8601)
      date -d $STDIN -u +"%Y-%m-%d" || echo -n $STDIN
      ;;
    to_string)
      date -d $STDIN -u +"%d %b %Y" || echo -n $STDIN
      ;;
    to_long_string)
      date -d $STDIN -u +"%d %B %Y" || echo -n $STDIN
      ;;
    rfc822|rfc2822|rss|email)
      LANG=C LC_ALL=C LC_CTYPE=C date -d $STDIN -u +"%a, %d %b %Y %H:%M:%S %z" || echo -n $STDIN
      ;;
    *"%"*)
      date -d $STDIN -u +"$1" || echo -n $STDIN
      ;;
    *)
      date
      return 1
      ;;
  esac
  return 0
}

# string filters

function base_name {
  local input="$1"
  [ ! -f "$1" ] && get_stdin && input="$STDIN"
  echo -n "${input##*/}"
}

function dir_name {
  local input="$1"
  [ ! -f "$1" ] && get_stdin && input="$STDIN"
  echo -n "${input%/*}"
}

function uppercase { tr '[:lower:]' '[:upper:]'; }

function lowercase { tr '[:upper:]' '[:lower:]'; }

function titlecase {
  get_stdin
  echo -n "${STDIN:0:1}" | uppercase
  echo -n "${STDIN:1}"   | lowercase
}

function capitalize {
  get_stdin
  for word in ${STDIN}
  do
    echo -n "${word:0:1}" | uppercase
    echo -n "${word:1}"   | lowercase
    echo -n " "
  done
}
alias capitalise=capitalize

function pluralize {
  get_stdin
  local singular="${1:-item}"
  local plural="${2:-item}"
  echo -n "$STDIN "
  if [ ${STDIN:-1} -gt 1 ] || [ ${STDIN:-0} -eq 0 ] ;then
    echo -n "$plural"
    return 0
  fi
  echo -n "$singular"
}
alias pluralise=pluralize

function slugify {
  get_stdin
  local slugified="$(echo -n "$STDIN" | sed -e 's/[^[:alnum:]]/-/g' 2>/dev/null | tr -s '-' | tr A-Z a-z | sed -e 's/-$//g' 2>/dev/null)"
  local RETVAL=$?
  if [ "$slugified" = "" ] || [ $RETVAL -gt 0 ];then
    slugified="$(echo "$STDIN" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)"
    RETVAL=$?
  fi
  [ "$slugified" != "" ] && echo -n "$slugified" || return 1
}

function camelcase_to_slug {
 sed 's/\(.\)\([A-Z]\)/\1-\2/g' | lowercase
}

function slug_to_camelcase {
  get_stdin
  IFS=- read -ra newstr <<<"${STDIN}"
  printf '%s' "${newstr[@]^}"
}

function lstrip { sed 's/^ *//'; }

function rstrip { sed 's/ *$//'; }

function strip { sed -e 's/^ *//' -e 's/ *$//'; }

function strip_html { sed 's/<[^>]*>//g'; }

function strip_newlines { tr -d '\n'; }

function escape_html { sed -e 's/>/\&gt;/g' -e 's/</\&lt;/g'; }

function unescape_html { sed -e 's/\&gt;/>/g' -e 's/\&lt;/</g'; }

function newline_to_br {
  get_stdin
  echo "${str//
/<br>}"
}

function br_to_newline {
  get_stdin
  local out="$(echo "${STDIN//<br>/
}")"
  out="${out//<br \/>/
}"
  out="${out//<br\/>/
}"
  echo -e "$out"
}

function reverse { rev; }

function replace_first { sed "s/$1/$2/"; }

function replace_last { sed "s/\(.*\)$1/\1$2/"; }

function replace_all { sed "s/$1/$2/g"; }

function prepend { get_stdin; echo -n "$1$STDIN"; }

function append  { get_stdin; echo -n "$STDIN$1"; }

function __print_truncation {
  get_stdin
  echo -n "$1"
  if [ "$1" = "$2" ];then
    return 1
  else
    echo -n "$3"
    return 0
  fi
}

function truncate {
  get_stdin
  local truncated="$(cut -b-${1:-9999} <<< "$STDIN")"
  __print_truncation "$truncated" "$STDIN" "$2"
}

function truncate_words {
  get_stdin
  local truncated="$(echo "$STDIN" | cut -d' ' -f1-${1:-9999})"
  __print_truncation "$truncated" "$STDIN" "$2"
}

function urlencode {
  get_stdin
  local LC_CTYPE=C
  local length="${#STDIN}"
  for (( i = 0; i < length; i++ )); do
      local c="${STDIN:i:1}"
      case $c in
          [a-zA-Z0-9.~_-]) printf "$c" ;;
          *) printf '%%%02X' "'$c"
      esac
  done
}

function urldecode {
  get_stdin
  STDIN="${STDIN:-$@}"
  local LC_CTYPE=C
  #while read; do : "${STDIN//%/\\x}"; echo -e ${_//+/ }; done # bash only, from https://stackoverflow.com/questions/6250698/how-to-decode-url-encoded-string-in-shell
  local url_encoded="${STDIN//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}

function base64_encode {
  #perl -MMIME::Base64 -0777 -ne 'print encode_base64($_)'  # perl solution
  base64
}

function base64_decode {
  #perl -MMIME::Base64 -ne 'print decode_base64($_)' # perl solution
  base64 -d
}

function html_decode {
  local LC_CTYPE=C
  [ "`which python3`" != "" ] && python3 -c 'import html, sys; [print(html.unescape(l), end="") for l in sys.stdin]' && return
  perl -MHTML::Entities -pe 'decode_entities($_);'
}

function html_encode {
  local LC_CTYPE=C
  [ "`which python3`" != "" ] && python3 -c 'import html, sys; [print(html.escape(l), end="") for l in sys.stdin]' && return
  perl -MHTML::Entities -pe 'encode_entities($_);'
}

function rgb2hex { get_stdin; printf "#%02x%02x%02x\n" ${STDIN}; }

function hex2rgb {
  get_stdin; STDIN="$(echo "${STDIN}" | sed 's/^#//')";
  [ "${#STDIN}" = "3" ] && STDIN="$STDIN$STDIN"
  printf "%d %d %d\n" 0x${STDIN:0:2} 0x${STDIN:2:2} 0x${STDIN:4:2};
}

function md5 { md5sum | sed 's/ .*$//'; }

function sha1 { sha1sum | sed 's/ .*$//'; }

function sha256 { sha256sum | sed 's/ .*$//'; }

function sha512 { sha512sum | sed 's/ .*$//'; }

function slice {
  local from=$((${1:-0} + 1))
  local to=$((${2:-0} + 1))
  from=${from//0/1}
  to="-${to//0/1}"
  [ -z "$2" ] && to=''
  cut -b${from}${to} 2>/dev/null
}

function absolute_url { get_stdin; echo -n "https://${site_domain}${site_url}/$STDIN"; }

function relative_url { get_stdin; echo -n "${site_url}/$STDIN"; }

function asset_url {
  get_stdin
  local asset_file="$(find assets -type f -name "$STDIN")"
  asset_file="${asset_file:-$STDIN}"
  echo -n "${asset_file}?$(date +%s)"
}

function time_tag {
  get_stdin
  local datetime="$STDIN"
  # format the innerText in of the <time> element as $1
  local formatted_date="$(echo $STDIN | date_format "${1}")"
  # if user gave $2, format the value of the `datetime` attribute
  if [ "$2" != "" ];then
    datetime="$(echo $datetime | date_format "${2}")"
  fi
  echo -n "<time datetime=\"$datetime\">${formatted_date}</time>"
}

function link_tag {
  get_stdin
  local title=''
  [ "$2" != "" ] && title=" title=\"$2\""
  echo -n "<a href=\"$1\"$title>$STDIN</a>"
}

function script_tag {
  get_stdin
  echo -n "<script>$STDIN</script>"
}

function img_tag {
  get_stdin
  echo -n "<img src=\"${STDIN}\" alt=\"$1\" />"
}

function stylesheet_tag {
  get_stdin
  echo -n "<link href=\"${STDIN}\" rel=\"stylesheet\" type=\"text/css\" media=\"all\" />"
}

function to_smart_quotes {
  sed -zEe 's/\x27\x27/"/g; s/\x27([^\x27]*)\x27/‘\1’/g; s/"([^"]*)"/“\1”/g; '
}

function time_to_read {
  local STDIN="$(cat)"
  local units="${units:-Min}"
  local words_per_min=${1:-250}
  local word_count=$(echo "$STDIN" | sed \
    -e 's/<area>.*<\/area>//g' \
    -e 's/<audio>.*<\/audio>//g' \
    -e 's/<canvas>.*<\/canvas>//g' \
    -e 's/<code>.*<\/code>//g' \
    -e 's/<embed>.*<\/embed>//g' \
    -e 's/<footer>.*<\/footer>//g' \
    -e 's/<form>.*<\/form>//g' \
    -e 's/<map>.*<\/map>//g' \
    -e 's/<math>.*<\/math>//g' \
    -e 's/<nav>.*<\/nav>//g' \
    -e 's/<object>.*<\/object>//g' \
    -e 's/<pre>.*<\/pre>//g' \
    -e 's/<script>.*<\/script>//g' \
    -e 's/<svg>.*<\/svg>//g' \
    -e 's/<table>.*<\/table>//g' \
    -e 's/<track>.*<\/track>//g' \
    -e 's/<video>.*<\/video>//g' \
    -e 's/<img.*\/>//g' \
    -e 's/<img.*>//g' \
    -e 's/<p>/<p> /g' \
    -e 's/<[^>]*>//g' | wc -w)
    # calculate time to read
    local reading_time="$( echo $(($word_count / $words_per_min)) | ceil )"
    # set correct units word
    [ "$reading_time" = "0" ] && reading_time="1"
    [ "$reading_time" -gt "1" ] && units="${units}s"
    # return
    echo -n "${reading_time} ${units}"
}

function markdown_to_html {
  # Use enhanced version of markdown.pl, which includes
  # tables support.. from https://github.com/mackyle/markdown
  .app/gf-markdown.pl
}

function csv_to_markdown {
  local STDIN="$(cat)"
  local tmp_file=/tmp/tmpfile.csv
  echo -e "$STDIN" > $tmp_file
  head -n 1 "$tmp_file" | \
      sed -e 's/^/|/' -e 's/,/|/g' -e 's/$/|/'
  echo '|---|---|---|'
  tail -n +2 "$tmp_file" | \
      sed -e 's/^/|/' -e 's/,/|/g' -e 's/$/|/'
}

function csv_to_html {
  local STDIN="$(cat)"
  local tmp_file=/tmp/tmpfile.csv
  echo "$STDIN" > $tmp_file
  echo "<table>"
  head -n 1 "$tmp_file" | \
      sed -e 's/^/<tr><th>/' -e 's/,/<\/th><th>/g' -e 's/$/<\/th><\/tr>/'
  tail -n +2 "$tmp_file" | \
      sed -e 's/^/<tr><td>/' -e 's/,/<\/td><td>/g' -e 's/$/<\/td><\/tr>/'
  echo -n "</table>"
}

function csv_to_json {
  read STDIN
  echo "$STDIN" > /tmp/csv_to_json.csv
  python -c "import csv,json;print json.dumps(list(csv.reader(open('/tmp/csv_to_json.csv'))))"
  rm /tmp/csv_to_json.csv
}

function csv_to_json {
  # CSV to JSON converter using BASH
  # original script from https://gist.github.com/dsliberty/3de707bc656cf757a0cb
  # Usage ./csv2json.sh input.csv > output.json
  #set -x
  shopt -s extglob
  local input="${1:-}"
  local SEP=','

  # sc0ttj: modified to accept piped input
  if [ ! -f "$input" ];then
    input="$(cat)"
    mkdir -p /tmp/mdsh/ &>/dev/null
    echo "$input" > /tmp/mdsh/csv
    input=/tmp/mdsh/csv
  fi
  [ -z "$input"   ] && echo "No CSV input specified" && return 1

  function csv_nextField {
      local line="$(echo "${1}" | sed 's/\r//g')"
      local start=0
      local stop=0

      if [[ -z "${line}" ]]; then
          return 0
      fi

      local offset=0
      local inQuotes=0
      while [[ -n "${line}" ]]; do
          local char="${line:0:1}"
          line="${line:1}"

          if [[ "${char}" == "${SEP}" && ${inQuotes} -eq 0 ]]; then
              inQuotes=0
              break
          elif [[ "${char}" == '"' ]]; then
              if [[ ${inQuotes} -eq 1 ]]; then
                  inQuotes=0
              else
                  inQuotes=1
              fi
          else
              echo -n "${char}"
          fi
          offset=$(( ${offset} + 1 ))
      done
      echo ""
      return $(( ${offset} + 1 ))
  }

  read first_line < "${input}"
  a=0
  local headings=`echo ${first_line} | awk -F"${SEP}" {'print NF'}`
  local lines=`cat "${input}" | wc -l`

  while [[ ${a} -lt ${headings} ]]; do
      field="$(csv_nextField "${first_line}")"
      first_line="${first_line:${?}}"
      head_array[${a}]="${field}"
      a=$(( ${a} + 1 ))
  done

  c=0
  echo "["
  while [ ${c} -lt ${lines} ]
  do
      read each_line
      each_line="$(echo "${each_line}" | sed 's/\r//g')"

      if [[ ${c} -eq 0 ]]; then
          c=$(( ${c} + 1 ))
      else
          d=0
          echo "    {"
          while [[ ${d} -lt ${headings} ]]; do
              item="$(csv_nextField "${each_line}")"
              each_line="${each_line:${?}}"
              echo -n "        \"${head_array[${d}]}\": "
              case "${item}" in
                  "")
                      echo -n "null"
                      ;;
                  null|true|false|\"*\"|+'('[0123456789]')')
                      echo -n ${item}
                      ;;
                  *)
                      echo -n "\"${item}\""
                      ;;
              esac
              d=$(( ${d} + 1 ))
              [[ ${d} -lt ${headings} ]] && echo "," || echo ""
          done

          echo -n "    }"

          c=$(( ${c} + 1 ))
          [[ ${c} -lt ${lines} ]] && echo "," || echo ""
      fi

  done < "${input}"
  echo "]"
}

function csv_to_array {
  local STDIN="$(cat)"
  local list=()
  while IFS=',' read -r -a my_array
  do
    list+=(${my_array[*]})
  done <<< $(echo "${STDIN[@]}");
  echo -n ${list[@]}
}

csv_to_arrays() {
    local -a values
    local -a headers
    local counter

    IFS=, read -r -a headers
    declare -ag new_array=()
    counter=1
    while IFS=, read -r -a values; do
        new_array+=( row$counter )
        declare -Ag "row$counter=($(
            paste -d '' <(
                printf "[%s]=\n" "${headers[@]}"
            ) <(
                printf "%q\n" "${values[@]}"
            )
        ))"
        (( counter++ ))
    done
    declare -p new_array ${!row*}
}

function csv_to_data {
  local -a values
  local -a headers
  local counter
  local array_name="${1:-new_array}"

  IFS=, read -r -a headers
  eval "unset ${array_name:-new_array}; unset ${!row*}; declare -ag $array_name"
  counter=1

  while IFS=, read -r -a values; do
    [ "$counter" = 1 ] && eval "echo unset $array_name"
    rand="${RANDOM}"
    eval "unset row${counter}_${rand};"
    eval "echo ${array_name:-new_array}+=\( row${counter}_${rand} \)"
    declare -Ag "row${counter}_${rand}=($(
        paste -d '' <(
            printf "[%s]=\n" "${headers[@]}"
        ) <(
            printf "%q\n" "${values[@]}"
        )
    ))"
    (( counter++ ))
  done
  declare -p ${array_name:-new_array} ${!row*}
}

function json_escape () {
  get_stdin
  printf '%s' "$STDIN" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

# number filters

function if_more_than {
  get_stdin
  if (( $(echo "${STDIN//[Aa-Zz<>: \/£$]/} > $1" | $bc -l) ));then
    echo -n "$STDIN"
  else
    return 1
  fi
  return 0
}

function if_less_than {
  get_stdin
  if (( $(echo "${STDIN//[Aa-Zz<>: \/£$]/} < $1" | $bc -l) ));then
    echo -n "$STDIN"
  else
    return 1
  fi
  return 0
}

function at_most {
  get_stdin
  if (( $(echo "${STDIN//[Aa-Zz<>: \/£$]/} > $1" | $bc -l) ));then
    echo -n "$1"
  else
    echo -n "$STDIN"
  fi
}

function at_least {
  get_stdin
  if (( $(echo "${STDIN//[Aa-Zz<>: \/]/} < $1" | $bc -l) ));then
    echo -n "$1"
  else
    echo -n "$STDIN"
  fi
}

function without_trailing_zeros {
  get_stdin
  echo -n "${STDIN//.[0-9.*]*[^ A-Za-z\-_()]/}"
}

function to_int {
  get_stdin
  echo -n `echo "(${STDIN}+0.5)/1" | $bc`
}

function ceil {
  get_stdin
  echo -n `echo "define ceil (x) {if (x<0) {return x/1} \
          else {if (scale(x)==0) {return x} \
          else {return x/1 + 1 }}} ; ceil($STDIN)" | $bc`
}

function floor {
  get_stdin
  local floored_int=${STDIN//.*/}
  floored_int=${floored_int//,*/}
  echo -n $floored_int
}

function modulo {
  get_stdin
  echo -n $(($STDIN % $1))
}

function plus {
  get_stdin
  echo -n $(($STDIN + $1))
}

function minus {
  get_stdin
  echo -n $(($STDIN - $1))
}

function divided_by {
  get_stdin
  echo -n `echo "(${STDIN}/${1})" | $bc -l`
}

function decimal_places {
  get_stdin
  echo -n `echo "scale=$1; (${STDIN}/1)" | $bc`
}

function money {
  get_stdin
  # make the following vars available (example for en_US):
  #   int_curr_symbol="USD "
  #   currency_symbol="$"
  #   mon_decimal_point="."
  local locale_currency_settings="$(locale -ck LC_MONETARY | grep -E '^int_curr_symbol=|^currency_symbol=|^mon_decimal_point=')"
  eval "$locale_currency_settings"
  # allow user to override these locale settings with $1 and $2
  local symbol=${1:-$currency_symbol}
  # formatting won't work C locale, fallback to en_US
  [ "$LC_ALL" = "C" ] && local LC_ALL=en_US.UTF-8
  # if we have a curreny symbol, prepend it
  [ ! -z "$symbol" ] && echo -n $symbol
  # print the (locale aware) formatted price
  printf "%'.2f" $STDIN
}

function money_with_currency {
  get_stdin
  # make the following vars available (example for en_US):
  #   int_curr_symbol="USD "
  #   currency_symbol="$"
  #   mon_decimal_point="."
  local locale_currency_settings="$(locale -ck LC_MONETARY | grep -E '^int_curr_symbol=|^currency_symbol=|^mon_decimal_point=')"
  eval "$locale_currency_settings"
  # allow user to override these locale settings with $1 and $2
  local symbol=${1:-$currency_symbol}
  local name=${2:-$int_curr_symbol}
  # formatting won't work C locale, fallback to en_US
  [ "$LC_ALL" = "C" ] && local LC_ALL=en_US.UTF-8
  # if we have a curreny symbol, prepend it
  [ ! -z "$symbol" ] && echo -n $symbol
  # print the (locale aware) formatted price
  printf "%'.2f" $STDIN
  # append the international currency name, if not empty
  [ ! -z "$name" ] && echo -n " $name"
}

function money_without_currency {
  get_stdin
  # formatting won't work C locale, fallback to en_US
  [ "$LC_ALL" = "C" ] && local LC_ALL=en_US.UTF-8
  # print the (locale aware) formatted price
  printf "%'.2f" $STDIN
}

function convert {
  get_stdin
  case "$1-$3" in
      inches-feet)
        new_value=`echo "${STDIN} / 12" | $bc -l`
        ;;
      inches-feet)
        new_value=`echo "${STDIN} * 12" | $bc -l`
        ;;
      miles-kms)
        new_value=`echo "${STDIN} * 1.6" | $bc -l`
        ;;
      kms-miles)
        new_value=`echo "${STDIN} / 1.6" | $bc -l`
        ;;
      kgs-stones)
         new_value=`echo "(${STDIN} * 2.205) / 14" | $bc -l`
        ;;
      stones-kgs)
         new_value=`echo "(${STDIN} / 2.205) * 14" | $bc -l`
        ;;
      kgs-lbs)
         new_value=`echo "${STDIN} * 2.205" | $bc -l`
        ;;
      lbs-kgs)
         new_value=`echo "${STDIN} / 2.205" | $bc -l`
        ;;
      gallons-quarts)
        new_value=`echo "${STDIN} * 4" | $bc -l`
        ;;
      *)
        echo -n "$STDIN" && return 1
        ;;
  esac
  printf "%'.2f" $new_value
  return 0
}

function ordinal {
  get_stdin
  case "$STDIN" in
    *1[0-9] | *[04-9]) echo "$STDIN"th;;
    *1) echo "$STDIN"st;;
    *2) echo "$STDIN"nd;;
    *3) echo "$STDIN"rd;;
  esac
}

# arrays

# combine two arrays
function concat {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi
  local arr=("${STDIN[@]}" "${@}")
  echo -n ${arr[@]}
}

# remove empty items from an array
function compact {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi
  local arr=()
  for i in "${STDIN[@]}"
  do
    [ "$i" != "" ] && arr+=("${i}")
  done
  echo -n ${arr[@]}
}

# unique without sort
function unique {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi
  local arr=()
  local dupes
  declare -A dupes
  for i in ${STDIN[@]}; do
    if [[ -z "${dupes[$i]}" ]]; then
        arr+=("$i")
    fi
    dupes["$i"]=1
  done
  echo -n ${arr[@]}
}

function exclude {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi
  local arr=()
  for bit in ${STDIN[@]}
  do
    # if we find the excluded word, dont add to $arr
    grep -q "$1" <<<"$bit" || arr+=("$bit")
  done
  # return the array with excluded resutls
  echo -n  ${arr[@]}
}

function exclude_first {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi
  local arr=()
  local removed=false
  for bit in ${STDIN[@]}
  do
    # if we find the excluded word, dont add to $arr
  if [ "$removed" = true ];then
    arr+=("$bit")
  else
    grep -q "$1" <<<"$bit" && removed=true || { arr+=("$bit"); }
  fi
  done
  # return the array with excluded resutls
  echo -n  ${arr[@]}
}

function exclude_last {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi
  local arr=()
  local removed=false
  for bit in `echo ${STDIN[@]} | rev`
  do
    # if we find the excluded word, dont add to $arr
  if [ "$removed" = true ];then
    arr+=("$bit")
  else
    grep -q "`echo $1 | rev`" <<<"$bit" && removed=true || { arr+=("$bit"); }
  fi
  done
  # return the array with excluded resutls
  echo -n  ${arr[@]} | rev
}


function exclude_exact {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi
  local arr=()
  for bit in ${STDIN[@]}
  do
    # if we find the excluded word, dont add to $arr
    grep -q "^$1$" <<<"$bit" || arr+=("$bit")
  done
  # return the array with excluded resutls
  echo -n  ${arr[@]}
}

function limit {
  get_stdin

  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi


  local arr=()
  local i=0
  for bit in ${STDIN[@]}
  do
    # if current index ($i) NOT more than $limit ,
    # add current array item ($bit) to array to
    # return ($arr)
    [ $i -ge ${1:-9999} ] && break
    arr+=("$bit")
    i=$(($i + 1))
  done
  # return the limited length array
  echo -n ${arr[@]}
}

# sort an array asc, desc.. works for numbers and strings
function sort_array {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi

  local order="${1//asc/}"
  order="${order//desc/-r}"
  local new_arr=($(for v in ${STDIN[@]}; do echo $v; done | sort $order -n))
  echo -n ${new_arr[@]}
}

# join array items into string.. $1 is the delimeter
function join_by {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi
  for item in ${STDIN[@]}
  do
    echo -n "${item}${1:-,}"
  done
}

function where {
  get_stdin
  # if we received declare commands from csv_to_arrays,
  # eval them to set the arrays, and set STDIN to $new_array[@]
  if [ "$(echo "$STDIN" | grep '^declare ')" != "" ];then
    source <(cat)
    eval "$STDIN"
    STDIN="${new_array[@]}"
  fi
  local arr=()
  local opt_count=$#
  # if user gave "where foo = bar", or similar
  if [ $# -eq 3 ];then
    # get the "needle", the thing we match against
    needle="$3"
    needle_val="$(eval "echo $3")"
    [ "$needle" != "$needle_val" ] && needle="$needle_val"
    # create a new hash to return later
    declare -Ag arrHash
    # for each hash in the given array
    for hash in ${STDIN[@]}
    do
      # get the hash keys
      hash_keys="$(eval "echo \${!$hash[@]}")"
      # for each key
      for hashkey in $hash_keys
      do
        # reset
        return_the_array=false
        # if $hashkey matches the key named in the where filter,
        # lets check it matches the given expression
        if [ "$hashkey" = "$1" ];then
          # get the value of the hash key
          hashkey_value="$(eval echo "\${$hash[$hashkey]}")"
          # lets match and evalutate the given expression:
          # $2 is the given operator.. if the current hash key matches
          # the given key, perform the expression, and if it passes
          # (returns truthy), then we will return that part of the array
          # as it matches the 'where' condition given by the user
          case "$2" in
            '=')
              [ "$hashkey_value" = "$needle" ] && return_the_array=true
              ;;
            '!=')
              [ "$hashkey_value" != "$needle" ] && return_the_array=true
              ;;
            '>')
              if [ "$hashkey_value"  -gt "$needle" ];then return_the_array=true; fi
              ;;
            '>=')
              if [ "$hashkey_value"  -ge "$needle" ];then return_the_array=true; fi
              ;;
            '<')
              if [ "$hashkey_value"  -lt "$needle" ];then return_the_array=true; fi
              ;;
            '<=')
              if [ "$hashkey_value"  -le "$needle" ];then return_the_array=true; fi
              ;;
            'contains')
              [[ "$hashkey_value" == *"$needle"* ]] && return_the_array=true
              ;;
          esac
          # if $return_the_array = true, then we found the right key and
          # filtered it, so lets add the data from this iteration to the
          # array to return
          if [ "$return_the_array" = true ];then
            # create the hash/key value pair to add to the hash
            arrHash["$hashkey"]="$hashkey_value"
            # add the key/val pair to our new hash
            eval "$hash[${!arrHash[@]}]=\"${arrHash[@]}\""
            # and add the hash to the tmp array to return
            arr+=("${hash[@]}")
          fi
        fi
      done
    done
    # return the array and leave
    echo -n ${arr[@]}
    return 0
  fi
  # here we process normal (non multi-dimensional) arrays..
  # if user gave "where contains foo" or "where = foo"
  if [ $# -eq 2 ];then
    for value in ${STDIN[@]}
    do
      case "$1" in
        '=')
          [ "$value" = "$needle" ] && arr+=("$value")
          ;;
        '!=')
          [ "$value" != "$needle" ] && arr+=("$value")
          ;;
        '>')
          if [ "$value" -gt "$needle" ];then arr+=("$value"); fi
          ;;
        '>=')
          if [ "$value" -ge "$needle" ];then arr+=("$value"); fi
          ;;
        '<')
          if [ "$value" -lt "$needle" ];then arr+=("$value"); fi
          ;;
        '<=')
          if [ "$value" -le "$needle" ];then arr+=("$value"); fi
          ;;
        'contains')
          [[ "$value" == *"$2"* ]] && arr+=("$value")
          ;;
      esac
    done
    echo -n ${arr[@]}
    return 0
  fi
  # if we got here, the user filter given was `where foo`, so
  # lets simply filter out the array keys whose values DONT
  # contain 'foo'
  for value in ${STDIN[@]}
  do
    grep -q "^$1$" <<<"$value" && arr+=("$value")
  done
  echo -n ${arr[@]}
}

function sort_by {
    local field sort_params elem
    field=$1
    # Build array with sort parameters
    [[ $2 == 'desc' ]] && sort_params+=('-r')
    [[ $field == 'age' ]] && sort_params+=('-n')
    # Schwartzian transform
    for elem in $(cat); do
        declare -n ref=$elem
        printf '%s\t%s\n' "${ref["$field"]}" "$elem"
    done | sort "${sort_params[@]}" | cut -f2 | tr '\n' ' '
}


#
# e-commerce filters
#
