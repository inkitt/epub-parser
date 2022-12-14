require 'forwardable'

module EPUB
  class Book
    module Features
      extend Forwardable
      attr_reader :ocf
      attr_accessor :epub_file

      # When writing, sets +ocf.book+ to self.
      # @param [OCF]
      def ocf=(mod)
        @ocf = mod
        mod.book = self
        mod
      end

      # @return [Array<OCF::Container::Rootfile>]
      def rootfiles
        ocf.container.rootfiles
      end

      # @return [Array<Publication::Package>]
      def packages
        rootfiles.map(&:package)
      end
      alias renditions packages

      # First +package+ in +packages+
      # @return [Package|nil]
      def default_rendition
        packages.first
      end
      alias package default_rendition

      # @!parse def_delegators :package, :metadata, :manifest, :spine, :guide, :bindings
      def_delegators :package, *Publication::Package::CONTENT_MODELS
      def_delegators :metadata, :title, :main_title, :subtitle, :short_title, :collection_title, :edition_title, :extended_title, :description, :date, :unique_identifier, :modified, :release_identifier, :package_identifier
      def_delegators :manifest, :nav

      def container_adapter
        @adapter || OCF::PhysicalContainer.adapter
      end

      def container_adapter=(adapter)
        @adapter = OCF::PhysicalContainer.find_adapter(adapter)
      end

      # Cover image defined in EPUB 3 or used in EPUB 2
      # @return [EPUB::Publication::Package::Manifest::Item]
      def cover_image
        manifest.cover_image || metadata.cover_image
      end

      # @overload each_page_on_spine(&blk)
      #   iterate over items in order of spine when block given
      #   @yieldparam item [Publication::Package::Manifest::Item]
      # @overload each_page_on_spine
      #   @return [Enumerator] which iterates over {Publication::Package::Manifest::Item}s in order of spine when block not given
      def each_page_on_spine(&blk)
        enum = package.spine.items
        if block_given?
          enum.each &blk
        else
          enum.each
        end
      end

      def each_page_on_toc(&blk)
        raise NotImplementedError
      end

      # @overload each_content(&blk)
      #   iterate all items over when block given
      #   @yieldparam item [Publication::Package::Manifest::Item]
      # @overload each_content
      #   @return [Enumerator] which iterates over all {Publication::Package::Manifest::Item}s in EPUB package when block not given
      def each_content(&blk)
        enum = manifest.items
        if block_given?
          enum.each &blk
        else
          enum.to_enum
        end
      end

      def other_navigation
        raise NotImplementedError
      end

      # @return [Array<Publication::Package::Manifest::Item>] All {Publication::Package::Manifest::Item}s in EPUB package
      def resources
        manifest.items
      end

      # Syntax sugar
      # @return String
      def rootfile_path
        ocf.container.rootfile.full_path.to_s
      end
    end
  end
end
