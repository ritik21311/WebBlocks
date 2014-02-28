require 'tsort'
require 'WebBlocks/thor/link'
require 'WebBlocks/manager/scss_linker'

module WebBlocks
  module Thor
    class Link

      description = "Construct linked construct of SCSS files based on dependencies"
      desc "scss", description
      long_desc description
      def scss
        begin
          ::WebBlocks::Manager::ScssLinker.new(framework, @base_path).execute!
        rescue ::TSort::Cyclic => e
          say "Cycle detected with dependency load order", [:red, :bold]
          fail e, :red
        end
      end

    end
  end
end