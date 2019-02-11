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

- tags/index.html - links to all tag pages available.
- update posts page - add tags as links to posts, link to tags/<tagname>.html
- fix posts.csv - include time (not only date)
- fix order of recents (use posts.csv)
- publish.sh - uses git to add, commit, revert, push (publish) the site changes
