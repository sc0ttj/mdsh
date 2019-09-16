

I've added a `.gitignore` file to the root directory of the `mdsh` repo, so that when you create new pages or posts, only the HTML files will be deployed to the server - the source files (`.mdsh` and `.md`) will remain on the local machine only.

This is to makes things work better with another new feature - unpublishing posts.

If a post has been unpublished, it is removed from the site, and all index pages are updated. So it makes sense not to publish the source files of pages - so that hidden, deleted or unpublished pages are not still available online in some other format (like Markdown or mdsh).

You can still use `-f` with `git` to force commit any files you like.
