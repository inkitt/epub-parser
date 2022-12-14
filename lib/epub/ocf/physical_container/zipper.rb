require 'zip'

module EPUB
  class OCF
    class PhysicalContainer
      class Zipper < self
        def open
          Zip::File.open @container_path do |archive|
            @monitor.synchronize do
              begin
                @archive = archive
                yield self
              rescue ::Zip::Error => error
                raise NoEntry.from_error(error)
              ensure
                @archive = nil
              end
            end
          end
        end

        def read(path_name)
          if @archive
            @archive.find{|entry| entry.name == path_name}&.get_input_stream&.read
          else
            open {|container| container.read(path_name)}
          end
        rescue ::Zip::Error => error
          raise NoEntry.from_error(error)
        ensure
          @archive = nil
        end
      end
    end
  end
end
