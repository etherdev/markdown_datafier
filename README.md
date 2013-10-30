# MarkdownDatafier

MarkdownDatafier is a ruby gem which reads a structure of Markdown files, parses their metadata and outputs to a simple hash. It is framework agnostic, configurable to any content and configuration location and easy to plug into your own API endpoints or controller actions.

This is currently in an early alpha stage. Though it is likely to remain simple, there will undoubtedly be some feature additions and improvement to things like exception handling. This gem was developed using Ruby 2.0.0p247.

## Installation

Add this line to your application's Gemfile:

    gem 'markdown_datafier'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install markdown_datafier

## Usage

Create an object for your server and include MarkdownDatafier:

    class MyServerObject
      include MarkdownDatafier
    end

Then create an instance of the server using the full path to your config directory:

    server = MyServerObject.new(config_directory: "/path/to/config/")
    
Inside your configuration directory, configure your config.yml file like so:

    content_directory: '/absolute/path/to/content/directory/'
    
Files are accessed individually by their "shortname" (the file name path inside your content_directory minus the extension, OR the parent directory name)

    content = server.find_by_path(some-existing-file)

You can also get the home page like so:
    
    content = server.home_page
    
Or a splash page like so:

    content = server.splash_page
    
You can also grab a collection of indexes for the top level sections of your content 
    
    collection = server.indexes_for_sections
    
Or specify a sub level (for instance by using the "shortname" of previously retrieved section):
    
    collection = server.indexes_for_sections("/section-two")


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
