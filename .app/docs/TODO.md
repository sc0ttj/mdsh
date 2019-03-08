# To do

- production bundles:

  - reduce network requests

    - combine css stylesheets
    - combine js

  - simple minify: echo `cat "$file"` > newfile
    - minify the css, html js in `./assets/*/`

- func to build navigation menu (which should appear in site footer, or an aside for large screens)

  - should output something like:

```
  Main:

    - Home
    - About
    - Foo (root dir html pages)

  Suggested:

    - post one
    - post two
    - post three

  Recent:

    - post one
    - post two
    - post three
    - post four

  Categories:

   bash
    - post one
    - post two

   css
    - post one
    - post two
    - post three

  Tags:

    list, all, tags, here,
    comma, separated,
    and-stuff, more, last
```

- func to generate a table of contents (TOC):

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

- more stylesheets:

  - github clone
  - gitlab clone
  - npm clone
  - medium clone
  - jekyll clone
  - hugo clone
  - wordpress clone
  - stack overflow clone
  - facebook clone
  - minimalist

- add a nice, small icons set:
  - favicons
  - or similar

* a suggested posts add-on:
  - store clicked tags, categories & post titles in localStorage
  - find related posts
  - add those to a "Suggested posts" section in the post footer or site navigation
