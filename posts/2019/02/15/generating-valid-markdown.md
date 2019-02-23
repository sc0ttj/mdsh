## Generating valid markdown

Here is a sub-shell, calling the `uname` command:

```
Linux
```

If this all works OK, we should end up with 3 files:

- `file.md` - a valid markdown file containing the _resulting output_ of any embedded sub-shells
- `file.mdsh` - a custom format, containing meta info at the top, then the post content as input by the user
- `file.html` - a valid HTML file of the post

The first attempt failed, as I had a typo i the script.. Hopefully it will work this time...
