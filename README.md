# Jekyll::StaticComments

Whilst most people go for a Disqus account, or some similar JS-abusing means
of putting comments on their blog, I'm old-fashioned, and like my site to be
dead-tree useable.  Hence this plugin: it provides a means of associating
comments with posts and rendering them all as one big, awesome page.

## Quick Start (or "what are all these files for?")

1. Put the `static_comments.rb` file in the `_plugins` directory of your
Jekyll site.

1. Edit the variables at the top of `commentsubmit.php`, and then place it
somewhere suitable in your site.

1. Modify `comment_received.html` to your liking (add a YAML front-matter to
render it in your site's style, for instance) and then place it alongside
`commentsubmit.php`.

1. Using `comment_template.html` as a base, add the appropriate code to your
blog post template.  Remember to provide an appropriate URL to
`commentsubmit.php`.

1. Create a `_comments` directory somewhere in your Jekyll site, and
populate it with YAML comments (as produced by `commentsubmit.php`, or
otherwise).

1. Enjoy a wonderful, spam-free, static-commenting Nirvana.

## Technical details

To use StaticComments, you need to have a store of comments; this is a
directory, called `_comments`, which contains all your comments.  You can
have an arbitrary hierarchy inside this `_comments` directory (so you can
put comments in post-specific directories, if you like), and the `_comments`
directory can be anywhere in your site tree (I put it alongside my `_posts`
directory).  The files containing comments can be named anything you like --
every single file within the `_comments` directory will be read and parsed
as a comment.

Each file in `_comments` represents a single comment, as a YAML hash.  The
YAML must contain a `post_id` attribute, which corresponds to the `id` of
the post it is a comment on, but apart from that the YAML fields are
anything you want them to be.

The fields in your YAML file will be mapped to fields in a Comment
object.  There is a new `page.comments` field, which contains a list of the
Comment objects for each post.  Iterating through a post and printing the
comments is as simple as:

    {% for c in page.comments %}
      <a href="{{c.link}}">{{c.nick}}</a>
      <p>
        {{c.content}}
      </p>
      <hr />
    {% endfor %}

This, of course, assumes that your YAML comments have the `link`, `nick`,
and `content` fields.  Your mileage will vary.

The order of the comments list returned in the page.comments array is
based on the lexical ordering of the filenames that the comments are
stored in.  Hence, you can preserve strict date ordering of your comments
by ensuring that the filenames are based around the date/time of comment
submission.

Of course, the tricky bit in all this is getting the comments from your
users into the filesystem.  For that, I'm using the `commentsubmit.php` in
this repo, which simply takes all the fields in your comment form, dumps
them straight into YAML, and e-mails it to me.  However, you can do whatever
you like -- save them somewhere on your webserver for you to scp down later,
or go the whole hog and have them automatically committed to your git repo
and the site regenerated.

E-mailing the comments to you, though, is a fairly natural workflow.  You
just save the comments out to your `_comments` directory, then re-generate
the site and upload.  This provides a natural "moderation" mechanism, at the
expense of discouraging wide-ranging "realtime" discussion.

## A caveat about Liquid

Never use the word `comment` by itself as an identifier of any kind
(variable, whatever) in your Liquid templates: the language considers it to
be the start of a comment (regardless of where it appears) and eats your
code.  Yes, apparently Liquid really *is* that stupid.  At the very least,
you'll need to put a prefix or suffix or something so that Liquid doesn't
think you're trying to execute it's `comment` function.

## Still too much dynamic code?

If you like the idea of static comments, but you think that there's still
too much dynamic code, then you might like to consider [Tomas Carnecky's
even-more-static-comments](https://blog.caurea.org/2012/03/31/this-blog-has-comments-again.html),
which uses a special per-post e-mail address to receive comments via a
`mailto:` URL.

## Licencing, bug reports, patches, etc

This plugin is licenced under the terms of the [GNU GPL version
3](http://www.gnu.org/licenses/gpl-3.0.html).  If it works for you, great. 
If it doesn't, please [e-mail me](mailto:mpalmer@hezmatt.org) a patch with a
description of the bug.  Bug reports without patches will probably be
ignored unless I'm feeling in a good mood.  Particularly bug reports may be
publically ridiculed.
