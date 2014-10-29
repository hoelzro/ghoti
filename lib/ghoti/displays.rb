#!/usr/bin/env ruby

require 'ghoti/theme'

module Ghoti
  module Displays
    module DisplayBehavior
      include Vedeu

      def modal?
        false
      end
    end

    class Alert
      include DisplayBehavior

      def modal?
        true
      end
    end

    class Help
      include DisplayBehavior

      def modal?
        true
      end
    end

    class IssuesList
      include DisplayBehavior

      attr_accessor :view
      attr_accessor :offset
      attr_reader :selected

      def initialize
        self.offset = 0
        @selected   = 0 # can't use the accessor until we have a view
      end

      def clamp(value, range)
        if value < range.min
          range.min
        elsif value > range.max
          range.max
        else
          value
        end
      end

      def make_selection_visible(index)
        interface_end = use(:issues_list).height + offset

        if index < offset then
          offset = index
        elsif index >= interface_end
          offset = index - use(:issues_list).height + 1
        end
      end

      def selected=(new_selection)
        new_selection = clamp new_selection, 0 ... @view.length
        make_selection_visible new_selection
        @selected = new_selection
      end

      def draw
        true_self = self

        render do
          view :issues_list do
            interface_end = use(:issues_list).height + true_self.offset

            true_self.view.each_with_index do |issue, index|
              # XXX let's add a method for telling the view to
              #     start at a particular offset...
              if index < true_self.offset then
                next
              end

              if index >= interface_end then
                break
              end

              line do
                if index == true_self.selected then
                  stream do
                    colour foreground: Theme::SELECTED_FOREGROUND_COLOR, background: Theme::SELECTED_BACKGROUND_COLOR
                    text issue['title']
                  end
                else
                  stream do
                    colour foreground: Theme::FOREGROUND_COLOR, background: Theme::BACKGROUND_COLOR
                    text issue['title']
                  end
                end
              end
            end
          end

          view :prompt do
          end
        end
      end
    end

    class IssueDetail
      include DisplayBehavior
    end

    class SelectView
      include DisplayBehavior
    end

    class EditView
      include DisplayBehavior
    end
  end

  class DisplayManager
    def initialize
      @active = []
      @displays_by_name = Hash.new do |_, k|
        raise "No such display '#{k}'"
      end

      register :alert,        Displays::Alert.new
      register :help,         Displays::Help.new
      register :issues_list,  Displays::IssuesList.new
      register :issue_detail, Displays::IssueDetail.new
      register :select_view,  Displays::SelectView.new
      register :edit_view,    Displays::EditView.new
    end

    def get_display(display_name)
      @displays_by_name[display_name]
    end

    def register(name, display)
      if @displays_by_name.has_key? name then
        raise "Cannot overwrite display '#{name}'"
      end

      @displays_by_name[name] = display
    end

    def show(display_name)
      display = get_display display_name

      if @active.include? display then
        return
      end

      @active.push display
    end

    def hide(display_name)
      @active.delete get_display(display_name)
    end

    def draw
      modal, non_modal = @active.partition { |d| d.modal? }

      (non_modal + modal).each do |d|
        d.draw
      end
    end
  end
end
