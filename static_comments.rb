# Store and render comments as a static part of a Jekyll site
#
# See README.mdwn for detailed documentation on this plugin.
#
# Homepage: http://theshed.hezmatt.org/jekyll-static-comments
#
#  Copyright (C) 2011 Matt Palmer <mpalmer@hezmatt.org>
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

Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  # code to call before Jekyll renders a post
  id = payload["page"]["id"]
  comments = StaticComments::find_for_post(payload["page"]["id"], payload["site"]["source"])
  payload["page"]["comments"] = comments
  payload["page"]["comment_count"] = comments.length
  payload["page"]["has_comments"] = (comments.length > 0)
end

Jekyll::Hooks.register :site, :pre_render do |post, payload|
  payload["site"]["posts"].each do |d|
    comments = StaticComments::find_for_post(d.id, payload["site"]["source"])
    
    d.data["comment_count"] = comments.length
  end
end

module StaticComments
  # Find all the comments for a post
  def self.find_for_post(post_id, site)
    @comments ||= read_comments(site)
    @comments[post_id]
  end

  # Read all the comments files in the site, and return them as a hash of
  # arrays containing the comments, where the key to the array is the value
  # of the 'post_id' field in the YAML data in the comments files.
  def self.read_comments(source)
    comments = Hash.new() { |h, k| h[k] = Array.new }

    Dir["#{source}/**/_comments/**/*"].sort.each do |comment|
      next unless File.file?(comment) and File.readable?(comment)
      yaml_data = YAML::load_file(comment)
      post_id = yaml_data.delete('post_id')
      comments[post_id] << yaml_data
    end

    comments
  end
end
