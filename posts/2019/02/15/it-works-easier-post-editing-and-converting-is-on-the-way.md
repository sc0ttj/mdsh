

## It works! Easier post editing and converting is on the way...

After the last fix, and as described in previous posts, each time you create a post, this blog tool thing will now save 3 files:

- `file.mdsh` - a custom format, contains post meta info, markdown, html, embedded sub-shell commands
- `file.md` - a valid markdown file, contains only post body and the **results** of any embedded sub-shell commands
- `file.html` - a valid HTML file generated from the `.md` file

So, as of this post, it will be easier to:

- convert the posts into PDF, bbcode, or some other format
- edit existings posts - just edit the md file and run `update_pages -all`

### To do

I still need to update `mdshell` so it can re-parse existing `.mdsh` files, not just take input form the user via the terminal.

After that is implemented, you will be able to edit any existing `.mdsh` files and generate the `.md` and `.html` from those.
