require 'epub/ocf'
require 'epub/publication'
require 'epub/content_document'
require 'epub/parser'

module EPUB
  modules = [ :ocf, :package, :content_document ]
  attr_reader *modules
  attr_reader :epub_file
  modules.each do |mod|
    define_method "#{mod}=" do |obj|
      instance_variable_set "@#{mod}", obj
      obj.book = self
    end
  end

  def parse(file, options = {})
    @epub_file = file
    options = options.merge({:book => self})
    Parser.parse(file, options)
  end

  %w[ title main_title subtitle short_title collection_title edition_title extended_title ].each do |met|
    define_method met do
      @package.metadata.__send__(met)
    end
  end

  def each_page_on_spine(&blk)
    enum = @package.spine.items
    if block_given?
      enum.each &blk
    else
      enum
    end
  end

  def each_page_on_toc(&blk)
  end

  def each_content(&blk)
    enum = @package.manifest.items
    if block_given?
      enum.each &blk
    else
      enum.to_enum
    end
  end

  def other_navigation
  end

  def resources
    @package.manifest.items
  end

  # Syntax sugar
  def rootfile_path
    ocf.container.rootfile.full_path
  end

  # Syntax sugar
  def cover_image
    package.manifest.cover_image
  end
end
