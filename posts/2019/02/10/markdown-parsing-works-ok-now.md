

## Markdown parsing works OK now

After getting it working somewhat, I realised that my pre-parsing fix (manually replacing triple backticks with HTML code tags) allows me to use `markdown.pl` without issues, which is nice, cos it formats the code well, with no need to escape backslashes to preserve formatting.

So, I have made `markdown.pl` the default parser, but left some code in `create_page` which can use other stuff too - `markdown.sh` and `md2html.sh`.

The `md2html.sh` script uses the GitHub API, but you might hit rate limits or not have a network connection, and it has issues with formatting newlines in code blocks, so it's not the default parser.
