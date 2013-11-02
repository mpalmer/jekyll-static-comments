# Store and render comments as a static part of a Jekyll site
#
# See README.mdwn for detailed documentation on this plugin.
# based on the work at
#  Homepage: http://theshed.hezmatt.org/jekyll-static-comments
#  Copyright (C) 2011 Matt Palmer <mpalmer@hezmatt.org>
#
# Additional work by:
#  Copyright (C) 2013 Shigeya Suzuki <shigeya@wide.ad.jp>
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 3, as
#  published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, see <http://www.gnu.org/licences/>

class Jekyll::Post
  alias :to_liquid_without_comments :to_liquid
  
  def to_liquid(attr = nil)
    data = to_liquid_without_comments(attr)
    data['comments'] = StaticComments::find_for_post(self, data)
    data['comment_count'] = data['comments'].length
    data
  end
end

#
# Following code is a quick hack, consists of Matt Palmer's code and
# some codes combined with Post/Site. this code should be refactored later
# to make consistent with other latest Jekyll modules.
# 
# expected output for _comments directory is by the hack added
# as https://github.com/shigeya/jekyll-import/tree/mt_comment_hack
#
# Note:
# 1) post output has a unique post_id (copy of entry_id of mt_entry table)
# 2) comment output has post_id, too
# 3) Comments are sorted by comment_id, which is copy of comment_id of
#    mt_comment table
# 

module StaticComments

  class StaticComment
    include Jekyll::Convertible

    # Attributes for Liquid templates
    EXCERPT_ATTRIBUTES_FOR_LIQUID = %w[
      author
      url
      date
    ]

    ATTRIBUTES_FOR_LIQUID = EXCERPT_ATTRIBUTES_FOR_LIQUID + %w[
      content
    ]

    attr_accessor :site, :data, :ext, :output, :name, :content
    attr_accessor :date

    def initialize(site, source, dir, name)
      @site = site
      @dir = dir
      @base = self.containing_dir(source, dir)
      @name = name
      self.read_yaml(@base, name)
      @date = Time.parse(data["date"].to_s)
    end
    
    # Get the full path to the directory containing the post files
    def containing_dir(source, dir)
      return File.join(source, dir, '_comments')
    end

    def comment_id
      data["comment_id"]
    end

    def author
      data["author"]
    end

    def url
      data["url"]
    end
    
    def post_id
      data['post_id']
    end
  end

  # Find all the comments for a post
  def self.find_for_post(post, data)
    @comments ||= read_comments(post.site)
    @comments[data['post_id']].sort {|a,b| a.comment_id <=> b.comment_id }
  end
  
  # Read all the comments files in the site, and return them as a hash of
  # arrays containing the comments, where the key to the array is the value
  # of the 'post_id' field in the YAML data in the comments files.
  def self.read_comments(site, dir = '')
    comments = Hash.new() { |h, k| h[k] = Array.new }
    
    comment_files = site.get_entries(dir, "_comments")
    comment_files.each do |f|
      c = StaticComment.new(site, site.source, dir, f)
      comments[c.post_id] << c
    end
    comments
  end
end
