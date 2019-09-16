


There is now an easier way to show only portions or excerpts of your blog posts on your homepage, and any other areas of your site where you wish to show or preview your posts content.

To mark the point at which your post should be truncated when being previewed, I have shamelessly stolen the `<!–– more ––>` marker idea used in Jekyll.

### How to create a post excerpt

When writing the markdown for your blog post, you can simply include `<!–– more ––>` on any line, and everything after that line will be removed in post previews (such as those on the Homepage). A "Read more about X..." link will appear at the end of the preview instead of `<!–– more ––>`.

<!-- more -->

### How it works

The `post_preview` function in `.app/generate_post_content.bash` truncates the post content, and creates a `$page_excerpt` variable, which is used in the `_post_preview.mustache` template as `{{page_excerpt}}`.

If you create other templates or template partials in which you wish to show post previews, you can use:

```shell

my_html="`post_preview posts/2019/03/22/some-file.mdsh`"
```

And in your template you can then show the post excerpt/preview using `{{my_html}}`
