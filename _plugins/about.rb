module Jekyll
  class AboutPage < Page
    def initialize(site, base, dir)
      @site = site
      @base = base
      @dir = dir
      @name = 'about.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'about.html')
      self.data['authors'] = get_authors
    end

    def get_authors
      authors = []
      Dir.foreach(File.join(@base, '_authors')) do |file|
        unless File.directory? file
          authors << AuthorInfo.new(@site, @base, '_authors', file)
        end
      end
      authors
    end
  end

  class AuthorInfo
    include Convertible

    attr_accessor :data, :content, :site, :ext

    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir = dir
      @name = name
      @ext = name.split('.')[1]

      self.read_yaml(File.join(@base, @dir), name)
      transform
    end

    def to_liquid
      data['content'] = content
      data
    end
  end

  class CategoryPageGenerator < Generator
    safe true

    def generate(site)
      site.pages << AboutPage.new(site, site.source, '')
    end
  end

end