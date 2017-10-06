module Knapsack
  module Runners
    class RSpecRunner
      def self.run(args)
        allocator = Knapsack::AllocatorBuilder.new(Knapsack::Adapters::RSpecAdapter).allocator

        Knapsack.logger.info
        Knapsack.logger.info 'Report specs:'
        Knapsack.logger.info allocator.report_node_tests
        Knapsack.logger.info
        Knapsack.logger.info 'Leftover specs:'
        Knapsack.logger.info allocator.leftover_node_tests
        Knapsack.logger.info

        uniq_folders = allocator.node_tests.map { |file| file.split("/spec/")[0] }.uniq

        any_non_zero_status = 0

        Knapsack.logger.info "REPORT_DIR:: #{ENV['KNAPSACK_REPORT_DIR']}"

        uniq_folders.each do |uniq_folder|
          tests_for_folder = allocator.node_tests.select { |node_test| node_test.start_with?("#{uniq_folder}/spec") }
          Dir.chdir(uniq_folder) do
            cmd = %[bundle exec rspec -- #{stringify_node_tests(tests_for_folder)}]
            system(cmd)
            any_non_zero_status = $CHILD_STATUS.exitstatus if $CHILD_STATUS.exitstatus != 0
          end
        end

        exit(any_non_zero_status) unless any_non_zero_status.zero?
      end

      def self.stringify_node_tests(node_tests)
        node_tests.map do |test_file|
          file_name = test_file[/\/spec\/.*/][1..-1]
          %{"#{file_name}"}
        end.join(" ")
      end
    end
  end
end
