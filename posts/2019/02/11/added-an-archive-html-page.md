


## Archive.html

I've added some new stuff to `update_pages`:

- It will now generate an `archive.html` page, which lists all posts on the site, oldest at the top.
- It will also generate tag pages.

### Tag pages

For each tag you add to a post, `update_pages` wil generate a `tags/<tag-name>.html` page, which lists all posts tagged with the relevant tag.

Example: You create a post with the tag 'games', and a `tags/games.html` page will be generated, listing that post.
