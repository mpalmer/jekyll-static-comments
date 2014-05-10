Static Comment Generator for MovableType imported sites

This plugin and template are a skeleton to generate a Jekyll static
site with data exported from MovableType.

The template is based on 
[Matt Palmer's jekyll-static-comments](https://github.com/mpalmer/jekyll-static-comments).
With the small hack added to MovableType Jeykll exporter, user can 
export MovableType entries with comments.

jekyll-import require 
(a hack)[https://github.com/shigeya/jekyll-import/tree/mt_comment_hack]
which (possibly) merged into jekyll-import.

Generation Steps:

- Export using jekyll/jekyll-import/mt.rb as directed. By adding
  option `comments: true`, `_comments` directories are created and
  all the comments are exported alongside with `_posts` directory.
- Copy `mt_exported_static_comments.rb` to `_plugins` directory of
  jekyll project directory
- Copy `post.html` to `_layout` directory of  project directory
- Build using Jekyll!


