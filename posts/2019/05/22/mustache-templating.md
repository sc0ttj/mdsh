

I've totally re-written `mdsh`. It now uses a Mustache templating system, which makes it much easier to edit, manage and create layouts for your pages.

Template files live in `.app/templates/`, sorted by type into folders - `html`, `js`, etc.

### The basics

The templates require various variables to be set before they are used - collectively we can call these variables the "page data":

```
page_header
page_lang
page_title
page_slug
page_descr
page_category
page_created
page_modified
page_time_to_read
page_keywords
page_author
page_author_slug
page_twitter
page_js_deps
page_google_analytics_id
page_url
```

Here is an example template which uses some of the page data above:

```
<h2>{{page_title}}</h2>
<p>{{page_descr}}</p>
```

<!-- more -->

For more complex stuff, read on.

### How the templating works

A `render` function is used in `generate_page_content` to run `mo` and convert
templates to HTML, using the `$page_` variables as input data.

There is a "main" template in `.app/templates/html/main.mustache`. This is the
template from which your HTML pages are generated. It includes things like
`{{site_header}}`, and if you look in
`.app/functions/generate_page_content.bash`, you'll see a function
_also_ called `site_header` - it's this function which generates the site header
HTML output for the `main` template.

You can add new functions to these files which generate HTML for any page areas
or elements, and call them in the templates like so: `{{my_func_name}}`.

### More advanced usage

In order to do complex things, like using custom variables, complex logic, etc,
you can create a shell function, called `foo`, which outputs HTML, and you can
then call that function in your templates like so:

```
{{foo}}
```

^ this will execute your `foo` shell function, and replace `{{foo}}` with the
output of your function. This is very handy if you need some complex logic to
manage your HTML output, or if you need to pre-process some other templates
using different data, before inserting it into your page.

### Loops in templates

If you need to create a loop in your templates, then you have to do it this way:

Example: let's create a template called "coolthing", that uses a loop:

1. create a `.app/templates/html/coolthing.mustache` file, that looks like this:

```handlebars
<ul class="some-list">
  {{#ITEMS}}

    <li>
      {{ITEM.name}} - {{ITEM.descr}}
    </li>

  {{/ITEMS}}
</ul>
```

2. add `{{coolthing}}` to one of the existing templates

3. add a function called 'coolthing' to a file in `.app/functions/`

4. in your new function:
    - get some data - a list of posts, authors, or something like that
    - create an empty `ITEMS` array, like so: `ITEMS=()`
    - create a `for` or `while` loop, and inside it:
        - create some `items` variables: `item_name="cool name"; item_descr="bar baz";`
        - create the variable `$hash_name`, containing your hash:
            - `hash_name="hash_${RANDOM}"; declare -A $hash_name`
        - add it all to the ITEMS array: `eval $ (add_keys_to_hash)`
    - lastly, after your loop, return the HTML by calling `render coolthing`

...and that's all about the new templating system, for now.

The `item` variables available inside the `{{#ITEM}}` loops of your templates are:

```
ITEM.title
ITEM.slug
ITEM.descr
ITEM.category
ITEM.created
ITEM.modified
ITEM.time_to_read
ITEM.keywords
ITEM.author
ITEM.author_slug
ITEM.twitter
ITEM.js_deps
ITEM.google_analytics_id
ITEM.url
```


### Other recent changes to `mdsh`

#### Cleaner code

  * all data (post and page vars) now separated from layouts completely
  * All data (from meta info in `.mdsh` files, or from `post_**` vars passed to
  `create_page.sh`) gathered and organised into arrays, then passed to `mo`.
  * All templates separated into `<renderer>/_<layout>.mustache` (Example:
`html/_list.mustache`)
  * Main scripts are as DRY as can be.

#### Render multiple formats

  - templates for different output types (HTML, JS, JSON-LD) live in different folders
  - look in  `.app/templates/<format>/`
  - where `<format>` can be `html`, `json-ld`, `js`
  - in future, can add more formats: `css`, `amp`, `fbia`, `rss`, etc
  - this makes it easy to render the site in HTML, and in other formats

#### Fixes in `JSON-LD` generation

  - better breadcrumbs
  - fixed all URLs (should be full URLs, not relative)
  - fixed author info
  - fixed `mainEntityOfPage` in article info

#### More robust CSS for post headers/footers

  - not using `nth-child()` anymore,
  - added some class names to target instead

#### W3C validation

  - removing the Google Font URL (containing `|`) from `<head>` fixes a W3C
validation error
  - CSS and JSON-LD also validate

#### Frontend performance improvement

  - add Google Font CSS to main CSS file at build time

#### Improvements to search page

  - better document/heading layout, looks nicer

#### Improvements displaying page/post dates

  - using `<time datetime="2019-06-24">`

#### Fixes in page meta

  - fixed canonical url
  - simpler google analytics stuff
  - fixed IE classes

#### Improvements to `publish.sh`

  - fixed: don't publish out-of-date sitemap and RSS feeds
  - the solution used: commit & push the pages first, _then_ generate the RSS feed and XML sitemaps...
  - (The RSS feed and XML sitemaps are generated from the online/published version of the site, hence committing & pushing the html pages first..)
