require 'pathname'
require 'fssm'
require 'WebBlocks/thor/watch'
require 'WebBlocks/manager/parallel_builder'

module WebBlocks
  module Thor
    class Watch

      description = "Watch and rebuild all assets"
      desc "all", description
      long_desc description

      def all

        # TODO: refactor this file so it's not a run-on routine

        prepare_blocks!

        triggers = framework.adjacency_list.keys.map(){|f| f.resolved_path.to_s }
        triggers << base_path + 'Blocksfile.rb'
        triggers << base_path + '.blocks/cache/bower/registry.yaml'
        triggers << base_path + 'bower_components/*/Blockfile.rb'

        handler = Proc.new do |base, relative|

          changed_file = Pathname.new(base) + relative
          relink_needed = changed_file.to_s.match(/Blocks+file.rb$/)

          log.info("Watch"){ "Detected change to #{changed_file}" }

          if relink_needed
            framework.remove_all_children
            prepare_blocks!
          end

          begin
            jobs = WebBlocks::Manager::ParallelBuilder.new self, log
            jobs.start :scss
            jobs.start :js
            jobs.wait_for_complete!
          rescue ::TSort::Cyclic => e
            log.error { "Build failed -- Cyclical dependencies detected" }
          end

        end

        monitor = FSSM::Monitor.new
        monitor.path @base_path do
          glob triggers
          update &handler
          delete &handler
          create &handler
        end
        monitor.run

      end

    end
  end
end