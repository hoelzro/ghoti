module Ghoti
  module Views
    module ViewBehavior
      attr_accessor :model

      def initialize model: nil
        self.model = model
      end

      def filter_issue(issue)
        true
      end

      def sort_issues(issues)
        issues.sort do |a, b|
          b['number'] <=> a['number']
        end
      end

      def each
        # XXX sort
        # XXX column selection
        model.each do |issue|
          if filter_issue issue
            yield issue
          end
        end
      end

      def each_with_index
        index = 0
        model.each do |issue|
          if filter_issue issue then
            yield issue, index
            index += 1
          end
        end
      end
    end

    class OpenOnly
      include ViewBehavior

      def filter_issue(issue)
        issue['state'] == 'open'
      end
    end
  end
end
