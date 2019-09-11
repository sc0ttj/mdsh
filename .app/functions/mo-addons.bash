
# Public: Iterate over arrays
#
# $1 - the row or item name
# $2 - must be a string that equals 'in'
# $3 - An indexed array, otionally containing references to associative arrays
#
# Returns parsed content
function foreach {
  # Trying to use unique names
  local foreachSourceName foreachIterator foreachEvalString foreachContent

  foreachContent=$(cat)

  if [[ "$2" != "in" ]]; then
      echo "Invalid foreach - bad format."
  elif [[ "$(declare -p "$3")" != "declare -"[aA]* ]]; then
      echo "$3 is not an array"
  elif [[ "$(declare -p "$3")" != "declare -"[gGaA]* ]]; then
      echo "$3 is not an array"
  elif [[ "$(declare -p "$3")" != "declare -"[aAgG]* ]]; then
      echo "$3 is not an array"
  else
    foreachSourceName="${3}[@]"

    for foreachIterator in "${!foreachSourceName}"; do

      foreachEvalString=$(declare -p "$foreachIterator")

#      xmessage "\$3 is $3
#      foreachEvalString = 'declare -p $foreachIterator'
#      \$foreachEvalString     $foreachEvalString
#      declare -A $1=${foreachEvalString#*=}
#      " &

      # skip if given key not found in current assoc array
      [ "$(echo ${foreachEvalString} | grep '(')" = "" ] && continue

      foreachEvalString="declare -A $1=${foreachEvalString#*=}"

      eval "$foreachEvalString"
      echo "$foreachContent" | mo
    done
  fi
}

