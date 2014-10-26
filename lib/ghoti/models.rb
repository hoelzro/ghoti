#!/usr/bin/env ruby

require 'json'

module Ghoti
  module Models
    class JSONDB
      def initialize filename: nil
        if filename.nil? then
          raise 'filename must be provided'
        end

        json    = File.read filename
        @issues = JSON.load(json)
      end

      def each(&block)
        @issues.each(&block)
      end
    end
  end
end
