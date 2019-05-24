# To do

- site navigation menu (which should appear in site footer, or an aside for large screens)

  - should output something like:

```
  Main:

    - Home
    - About
    - Foo (root dir html pages)

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

- add a nice, small icons set:
  - octicons, font-awesome, favicons
  - or similar
