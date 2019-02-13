# title: About `mdshell`

# slug name: about-mdshell

# description: A simple script I wrote for creating dynamically generated webpages using only the terminal.

# time to read: 2 mins

# category: blog

# tags: blog,markdown,shell

# author: John Doe

# email: foo@bar.com

# twitter: @foobar

# language: en

# JS deps: cash-dom

# created: 2019/02/13

# modified: 2019/02/13

---

## About mdshell

The `mdshell` script is a part of this blogging software thing I'm making.

### Adding dynamic content using `mdshell`

It lets you create web pages super fast, using Markdown and embedded sub-shells.

The _results_ of the sub-shell commands are included in the final output.

For example, if you write the following in your blog post when using `mdshell` (removing the space ater the $):

```
$ (uname)
```

Then the actual output in the final HTML file will be:

```
Linux
```

This is an easy way to embed functions and commands inside your markdown, and to auto-generate your web pages with the results of those commands/functions.

Another example, showing how to list folder contents:

```
$ (ls $HOME)
```

Would produce the following final output:

```
bin
blog_ideas.txt
Choices
colored-completion-prefix
default.jpg
Desktop
Documents
dotfiles
Downloads
File-Sharing
index.md
mdshell.gif
mdshell-opt.gif
mdshell.ttyrecord
network
pkg
puppy_arcade_readme.txt
README.md
Sites
small.md
spot
src
Startup
test1.html
test.md
tree.html
www
```

(or something like that, depending on what's in your home dir, obviously)

### Using HTML in `mdshell`

The `mdshell` also lets you write HTML straight into the post, and it will also work fine.

This is useful if Markdown alone cannot produce the custom HTML layouts/elements that you need.

### Using python (or whatever) in `mdshell`

Simply put your code or commands inside a sub-shell as usual..

The following would run a Python script, the results of which would end up in your page HTML:

```
python /path/to/script.py
```

You could also call `node` scripts - for things like server-side chart rendering..

You could, for example, have installed the ChartJS or Chartist node packages which, when called in a sub-shell, would return the charts HTML/SVG.

### Summary of `mdshell`

It's a super easy way to write blog posts in the terminal, using anything from plain Markdown to dynamic shell-based scripts, to plain HTML - or a mix of all of those..

I've yet to work out a more convenient way of writing blog posts that is no-frills, flexible, and "just works".

And best of all, I don't need any extra software AT ALL - just my terminal.

Nice.
