require 'pathname'
require 'RedCloth'

class BlogPost < Chisel::Resource
	attr_accessor :url_title, :title, :content, :archived, :date
	
	def initialize(filename)
		filename = Pathname.new(filename)
		tokens = filename.basename.to_s.split('-')
		
		year, month, day = tokens[0..2]
		@date = Date.civil(year.to_i, month.to_i, day.to_i)
		
		@url_title = tokens[3..-1].join('-').gsub('.textile', '')
		
		@content = File.read(filename)
		header = YAML.load_header(@content)
		@content = YAML.remove_header(@content)
		@content = RedCloth.new(@content).to_html
		@archived = header['archived']
		
		@title = header['title']
	end

	def self.all
		post_filenames = Dir.glob('_posts/*.textile').sort
		post_filenames.map { |filename| BlogPost.new(filename) }
	end
	
	def self.unarchived
		BlogPost.find_in(BlogPost.all, :archived => false)
	end
	
	def id
		[@date.year.to_s, @date.month.to_s, @date.day.to_s, @url_title]
	end
end