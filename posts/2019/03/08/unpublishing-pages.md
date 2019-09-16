

A new command has been added to help unpublish already published pages - without having to delete them.

Here is how to use it:

```
unpublish path/to/file.html
```

This will delete the HTML file, and re-build all site index pages so that the given file no longer appears anywhere on the site.

To re-publish a post, simply open `posts.csv` an uncomment the relevant line, then run `rebuild -all`.

Currently, *this only works for blog posts - which are basically any pages listed in `posts.csv`, with files in `./posts`*.
