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
