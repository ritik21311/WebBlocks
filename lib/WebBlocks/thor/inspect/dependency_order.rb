require 'tsort'

module WebBlocks
  module Thor
    class Inspect

      order_desc = "File order based on topological sort of dependency list"
      desc "dependency_order", order_desc
      long_desc order_desc
      method_option :type, :desc => "Any of: \"#{types.keys.join('", "')}\"; default \"all\"."
      def dependency_order
        type = self.class.type_get_class_from_string options.type
        begin
          framework.get_file_load_order(type).each do |file|
            say "#{file.resolved_path.to_s}"
          end
        rescue ::TSort::Cyclic => e
          say "Cycle detected with dependency load order", [:red, :bold]
          fail e, :red
        end
      end

    end
  end
end