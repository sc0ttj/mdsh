## Missing post header


This post should have a `h2` title called "Missing post header" .. The previous post (now fixed) was generated but had a missing header.

This was because `mdshell` was not appending to the `.md` file, but overwriting it with the post contents.

This was wrong, cos `create_post` already creates the `.md` file, with a `h2` header at the top.

Should be fixed now.


