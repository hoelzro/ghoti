#!/usr/bin/env ruby

require 'vedeu'

# this does some messy stuff, but it works
module Ghoti
  class ViewportImpl
    include Vedeu

    attr_accessor :old_line

    def draw(name, offset, &block)
      @current_line = 0
      @delegate     = block.binding.eval 'self'
      @view_range   = offset ... use(name).height + offset
      true_self     = self

      @delegate.view name do
        true_self.old_line = method :line

        true_self.instance_eval(&block)
      end
    ensure
      self.old_line = nil
      @delegate     = nil
    end

    def line(*args, &block)
      if @view_range.cover? @current_line then
        old_line.(*args, &block)
      end

      @current_line += 1
    end

    def method_missing(method, *args, &block)
      @delegate.send(method, *args, &block) if @delegate
    end
  end

  module Viewport
    def viewport(name, offset, &block)
      vp = ViewportImpl.new
      vp.draw(name, offset, &block)
    end
  end
end

=begin

render do
  viewport name, offset do
    line 'first line'
    line 'second line'
    # etc
  end
end

=end
