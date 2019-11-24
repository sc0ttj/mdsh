# get the values we want in our front matter
echo -n "Currency (symbol): "
read -er currency_value

echo -n "Price: "
read -er price_value

# -a   sets indexed array
# -g   makes it global (exports to env)
declare -ag front_matter_fields

# declare the associative array names
# -A   sets assoc array
# -g   makes it global (exports to env)
declare -Ag currency_field
declare -Ag price_field

currency_field=(
  [varname]="product_currency"
  [value]="$currency_value"
)
price_field=(
  [varname]="product_price"
  [value]="$price_value"
)

# declare the array which will contain the *names* of our associative arrays
front_matter_fields=(currency_field price_field)

export front_matter_fields
