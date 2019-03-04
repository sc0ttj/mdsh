## IFS and the read command

In order to (finally) get the `.mdsh` files to generate valid markdown, and from there to convert to valid HTML, while **also** preserving code block formatting (new lines, indentations, etc), I had to set IFS and use the `-er` options of the read command.

### About `IFS`

> The Internal Field Separator (IFS) that is used for word splitting after expansion and to split lines into words with the read builtin command.

The `IFS` variable is a special Bash/shell variable which commands like `read` use to workout what counts as a field separator.

By default, it is usually set to new lines and spaces.

In order to parse our the markdown generated from our `.mdsh` files, we set IFS to parse new lines only (ignoring spaces).

### About the `read` command

The `read` command is built-in to bash, and used to read input from the terminal input, or stdin.

In order to read the markdown we generated line by line, while also preserving formatting, we need to set `IFS` as described above, **and** to set the `-er` params for `rread` so that backslashes are interpreted literally.

After doing that, these paras you're reading will be converted to p tags in the HTML, and the code blocks will preserve their formatting too.

See previous posts for examples of embedded code blocks for examples.
