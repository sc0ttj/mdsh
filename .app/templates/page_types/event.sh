echo -n "Start date (in format YYYY-MM-DD:HHMM): "
read -er start_date

echo -n "End date (in format YYYY-MM-DD:HHMM): "
read -er end_date

# -a   sets indexed array
# -g   makes it global (exports to env)
declare -ag front_matter_fields

# declare the associative array names
# -A   sets assoc array
# -g   makes it global (exports to env)
declare -Ag start_date_field
declare -Ag end_date_field

start_date_field=(
  [varname]="start_date"
  [value]="$start_date"
)

end_date_field=(
  [varname]="end_date"
  [value]="$end_date"
)

# declare the array which will contain the *names* of our associative arrays
front_matter_fields=(start_date_field end_date_field)

export front_matter_fields
