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

## TODO

Update mdshell:

- generate 3 files:

  - a proper markdown (file.md)
  - the source (file.mdsh)
  - and a plain text (file.txt)

- the file.md file should contain only the body post, and only valid markdown
- maybe... a bbcode version should be generated from the mdsh version

Post footer:

- put post author, contact, tags and category in post footer

Footer:

- main categories, like in header
- social media buttons/links
- links to about, sitemap, privacy page, terms of service, contact page,
- search box

RSS feed: generate it in update_pages

Randoms:

- fix posts.csv - include time (not only date)
- create publish.sh - uses git to add, commit, revert, push (publish) the site changes
