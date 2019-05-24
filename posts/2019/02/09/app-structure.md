


## App structure

So far, I have a script called `create_post`, which I am using to write this post.

After creating this post, I need to auto-generate the HTML from this Markdown.

So `create_post` should run `markdown.pl` to produce the post HTML, and run the following:

```
create_page "$post_html" > ./posts/${date_created}/${slug}.html
```

This should produce an HTML page, complete with header, footer, and post contents.

After generating this page, it should be added to the relevant places on the site:

* main site homepage (which lists the 10 most recent posts)
* archive page (lists all posts)
* category page (page listing of posts of a particular category)
