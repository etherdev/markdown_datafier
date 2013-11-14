require "markdown_datafier/version"
require "time"
require "redcarpet"

module MarkdownDatafier
  attr_accessor :config
  class MetadataParseError < RuntimeError; end
  
  def self.root
    File.expand_path '../..', __FILE__
  end
  
  def initialize(attributes)
    set_config_directory(attributes[:config_directory])
  end
  
  def set_config_directory(path)
    @config = YAML.load_file( path + "markdown_datafier.yml")
  end
  
  def content_directory
    @config["content_directory"]
  end
  
  def home_page
    find_by_path("index")
  end
  
  def splash_page
    find_by_path("splash")
  end
  
  def indexes_for_sections(directory=nil)
    sections = []
    if directory.nil?
      Dir.chdir(content_directory)
      currrent_dir_name = ""
    else
      Dir.chdir(content_directory + directory)
      currrent_dir_name = File.basename(Dir.pwd)
    end
    sub_directories.each do |section|
      sections << find_by_path(currrent_dir_name + section)
    end
    sections
  end
  
  def sub_directories
    sub_directories = Dir["*"].reject{|file| not File.directory?(file)}.map! {|sub_directory| "/" + sub_directory }
  end
  
  def find_by_path(shortname)
    path = determine_file_path(content_directory + strip_leading_slashes(shortname))
    content = "Shortname: #{shortname}\nCreate Datetime: #{File.ctime(path)}\n" + File.open(path).read
    parse_file_content(content)
  end
  
  def strip_leading_slashes(shortname)
     shortname.match(/^\//) ? shortname.gsub(/^\//, "") : shortname
  end
  
  def determine_file_path(path)
    is_directory?(path) ? serve_index(path) : append_file_extention(path)
  end
  
  def is_directory?(path)
    File.directory?(path)
  end

  def serve_index(shortname)
    shortname.match(/\/$/) ? (shortname + "index.mdown") : (shortname + "/index.mdown")
  end
  
  def append_file_extention(path)
    path + ".mdown"
  end
  
  def underscores_to_dashes(shortname)
    shortname.gsub(/_/, "-")
  end
  
  def parse_file_content(content)
    convert_body_to_html(set_meta_defaults(determine_publish_datetime(parse_meta(split_meta_and_body(content)))))
  end
  
  def split_meta_and_body(content)
    meta, body = content.split(/\r?\n\r?\n/, 2)
    {:meta => meta}.merge!({:body => body})
  end
  
  def parse_meta(content_hash)
    is_metadata = content_hash[:meta].split("\n").first =~ /^[\w ]+:/
    raise MetadataParseError unless is_metadata
    parsed_hash = Hash.new
    content_hash[:meta].split("\n").each do |line|
      key, value = line.split(/\s*:\s*/, 2)
      next if value.nil?
      parsed_hash[key.downcase.gsub(/\s+/, "_").to_sym] = value.chomp
    end
    content_hash[:meta] = parsed_hash
    content_hash
  end
  
  def determine_publish_datetime(content_hash)
    if [:date, :publish_date, :publish_datetime].any? {|symbol| content_hash[:meta].key? symbol}
      content_hash[:meta][:publish_datetime] = Time.parse(content_hash[:meta][:publish_datetime]).utc.iso8601 if content_hash[:meta][:publish_datetime]
      content_hash[:meta][:publish_datetime] = Time.parse(content_hash[:meta].delete(:date)).utc.iso8601 if content_hash[:meta][:date]
      content_hash[:meta][:publish_datetime] = Time.parse(content_hash[:meta].delete(:publish_date)).utc.iso8601 if content_hash[:meta][:publish_date]
    else
      content_hash[:meta][:publish_datetime] = Time.parse(content_hash[:meta][:create_datetime]).utc.iso8601
    end
    content_hash
  end
  
  def set_meta_defaults(content_hash)
    meta_hash = content_hash[:meta]
    meta_hash[:nav_name] ||= default_nav_name(content_hash[:body])
    meta_hash[:position] ||= nil
    meta_hash[:large_image] ||= nil
    meta_hash[:medium_image] ||= nil
    meta_hash[:small_image] ||= nil
    content_hash[:meta] = meta_hash
    content_hash
  end
  
  def default_nav_name(body)
    body.split(/\r?\n\r?\n/, 2)[0].gsub(/# /, "")
  end
  
  def convert_body_to_html(content_hash)
    converter = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true) 
    content_hash[:body] = converter.render(content_hash[:body])
    content_hash
  end

end
