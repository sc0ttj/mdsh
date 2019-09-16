


Now it's much easier to update/rebuild only the parts of the site you need to.

The `rebuild` command has been greatly improved, so you can (re)build specific index pages, and keep your site up-to-date much more easily.

### How it works

The `rebuild` command now accepts options in the following format:

```
rebuild <index-page>[:item1,item2,...]
```

Examples:

```
rebuild tags:templating,yaml

rebuild authors:sc0ttj categories:games

rebuild search
```


### All `rebuild` options:

```console
$ rebuild 404                 # update 404.html

$ rebuild homepage            # update index.html (the homepage)

$ rebuild archive             # update archive.html (lists all blog posts)

$ rebuild search              # update search.html (your website search page)

$ rebuild sitemap             # update sitemap.xml (used by search engines)

$ rebuild rss                 # update feed.rss (your RSS new feed)

$ rebuild authors             # update all pages in authors/

$ rebuild authors:foo,bar     # update pages authors/foo.html and tags/bar.html

$ rebuild categories          # update all pages in categories/

$ rebuild categories:foo,bar  # update pages categories/foo.html and tags/bar.html

$ rebuild tags                # update all pages in tags/

$ rebuild tags:foo,bar        # update pages tags/foo.html and tags/bar.html

$ rebuild years               # update all posts/<years>/index.html index pages

$ rebuild years:foo           # update posts/foo/index.html specifically

$ rebuild months 2019         # update all monthly index pages in posts/2019/

$ rebuild months:foo 2019     # update posts/2019/foo/index.html specifically
```

### Chaining commands

The commands above can also be combined like so:

```console
$ rebuild tags:foo,bar year:2019 authors:someone search
```
