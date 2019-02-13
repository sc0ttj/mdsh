# README

Write your blog straight from the terminal.

## Usage

`.site_config` - important site settings like blog name, description, url, etc.

`create_post` - create a new post (add meta, then markdown content)

`create_page > index.html` - generate default index, listing recent posts

`create_page posts/xx/xx/xx/file.md` - create HTML page from markdown file

`create_page "$some_HTML_string"` - create custom page containing the given HTML

`update_pages` - rebuild all pages and indexes on the site

`mdshell /path/to/file.md` - interactive shell for creatin markdown documents

DONE

- archive.html - lists all posts
- tags/$tagname.html - lists all posts matching tag
- add [-all] option to `update`, and only update posts if it is given (else only update index pages [tags, categories, archive, etc])

## TODO

Update page header:

- auto-include in main menu all `*.html` files in the root dir (index.html, tags.html, categories.html, archive.html, about.html, etc)

Update mdshell:

- generate 3 files: a proper markdown (file.md), the source (file.mdsh) and file.txt
- the 'source' file (file.mdsh) should contain exactly what was entered in the terminal, and the meta info at the top
- the file.md file should contain only the body post, and only valid markdown
- a plain text version (file.txt) should be generated from the mdsh version
- maybe... a bbcode version should be generated from the mdsh version

Footer:

- main categories, like in header
- social media buttons/links
- links to about, sitemap, privacy page, terms of service, contact page,
- search box

RSS feed: generate it in update_pages

Randoms:

- fix posts.csv - include time (not only date)
- fix order of recents (use posts.csv)
- create publish.sh - uses git to add, commit, revert, push (publish) the site changes
