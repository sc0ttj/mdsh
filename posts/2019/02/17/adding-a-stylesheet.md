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
body,
input,
select,
textarea,
button {
  font-family: Ubuntu, sans;
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
h1 code {
  font-size: 32px;
  line-height: 1.2em;
}
h2,
h2 code {
  font-size: 24px;
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
  border: 1px solid #e6e6e6;
  display: inline-block;
  line-height: 1em;
  padding: 1px 2px;
  margin-left: 2px;
  margin-right: 1px;
  margin-bottom: 1px;
  vertical-align: middle;
}
pre {
  border: 1px solid #e6e6e6;
  font-size: 15px;
  line-height: 18px;
  overflow-x: auto;
  padding: 16px;
  word-break: break-all;
  word-wrap: break-word;
}
div.highlight pre .hll {
  background-color: #49483e;
}
div.highlight pre {
  background: #272822;
  color: #f8f8f2;
}
div.highlight pre .c {
  color: #75715e;
} /* Comment */
div.highlight pre .err {
  color: #960050;
  background-color: #1e0010;
} /* Error */
div.highlight pre .k {
  color: #66d9ef;
} /* Keyword */
div.highlight pre .l {
  color: #ae81ff;
} /* Literal */
div.highlight pre .n {
  color: #f8f8f2;
} /* Name */
div.highlight pre .o {
  color: #f92672;
} /* Operator */
div.highlight pre .p {
  color: #f8f8f2;
} /* Punctuation */
div.highlight pre .ch {
  color: #75715e;
} /* Comment.Hashbang */
div.highlight pre .cm {
  color: #75715e;
} /* Comment.Multiline */
div.highlight pre .cp {
  color: #75715e;
} /* Comment.Preproc */
div.highlight pre .cpf {
  color: #75715e;
} /* Comment.PreprocFile */
div.highlight pre .c1 {
  color: #75715e;
} /* Comment.Single */
div.highlight pre .cs {
  color: #75715e;
} /* Comment.Special */
div.highlight pre .gd {
  color: #f92672;
} /* Generic.Deleted */
div.highlight pre .ge {
  font-style: italic;
} /* Generic.Emph */
div.highlight pre .gi {
  color: #a6e22e;
} /* Generic.Inserted */
div.highlight pre .gs {
  font-weight: bold;
} /* Generic.Strong */
div.highlight pre .gu {
  color: #75715e;
} /* Generic.Subheading */
div.highlight pre .kc {
  color: #66d9ef;
} /* Keyword.Constant */
div.highlight pre .kd {
  color: #66d9ef;
} /* Keyword.Declaration */
div.highlight pre .kn {
  color: #f92672;
} /* Keyword.Namespace */
div.highlight pre .kp {
  color: #66d9ef;
} /* Keyword.Pseudo */
div.highlight pre .kr {
  color: #66d9ef;
} /* Keyword.Reserved */
div.highlight pre .kt {
  color: #66d9ef;
} /* Keyword.Type */
div.highlight pre .ld {
  color: #e6db74;
} /* Literal.Date */
div.highlight pre .m {
  color: #ae81ff;
} /* Literal.Number */
div.highlight pre .s {
  color: #e6db74;
} /* Literal.String */
div.highlight pre .na {
  color: #a6e22e;
} /* Name.Attribute */
div.highlight pre .nb {
  color: #f8f8f2;
} /* Name.Builtin */
div.highlight pre .nc {
  color: #a6e22e;
} /* Name.Class */
div.highlight pre .no {
  color: #66d9ef;
} /* Name.Constant */
div.highlight pre .nd {
  color: #a6e22e;
} /* Name.Decorator */
div.highlight pre .ni {
  color: #f8f8f2;
} /* Name.Entity */
div.highlight pre .ne {
  color: #a6e22e;
} /* Name.Exception */
div.highlight pre .nf {
  color: #a6e22e;
} /* Name.Function */
div.highlight pre .nl {
  color: #f8f8f2;
} /* Name.Label */
div.highlight pre .nn {
  color: #f8f8f2;
} /* Name.Namespace */
div.highlight pre .nx {
  color: #a6e22e;
} /* Name.Other */
div.highlight pre .py {
  color: #f8f8f2;
} /* Name.Property */
div.highlight pre .nt {
  color: #f92672;
} /* Name.Tag */
div.highlight pre .nv {
  color: #f8f8f2;
} /* Name.Variable */
div.highlight pre .ow {
  color: #f92672;
} /* Operator.Word */
div.highlight pre .w {
  color: #f8f8f2;
} /* Text.Whitespace */
div.highlight pre .mb {
  color: #ae81ff;
} /* Literal.Number.Bin */
div.highlight pre .mf {
  color: #ae81ff;
} /* Literal.Number.Float */
div.highlight pre .mh {
  color: #ae81ff;
} /* Literal.Number.Hex */
div.highlight pre .mi {
  color: #ae81ff;
} /* Literal.Number.Integer */
div.highlight pre .mo {
  color: #ae81ff;
} /* Literal.Number.Oct */
div.highlight pre .sa {
  color: #e6db74;
} /* Literal.String.Affix */
div.highlight pre .sb {
  color: #e6db74;
} /* Literal.String.Backtick */
div.highlight pre .sc {
  color: #e6db74;
} /* Literal.String.Char */
div.highlight pre .dl {
  color: #e6db74;
} /* Literal.String.Delimiter */
div.highlight pre .sd {
  color: #e6db74;
} /* Literal.String.Doc */
div.highlight pre .s2 {
  color: #e6db74;
} /* Literal.String.Double */
div.highlight pre .se {
  color: #ae81ff;
} /* Literal.String.Escape */
div.highlight pre .sh {
  color: #e6db74;
} /* Literal.String.Heredoc */
div.highlight pre .si {
  color: #e6db74;
} /* Literal.String.Interpol */
div.highlight pre .sx {
  color: #e6db74;
} /* Literal.String.Other */
div.highlight pre .sr {
  color: #e6db74;
} /* Literal.String.Regex */
div.highlight pre .s1 {
  color: #e6db74;
} /* Literal.String.Single */
div.highlight pre .ss {
  color: #e6db74;
} /* Literal.String.Symbol */
div.highlight pre .bp {
  color: #f8f8f2;
} /* Name.Builtin.Pseudo */
div.highlight pre .fm {
  color: #a6e22e;
} /* Name.Function.Magic */
div.highlight pre .vc {
  color: #f8f8f2;
} /* Name.Variable.Class */
div.highlight pre .vg {
  color: #f8f8f2;
} /* Name.Variable.Global */
div.highlight pre .vi {
  color: #f8f8f2;
} /* Name.Variable.Instance */
div.highlight pre .vm {
  color: #f8f8f2;
} /* Name.Variable.Magic */
div.highlight pre .il {
  color: #ae81ff;
} /* Literal.Number.Integer.Long */

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
.page-header #site-search {
  background-color: #efefef;
  border: 0;
  display: none;
  margin-right: 8px;
  padding: 4px;
  max-width: 120px;
}
@media (min-width: 414px) {
  .page-header #site-search {
    margin-top: 8px;
    top: 1.5em;
    position: absolute;
    right: 12px;
  }
}
.highlight {
  background-color: #fff34d;
}
.highlight {
  padding: 0;
  margin: 0;
}
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
  content: "Time to read:";
  display: inline-block;
  margin-right: 4px;
  width: 100px;
}
.post-header .post-meta .date:before {
  content: "Published:";
  display: inline-block;
  margin-right: 4px;
  width: 100px;
}
.post-header .tags span,
.post-header .tags span {
  margin-right: 4px;
}

