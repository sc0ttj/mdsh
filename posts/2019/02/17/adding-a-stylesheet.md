

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

```css
* {
  box-sizing: border-box;
}

body,
input,
select,
textarea,
button {
  font-family: Ubuntu, sans, sans-serif;
  font-size: 16px;
}
pre,
code {
  font-family: Inconsolata, monospace;
  font-size: 14px;
}
html,
body {
  box-sizing: border-box;
  font-size: 16px;
  line-height: 1.4em;
  min-height: 100vh;
  margin: 0;
  padding: 0;
}
body {
  background-color: #333;
}
p,
li {
  line-height: 1.6em;
}
ul,
ol {
  padding-left: 15px;
}
code {
  display: inline;
  padding: 0;
  margin: 0;
}
h1,
h2,
h3,
h4 {
  color: #303030;
}
h1,
h1 code {
  font-size: 34px;
  line-height: 1.2em;
}
h2,
h2 code {
  font-size: 26px;
  line-height: 1.2em;
}
h3,
h3 code {
  font-size: 20px;
  line-height: 1.2em;
}
h4,
h4 code {
  font-size: 18px;
  line-height: 1.2em;
}
p code,
li code {
  font-size: 16px;
  line-height: 1.2em;
}
h1 code,
h2 code,
h3 code,
h4 code,
p code,
li code,
span code {
  background-color: #f7f7f7;
  border: 1px solid #eee;
  border-radius: 2px;
  color: #292929;
  display: inline-block;
  line-height: 1.15em;
  padding: 0px 3px;
  margin-left: 2px;
  margin-right: 2px;
  margin-top: -2px;
  vertical-align: middle;
}
pre {
  background-color: #f7f7f7;
  border: 1px solid #eee;
  border-radius: 2px;
  color: #292929;
  overflow-x: auto;
  word-break: break-all;
  word-wrap: break-word;
  line-height: 15px;
  padding: 0px 15px;
  font-size: 15px;
  margin: 0px;
}
div.highlight pre {
  border: 0px none;
  font-size: 15px;
  line-height: 18px;
  overflow-x: auto;
  padding: 12px;
}
.off-screen {
  clip: rect(1px, 1px, 1px, 1px);
  height: 1px;
  left: -999em;
  overflow: hidden;
  position: absolute;
  width: 1px;
}
.main-container {
  background-color: #fff;
  color: #222;
  height: 100%;
  min-height: 100%;
  min-height: 100vh;
  max-width: 800px;
  margin: 0px auto;
  padding: 0;
  position: relative;
  width: 100%;
}
.body-container {
  padding-bottom: 62px;
}
.site-header {
  background-color: #101010;
  color: #fff;
  font-weight: bold;
  margin-top: -1px;
  padding: 18px;
  padding-bottom: 1px;
}
.site-header h1 {
  margin-top: 6px;
}
.site-header a {
  text-decoration: none;
}
.site-header a,
.site-header a:visited {
  color: #f0f0f0;
}
.site-header a:hover,
.site-header a:focus {
  color: #fff;
  text-decoration: underline;
}
.site-header ul {
  list-style: none;
  margin-left: 0;
  padding-left: 0;
}
.site-header li {
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
.site-header #site-search {
  background-color: #efefef;
  border: 0;
  display: none;
  margin-right: 8px;
  padding: 4px;
  max-width: 120px;
}
@media (min-width: 414px) {
  .site-header #site-search {
    margin-top: 8px;
    top: 1.5em;
    position: absolute;
    right: 12px;
  }
}
.highlighted {
  background-color: #fff34d;
  color: #222;
  padding: 0;
  margin: 0;
}
.page-header {
  font-style: italic;
}
.page-header .page-meta .category,
.page-header .page-meta .author,
.page-header .page-meta .twitter {
  display: none;
}
.page-header .page-meta .time-to-read,
.page-header .page-meta .date {
  display: block;
}
.page-header .page-meta .time-to-read:before {
  content: "Time to read:";
  display: inline-block;
  margin-right: 4px;
  width: 100px;
}
.page-header .page-meta .date:before {
  content: "Published:";
  display: inline-block;
  margin-right: 4px;
  width: 100px;
}
.page-header .tags span,
.page-header .tags span {
  margin-right: 4px;
}

.page-header .tags:before,
.page-footer .tags:before {
  content: "Tags:";
  display: inline-block;
  margin-right: 4px;
  width: 95px;
}
.main-content,
.page-footer {
  padding: 0;
  padding-left: 18px;
  padding-right: 18px;
}
@media (min-width: 640px) {
  .main-content,
  .page-footer {
    padding: 0;
    padding-left: 72px;
    padding-right: 72px;
  }
}
.main-content {
  padding-top: 1em;
}
ul.posts,
ul.categories,
ul.tags {
  list-style: none;
  list-style-position: inside;
  margin-left: 0;
  padding-left: 0;
}
ul.archive-posts li {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}
.page-footer {
  font-style: italic;
  margin: 0;
  padding: 0;
  margin-top: 16px;
  margin-bottom: 16px;
}
.page-footer .page-meta .category:before {
  content: "Category:";
  display: inline-block;
  margin-right: 4px;
  width: 100px;
}
.page-footer .page-meta .category {
  display: block;
}
.page-footer .page-meta .twitter,
.page-footer .page-meta .time-to-read,
.page-footer .page-meta .date {
  display: none;
}
.page-footer .page-meta .author:before {
  content: "Author:";
  display: inline-block;
  margin-right: 4px;
  width: 100px;
}
.page-footer .page-meta .author {
  display: inline-block;
}
.page-footer .tags {
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
.footer a {
  color: #efefef;
}
.footer a:hover,
.footer a:focus {
  color: #fff;
}
.contact-form {
  margin-bottom: 28px;
}
.contact-form label {
  display: inline-block;
  min-width: 70px;
  vertical-align: top;
  line-height: 2.75em;
}
.contact-form input,
.contact-form textarea {
  appearance: none;
  background: none;
  border: 1px solid #ccc;
  border-radius: 2px;
  font-size: 16px;
  padding: 8px;
  margin: 4px;
  min-width: 280px;
}
.contact-form textarea {
  min-height: 100px;
}
.contact-form button[type="submit"] {
  color: #fff;
  cursor: pointer;
  background-color: #222;
  border: 0;
  padding: 8px;
  margin-left: 4px;
}
@media (min-width: 416px) {
  .contact-form button[type="submit"] {
    margin-left: 78px;
  }
}
.contact-form button[type="submit"]:hover,
.contact-form button[type="submit"]:focus {
  background-color: #000;
}
.page-preview {
  border-bottom: 1px solid #ccc;
  padding-bottom: 12px;
}
.page-preview h2,
.page-preview time {
  display: inline-block;
}
.page-preview h2 {
  margin-right: 4px;
  margin-bottom: 8px;
}
.page-preview .page-meta {
  font-style: italic;
  padding: 0;
  margin: 0;
}
.page-preview .page-meta li {
  display: block;
}
.page-preview .page-meta li:before {
  display: inline-block;
  margin-right: 4px;
  min-width: 100px;
}
.page-preview .page-meta .time-to-read:before {
  content: "Time to read:";
}
.page-preview .tags {
  font-style: italic;
}
.page-preview .tags:before {
  content: "Tags:";
  display: inline-block;
  margin-right: 4px;
  min-width: 100px;
}
.page-preview .page-meta .time-to-read:before {
  content: "Time to read:";
}
.page-preview .page-meta > li:nth-child(2),
.page-preview .page-meta > li:nth-child(3),
.page-preview .page-meta > li:nth-child(4),
.page-preview .page-meta > li:nth-child(5) {
  display: none;
}
.page-preview .tags {
  padding: 0;
  margin: 0;
}
.page-preview .tags li {
  display: inline-block;
  padding-right: 5px;
}

.archive-posts li time {
  margin-right: 6px;
}

/* search page */
.search-box input {
  padding: 8px;
  border: 1px solid #ccc;
}

.search-box button {
  color: #fff;
  cursor: pointer;
  background-color: #222;
  border: 0;
  padding: 8px;
  margin-left: 4px;
}
.search-back {
  display: block;
  margin: -12px 0px 0px;
}
.search-results {
  display: none;
  list-style: none;
  margin-bottom: 36px;
  margin-left: 0;
  padding-left: 0;
}
/* custom styles for individual pages below */
/* hide main h2 headers for various pages  */
.mdsh .main-content > h2:first-child,
.homepage .main-content > h2:first-child,
.about .main-content > h2:first-child,
.search .main-content > h2:first-child {
  display: none;
}
```
