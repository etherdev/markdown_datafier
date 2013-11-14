require_relative 'spec_helper'

describe MarkdownDatafier do
  
  let(:server) { TestServer.new( config_directory: MarkdownDatafier.root + "/spec/fixtures/config/" )}
  
  describe "initialization" do
  
    it "should load configuration settings" do
      expect(server.content_directory).to eq "/path/to/your/content/"
    end
  end

  describe "file parsing" do
    let(:contents) { File.open(server.content_directory + "test-one.mdown").read }
    
    before(:each) do
      server.config["content_directory"] = MarkdownDatafier.root + "/spec/fixtures/content/"
    end
    
    it "should strip leading slashes from shortname" do
      shortname = "/test-one"
      expect(server.strip_leading_slashes(shortname)).to eq "test-one"
    end
    
    it "should change underscores to dashes" do
      shortname = "test_one_two_three"
      expect(server.underscores_to_dashes(shortname)).to eq "test-one-two-three"
    end
    
    it "should check if requested path is a directory" do
      path = MarkdownDatafier.root + "/spec/fixtures/content/section-two/child-section-one"
      expect(server.is_directory?(path)).to eq true
    end
    
    it "should split the meta and body" do
      expect(server.split_meta_and_body(contents)).to include(:meta, :body)
    end
    
    it "should set publish_datetime when it is provided" do
      provided_content = {:meta=>
                        {:create_datetime=>"2013-10-21 23:12:06 -0400",
                         :publish_datetime=>"23 July 2010 00:00 EST"}}
      result = server.determine_publish_datetime(provided_content)         
      expect(result[:meta][:publish_datetime]).to eq "2010-07-23T05:00:00Z"
    end
    
    it "should set publish_datetime from provided publish date" do
      provided_content = {:meta=>
                        {:create_datetime=>"2013-10-21 23:12:06 -0400",
                         :publish_date=>"23 July 2010"}}
      result = server.determine_publish_datetime(provided_content)         
      expect(result[:meta][:publish_datetime]).to eq "2010-07-23T04:00:00Z"
    end
    
    it "should set publish_datetime from provided date" do
      provided_content = {:meta=>
                        {:create_datetime=>"2013-10-21 23:12:06 -0400",
                         :date=>"23 July 2010 00:00 EST"}}
      result = server.determine_publish_datetime(provided_content)         
      expect(result[:meta][:publish_datetime]).to eq "2010-07-23T05:00:00Z"
    end
    
    it "should set publish_datetime from create datetime when no date meta is provided" do
      provided_content = {:meta=>
                        {:create_datetime=>"2013-10-21 23:12:06 -0400"}}
      result = server.determine_publish_datetime(provided_content)         
      expect(result[:meta][:publish_datetime]).to eq "2013-10-22T03:12:06Z"
    end
    
    describe "resolve shortname to absolute path" do
      
      it "with leading slash directory index request" do
        expect(server.find_by_path("/section-two")[:meta][:title_tag]).to eq "Subsection 2 Index | My Website"
      end
      
      it "with trailing slash directory index request" do
        expect(server.find_by_path("section-two/")[:meta][:title_tag]).to eq "Subsection 2 Index | My Website"
      end
      
      it "with leading and trailing slash directory index request" do
        expect(server.find_by_path("/section-two/")[:meta][:title_tag]).to eq "Subsection 2 Index | My Website"
      end
      
      it "with middle only slash on a non-index subdirectory file" do
        expect(server.find_by_path("section-one/sub-one-test-one")[:meta][:title_tag]).to eq "My Subsection 1 Test Page 1 | My Website"
      end
      
      it "with middle only slash on a child subdirectory request" do
        expect(server.find_by_path("section-two/child-section-one")[:meta][:title_tag]).to eq "Subsection Child 1 Index | My Website"
      end
      
    end
  end
  
  describe "with existing content" do

    before(:each) do
      server.config["content_directory"] = MarkdownDatafier.root + "/spec/fixtures/content/"
    end

    it "should return the home page content" do
      expect(server.home_page[:meta][:title_tag]).to eq "My Homepage | My Website"
    end
    
    it "should hide indexes as root directories" do
      expect(server.home_page[:meta][:title_tag]).to eq "My Homepage | My Website"
    end
  
    it "should return the splash page" do
      expect(server.splash_page[:meta][:title_tag]).to eq "My Home Splash | My Website"
    end

    it "should return a populated array of indexes for top level sections" do
      expect(server.indexes_for_sections()).to have(2).items
    end
    
    it "should return a populated array of indexes for the specified section's child directories" do
      expect(server.indexes_for_sections("/section-two")).to have(1).items
    end
    
    it "should return an empty array for section with no child directories" do
      expect(server.indexes_for_sections("section-one/")).to be_empty
    end
    
    it "should return the appropriate first index for sections in the array" do
      expect(server.indexes_for_sections.first[:meta][:title_tag]).to eq "Subsection 1 Index | My Website"
    end
    
    it "should deliver index file for a root directory request" do
      expect(server.find_by_path("/")[:meta][:shortname]).to eq "/"
    end
    
    it "should return a file from a section directory" do
      expect(server.find_by_path("section-one/sub-one-test-one")[:meta][:nav_name]).to eq "One Deep"
    end
    
    it "should return a file from a child of section directory" do
      expect(server.find_by_path("section-two/child-section-one/child-one-test-one")[:meta][:nav_name]).to eq "Two Deep"
    end
    
    describe "should deliver an index file from a subdirectory directory request" do
      it "with no trailing slash" do
        expect(server.find_by_path("/section-two")[:meta][:nav_name]).to eq "Subsection 2 Index"
      end
      
      it "with trailing slash" do
        expect(server.find_by_path("/section-two/")[:meta][:nav_name]).to eq "Subsection 2 Index"
      end
    end
    
    describe "should deliver an index file from a child directory directory request" do
      it "with no trailing slash" do
        expect(server.find_by_path("/section-two/child-section-one")[:meta][:nav_name]).to eq "Subsection Child 1 Index"
      end
      
      it "with trailing slash" do
        expect(server.find_by_path("/section-two/child-section-one/")[:meta][:nav_name]).to eq "Subsection Child 1 Index"
      end
    end
  
    describe "should return the correct" do
      it "shortname" do
        expect(server.find_by_path("test-one")[:meta][:shortname]).to eq "test-one"
      end
      
      it "title_tag" do
        expect(server.find_by_path("test-one")[:meta][:title_tag]).to eq "My Test Page 1 | My Website"
      end
      
      it "description" do
        expect(server.find_by_path("test-one")[:meta][:description]).to eq "This is a description meta for test page 1."
      end
      
      it "keywords" do
        expect(server.find_by_path("test-one")[:meta][:keywords]).to eq "rspec, testing, markdown"
      end
      
      it "publish_date in UTC ISO 8601 format" do
        expect(server.find_by_path("test-one")[:meta][:publish_datetime]).to eq "2010-07-23T05:00:00Z"
      end
      
      it "nav_name when supplied" do
        expect(server.find_by_path("/")[:meta][:nav_name]).to eq "Home"
      end
      
      it "nav_name when not supplied" do
        expect(server.find_by_path("test-one")[:meta][:nav_name]).to eq "Test Page 1"
      end
      
      it "summary" do
        expect(server.find_by_path("test-one")[:meta][:summary]).to eq "This is a summary text for test page 1."
      end
      
      it "large_image" do
        expect(server.find_by_path("test-one")[:meta][:large_image]).to eq "http://mysite.com/images/test-one-500x500.png"
      end
      
      it "medium_image" do
        expect(server.find_by_path("test-one")[:meta][:medium_image]).to eq "http://mysite.com/images/test-one-200x200.png"
      end
      
      it "small_image" do
        expect(server.find_by_path("test-one")[:meta][:small_image]).to eq "http://mysite.com/images/test-one-75x75.png"
      end
      
      it "position of nil" do
        expect(server.find_by_path("test-one")[:meta][:position]).to be_nil
      end
      
      it "position of 2" do
        expect(server.find_by_path("test-two")[:meta][:position]).to eq "2"
      end
      
      it "body in html format" do
        expect(server.find_by_path("test-one")[:body]).to include("<h1>Test Page 1</h1>")
      end

    end
  end
  describe "with no matching content" do
    
    before(:each) do
      server.config["content_directory"] = MarkdownDatafier.root + "/spec/fixtures/empty/"
    end
    
    it "should return nil for find_by_path" do
      expect(server.find_by_path("ragamuffin")).to be_nil
    end
    
    it "should return nil for home page" do
      expect(server.home_page).to be_nil
    end
    
    it "should return nil for splash page" do
      expect(server.splash_page).to be_nil
    end
    
  end

  
  describe ".root" do
    it "should return the gem's root directory" do
      expect(File.basename(MarkdownDatafier.root)).to eq "markdown_datafier"
    end
  end
end