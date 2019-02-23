

## Better site headers

I've updated the `create_page` script so that the `print_site_header` function now does the following:

- always include the homepage as the first link in the main navigation menu
- include all other HTML pages found in the root directory

So far, the following HTML files live in the root directory, and get included in the main site header as links:

- archive.html - lists all posts on the site, newest at the top, oldest at the bottom
- categories.html - lists all categories, links to specific category pages in `./categories/`
- index.html - the main homepage, listed first in the site header, as "home"
- tags.html - lists all tags, links to specific tag pages in `./tags/`
