# MarkdownDatafier

MarkdownDatafier is a ruby gem which reads a structure of Markdown files, parses their metadata and outputs to a simple hash or array of hashes. It's framework agnostic, configurable to any content location, and is easy to plug into your own API endpoints or controller actions.

MarkdownDatafier was inspired by the NestaCMS framework. But instead of a self-contained CMS, I simply wanted to get data out of a Markdown file structure to be used however I like (direct into Mustache templates via server-side Sinarta or Rails; or via an API endpoint to a javascript framework, iOS/Android app, and so on).

This gem was developed and tested using Ruby 2.0.0p353.

## Installation

Add this line to your application's Gemfile:

    gem 'markdown_datafier'

And then execute:

    bundle install

Or install it yourself as:

    gem install markdown_datafier


## Purpose

I've attempted to design this gem to be useful in a few different ways, depending on your needs. In each case, you create a server instance targeted at the content directory of your choosing. However, how you represent your content in Markdown and what you do with the resulting structured data is up to you. For instance, you can set it up so that each page of a website is represented by the structure of your Markdown files and subdirectories (look in /spec/fixtures/server_content/ for an example of this). Or, you could alternatively use each Markdown file to represent persistence of object data (look in /spec/fixtures/instances/ for an example of this), which could then be used to create objects on another class. 

## Setup

Create one (or many) Datafier objects by requiring and including MarkdownDatafier for your class:

    require 'markdown_datafier'
    class MyDatafier
      include MarkdownDatafier
    end

## Usage
    
Set up an instance of your server, passing the path to your content directory as shown:

    server = MyDatafier.new(content_path: "/path/to/content/directory")
    
If you want an array of hashes representing each Markdown file in the immediate :content_path, do:

    content = server.collect
    
If you want an array of hashes representing each Markdown file in a subdirectory of :content_path, do:

    content = server.collect("some_sub_directory")
    
Files can also be accessed individually by their "shortname" (the file name path inside your content_directory minus the extension, OR the parent directory name)

    content = server.find_by_path(some-existing-file)

Nil is returned for non-matching requests.

You can also get the home page like so:
    
    content = server.home_page
    
Or a splash page like so:

    content = server.splash_page
    
Both the home_page and splash_page methods work by the file naming convention on the root :content_path.
    
You can also grab a collection of indexes for the top level sections of your content 
    
    collection = server.indexes_for_sections
    
Or specify a sub level (for instance by using the "shortname" of previously retrieved section):
    
    collection = server.indexes_for_sections("/section-two")

Take a look at the file structure examples in spec/fixtures/ to see how the directory structure and meta data works. You can pass any fields in the meta data that you like. Many basic ones are assumed and set for you as well.

## Recommendation

This will work just dandy running as it does in Ruby's ObjectSpace. However, the intention is that you would use Markdown files to manage your content and its structure, and either use Rake to generate actual HTML files or set up some sort of caching system (clearing and rewriting your cache when content is changed). There's no need to be doing all this parsing overhead with each request to your application.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
