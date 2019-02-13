# title:        How to edit existing pages
# slug name:    how-to-edit-existing-pages
# description:  Here is the not-so-nice method currently being used to edit pre-existing posts
# time to read: 1 min
# category:     blog
# tags:         blog
# author:       John Doe
# email:        foo@bar.com
# twitter:      @foobar
# language:     en
# JS deps:      cash-dom 
# created:      2019/02/13
# modified:     2019/02/13

---
## How to edit existing pages

To create a new page, you use `create_page` with no options - the `mdshell` script will run and you can write your post in the terminal.

But what if you make a mistake while writing your post? With `mdshell` it is impossible to 'go back' (up) a line and fix any mistakes, because as soon as you hit ENTER you're on a new line, and can't go back (`mdshell` takes the input from the terminal, and writes it to a markdown file, line by line).

So how to edit a pre-existing post?

Easy. Simply open the relevant `.md` file in a text editor, make your changes and save.

Finally, to rebuild the new HTML file from your edited/fixed markdown, just run this command:

```
./create_page posts/<year>/<month>/<day>/some-file.md > posts/<year>/<month>/<day>/some-file.html
```

Example:

```
./create_page posts/2019/02/13/better-site-headers.md > posts/2019/02/13/better-site-headers.html
```

Done! That is how to edit existing posts and rebuild the HTML pages.


