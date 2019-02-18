## Adding a stylesheet


I've added a stylesheet for this site, `assets/css/main.css`.

The main classes are:

`.main-container` - all site content goes in this container

`.body-container` - contains everything except the site footer

`.footer` - the site footer

`.page-header` - the main header at the top of every page

`.post-content` - contains the post title and body content

`.post-header` - contains post meta info (author, category, etc)

`.post-footer` - same as post header, but appears **below** post body content

There are other classes inside those, the most important of which are:

`.post-meta` - inside `.post-header` and `.post-footer`, contains the post meta info

`.prev-next-posts` - inside `.post-footer` only, last item before `.footer`

All of the lists of posts on the site will have the class `.posts`, with added classes to differentiate them from each other:

`.archive-posts` - the list of posts on the archive page

`.recent-posts` - the list of posts on the homepage

`.posts-in-category` - the list of posts in `category/<category-name>.html`

`.posts-matching-tag` - the list of posts in `tags/<tag-name>.html`

The classes above can be targed in your CSS to style the page, and you can create additional stylesheets that will be automatically included on your generated pages by giving those stylesheets filenames with match the html files on your site. For example, when you generate `categories.html`, the additional css file `assets/css/categories.css` will be included in the `<head>` of the page, if it exists.

So, you can edit the styles in `assests/css/main.css`, or create a stylesheet for individual pages - just make sure the HTML files have stylesheets with matching filenames in `assets/css/`.

Here is the contents of the main stylesheet (so far):

```
html,
body {
  box-sizing: border-box;
  font-size: 16px;
  line-height: 1.4em;
  min-height: 100vh;
  margin: 0;
  padding: 0;
}

/* body bg color */
body {
  background-color: #333;
}

/* extra line height for para text */
p {
  line-height: 1.6em;
}

/* heades and inline code elems */
code {
  background-color: #eee;
  color: #000;
  display: inline;
  padding: 0;
  margin: 0;
}

h1,
h1 code {
  font-size: 32px;
}

h2,
h2 code {
  font-size: 24px;
}

h3,
h3 code {
  font-size: 20px;
}

h4,
h4 code {
  font-size: 18px;
}

p code,
li code {
  font-size: 16px;
}

h1 code,
h2 code,
h3 code,
h4 code,
p code,
li code,
span code {
  /* enable padding in inline snippets */
  display: inline-block;
  line-height: 18px;
  padding: 1px 6px;
  margin-left: 2px;
  margin-right: 1px;
  vertical-align: middle;
}

/* code blocks */
pre {
  background-color: #eee;
  color: #000;
  font-size: 15px;
  line-height: 18px;
  overflow-x: auto;
  padding: 12px;
  padding-top: 0;
  word-break: break-all;
  word-wrap: break-word;
}

/* off screen text in site header */
.off-screen {
  clip: rect(1px 1px 1px 1px); /* IE 6/7 */
  clip: rect(1px, 1px, 1px, 1px);
  height: 1px;
  left: -999em;
  overflow: hidden;
  position: absolute;
  white-space: nowrap; /* added line */
  width: 1px;
}

/* wraps around all content */
.main-container {
  background-color: #fff;
  color: #222;
  height: 100%;
  min-height: 100%;
  min-height: 100vh;
  max-width: 800px;
  margin: 0px auto;
  padding: 0;
  padding-bottom: 0; /* height of footer .. OR -1px and add padding-bottom to .body-container */
  padding-top: -1px; /* pushes container to top of page */
  position: relative;
  width: 100%;
}

.body-container {
  padding-bottom: 62px;
}

/* main site header */
.page-header {
  background-color: #101010;
  color: #fff;
  font-weight: bold;
  margin-top: -1px;
  padding: 18px;
  padding-bottom: 1px;
}

.page-header h1 {
  margin-top: 6px;
}

.page-header a {
  text-decoration: none;
}

.page-header a,
.page-header a:visited {
  color: #f0f0f0;
}

.page-header a:hover,
.page-header a:focus {
  color: #fff;
  text-decoration: underline;
}

.page-header ul {
  list-style: none;
  margin-left: 0;
  padding-left: 0;
}

.page-header li {
  display: inline-block;
  padding-right: 8px;
}

.skip-to-content:focus {
  background: #fff;
  border: 2px solid #bbb;
  color: #000;
  clip: initial;
  display: block;
  height: auto;
  overflow: initial;
  padding: 12px 24px;
  position: absolute;
  top: 12px;
  left: 12px;
  width: auto;
  z-index: 10;
}

a.skip-to-content,
a.skip-to-content:hover,
a.skip-to-content:focus {
  color: #222;
}

/* post header */
.post-header {
  font-style: italic;
}

.post-header .post-meta .category,
.post-header .post-meta .author,
.post-header .post-meta .twitter {
  display: none;
}

.post-header .post-meta .time-to-read,
.post-header .post-meta .date {
  display: block;
}

.post-header .post-meta .time-to-read:before {
  content: "Time to read: ";
  display: inline-block;
  width: 100px;
}

.post-header .post-meta .date:before {
  content: "Published: ";
  display: inline-block;
  width: 100px;
}

/* tags */
.post-header .tags:before,
.post-footer .tags:before {
  content: "Tags: ";
  display: inline-block;
  width: 95px;
}

/* main content */

/* add padding to sections inside main container */
.post-content,
.post-footer {
  padding: 0;
  padding-left: 18px;
  padding-right: 18px;
}

@media (min-width: 640px) {
  .post-content,
  .post-footer {
    padding: 0;
    padding-left: 72px;
    padding-right: 72px;
  }
}

ul.posts,
ul.categories,
ul.tags {
  list-style: none;
  list-style-position: inside;
  margin-left: 0;
  padding-left: 0;
}

/* target all post lists on the site */
ul.posts li {
  /* auto trunate and append ... */
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

/* post footer */
.post-footer {
  font-style: italic;
  margin: 0 auto;
  margin-top: 12px;
}

.post-footer .post-meta .category:before {
  content: "Category: ";
  display: inline-block;
  width: 100px;
}

.post-footer .post-meta .category {
  display: block;
}

.post-footer .post-meta .twitter,
.post-footer .post-meta .time-to-read,
.post-footer .post-meta .date {
  display: none;
}

.post-footer .post-meta .author:before {
  content: "Author: ";
  display: inline-block;
  width: 100px;
}

.post-footer .post-meta .author {
  display: inline-block;
}

.post-footer .tags {
  display: none;
}

.prev-next-posts {
  font-style: italic;
  list-style: none;
  padding: 0;
}

.prev-next-posts span {
  display: inline-block;
  width: 96px;
}

.footer {
  position: absolute;
  background-color: #101010;
  color: #fff;
  bottom: 0;
  margin: 0 auto;
  text-align: center;
  width: 100%;
}
```

