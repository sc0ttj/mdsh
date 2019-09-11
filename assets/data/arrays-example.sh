# This is an example showing how to set template data
# using Bash variables and arrays.
#
# It's equivalent to having the following in a "footer_links.yml" file:
#
#    link1:
#      name: Site one
#      url: one.com
#    link2:
#      name: Site two
#      url: two.com
#
# The (YAML or Bash arrays) data can be used in your
# templates like so:
#
#  {{#foreach link in footer_links}}
#    {{link.name}} is at {{link.url}}
#  {{/foreach}}
#

# reset data.. important
unset footer_links link1 link2

# declare the array which will contain the *names* of our associative arrays
footer_links=(link1 link2)

# declare the associative array names
declare -A link1
declare -A link2

# add the data to the associative arrays
link1=(
  [name]="Site one"
  [url]="one.com"
)
link2=(
  [name]="Site two"
  [url]="two.com"
)
