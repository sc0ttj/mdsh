


`mdsh` now has a new feature, inspired by [Liquid filters](https://help.shopify.com/en/themes/liquid/filters).

The [Liquid templating](https://shopify.github.io/liquid/) system was created by [Shopify](https://www.shopify.co.uk/)
and is used in the templating system of [Jekyll](https://jekyllrb.com/).

Here's a description of "liquid filters" from the [liquid filters documentation](https://help.shopify.com/en/themes/liquid/filters):

> Filters are simple methods that modify the output of numbers, strings,
> variables and objects. They are placed within an output tag &#123;&#123; &#125;&#125; and are
> denoted by a pipe character |.

As `mdsh` is written in shell, and uses [`mo`](https://github.com/tests-always-included/mo)
as its [Mustache](https://mustache.github.io/mustache.5.html) library, I've
implemented a rip-off version of liquid filters.

You can use the filters in your `.mustache` templates files, and in your `.mdsh`
source files. You pass the variables through a filter using the pipe symbol `|`.

<h3>Usage and examples:</h3>

<h4>1. Template usage</h4>

<p><b>Filtering basic page data (strings):</b></p>

```handlebars
<h2>{{page_name | uppercase}}</h2>
```

<p>^ this will output the page title in upper case.</p>

<p>Here is a more advanced example:</p>

```handlebars
<h2>{{page_name | truncate_words 6 ".." | strip_newlines}}</h2>
```

<p>^ this will truncate to 6 words, and append `..` if truncated, and strip new lines.</p>

<p>These filters also can also be applied to whole sections (if you must!):</p>

```handlebars
{{page_header | strip_html}}
```

<p><b>Filtering arrays:</b></p>

<p>In your templates various places use arrays to iterate over lists, such as
recent posts. These lists can also be "filtered", in much the same way as the
page data variables described above.</p>

<p>In your templates, normal `arrays` work as iterators, that can also take filters.</p>

<p>For example:</p>

```handlebars
{{#someArray | sort_array desc | limit 3}}
  {{. | titlecase}}
{{/someArray}}
```

<p>Associative arrays also work nicely with the `foreach` iterator:</p>

```handlebars
{{#foreach item in someAssocArray | sort_by "age" "asc" | limit 3}}
  Hi {{item.name | titlecase}},
  at {{item.address | uppercase | newline_to_br}}
{{/foreach}}
```

<h4>2. Markdown usage</h4>

<p>You can even use them in the sub-shells of your `*.mdsh` source files:</p>

```
< ?bash echo "$something" | replace_all foo bar ;? >
```

<!-- more -->

<h3>Available filters:</h3>

<p>Here is a list of all the filters available:</p>

<h4>String filters</h4>

<p>Here is the general usage:</p>

<div>
```handlebars
{{someString | <filter> [options]}}
```
</div>

<div class="filter-heading">uppercase</div>
<div class="filter-body">
<p>Make text upper case:</p>
```handlebars
{{someString | uppercase}}
```
</div>

<div class="filter-heading">lowercase</div>
<div class="filter-body">
<p>Make text lower case</p>
```handlebars
{{someString | lowercase}}
```
</div>


<div class="filter-heading">titlecase</div>
<div class="filter-body">
<p>Make text title case</p>
```handlebars
{{someString | titlecase}}
```
</div>


<div class="filter-heading">capitalise</div>
<div class="filter-body">
<p>Capitalise first-letter of string, lower case the rest</p>
```handlebars
{{someString | capitalise}}
```
</div>


<div class="filter-heading">slugify</div>
<div class="filter-body">
<p>Convert string to slug</p>
```handlebars
{{someString | slugify}}
```
</div>


<div class="filter-heading">camelcase_to_slug</div>
<div class="filter-body">
<p>Convert camel case string to a slug</p>
```handlebars
{{someString | camelcase_to_slug}}
```
</div>


<div class="filter-heading">slug_to_camelcase</div>
<div class="filter-body">
<p>Convert a slug to camel case</p>
```handlebars
{{someString | slug_to_camelcase}}
```
</div>


<div class="filter-heading">lstrip</div>
<div class="filter-body">
<p>Remove leading whitepace from (left of string)</p>
```handlebars
{{someString | lstrip}}
```
</div>


<div class="filter-heading">rstrip</div>
<div class="filter-body">
<p>Remove trailing whitepace from (right of string)</p>
```handlebars
{{someString | rstrip}}
```
</div>


<div class="filter-heading">strip</div>
<div class="filter-body">
<p>Remove leading and trailing whitespace</p>
```handlebars
{{someString | strip}}
```
</div>


<div class="filter-heading">strip_html</div>
<div class="filter-body">
<p>Remove all HTML tags, keeping the inner content</p>
```handlebars
{{someString | strip_html}}
```
</div>


<div class="filter-heading">strip_newlines</div>
<div class="filter-body">
<p>Strip newline characters from string</p>
```handlebars
{{someString | strip_newlines}}
```
</div>


<div class="filter-heading">escape_html</div>
<div class="filter-body">
<p>Replace `&lt;p&gt;` with `&amp;lt;p&amp;gt;`</p>
```handlebars
{{someString | escape_html}}
```
</div>


<div class="filter-heading">unescape_html</div>
<div class="filter-body">
<p>Replace `&amp;lt;p&amp;gt;` with `&lt;p&gt;`</p>
```handlebars
{{someString | unescape_html}}
```
</div>


<div class="filter-heading">newline_to_br</div>
<div class="filter-body">
<p>Replace newline characters with `&lt;br&gt;` tags</p>
```handlebars
{{someString | newline_to_br}}
```
</div>


<div class="filter-heading">br_to_newline</div>
<div class="filter-body">
<p>Replace `&lt;br&gt;` tags with newline characters</p>
```handlebars
{{someString | br_to_newline}}
```
</div>


<div class="filter-heading">reverse</div>
<div class="filter-body">
<p>Reverse a string</p>
```handlebars
{{someString | reverse}}
```
</div>


<div class="filter-heading">replace_first</div>
<div class="filter-body">
<p>Replace first occurance of $1 with $2</p>
```handlebars
{{someString | replace_first 'old' 'new'}}
```
</div>


<div class="filter-heading">replace_last</div>
<div class="filter-body">
<p>Replace last occurance of $1 with $2</p>
```handlebars
{{someString | replace_last 'old' 'new'}}
```
</div>


<div class="filter-heading">replace_all</div>
<div class="filter-body">
<p>Replace all occurances of $1 with $2</p>
```handlebars
{{someString | replace_all 'old' 'new'}}
```
</div>


<div class="filter-heading">prepend</div>
<div class="filter-body">
<p>Prepend a string with another string</p>
```handlebars
{{someString | prepend 'some other string'}}
```
</div>


<div class="filter-heading">append</div>
<div class="filter-body">
<p>Append a string with another string</p>
```handlebars
{{someString | append 'some other string'}}
```
</div>

<div class="filter-heading">truncate</div>
<div class="filter-body">
<p>Truncate string to the given number of characters</p>
```handlebars
{{someString | truncate 20}}
```
</div>


<div class="filter-heading">truncate_words</div>
<div class="filter-body">
<p>Truncate string to the given number of words.</p>
<p>Optionally pass a string as the second parameter, which will be appended if text was indeed truncated.</p>
```handlebars
{{someString | truncate_words 20 '...'}}
```
</div>


<div class="filter-heading">time_to_read</div>
<div class="filter-body">
<p>Intelligently guesses the time to read the given string in "Mins"</p>
<p>Optionally, override the default units by giving the desired units name as the second parameter.</p>
```handlebars
{{someString | time_to_read "Minutes"}}
```
</div>


<div class="filter-heading">urlencode</div>
<div class="filter-body">
<p>Encode string to URL friendly format</p>
```handlebars
{{someString | urlencode}}
```
</div>


<div class="filter-heading">urldecode</div>
<div class="filter-body">
<p>Decode string from URL friendly format</p>
```handlebars
{{someString | urldecode}}
```
</div>


<div class="filter-heading">rgb2hex</div>
<div class="filter-body">
<p>Convert colour values `255 0 0` into `#ff0000`</p>
```handlebars
{{someString | rgb2hex}}
```
</div>


<div class="filter-heading">hex2rgb</div>
<div class="filter-body">
<p>Convert colour values `#ff0000` into `255 0 0`</p>
```handlebars
{{someString | hex2rgb}}
```
</div>


<div class="filter-heading">md5</div>
<div class="filter-body">
<p>Replace string with its md5 checksum</p>
```handlebars
{{someString | md5}}
```
</div>


<div class="filter-heading">sha1</div>
<div class="filter-body">
<p>Replace string with its sha1 checksum</p>
```handlebars
{{someString | sha1}}
```
</div>


<div class="filter-heading">sha256</div>
<div class="filter-body">
<p>Replace string with its sha256 checksum</p>
```handlebars
{{someString | sha256}}
```
</div>


<div class="filter-heading">sha512</div>
<div class="filter-body">
<p>Replace string with its sha512 checksum</p>
```handlebars
{{someString | sha512}}
```
</div>


### Data filters

<div class="filter-heading">markdown_to_html</div>
<div class="filter-body">
<p>Convert the given markdown to HTML</p>
```handlebars
{{someString | markdown_to_html}}
```
</div>


<div class="filter-heading">csv_to_markdown</div>
<div class="filter-body">
<p>Convert the given csv to a markdown table</p>
```handlebars
{{someString | csv_to_markdown}}
```
</div>


<div class="filter-heading">csv_to_html</div>
<div class="filter-body">
<p>Convert the given csv to an HTML table</p>
```handlebars
{{someString | csv_to_html}}
```
</div>


<div class="filter-heading">csv_to_json</div>
<div class="filter-body">
<p>Convert the given csv to JSON</p>
```handlebars
{{someString | csv_to_json}}
```
</div>


<div class="filter-heading">csv_to_array</div>
<div class="filter-body">
<p>Convert the given csv to a single, flat, indexed array</p>
```handlebars
{{someString | csv_to_array}}
```
</div>


<div class="filter-heading">csv_to_arrays</div>
<div class="filter-body">
<p>Convert csv data into an array of associative arrays. The CSV headers become
the arrays keys. It can be used to iterate over and filter CSV data in your
templates (see <b>Array filters</b> below).</p>
```handlebars
{{someString | csv_to_arrays}}
```
</div>


### Number filters

<div class="filter-heading">at_least</div>
<div class="filter-body">
<p>Sets a minimum value for returned numbers</p>
```handlebars
{{someNumber | at_least 10}}
```
</div>


<div class="filter-heading">at_most</div>
<div class="filter-body">
<p>Sets a maximum value for returned numbers</p>
```handlebars
{{someNumber | at_most 10}}
```
</div>


<div class="filter-heading">decimal_places</div>
<div class="filter-body">
<p>Limit number to the given number of decimal places</p>
```handlebars
{{someNumber | decimal_places 2}}
```
</div>


<div class="filter-heading">divided_by</div>
<div class="filter-body">
<p>Divide input by the given number</p>
```handlebars
{{someNumber | divided_by 2}}
```
</div>


<div class="filter-heading">minus</div>
<div class="filter-body">
<p>Subtract the given number from the input number</p>
```handlebars
{{someNumber | minus 2}}
```
</div>


<div class="filter-heading">plus</div>
<div class="filter-body">
<p>Add the given number to the input number</p>
```handlebars
{{someNumber | plus 2}}
```
</div>


<div class="filter-heading">modulo</div>
<div class="filter-body">
<p>Find remainder after division of input and given number</p>
```handlebars
{{someNumber | modulo 3}}
```
</div>


<div class="filter-heading">ordinal</div>
<div class="filter-body">
<p>Return the given number in ordinal form (112 => 112th)</p>
```handlebars
{{someNumber | ordinal}}
```
</div>


<div class="filter-heading">to_int</div>
<div class="filter-body">
<p>Convert a float to an int</p>
```handlebars
{{someNumber | to_int}}
```
</div>


<div class="filter-heading">floor</div>
<div class="filter-body">
<p>Round float down to the nearest integer</p>
```handlebars
{{someNumber | floor}}
```
</div>


<div class="filter-heading">ceil</div>
<div class="filter-body">
<p>Round float up to the nearest integer</p>
```handlebars
{{someNumber | ceil}}
```
</div>


<div class="filter-heading">pluralize</div>
<div class="filter-body">
<p>Append a singular (first param) or plural (second param) to a number</p>
```handlebars
{{someNumber | pluralize 'ox' 'oxen'}}
```
</div>


<div class="filter-heading">convert</div>
<div class="filter-body">
<p>Perform unit conversions. Supported conversions: inches/feet, miles/km,
kgs/stones, kgs/lbs, gallons/quarts</p>
```handlebars
{{someNumber | convert miles to km}}
```
</div>


### Money filters

<div class="filter-heading">money</div>
<div class="filter-body">
<p>Converts number to money format, with currency symbol (locale aware).</p>
<p>Optional: give the currency symbol to override the locale default.</p>
```handlebars
{{someNumber | money £}}
```
<p>If input is `10`, it will output:</p>
```
£10.00
```
</div>


<div class="filter-heading">money_with_currency</div>
<div class="filter-body">
<p>Converts number to money format, with currency symbol and name (locale aware)</p>
<p>Optional:</p>
<ul>
  <li>Give a currency symbol as the first parameter to override locale defaults.</li>
  <li>Give a currency name as the second parameter to override locale defaults.</li>
</ul>
```handlebars
{{someNumber | money_with_currency £ GBP}}
```
<p>If input is `10`, it will output:</p>
```
£10.00 GBP
```
</div>


<div class="filter-heading">money_without_currency</div>
<div class="filter-body">
<p>Converts number to money format, <em>without</em> currency symbol or name.</p>
```handlebars
{{someNumber | money_without_currency}}
```
</div>


<div class="filter-heading">without_trailing_zeros</div>
<div class="filter-body">
<p>Remove ".0*" from end of numbers (and strings).</p>
```handlebars
{{someNumber | without_trailing_zeros}}
```
</div>


#### Date filters

<p>These filters can be used with the variables `page_created` and `page_modified`,
 or any others which hold dates in this format: <em>2019-07-13T23:56:01Z</em></p>

<div class="filter-heading">date_format</div>
<div class="filter-body">
<p> Re-format a date, where `format` is a named format, GNU date format or 'now':</p>
<ul>
  <li>`basic` => 09/31/2019</li>
  <li>`basic_uk` => 31/09/2019</li>
  <li>`iso8601` =>  2019-90-31</li>
  <li>`to_string` => 09 Nov 2019</li>
  <li>`to_long_string` => 09 November 2019</li>
  <li>`rfc822` => Mon, 09 Nov 2019 13:07:54 -0800</li>
  <li>`"%Y %m %d"` => 2019 09 31</li>
  <li>`"%d %B %Y"` => 31 November 2009</li>
</ul>
```handlebars
{{page_created | date_format 'basic_uk'}}
```
or

```handlebars
{{page_created | date_format "%d %B %Y"}}
```
<p>Note that `rfc822` has these easier aliases:</p>
<ul>
  <li>`rss`</li>
  <li>`email`</li>
</ul>
<p>You can also use `now` to get the current date/time when the page is built:</p>
```handlebars
{{now | date_format rss}}
```
</div>

#### HTML filters

<div class="filter-heading">absolute_url</div>
<div class="filter-body">
<p> Return the absolute URL to the given file, starting with <em>http://${blog_domain}${blog_url}</em>.</p>
```handlebars
{{someURL | absolute_url}}
```
</div>


<div class="filter-heading">relative_url</div>
<div class="filter-body">
<p>Return a relative URL to the given string, starting with "${blog_url}" (top dir of blog).</p>
```handlebars
{{someURL | relative_url}}
```
</div>


<div class="filter-heading">asset_url</div>
<div class="filter-body">
<p>Return a relative path to the given file, appended with a timestamp as a
query string, for cache busting purposes. Uses `find` to locate the path to the
file (if it exists), else it uses the given string.</p>
```handlebars
{{someURL | asset_url}}
```
</div>


<div class="filter-heading">link_tag</div>
<div class="filter-body">
<p>Return a `&lt;a href=".."&gt;..&lt;/a&gt;` tag, linking to the given string.<p>
<p>Works well with these other filters: `asset_url`, `absolute_url`, `relative_url`.</p>
```handlebars
{{someURL | absolute_url | link_tag "My link title"}}
```
</div>


<div class="filter-heading">time_tag</div>
<div class="filter-body">
<p> Return a `&lt;time&gt;` tag, with `datetime` attribute. $1 is required and formats
the printed (visible) date. $2 is optional, and formats the `datetime` attribute.</p>
<p>Supports the same options as the `date_format` filter: `basic`, `basic_uk`,
`to_string`, `email`, and GNU date format strings like `%d %M %Y %H:%M`.</p>
```handlebars
{{someDate | time_tag basic iso8601}}
```
<p>Outputs:</p>
```html
<time datetime="2019-07-13">13 July, 2019</time>
```
</div>


<div class="filter-heading">script_tag</div>
<div class="filter-body">
<p>Return the given content wrapped inside a &lt;script&gt; tag.</p>
```handlebars
{{someString | script_tag}}
```
</div>


<div class="filter-heading">stylesheet_tag</div>
<div class="filter-body">
<p>Return the given content wrapped inside a &lt;stylesheet&gt; tag.</p>
```handlebars
{{someString | stylesheet_tag}}
```
</div>


<div class="filter-heading">img_tag</div>
<div class="filter-body">
<p>Return the given URL wrapped inside an &lt;img&gt; tag.</p>
<p>Optionally set the alt text using the first parameter.</p>
<p>Works well with `asset_url`.</p>
```handlebars
{{someURL | asset_url | img_tag "My alt text."}}
```
</div>


#### Array filters

<div class="filter-heading">concat</div>
<div class="filter-body">
<p>Concatenate two arrays (append one to another).</p>
```handlebars
{{#someArray | concat 'otherArrayName'}}
  ...
{{/someArray}}
```
</div>


<div class="filter-heading">compact</div>
<div class="filter-body">
<p>Remove empty items from array.</p>
```handlebars
{{#someArray | compact}}
  ...
{{/someArray}}
```
</div>


<div class="filter-heading">unique</div>
<div class="filter-body">
<p>Remove duplicate items from array.</p>
```handlebars
{{#someArray | unique}}
  ...
{{/someArray}}
```
</div>


<div class="filter-heading">limit</div>
<div class="filter-body">
<p>Limit total items returned to the given number.</p>
```handlebars
{{#someArray | limit 5}}
  ...
{{/someArray}}
```
</div>


<div class="filter-heading">exclude</div>
<div class="filter-body">
<p>Exclude all items containing the given string.</p>
```handlebars
{{#someArray | exclude 'foo'}}
  ...
{{/someArray}}
```
</div>


<div class="filter-heading">exclude_first</div>
<div class="filter-body">
<p>Exclude the first item containing the given string.</p>
```handlebars
{{#someArray | exclude_first 'foo'}}
  ...
{{/someArray}}
```
</div>


<div class="filter-heading">exclude_last</div>
<div class="filter-body">
<p>Exclude the last item containing the given string.</p>
```handlebars
{{#someArray | exclude_last 'foo'}}
  ...
{{/someArray}}
```
</div>

<div class="filter-heading">exclude_exact</div>
<div class="filter-body">
<p>Exclude all items matching the given string exactly.</p>
```handlebars
{{#someArray | exclude_exact 'foo'}}
  ...
{{/someArray}}
```
</div>


<div class="filter-heading">join_by</div>
<div class="filter-body">
<p>Convert an array into a string delimeted by the given string.</p>
```handlebars
{{#someArray | join_by ','}}
  {{.}}
{{/someArray}}
```
</div>


<div class="filter-heading">sort_array</div>
<div class="filter-body">
<p>Sort the array 'asc' or 'desc'.</p>
```handlebars
{{#someArray | sort_array 'asc'}}
  ...
{{/someArray}}
```
</div>


<div class="filter-heading">sort_by</div>
<div class="filter-body">
<p>Sort an array by the given key, either ascending or descending.</p>
```handlebars
{{#foreach item in someAssocArray | sort_by someKey desc}}
  ...
{{/foreach}}
```
</div>


<div class="filter-heading">where</div>
<div class="filter-body">
<p>Keep only the array items matching the given string/expression.</p>
<p>Usage of `where`, with associative arrays (hashes):</p>

```handlebars
{{#foreach item in someAssocArray | where someKey '!=' 'foo'}}
  ...
{{/foreach}}

{{#foreach item in someAssocArray | where someKey 'contains' 'foo'}}
  ...
{{/foreach}}

{{#foreach item in someAssocArray | where someKey '!=' 'foo'}}
  ...
{{/foreach}}

{{#foreach item in someAssocArray | where someKey '=' 'foo'}}
  ...
{{/foreach}}

{{#foreach item in someAssocArray | where someKey '>=' 20}}
  ...
{{/foreach}}

{{#foreach item in someAssocArray | where someKey '<' 60}}
  ...
{{/foreach}}
```

<p>Usage of `where` With simple (indexed) arrays:</p>

```handlebars
{{#someIndexedArray | where contains "Smith" }}
  {{.}}
{{/someIndexedArray}}

{{#someIndexedArray | where ">" 20 }}
  {{.}}
{{/someIndexedArray}}
```
</div>

### Conclusion

Using these filters, you can do even more with your templates - transform date
formats on the page, sanitize names, exclude specific items, re-order content
and more.

But be aware that using lots of filters will slow down your pages build times.
