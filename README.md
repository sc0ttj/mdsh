# README

`mdshell` - Write your blog straight from the terminal.

## Description

This is a simple static site generator (SSG), or "blog making thing".

`mdshell` requires only Bash and Perl, and builds HTML files from Markdown files.

The name `mdshell` refers to the fact you can combine Markdown and Bash sub-shells in your blog posts to dynamically produce the HTML output.

This is a fast way of producing documentation for any installed programs or commands, and a nice easy way to write blog posts in Markdown.

## Features

- Written in Bash shell script
- Builds a fast blog with great SEO and mobile support
- Creates blog posts or custom pages.
- Use a mix of Markdown and shell code to write blog posts!
- Use your terminal - no text editor or IDE required (but you can use them too).
- Automatically generates index pages for categories, tags, authors and more.
- Also generates a valid RSS feed and XML sitemap.
- Includes a "Contact" page that works out of the box! (uses [formspree.io](http://formspree.io) to send you emails, requires JS)
- Includes a very fast page search, with highlighted matches (uses [Jets](https://jets.js.org/), requires JS)
- Supports fullscreen, native app experience on mobile/smartphone if added to Homescreen
- Supports code syntax highlighting (requires [Pygments](http://pygments.org/), default theme is `monokai`)
- Optionally use [Google Fonts](https://fonts.google.com/) to choose custom web fonts
- Optionally use [Unpkg.com](http://unpkg.com) to manage JavaScript libraries/dependencies
- Optionally use [Git](https://kbroman.org/github_tutorial/) for saving, managing and reverting versions and deployments
- Optionally use [GitHub Pages](https://pages.github.com/) for free, fast, and secure (SSL enabled) site hosting
- Supports many other web hosting options too ([GitLab Pages](https://about.gitlab.com/product/pages/), [Netlify](https://www.netlify.com/docs/continuous-deployment/), others).

## Setup

`setup` - set site defaults, settings and options.

`source .site_setup` - source the app and site settings - _important!_

`server [start|stop]` - start/stop a local web server.

## Usage

`new post` - create a new post. Follow the on-screen instructions. All index pages will be updated and re-built after creating a new post.

`publish "message"` - save and publish latest changes.

## Advanced usage

#### Customising posts

`new post -all` - creates a new post, as above, but allows overriding various site defaults.

#### Creating pages

`new page file.md > file.html` - create a page from a Markdown file.

`new page "$html" > file.html` - create a page from an HTML string.

#### Rebuilding pages

If you edit any existing Markdown or .mdsh files, you may need to re-build the HTML pages:

`rebuild` - re-build all index pages (authors, categories, tags, etc).

`rebuild file.md file.html` - re-build a specific page.

`rebuild file.mdsh file.html` - re-build a page from a .mdsh file.

`rebuild -all` - re-build all posts from their Markdown files.

`rebuild -ALL` - re-build all posts from their .mdsh files.

#### Updating sitemap

_After_ publishing your new post or page, you can update your sitemap.

`rebuild sitemap` - re-build and publish an updated XML sitemap file.

## Documentation

Read the [wiki](https://github.com/sc0ttj/mdsh/wiki) for more help and usage information.

## To do

See [Issues page](https://github.com/sc0ttj/mdsh/issues) for planned features and known bugs.
