


A new permalinks feature has been added, so you can create shorter, easier, custom URLs for your blog posts.

Simply run the command `new post -all` and follow the on-screen instructions.

Your page will be available at its normal URL (`posts/year/month/day/post-name.html`,
as well as the permalink, which can be simply `post-name`, if you wish.

Example: If the post `$site_domain/$site_url/posts/2019/09/07/13/liquid-filters.html` had the permalink
`docs/liquid-filters`, then it would be available at `$site_domain/$site_url/docs/liquid-filters`.

The permalink is saved in the front matter of your `.mdsh` files, and (ideally)
should not be changed.
