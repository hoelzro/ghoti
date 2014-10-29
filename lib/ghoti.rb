require 'vedeu'

require 'ghoti/models'
require 'ghoti/views'
require 'ghoti/displays'

module Ghoti
  class App
    include Vedeu

    def initialize(args)
      @args = args
    end

    def define_interfaces
      interface :alert do
      end

      interface :issues_list do
        x      1
        y      1
        width  Terminal.width
        height Terminal.height - 1
      end

      interface :issue_detail do
      end

      interface :prompt do
        width  Terminal.width
        height 1
        x      1
        y      { use(:issues_list).south }
      end

      interface :help do
      end

      interface :select_view do
      end

      interface :edit_view do
      end
    end

    def define_keys
      keys :issues_list do
        key 'h', '?' do
          # show help
        end

        key 'v' do
          # select/create a view
        end

        key '/' do
          # search within this view
        end

        0.upto(9) do |k|
          key k.to_s do
            # display view #{k}
          end
        end

        # XXX does this work with upper case?
        key 'S' do
          # synchronize
        end

        key 'm' do
          # toggle mark
        end

        key 'j' do
          # move down
        end

        key 'k' do
          # move up
        end

        key :enter do
          # view details
        end
      end
    end

    def initialize_displays
      issues_list = @displays.get_display :issues_list

      issues_list.view = @view
    end

    def run
      @model    = Ghoti::Models::JSONDB.new filename: 'issues.json'
      @view     = Ghoti::Views::OpenOnly.new model: @model
      @displays = Ghoti::DisplayManager.new

      define_interfaces
      define_keys
      initialize_displays

      event :_initialize_ do
        @displays.show :issues_list
        @displays.draw
        focus :issues_list
      end

      event :redraw do
        @displays.draw
      end

      configure do
        interactive!
        raw!
      end

      Vedeu::Launcher.new(@args).execute!
    end
  end
end