.post-header .tags:before,
.post-footer .tags:before {
  content: "Tags:";
  display: inline-block;
  margin-right: 4px;
  width: 95px;
}
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
.post-content {
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
ul.posts li {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}
.post-footer {
  font-style: italic;
  margin: 0 auto;
  margin-top: 12px;
}
.post-footer .post-meta .category:before {
  content: "Category:";
  display: inline-block;
  margin-right: 4px;
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
  content: "Author:";
  display: inline-block;
  margin-right: 4px;
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
.post-preview {
  border-bottom: 1px solid #ccc;
  padding-bottom: 12px;
}
.post-preview h2,
.post-preview time {
  display: inline-block;
}
.post-preview h2 {
  margin-right: 4px;
  margin-bottom: 8px;
}
.post-preview .post-meta {
  font-style: italic;
  padding: 0;
  margin: 0;
}
.post-preview .post-meta li {
  display: inline-block;
}
.post-preview .post-meta li:nth-child(1):before {
  content: "Time to read:";
  display: inline-block;
  margin-right: 4px;
}
.post-preview .tags {
  font-style: italic;
}
.post-preview .tags:before {
  content: "Tags:";
  margin-right: 4px;
}
.post-preview .post-meta li:nth-child(1):before {
  content: "Time to read:";
  display: inline-block;
  margin-right: 4px;
}
.post-preview .post-meta li:nth-child(2),
.post-preview .post-meta li:nth-child(3),
.post-preview .post-meta li:nth-child(4),
.post-preview .post-meta li:nth-child(5) {
  display: none;
}
.post-preview .tags {
  padding: 0;
  margin: 0;
}
.post-preview .tags li {
  display: inline-block;
  padding-right: 5px;
}

.archive-posts li span {
  margin-right: 4px;
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
  margin-bottom: 24px;
}
.search-results {
  display: none;
  margin-bottom: 36px;
}
.search-results .result {
  margin-bottom: 16px;
}
```
