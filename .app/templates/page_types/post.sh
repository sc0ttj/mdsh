echo -n "Time to read: "
read -er time_to_read

# -a   sets indexed array
# -g   makes it global (exports to env)
declare -ag front_matter_fields

# declare the associative array names
# -A   sets assoc array
# -g   makes it global (exports to env)
declare -Ag ttr_field

ttr_field=(
  [varname]="time_to_read"
  [value]="$time_to_read"
)

# declare the array which will contain the *names* of our associative arrays
front_matter_fields=(ttr_field)

export front_matter_fields
