
## Automatically add titles to posts

I have improved the post creation routine a tiny bit, by automatically using `$title` as an `h2` header (##) at the top of each newly created post.

So, users enter the title of their post when prompted, as usual, and now this title will be automatically added to the top of the post as

```
## Some title here
```

This has two advantages:

- it's faster to create posts, no adding titles twice
- posts always begin with a `<h2>`

The 2nd point is important - it means we *always* know what is a the top of the post, and so we can programmatically do stuff to it - like adding an auto-generated sub-header below the post title (which might include the posts category, tags, time to read, etc)
