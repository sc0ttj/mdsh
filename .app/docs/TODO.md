# To do

### Fixes

### Refactor

#### HOW TO

- dont duplicate page data:

  - remove posts.csv:

    - search yml in `*.mdsh` files instead:
      - grep all `*.mdsh` files in one go to get site authors, tags, categories, etc
      - use `lookup` to grab specific values
        - save frontmatter to tmp yml file, then search that
    - search files/dirs:
      - use `find`, `grep` to list all/matching posts

- make build data easier to use:

  - indexed arrays:

    - site:
      - `site_authors`
      - `site_categories`
      - `site_tags`
      - `site_pages`
      - `site_recent_pages`

  - make `mo` support Javascript style, dot-notation format:

    - if it encounters `{{page_meta.descr}}`, check for `${page_meta[descr]}` and `${page[meta_descr]}`
    - if it encounters `{{page.js_deps[0]}}`, check for `${page_js_deps[0]}` and `${page[js_deps][0]}` (using eval)
    - then if it exists,
    - set that var as the current var/array/func to parse

  - make `foreach` support this syntax:

    - `{{#foreach foo in page_meta.js_deps}}`
    - if array not found, use `lookup` to find it..?

  - access vars like:

    - `{{var_name}}`
    - `{{var_name.assoc.key}}`
    - `{{var_name.array[int]}}`

  - access indexed arrays like:

    - `{{#foreach item in array_name}} {{item}} {{/array_name}}`
    - `{{#foreach item in foo.array_name}} {{item}} {{/array_name}}`

  - access associative arrays like:

    - `{{#foreach item in assoc_array}} {{item.foo}} {{/foreach}}`
    - `{{#foreach item in foo.assoc_name}} {{item.foo}} {{/foreach}}`

### More content

#### TOC

- func to generate a table of contents (TOC):

  - put it below post/page h2 heading, above first para
  - to be used by screen readers (a la skip to content) and as an aside on large screens
  - should output small menu of links to headers, something like:

```
1. h1 name
  2. h2 name
    a. h3 name
    b. h3 name
  3. h2 name
  4. h2 name
    a. h3 name
    b. h3 name
```

#### Icons

- add a nice, small icons set:
  - octicons, font-awesome, favicons
  - or similar
