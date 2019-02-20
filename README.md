`NOTE: This blog thing is a work-in-progress [WIP], not yet "finished"`)

---

# `mdshell` README

`mdshell` - Write your blog straight from the terminal.

## Description

This is a simple static site generator (SSG), or "blog making thing".

`mdshell` requires only Bash and Perl, and builds HTML files from Markdown files.

The name `mdshell` refers to the fact you can combine Markdown and `$()` sub-shells in your blog posts to dynamically produce the HTML output.

This is a fast way of producing documentation for any installed programs or commands, and a nice easy way to write blog posts in Markdown.

## Features:

- Written in Bash shell script
- Easy setup - just clone the repo, edit the .site_config file.
- Use a mix of Markdown and shell code to write blog posts!
- Use your terminal - no text editor or IDE required.
- Automatically generates index and listings pages for categories, tags, and more.
- Builds a fast blog with great SEO and mobile support
- Supports fullscreen, native app experience if added to Homescreen (on mobile)
- Uses Google Fonts to choose custom web fonts
- Uses Unpkg.com to manage JavaScript libraries/dependencies
- Uses Git for saving, managaging and reverting versions and deployments
- Uses GitHub Pages for fast, free hosting

## Usage

`.site_config` - important site settings like blog name, description, url, etc.

`create_post` - create a new post (add meta, then markdown content)

`update_pages` - rebuild all pages and indexes on the site

`update_pages -all` - rebuild all pages and indexes on the site, _AND blog posts too_

`publish "some message"` - commit and push (deploy) your site to the remote host/server

## Advanced usage

Aside from adding blog posts, you can easily create custom pages too:

- manually re-generate the default homepage, listing recent posts

  `create_page > index.html`

- create HTML page from markdown file (recommended)

  `create_page path/to/some-file.md > some-file.html`

- create custom page containing the given HTML

  `create_page "$some_HTML_string" > some-file.html`

## Wiki

Read the [wiki](https://github.com/sc0ttj/mdsh/wiki) for more help and usage information.

## TODO

See Issues page for planned features and known bugs.
