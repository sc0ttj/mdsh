


## Creating HTML from Markdown

This is how I am tackling it:

```
html="`markdown.pl /path/to/some/file.md`"
./create_page "$html" > /path/to/some/file.html
```

This is untested, and I would ideally like to use the GitHub API to do the conversion, as the HTML it provides is suitable for syntax highlighting.

So far, I have not setup overwriting the default page meta info for each page created - the posts should have their own titles and descriptions in the page meta.

Currently, the defaults are taken from `~/.bl/config`, then `.site_config` - in that order. If those are not sourced, the required vars won't be set, and the scripts won't work.
