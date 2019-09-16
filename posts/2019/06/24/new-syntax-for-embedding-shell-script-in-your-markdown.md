

I've created a new way of embedding Bash sub-shells in your Markdown.

Previously, you would add something like `some markdown text $( your_bash_code )
and more text` in order to embed Bash (shell) scripting in your Markdown files -
that is you had to use the regular `$()` syntax familiar to all shell scripters.

However, this was a problem - parsing the Markdown, and the sub shell code in
particular, created errors because of sub-shell invocations _within_ the
sub-shell code. In other words, trying to parse the embedded bash code was not
working right, cos `$()` is too commonly found _within_ the returned code, and
my coding is crappy.

So, here is the change: your sub-shells must now be invoked using a custom
syntax, not used by any official languages/scripts/etc, and stolen from the
[Bash-On-Steroids](https://github.com/tinoschroeter/bash_on_steroids) project.

Here is the new way of invoking Bash sub-shells in your Markdown:

```
<#bash
// your shell code here
// cat some file, or run a function, or something..
echo hi
;#>
```

Or, you can do it like this as well:

```
..a sentence about OS < ?bash uname ;? > and user < ?bash whoami ;? >.
```

Which would produce something like:

```
..a sentence about OS Linux and user bob.
```

Don't forget - the sub-shell invokations (as above) go in your `.mdsh` files
(the files created when you run `new post` or `new page`), and _the evaluated
output_ of those sub-shells will appear in the final HTML files.
