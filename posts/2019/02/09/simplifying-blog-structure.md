## Simplifying blog structure

I needed a way to simplify the way my scripts searched and listed site content.

So, each time you create a post, it is added to a `posts.csv` file, which lists all site posts, oldest to newest.

The fields in this csv file are: `date|filename|title|category|author|tags`

So, searching for posts by tags, category (etc) will now be as easy as a few `grep` commands.

I may add other fields to `posts.csv` in future.
