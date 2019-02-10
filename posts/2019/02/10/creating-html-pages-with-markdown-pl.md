# title:        Creating HTML pages with markdown.pl
# slug name:    creating-html-pages-with-markdown-pl
# description:  This technique uses the widely used Perl script.
# time to read: 1 min
# category:     blog
# tags:         blog,shell,markdown
# author:       John Doe
# email:        foo@bar.com
# twitter:      @foobar
# language:     en
# JS deps:      cash-dom 
# created:      2019/02/10
# modified:     2019/02/10

---

## Using `markdown.pl`

Here is the easiest way to convert your Markdown to HTML:

```
html="`echo -e "$my_markdown" | markdown.pl`"
```


