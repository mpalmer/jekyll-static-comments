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

Jekyll::Hooks.register :site, :post_read do |site|
  StaticComments::read_comments(site)

  site.posts.docs.each do |post|
    comments = StaticComments::find_for_post(post.id)
    comments.each do |comment|
      comment_path = comment["path"]
      site.regenerator.add_dependency(post.path, comment_path)
    end
  end
end

Jekyll::Hooks.register :posts, :pre_render do |post, payload|
	id = payload["page"]["id"]
	comments = StaticComments::find_for_post(payload["page"]["id"])
	payload["page"]["comments"] = comments
	payload["page"]["comment_count"] = comments.length
	payload["page"]["has_comments"] = (comments.length > 0)
end

module StaticComments
	# Find all the comments for a post
	def self.find_for_post(post_id)
		@comments[post_id]
	end

	def self.read_comments(site)
    source = site.source
		comments = Hash.new() { |h, k| h[k] = Array.new }

		Dir["#{source}/**/_comments/**/*"].sort.each do |comment|
			next unless File.file?(comment) and File.readable?(comment)
			yaml_data = YAML::load_file(comment)
			post_id = yaml_data.delete('post_id')
      yaml_data["path"] = comment
			comments[post_id] << yaml_data
		end
    
    comments.each_key do |key|
        comments[key].sort!{|a,b| a['date'] <=> b['date'] }
    end
    
    @comments = comments
	end
end
